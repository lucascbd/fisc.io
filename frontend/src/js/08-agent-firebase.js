        // ============================================
        // DARK MODE
        // ============================================
        
        function toggleDarkMode() {
            const body = document.body;
            const toggle = document.getElementById('darkModeToggle');
            const themeColor = document.getElementById('themeColorMeta');
            if (body.classList.contains('dark-mode')) {
                body.classList.remove('dark-mode');
                toggle.classList.remove('active');
                localStorage.setItem('darkMode', 'false');
                if (themeColor) themeColor.setAttribute('content', '#1a73e8');
            } else {
                body.classList.add('dark-mode');
                toggle.classList.add('active');
                localStorage.setItem('darkMode', 'true');
                if (themeColor) themeColor.setAttribute('content', '#1f1f1f');
            }
            invalidateCache();
            _updateTotalVisibilityIcon();
            loadDashboardData();
            const chartsTabEl = document.getElementById('chartsTab');
            const inflTabEl = document.getElementById('inflationTab');
            if (chartsTabEl && !chartsTabEl.classList.contains('hidden')) {
                updatePieChart?.(); updateDailyChart?.(); updatePmBarChart?.(); updateMvMChart?.();
            }
            if (inflTabEl && !inflTabEl.classList.contains('hidden')) {
                inflLoaded = false; loadInflation?.();
            }
        }

        // Abrir modal de configurações
        function openNotificationSettings() {
            // Esconder FAB
            const fab = document.getElementById('fabNewExpense');
            if (fab) fab.style.display = 'none';
            
            loadNotificationSettings();
            document.getElementById('notificationSettingsModal').classList.remove('hidden');
        }

        // Fechar modal
        function closeNotificationSettings() {
            // Mostrar FAB se em aba apropriada
            const fab = document.getElementById('fabNewExpense');
            const homeTab = document.getElementById('homeTab');
            const expTab = document.getElementById('expensesTab');
            if (fab && ((homeTab && !homeTab.classList.contains('hidden')) || (expTab && !expTab.classList.contains('hidden')))) {
                fab.style.display = 'flex';
            }
            
            document.getElementById('notificationSettingsModal').classList.add('hidden');
        }

        // Ativar/Desativar notificações
        async function toggleNotifications() {
            const checkbox = document.getElementById('notificationsEnabled');
            console.log('🔘 Toggle notificações:', checkbox.checked);
            
            if (checkbox.checked) {
                // Solicitar permissão
                if ('Notification' in window) {
                    console.log('🔔 Solicitando permissão...');
                    const permission = await Notification.requestPermission();
                    console.log('📋 Permissão:', permission);
                    
                    if (permission === 'granted') {
                        notificationSettings.enabled = true;
                        localStorage.setItem('notificationEnabled', 'true');
                        updatePermissionStatus();
                        
                        // Enviar notificação de boas-vindas
                        try {
                            const title = '🎉 Notificações ativadas!';
                            const body = 'Você receberá alertas sobre suas despesas.';
                            
                            if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
                                navigator.serviceWorker.ready.then(registration => {
                                    registration.showNotification(title, {
                                        body: body,
                                        icon: '/icon-192.png',
                                        tag: 'welcome-notification'
                                    });
                                    console.log('✅ Notificação de boas-vindas enviada via ServiceWorker!');
                                });
                            } else {
                                const notif = new Notification(title, {
                                    body: body,
                                    icon: '/icon-192.png'
                                });
                                console.log('✅ Notificação de boas-vindas enviada!', notif);
                            }
                        } catch (err) {
                            console.error('❌ Erro ao enviar notificação:', err);
                        }
                        
                        // Registrar token FCM
                        console.log('🔥 Registrando token FCM...');
                        if (typeof registerFCMToken === 'function') {
                            registerFCMToken();
                        }
                    } else {
                        checkbox.checked = false;
                        alert('⚠️ Permissão negada. Ative nas configurações do navegador.');
                    }
                }
            } else {
                notificationSettings.enabled = false;
                localStorage.setItem('notificationEnabled', 'false');
                console.log('🔕 Notificações desativadas');
            }
        }

        // Enviar notificação de teste
        function testNotification() {
            console.log('🧪 === TESTE DE NOTIFICAÇÃO ===');
            console.log('Enabled:', notificationSettings.enabled);
            console.log('Permission:', Notification.permission);
            console.log('Settings:', notificationSettings);
            
            if (!('Notification' in window)) {
                alert('❌ Este navegador não suporta notificações!');
                return;
            }
            
            if (!notificationSettings.enabled) {
                alert('⚠️ Ative as notificações primeiro!');
                return;
            }
            
            if (Notification.permission !== 'granted') {
                alert('⚠️ Permissão de notificação não concedida. Clique em "Ativar Notificações" primeiro.');
                return;
            }
            
            try {
                const user = JSON.parse(localStorage.getItem('user'));
                const title = '🧪 Notificação de Teste';
                const body = `Olá ${user.name}! As notificações estão funcionando perfeitamente. 🎉`;
                
                // Verificar se está rodando no PWA
                if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
                    console.log('📱 PWA detectado - usando ServiceWorker');
                    navigator.serviceWorker.ready.then(registration => {
                        registration.showNotification(title, {
                            body: body,
                            icon: '/icon-192.png',
                            vibrate: [200, 100, 200],
                            requireInteraction: false,
                            tag: 'test-notification'
                        });
                        console.log('✅ Notificação de teste enviada via ServiceWorker!');
                    });
                } else {
                    console.log('🌐 Navegador detectado - usando Notification API');
                    const notification = new Notification(title, {
                        body: body,
                        icon: '/icon-192.png',
                        vibrate: [200, 100, 200],
                        requireInteraction: false
                    });
                    
                    notification.onclick = function() {
                        window.focus();
                        this.close();
                    };
                    
                    console.log('✅ Notificação de teste enviada via Notification API!', notification);
                }
            } catch (err) {
                console.error('❌ Erro ao enviar notificação:', err);
                alert('Erro: ' + err.message);
            }
        }

        // Salvar configurações
        async function saveNotificationSettings() {
            notificationSettings.enabled = document.getElementById('notificationsEnabled').checked;
            notificationSettings.new_expense = document.getElementById('notify_new_expense').checked;
            notificationSettings.edit_expense = document.getElementById('notify_edit_expense').checked;
            notificationSettings.delete_expense = document.getElementById('notify_delete_expense').checked;
            notificationSettings.reminders = document.getElementById('notify_reminders').checked;
            notificationSettings.time = document.getElementById('notify_time').value;
            
            // Salvar no localStorage (backup local)
            localStorage.setItem('notificationSettings', JSON.stringify(notificationSettings));
            // ✅ Salvar enabled separadamente (fonte de verdade)
            localStorage.setItem('notificationEnabled', notificationSettings.enabled ? 'true' : 'false');
            
            // Salvar no servidor (para que o backend respeite as preferências)
            try {
                await fetch(`${API}/notification-preferences`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${localStorage.getItem('token')}`
                    },
                    body: JSON.stringify({
                        notify_new_expense: notificationSettings.new_expense,
                        notify_edit_expense: notificationSettings.edit_expense,
                        notify_delete_expense: notificationSettings.delete_expense,
                        notify_reminders: notificationSettings.reminders,
                        reminder_time: notificationSettings.time
                    })
                });
                console.log('💾 Preferências salvas no servidor');
            } catch (err) {
                console.error('❌ Erro ao salvar no servidor:', err);
            }
            
            console.log('💾 Configurações salvas:', notificationSettings);
            
            closeNotificationSettings();
            alert('✅ Configurações salvas com sucesso!');
        }

        // Enviar notificação de despesa criada/editada/deletada
        window.sendExpenseNotification = function(action, data) {
            // DESABILITADO: Notificações agora são enviadas pelo BACKEND via Firebase
            // Isso evita duplicação - o backend já envia push para outros usuários
            console.log('📢 sendExpenseNotification: ignorado (notificações vêm do Firebase)');
            return;
            
            // Verificar se notificações estão habilitadas
            if (!notificationSettings.enabled) {
                console.log('❌ Notificações desabilitadas');
                return;
            }
            
            // Verificar permissão
            if (Notification.permission !== 'granted') {
                console.log('❌ Permissão não concedida:', Notification.permission);
                return;
            }
            
            // Verificar se esse tipo de notificação está ativo
            const actionMap = {
                'new': 'new_expense',
                'edit': 'edit_expense',
                'delete': 'delete_expense'
            };
            
            const settingKey = actionMap[action];
            console.log('Verificando setting:', settingKey, '=', notificationSettings[settingKey]);
            
            if (!notificationSettings[settingKey]) {
                console.log(`❌ Notificação de ${action} desabilitada`);
                return;
            }
            
            // Montar mensagem
            const user = JSON.parse(localStorage.getItem('user'));
            let title, body;
            
            if (action === 'new') {
                title = '💸 Despesa adicionada';
                body = `${user.name} adicionou: ${data.description} - R$ ${formatBRL(data.total_amount)}`;
            } else if (action === 'edit') {
                title = '✏️ Despesa editada';
                body = `${user.name} editou: ${data.description}`;
            } else if (action === 'delete') {
                title = '🗑️ Despesa deletada';
                body = `${user.name} deletou uma despesa`;
            }
            
            console.log('📨 Enviando:', title, '/', body);
            
            // Enviar notificação (suporte para PWA e navegador)
            try {
                // Verificar se está rodando no contexto do Service Worker (PWA)
                if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
                    console.log('📱 Rodando no PWA - usando ServiceWorker');
                    navigator.serviceWorker.ready.then(registration => {
                        registration.showNotification(title, {
                            body: body,
                            icon: '/icon-192.png',
                            vibrate: [200, 100, 200],
                            requireInteraction: false,
                            tag: 'expense-notification',
                            data: { url: '/' }
                        });
                        console.log('✅ Notificação enviada via ServiceWorker!');
                    });
                } else {
                    console.log('🌐 Rodando no navegador - usando Notification API');
                    const notification = new Notification(title, {
                        body: body,
                        icon: '/icon-192.png',
                        vibrate: [200, 100, 200],
                        requireInteraction: false
                    });
                    
                    notification.onclick = function() {
                        window.focus();
                        this.close();
                    };
                    
                    console.log('✅ Notificação enviada via Notification API!', notification);
                }
            } catch (err) {
                console.error('❌ Erro ao enviar notificação:', err);
            }
        };
        
        // Inicializar notificações ao carregar
        if (token && localStorage.getItem('user')) {
            loadNotificationSettings();
            console.log('🔔 Notificações inicializadas:', notificationSettings);
        }

        // ============================================================================
        // FIREBASE CLOUD MESSAGING
        // ============================================================================
        
        // Configuração do Firebase
        const firebaseConfig = {
            apiKey: "AIzaSyCKjBU5unmEXsd6O1UD9_ZGaUdtFX5fRaw",
            authDomain: "splitmate-e3053.firebaseapp.com",
            projectId: "splitmate-e3053",
            storageBucket: "splitmate-e3053.firebasestorage.app",
            messagingSenderId: "165892275443",
            appId: "1:165892275443:web:4716b42e6f64afc2e14b86"
        };
        
        // VAPID Key para Web Push
        const vapidKey = "BE0Cx6nSjqMn3gaeOwGSGKRlA-3jdgfrfPCnYtMI160liRY7tSzA7eGD_SMOCqmOLjB9ERXMWScPqfrdm0HUfhI";
        
        // Variáveis globais para Firebase
        let messaging = null;
        let fcmSwRegistration = null;  // Service Worker registration para FCM
        
        // Inicializar Firebase
        async function initializeFirebase() {
            try {
                // Service Workers requerem HTTPS ou localhost
                if (!('serviceWorker' in navigator)) {
                    console.warn('⚠️ Service Worker não disponível (requer HTTPS). Notificações push desabilitadas.');
                    return;
                }

                // Registrar Service Worker PRIMEIRO
                console.log('📋 Registrando Service Worker...');
                const swRegistration = await navigator.serviceWorker.register('/firebase-messaging-sw.js');
                fcmSwRegistration = swRegistration;  // Salvar para uso no getToken
                console.log('✅ Service Worker registrado:', swRegistration.scope);
                
                // Aguardar Service Worker estar ATIVO
                if (!swRegistration.active) {
                    console.log('⏳ Aguardando Service Worker ativar...');
                    await new Promise((resolve) => {
                        const sw = swRegistration.installing || swRegistration.waiting;
                        if (sw) {
                            sw.addEventListener('statechange', (e) => {
                                console.log('📋 SW estado:', e.target.state);
                                if (e.target.state === 'activated') {
                                    resolve();
                                }
                            });
                        }
                        // Também aguarda o ready como backup
                        navigator.serviceWorker.ready.then(resolve);
                    });
                }
                
                console.log('✅ Service Worker ativo!');
                
                // Pequena pausa para estabilizar
                await new Promise(r => setTimeout(r, 300));
                
                // Inicializar Firebase App
                firebase.initializeApp(firebaseConfig);
                console.log('🔥 Firebase inicializado com sucesso');
                
                // Obter instância do Messaging
                messaging = firebase.messaging();
                console.log('📱 Firebase Messaging pronto');
                
                // Handler para mensagens em foreground
                messaging.onMessage((payload) => {
                    console.log('📩 Mensagem recebida em foreground:', payload);
                    
                    const title = payload.notification?.title || payload.data?.title || '💸 fisc.io';
                    const body = payload.notification?.body || payload.data?.body || 'Nova notificação';
                    
                    // Mostrar notificação quando app está aberto
                    if (Notification.permission === 'granted') {
                        if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
                            navigator.serviceWorker.ready.then(registration => {
                                registration.showNotification(title, {
                                    body: body,
                                    icon: '/icon-192.png',
                                    badge: '/icon-192.png',
                                    vibrate: [200, 100, 200],
                                    data: payload.data || {}
                                });
                            });
                        } else {
                            new Notification(title, {
                                body: body,
                                icon: '/icon-192.png',
                                vibrate: [200, 100, 200]
                            });
                        }
                    }
                });
                
            } catch (err) {
                console.error('❌ Erro ao inicializar Firebase:', err);
            }
        }
        
        // Solicitar permissão e registrar token
        async function registerFCMToken() {
            if (!messaging) {
                console.log('⚠️ Firebase Messaging não inicializado');
                return;
            }
            
            if (!fcmSwRegistration) {
                console.log('⚠️ Service Worker não registrado ainda');
                return;
            }
            
            try {
                // AGUARDAR Service Worker estar ATIVO (não apenas ready)
                console.log('⏳ Aguardando Service Worker estar ativo...');
                
                // Verificar estado atual
                const sw = fcmSwRegistration.active || fcmSwRegistration.installing || fcmSwRegistration.waiting;
                console.log('📋 Estado do SW:', sw ? sw.state : 'null');
                
                // Se não está ativo, aguardar
                if (!fcmSwRegistration.active) {
                    await new Promise((resolve, reject) => {
                        const swToWatch = fcmSwRegistration.installing || fcmSwRegistration.waiting;
                        if (!swToWatch) {
                            reject(new Error('Nenhum Service Worker encontrado'));
                            return;
                        }
                        
                        swToWatch.addEventListener('statechange', (e) => {
                            console.log('📋 SW mudou para:', e.target.state);
                            if (e.target.state === 'activated') {
                                resolve();
                            }
                        });
                        
                        // Timeout de 10 segundos
                        setTimeout(() => reject(new Error('Timeout aguardando SW ativar')), 10000);
                    });
                }
                
                console.log('✅ Service Worker está ativo!');
                
                // Aguardar um pouco mais para estabilizar
                await new Promise(resolve => setTimeout(resolve, 500));
                
                // Solicitar permissão de notificação
                const permission = await Notification.requestPermission();
                console.log('📋 Permissão de notificação:', permission);
                
                if (permission === 'granted') {
                    // Obter token FCM - PASSANDO O SERVICE WORKER EXPLICITAMENTE
                    console.log('🔑 Solicitando token FCM...');
                    const token = await messaging.getToken({ 
                        vapidKey: vapidKey,
                        serviceWorkerRegistration: fcmSwRegistration
                    });
                    console.log('🔑 Token FCM obtido:', token.substring(0, 20) + '...');
                    
                    // Enviar token para o backend
                    try {
                        await api(`${API}/device-tokens`, {
                            method: 'POST',
                            body: JSON.stringify({ token })
                        });
                        console.log('✅ Token FCM registrado no backend');
                    } catch (err) {
                        console.error('❌ Erro ao registrar token no backend:', err);
                    }
                    
                    // Listener para atualização de token
                    messaging.onTokenRefresh(async () => {
                        console.log('🔄 Token FCM renovado');
                        try {
                            const newToken = await messaging.getToken({ 
                                vapidKey: vapidKey,
                                serviceWorkerRegistration: fcmSwRegistration
                            });
                            await api(`${API}/device-tokens`, {
                                method: 'POST',
                                body: JSON.stringify({ token: newToken })
                            });
                            console.log('✅ Novo token registrado');
                        } catch (err) {
                            console.error('❌ Erro ao renovar token:', err);
                        }
                    });
                } else {
                    console.log('⚠️ Permissão de notificação negada');
                }
            } catch (err) {
                console.error('❌ Erro ao registrar token FCM:', err);
            }
        }
        
        // Inicializar Firebase quando a página carregar
        if (typeof firebase !== 'undefined') {
            initializeFirebase().catch(err => {
                console.error('❌ Erro ao inicializar Firebase:', err);
            });
        }
        
        // Registrar token após login
        const originalShowDashboard = showDashboard;
        showDashboard = function() {
            originalShowDashboard();
            
            // Aguardar Firebase e Service Worker estarem prontos
            requestAnimationFrame(() => {
                if (messaging && notificationSettings.enabled) {
                    console.log('🔥 Auto-registrando token FCM após login...');
                    registerFCMToken();
                }
            }, 3000);  // 3 segundos para garantir que Service Worker está ativo
        };
