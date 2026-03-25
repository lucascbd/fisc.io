"""
Firebase Cloud Messaging Service
Envia notificações push para dispositivos registrados
COM VERIFICAÇÃO DE PREFERÊNCIAS E LIMPEZA DE TOKENS INVÁLIDOS
"""

import firebase_admin
from firebase_admin import credentials, messaging
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)


class FirebaseService:
    """Serviço para envio de notificações push via Firebase Cloud Messaging"""
    
    _app = None
    
    # Erros que indicam token inválido (deve ser removido)
    INVALID_TOKEN_ERRORS = [
        'NotRegistered',
        'Requested entity was not found',
        'InvalidRegistration',
        'MismatchSenderId',
    ]
    
    @classmethod
    def initialize(cls, credentials_path: str):
        """Inicializar Firebase Admin SDK"""
        if not cls._app:
            try:
                cred = credentials.Certificate(credentials_path)
                cls._app = firebase_admin.initialize_app(cred)
                logger.info("✅ Firebase Admin SDK inicializado com sucesso")
            except Exception as e:
                logger.error(f"❌ Erro ao inicializar Firebase: {e}")
                raise
    
    @classmethod
    def _is_invalid_token_error(cls, error_message: str) -> bool:
        """Verifica se o erro indica um token inválido que deve ser removido"""
        return any(err in str(error_message) for err in cls.INVALID_TOKEN_ERRORS)
    
    @classmethod
    def _remove_invalid_token(cls, db, token: str):
        """Remove token inválido do banco de dados"""
        try:
            from models import DeviceToken
            
            deleted = db.query(DeviceToken).filter(
                DeviceToken.token == token
            ).delete()
            
            db.commit()
            
            if deleted:
                logger.info(f"🗑️ Token inválido removido do banco: {token[:30]}...")
            
        except Exception as e:
            logger.error(f"❌ Erro ao remover token inválido: {e}")
            db.rollback()
    
    @classmethod
    def _get_user_notification_preference(cls, db, user_id: int, action_type: str) -> bool:
        """
        Verifica se o usuário quer receber notificações deste tipo
        
        Args:
            db: Sessão do banco
            user_id: ID do usuário
            action_type: 'new', 'edit', 'delete', 'reminder'
            
        Returns:
            True se deve enviar, False caso contrário
        """
        try:
            from models import NotificationPreferences
            
            prefs = db.query(NotificationPreferences).filter(
                NotificationPreferences.user_id == user_id
            ).first()
            
            if not prefs:
                # Se não tem preferências salvas, usar defaults
                defaults = {
                    'new': True,
                    'edit': False,
                    'delete': False,
                    'reminder': True
                }
                return defaults.get(action_type, True)
            
            # Mapear action_type para campo do banco
            preference_map = {
                'new': prefs.notify_new_expense,
                'edit': prefs.notify_edit_expense,
                'delete': prefs.notify_delete_expense,
                'reminder': prefs.notify_reminders
            }
            
            return preference_map.get(action_type, True)
            
        except Exception as e:
            logger.warning(f"⚠️ Erro ao verificar preferências (assumindo True): {e}")
            return True  # Em caso de erro, envia a notificação
    
    @classmethod
    def send_push(
        cls,
        tokens: List[str],
        title: str,
        body: str,
        data: Optional[dict] = None,
        icon: str = "/icon-192.png",
        db = None
    ) -> dict:
        """
        Enviar notificação push para múltiplos dispositivos
        
        Args:
            tokens: Lista de tokens FCM dos dispositivos
            title: Título da notificação
            body: Corpo da mensagem
            data: Dados adicionais (opcional)
            icon: URL do ícone
            db: Sessão do banco (para limpeza de tokens inválidos)
            
        Returns:
            dict com success_count e failure_count
        """
        if not tokens:
            logger.warning("⚠️ Nenhum token fornecido")
            return {"success_count": 0, "failure_count": 0}
        
        success_count = 0
        failure_count = 0
        invalid_tokens_removed = 0
        
        for token in tokens:
            message = messaging.Message(
                data={
                    "title": title,
                    "body": body,
                    **(data or {})
                },
                token=token,
                webpush=messaging.WebpushConfig(
                    fcm_options=messaging.WebpushFCMOptions(
                        link="https://splitmate.lucascbd.app.br/"
                    )
                )
            )
            
            try:
                response = messaging.send(message)
                logger.info(f"✅ Push enviado: {token[:30]}... -> {response}")
                success_count += 1
                
            except Exception as e:
                error_str = str(e)
                logger.warning(f"❌ Falha push para {token[:30]}...: {error_str}")
                failure_count += 1
                
                # Remover tokens inválidos
                if db and cls._is_invalid_token_error(error_str):
                    cls._remove_invalid_token(db, token)
                    invalid_tokens_removed += 1
        
        log_msg = f"📤 Push: {success_count} ok, {failure_count} falhas"
        if invalid_tokens_removed > 0:
            log_msg += f", {invalid_tokens_removed} tokens removidos"
        logger.info(log_msg)
        
        result = {
            "success_count": success_count,
            "failure_count": failure_count
        }
        
        if invalid_tokens_removed > 0:
            result["invalid_tokens_removed"] = invalid_tokens_removed
        
        return result
    
    @classmethod
    def send_to_user(
        cls,
        user_tokens: List[str],
        title: str,
        body: str,
        data: Optional[dict] = None,
        db = None
    ) -> dict:
        """Enviar notificação para todos os dispositivos de um usuário"""
        return cls.send_push(
            tokens=user_tokens,
            title=title,
            body=body,
            data=data,
            db=db
        )
    
    @classmethod
    def send_to_profile_users(
        cls,
        db,
        profile_id: int,
        exclude_user_id: int,
        title: str,
        body: str,
        data: Optional[dict] = None,
        action_type: str = None  # 'new', 'edit', 'delete', 'reminder'
    ) -> dict:
        """
        Enviar notificação para todos os usuários de um perfil, exceto um
        RESPEITANDO AS PREFERÊNCIAS DE CADA USUÁRIO
        
        Args:
            db: Sessão do banco de dados
            profile_id: ID do perfil de divisão
            exclude_user_id: ID do usuário a excluir (quem fez a ação)
            title: Título da notificação
            body: Corpo da mensagem
            data: Dados adicionais
            action_type: Tipo da ação ('new', 'edit', 'delete', 'reminder')
            
        Returns:
            Resultado do envio
        """
        from models import SplitProfileUser, DeviceToken, User
        
        logger.info(f"🔔 send_to_profile_users: profile_id={profile_id}, exclude={exclude_user_id}, action={action_type}")
        
        # Buscar usuários do perfil (exceto quem fez a ação)
        profile_users = db.query(SplitProfileUser).filter(
            SplitProfileUser.profile_id == profile_id,
            SplitProfileUser.user_id != exclude_user_id
        ).all()
        
        if not profile_users:
            logger.info(f"ℹ️ Nenhum outro usuário no perfil {profile_id}")
            return {"success_count": 0, "failure_count": 0, "reason": "no_other_users_in_profile"}
        
        # Filtrar usuários que QUEREM receber este tipo de notificação
        user_ids_to_notify = []
        users_skipped = []
        
        for pu in profile_users:
            if action_type:
                wants_notification = cls._get_user_notification_preference(db, pu.user_id, action_type)
                if wants_notification:
                    user_ids_to_notify.append(pu.user_id)
                else:
                    user = db.query(User).filter(User.id == pu.user_id).first()
                    users_skipped.append(user.name if user else str(pu.user_id))
            else:
                # Se não especificou action_type, envia para todos
                user_ids_to_notify.append(pu.user_id)
        
        if users_skipped:
            logger.info(f"⏭️ Usuários pulados (preferência desativada): {', '.join(users_skipped)}")
        
        if not user_ids_to_notify:
            logger.info(f"ℹ️ Nenhum usuário quer receber notificação de '{action_type}'")
            return {"success_count": 0, "failure_count": 0, "reason": "all_users_disabled_this_notification"}
        
        logger.info(f"👥 Enviando para {len(user_ids_to_notify)} usuário(s)")
        
        # Buscar tokens dos usuários filtrados
        tokens = db.query(DeviceToken.token, DeviceToken.user_id).filter(
            DeviceToken.user_id.in_(user_ids_to_notify)
        ).all()
        
        # Log detalhado
        for t in tokens:
            user = db.query(User).filter(User.id == t.user_id).first()
            logger.info(f"🔑 Token: user={user.name if user else '?'}, token={t.token[:30]}...")
        
        token_list = [t[0] for t in tokens]
        
        if not token_list:
            logger.info(f"ℹ️ Nenhum token registrado para usuários do perfil {profile_id}")
            return {"success_count": 0, "failure_count": 0, "reason": "no_tokens_registered"}
        
        logger.info(f"📤 Enviando push para {len(token_list)} dispositivos")
        
        return cls.send_push(
            tokens=token_list,
            title=title,
            body=body,
            data=data,
            db=db
        )
