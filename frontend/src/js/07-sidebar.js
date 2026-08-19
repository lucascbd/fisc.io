        async function loadNotificationSettings() {
            // Carregar enabled do localStorage (fonte principal)
            const savedEnabled = localStorage.getItem('notificationEnabled');
            if (savedEnabled !== null) {
                notificationSettings.enabled = savedEnabled === 'true';
            }
            
            // Carregar outras preferências do servidor
            try {
                const serverPrefs = await api(`${API}/notification-preferences`);
                notificationSettings.new_expense = serverPrefs.notify_new_expense;
                notificationSettings.edit_expense = serverPrefs.notify_edit_expense;
                notificationSettings.delete_expense = serverPrefs.notify_delete_expense;
                notificationSettings.reminders = serverPrefs.notify_reminders;
                notificationSettings.time = serverPrefs.reminder_time;
                console.log('📥 Preferências carregadas do servidor:', serverPrefs);
            } catch (err) {
                console.warn('⚠️ Erro ao carregar do servidor, usando localStorage:', err);
                // Fallback para localStorage (apenas campos que não sobrescrevem enabled)
                const savedSettings = localStorage.getItem('notificationSettings');
                if (savedSettings) {
                    const parsed = JSON.parse(savedSettings);
                    notificationSettings.new_expense = parsed.new_expense ?? true;
                    notificationSettings.edit_expense = parsed.edit_expense ?? true;
                    notificationSettings.delete_expense = parsed.delete_expense ?? true;
                    notificationSettings.reminders = parsed.reminders ?? true;
                    notificationSettings.time = parsed.time ?? '09:00';
                    // NÃO sobrescreve enabled - já foi carregado acima
                }
            }
            
            // Atualizar UI
            if (document.getElementById('notificationsEnabled')) {
                const toggle = document.getElementById('notificationsEnabled');
                toggle.checked = notificationSettings.enabled;
                // ✅ Atualizar cor do toggle
                const toggleBg = toggle.parentElement.querySelector('.toggle-bg');
                if (toggleBg) {
                    toggleBg.style.background = notificationSettings.enabled ? '#1a73e8' : '#dadce0';
                }
                document.getElementById('notify_new_expense').checked = notificationSettings.new_expense;
                document.getElementById('notify_edit_expense').checked = notificationSettings.edit_expense;
                document.getElementById('notify_delete_expense').checked = notificationSettings.delete_expense;
                document.getElementById('notify_reminders').checked = notificationSettings.reminders;
                document.getElementById('notify_time').value = notificationSettings.time;
            }
            
            updatePermissionStatus();
        }

        // Atualizar status de permissão
        function updatePermissionStatus() {
            const statusDiv = document.getElementById('notificationPermissionStatus');
            if (!statusDiv) return;
            
            if (!('Notification' in window)) {
                statusDiv.className = 'p-4 rounded-lg border-2 border-red-500 bg-red-50';
                statusDiv.innerHTML = `
                    <p class="font-bold text-red-700">❌ Navegador não suporta notificações</p>
                    <p class="text-sm text-red-600">Tente usar Chrome, Edge ou Firefox</p>
                `;
                return;
            }
            
            const permission = Notification.permission;
            
            if (permission === 'granted') {
                statusDiv.className = 'p-4 rounded-lg border-2 border-green-500 bg-green-50';
                statusDiv.innerHTML = `
                    <p class="font-bold text-green-700">✅ Notificações permitidas</p>
                    <p class="text-sm text-green-600">Você receberá notificações normalmente</p>
                `;
            } else if (permission === 'denied') {
                statusDiv.className = 'p-4 rounded-lg border-2 border-red-500 bg-red-50';
                statusDiv.innerHTML = `
                    <p class="font-bold text-red-700">❌ Notificações Bloqueadas</p>
                    <p class="text-sm text-red-600">Ative nas configurações do navegador</p>
                `;
            } else {
                statusDiv.className = 'p-4 rounded-lg border-2 border-yellow-500 bg-yellow-50';
                statusDiv.innerHTML = `
                    <p class="font-bold text-yellow-700">⚠️ Permissão necessária</p>
                    <p class="text-sm text-yellow-600">Clique em "Permitir notificações"</p>
                `;
            }
        }

        // ============================================
        // SIDEBAR FUNCTIONS
        // ============================================
        
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('sidebarOverlay');
            const fab = document.getElementById('fabNewExpense');
            
            if (sidebar.classList.contains('open')) {
                // Fechar
                sidebar.classList.remove('open');
                overlay.classList.remove('open');
                document.body.classList.remove('sidebar-open');
                
                // Mostrar FAB se em aba apropriada
                const homeTab = document.getElementById('homeTab');
                const expTab = document.getElementById('expensesTab');
                if (fab && ((homeTab && !homeTab.classList.contains('hidden')) || (expTab && !expTab.classList.contains('hidden')))) {
                    fab.style.display = 'flex';
                }
            } else {
                // Abrir
                sidebar.classList.add('open');
                overlay.classList.add('open');
                document.body.classList.add('sidebar-open');
                backToSidebarMenu();
                
                // Ocultar FAB
                if (fab) fab.style.display = 'none';
            }
        }
        
        function openSidebarPanel(panel) {
            // Esconder menu
            document.getElementById('sidebarMenu').style.display = 'none';
            
            // Esconder todos os painéis
            document.querySelectorAll('.sidebar-panel').forEach(p => p.classList.remove('active'));
            
            // Mostrar painel selecionado
            const panelId = 'sidebarPanel' + panel.charAt(0).toUpperCase() + panel.slice(1);
            const panelElement = document.getElementById(panelId);
            if (panelElement) {
                panelElement.classList.add('active');
            }
            
            // Mostrar botão de voltar e atualizar título
            const backBtn = document.getElementById('sidebarBackBtn');
            const title = document.getElementById('sidebarTitle');
            if (backBtn) backBtn.style.display = 'flex';
            
            // Atualizar título baseado no painel
            const titles = {
                'notifications': '🔔 Notificações',
                'recurring': '🔁 Recorrentes',
                'targets': '🎯 Targets',
                'payments': '💳 Pagamento',
                'categories': '🛍️ Categorias',
                'profiles': '⚖️ Perfis',
                'users': '👥 Usuários'
            };
            if (title) title.textContent = titles[panel] || 'Configurações';

            // Carregar dados do painel
            if (panel === 'recurring') {
                loadSidebarRecurring();
            } else if (panel === 'notifications') {
                loadSidebarNotifications();
            } else if (panel === 'targets') {
                loadSidebarTargets();
            } else if (panel === 'payments') {
                loadSidebarPaymentMethods();
            } else if (panel === 'categories') {
                loadSidebarCategories();
            } else if (panel === 'profiles') {
                loadSidebarProfiles();
            } else if (panel === 'users') {
                const addBtn = document.getElementById('sidebarBtnAddUser');
                if (addBtn) addBtn.style.display = user.is_admin ? '' : 'none';
                loadSidebarUsers();
            }
        }
        
        // ================================================================
        // RECORRENTES
        // ================================================================
        let _recurringCache = null;
        async function loadSidebarRecurring() {
            const list = document.getElementById('sidebarRecurringList');
            // Use static cache for users/profiles, and a simple recurring cache
            await fetchStaticData();
            if (!_recurringCache) _recurringCache = await api(`${API}/recurring`).catch(() => []);
            const items = _recurringCache;
            try {
                if (!items.length) {
                    list.innerHTML = '<p class="text-sm text-gray-400 p-4 text-center">Nenhuma despesa recorrente.</p>';
                    return;
                }
                const isDark = document.body.classList.contains('dark-mode');
                const textColor = isDark ? '#e8eaed' : '#202124';
                const subColor  = isDark ? '#9aa0a6' : '#5f6368';

                const userProfileIds = new Set((profiles||[])
                    .filter(p => p.users?.some(u => u.user_id === user.id))
                    .map(p => p.id));
                const visible = items.filter(r =>
                    r.paid_by_user_id === user.id || userProfileIds.has(r.split_profile_id)
                );

                if (!visible.length) {
                    list.innerHTML = '<p class="text-sm text-gray-400 p-4 text-center">Nenhuma recorrente visível para você.</p>';
                    return;
                }

                list.innerHTML = visible.map(r => {
                    // Admin can edit all; regular users can edit their own (created_by) or where they are paid_by
                    const canEdit = user.is_admin || r.created_by_user_id === user.id || r.paid_by_user_id === user.id;
                    const prof = byId(profiles, r.split_profile_id);
                    const paidUser = byId(users, r.paid_by_user_id);
                    const profLabel  = prof     ? (prof.emoji||'⚖️')     + ' ' + prof.name     : (r.split_profile_name||'');
                    const paidLabel  = paidUser ? (paidUser.emoji||'👤') + ' ' + paidUser.name : (r.paid_by_name||'');
                    const iv = r.interval ?? 0;
                    const freqLabel = iv === 0 ? 'Mensal' : iv === 0.5 ? 'A cada 45 dias' : iv === 1 ? 'Bimestral (pula 1 mês)' : iv === 2 ? 'Trimestral (pula 2 meses)' : `Pula ${iv} meses`;
                    const enabled = r.is_enabled !== false;
                    const cardOpacity = enabled ? '1' : '0.45';
                    const toggleTitle = enabled ? 'Pausar (não gera despesas)' : 'Ativar';
                    const toggleIcon = enabled ? '⏸️' : '▶️';
                    return `<div class="target-item" style="background: #f1f3f4;border-radius:12px;padding:12px;margin-bottom:8px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 1px 2px rgba(0,0,0,0.1);opacity:${cardOpacity};">
                        <div style="flex:1;min-width:0;">
                            <div style="display:flex;align-items:baseline;gap:6px;min-width:0;">
                                <p style="font-weight:600;font-size:14px;color:${textColor};margin:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;min-width:0;">${r.category_emoji||'📁'} ${r.description}</p>
                                <p style="font-size:13px;font-weight:600;margin:0;white-space:nowrap;flex-shrink:0;color:${isDark?'#8ab4f8':'#1a73e8'} !important;">R$ ${formatBRL(r.total_amount)}</p>
                            </div>
                            <p style="font-size:12px;color:${subColor};margin:1px 0 0 0;">${profLabel}</p>
                            <p style="font-size:12px;color:${subColor};margin:1px 0 0 0;">${paidLabel}</p>
                            <p style="font-size:12px;color:${subColor};margin:1px 0 0 0;">🗓️ ${freqLabel}</p>
                        </div>
                        <div style="display:flex;flex-direction:column;justify-content:space-between;align-self:stretch;flex-shrink:0;align-items:center;margin-left:6px;">
                            ${canEdit ? `<button onclick="toggleRecurringEnabled(${r.id})" title="${toggleTitle}" style="background:none;border:none;cursor:pointer;font-size:15px;padding:4px 4px;line-height:1;">${toggleIcon}</button><button onclick="showRecurringModal(${r.id})" style="background:none;border:none;cursor:pointer;font-size:15px;padding:4px 4px;line-height:1;">✏️</button><button onclick="deleteRecurring(${r.id})" style="background:none;border:none;cursor:pointer;font-size:15px;padding:4px 4px;line-height:1;">🗑️</button>` : ''}
                        </div>
                    </div>`;
                }).join('');
            } catch(e) {
                document.getElementById('sidebarRecurringList').innerHTML = '<p class="text-sm text-red-400 p-4">Erro ao carregar.</p>';
            }
        }

        async function generateRecurring() {
            try {
                const res = await api(`${API}/recurring/generate`, { method: 'POST' });
                if (res.generated > 0) { invalidateCache(); loadDashboardData(); }
            } catch(e) { console.error('generateRecurring:', e); }
        }

        async function deleteRecurring(id) {
            if (!confirm('Remover esta despesa recorrente?')) return;
            await api(`${API}/recurring/${id}`, { method: 'DELETE' });
            _recurringCache = null;
            loadSidebarRecurring();
        }

        async function toggleRecurringEnabled(id) {
            const updated = await api(`${API}/recurring/${id}/toggle-enabled`, { method: 'POST' });
            if (_recurringCache) {
                const idx = _recurringCache.findIndex(r => r.id === id);
                if (idx !== -1) _recurringCache[idx] = updated;
            }
            loadSidebarRecurring();
        }

        async function showRecurringModal(recurringId = null) {
            if (!categories.length) categories = await api(`${API}/categories`).catch(() => []);
            if (!profiles.length) profiles = await api(`${API}/split-profiles`).catch(() => []);
            if (!users.length) users = await api(`${API}/users`).catch(() => []);

            let rec = null;
            if (recurringId) {
                const items = await api(`${API}/recurring`).catch(() => []);
                rec = items.find(r => r.id === recurringId) || null;
            }

            const isDark = document.body.classList.contains('dark-mode');
            const optionBg = isDark ? '#3c4043' : '#f8f9fa';
            const optionSelectedBg = isDark ? '#8ab4f8' : '#e8f0fe';
            const optionBorder = isDark ? '#8ab4f8' : '#1a73e8';
            const optionTextColor = isDark ? '#9aa0a6' : '#5f6368';

            const userOptions = users.map(u =>
                '<option value="' + u.id + '" ' + (u.id === (rec?.paid_by_user_id || user.id) ? 'selected' : '') + '>' + (u.emoji||'👤') + ' ' + u.name + '</option>'
            ).join('');

            const profileOptions = profiles.filter(p => p.is_active !== false).map(p =>
                '<option value="' + p.id + '" ' + (p.id === (rec?.split_profile_id || user.preferred_split_profile_id || null) ? 'selected' : '') + '>' + (p.emoji||'⚖️') + ' ' + p.name + '</option>'
            ).join('');

            const catOptions = categories.map(c =>
                '<option value="' + c.id + '" ' + (c.id === (rec?.category_id||null) ? 'selected' : '') + '>' + (c.icon||'📁') + ' ' + c.name + '</option>'
            ).join('');

            const _recPmList = activePms(rec?.paid_by_user_id || user.id);
            const _recSelPmId = rec?.payment_method_id || user.preferred_payment_method || (_recPmList[0]?.id || null);
            const pmRow = _recPmList.map(pm => {
                const on = pm.id === _recSelPmId;
                const imgHtml = pm.icon_path ? '<img src="' + pm.icon_path + '" style="width:26px;height:26px;object-fit:contain;">' : '<span style="width:26px;height:26px;display:inline-flex;align-items:center;justify-content:center;border-radius:50%;background:' + (pm.color||'#999') + ';font-size:12px;">💳</span>';
                return '<label class="flex flex-col items-center gap-1 cursor-pointer tgt-pm-label" onclick="event.stopPropagation()"><div class="pm-option ' + (on?'selected':'') + '" id="rec_pm_wrap_' + pm.id + '" style="width:44px;height:44px;border-radius:12px;border:2px solid ' + (on?optionBorder:'transparent') + ';display:flex;align-items:center;justify-content:center;background:' + (on?optionSelectedBg:optionBg) + ';transition:.15s;">' + imgHtml + '</div><input type="radio" name="rec_pm" class="sr-only" value="' + pm.id + '" ' + (on?'checked':'') + ' onchange="recUpdatePm()"><span class="text-xs" style="max-width:48px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + pm.description + '</span></label>';
            }).join('');

            const amountDisplay = rec ? formatBRL(rec.total_amount) : '';

            const _savedScrollY = window.scrollY;
            document.body.classList.add('modal-open');
            document.body.style.top = `-${_savedScrollY}px`;
            document.getElementById('modalContainer').innerHTML = `
                <div class="fixed inset-0 flex items-center justify-center z-50" style="background:rgba(0,0,0,0.32);backdrop-filter:blur(4px);padding:1rem;">
                    <div class="bg-white w-full max-w-md overflow-hidden flex flex-col" style="border-radius:28px;box-shadow:0 4px 8px 3px rgba(60,64,67,0.15),0 1px 3px rgba(60,64,67,0.3);max-height:calc(100dvh - 2rem);">
                        <div style="background:#e8f0fe;padding:1.25rem 1.5rem;border-radius:28px 28px 0 0;flex-shrink:0;">
                            <div class="flex justify-between items-center">
                                <div class="flex items-center gap-3">
                                    <div style="width:40px;height:40px;background:#d2e3fc;border-radius:50%;display:flex;align-items:center;justify-content:center;"><span style="font-size:1.1rem;">🔁</span></div>
                                    <h2 style="font-size:1.25rem;font-weight:500;color:#202124;margin:0;">${rec ? 'Editar' : 'Adicionar'} recorrente</h2>
                                </div>
                                <button type="button" onclick="closeModal()" style="width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;background:transparent;border:none;cursor:pointer;"><span style="font-size:1.5rem;color:#5f6368;">✕</span></button>
                            </div>
                        </div>
                        <form id="recurringForm" class="flex flex-col" style="flex:1;overflow:hidden;">
                            <div class="p-6 space-y-4" style="overflow-y:auto;flex:1;">
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${optionTextColor};">Descrição *</label>
                                    <input type="text" id="rec_desc" value="${rec?.description||''}" placeholder="Ex: Aluguel" class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;" required>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${optionTextColor};">Valor (R$) *</label>
                                    <input type="text" id="rec_amount" value="${amountDisplay}" inputmode="decimal" placeholder="Ex: 1.500,00" class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;" required>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${optionTextColor};">Categoria *</label>
                                    <select id="rec_cat" required class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;">
                                        <option value="">Selecione...</option>
                                        ${catOptions}
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${optionTextColor};">Perfil *</label>
                                    <select id="rec_profile" class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;">${profileOptions}</select>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${optionTextColor};">Pago por *</label>
                                    <select id="rec_paid_by" class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;">${userOptions}</select>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${optionTextColor};">Dia de inserção (1–31)</label>
                                    <input type="number" id="rec_insert_day" min="1" max="31" value="${rec?.insert_day || 1}" class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;">
                                    <p class="text-xs mt-1" style="color:#5f6368;">Se o dia não existir no mês, usa o último dia disponível</p>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${optionTextColor};">Frequência</label>
                                    <select id="rec_interval" class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;">
                                        <option value="0"   ${(rec?.interval||0)==0    ? 'selected':''}>Mensal</option>
                                        <option value="0.5" ${(rec?.interval||0)==0.5  ? 'selected':''}>A cada 45 dias</option>
                                        <option value="1"   ${(rec?.interval||0)==1    ? 'selected':''}>Bimestral (pula 1 mês)</option>
                                        <option value="2"   ${(rec?.interval||0)==2    ? 'selected':''}>Trimestral (pula 2 meses)</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${optionTextColor};">Método de pagamento</label>
                                    <div class="flex gap-3 justify-start">${pmRow}</div>
                                </div>
                                <div id="recError" class="hidden text-red-600 text-sm"></div>
                            </div>
                            <div class="p-4 flex gap-3" style="border-top:1px solid #dadce0;flex-shrink:0;">
                                <button type="button" onclick="closeModal()" class="flex-1 py-3" style="background:#f1f3f4;color:#1a73e8;font-weight:500;border-radius:20px;border:none;">Cancelar</button>
                                <button type="submit" class="flex-1 py-3" style="background:#1a73e8;color:white;font-weight:500;border-radius:20px;border:none;">Salvar</button>
                            </div>
                        </form>
                    </div>
                </div>`;

            document.getElementById('recurringForm').onsubmit = async (e) => {
                e.preventDefault();
                const btn = e.target.querySelector('[type=submit]');
                btn.disabled = true; btn.textContent = 'Salvando...';
                const catVal = document.getElementById('rec_cat').value;
                if (!catVal) { btn.disabled=false; btn.textContent='Salvar'; return; }
                const rawAmt = document.getElementById('rec_amount').value.replace(/\./g,'').replace(',','.');
                const payload = {
                    description: document.getElementById('rec_desc').value,
                    total_amount: parseFloat(rawAmt),
                    category_id: parseInt(catVal),
                    split_profile_id: parseInt(document.getElementById('rec_profile').value),
                    paid_by_user_id: parseInt(document.getElementById('rec_paid_by').value),
                    payment_method_id: parseInt(document.querySelector('input[name=rec_pm]:checked')?.value) || null,
                    insert_day: parseInt(document.getElementById('rec_insert_day').value) || 1,
                    interval: parseFloat(document.getElementById('rec_interval').value) || 0,
                };
                try {
                    if (rec) {
                        await api(`${API}/recurring/${rec.id}`, { method: 'PUT', body: JSON.stringify(payload) });
                    } else {
                        await api(`${API}/recurring`, { method: 'POST', body: JSON.stringify(payload) });
                    }
                    closeModal();
                    _recurringCache = null;
                    loadSidebarRecurring();
                } catch(err) {
                    const errDiv = document.getElementById('recError');
                    errDiv.textContent = err.message; errDiv.classList.remove('hidden');
                    btn.disabled = false; btn.textContent = 'Salvar';
                }
            };
        }

        function recSelectCat(catId) {
            document.getElementById('rec_cat').value = catId;
            const isDark = document.body.classList.contains('dark-mode');
            const selBg  = isDark ? '#8ab4f8' : '#e8f0fe';
            const selBdr = isDark ? '#8ab4f8' : '#1a73e8';
            const defBg  = isDark ? '#3c4043' : '#f8f9fa';
            const defTxt = isDark ? '#9aa0a6' : '#5f6368';
            document.querySelectorAll('.rec-cat-opt').forEach(el => {
                const sel = parseInt(el.dataset.catId) === catId;
                el.style.background = sel ? selBg : defBg;
                el.style.borderColor = sel ? selBdr : 'transparent';
                const spans = el.querySelectorAll('span');
                if (spans[1]) spans[1].style.color = sel && isDark ? '#202124' : defTxt;
            });
        }

        function recUpdatePm() {
            const isDark = document.body.classList.contains('dark-mode');
            const selBg  = isDark ? '#8ab4f8' : '#e8f0fe';
            const selBdr = isDark ? '#8ab4f8' : '#1a73e8';
            const defBg  = isDark ? '#3c4043' : '#f8f9fa';
            document.querySelectorAll('input[name=rec_pm]').forEach(rb => {
                const wrap = document.getElementById('rec_pm_wrap_' + rb.value);
                if (!wrap) return;
                const on = rb.checked;
                wrap.classList.toggle('selected', on);
                wrap.style.borderColor = on ? selBdr : 'transparent';
                wrap.style.background  = on ? selBg : defBg;
            });
        }

        // ================================================================
        // MÉTODOS DE PAGAMENTO
        // ================================================================
        async function loadSidebarPaymentMethods() {
            const list = document.getElementById('sidebarPaymentsList');
            if (!list) return;
            const pms = activePms(user.id);
            if (!pms.length) {
                list.innerHTML = '<p class="text-sm text-gray-400 p-4 text-center">Nenhum método cadastrado.</p>';
                return;
            }

            list.innerHTML = pms.map(pm => {
                const imgHtml = pm.icon_path
                    ? `<img src="${pm.icon_path}" style="width:28px;height:28px;object-fit:contain;flex-shrink:0;">`
                    : `<span style="width:28px;height:28px;display:inline-flex;align-items:center;justify-content:center;border-radius:50%;background:${pm.color||'#999'};font-size:14px;flex-shrink:0;">💳</span>`;
                const badge = pm.is_card ? `<span class="admin-badge" style="font-size:10px;background:#e8f0fe;color:#1a73e8;border-radius:10px;padding:2px 6px;margin-left:4px;vertical-align:middle;white-space:nowrap;">Cartão</span>` : '';
                const fmtClosing = d => { const p = d.split('-'); return `${p[2]}/${p[1]}`; };
                const dueInfo = pm.is_card && pm.due_day
                    ? `<p style="font-size:12px;color:#5f6368;margin:2px 0 0 0;">Venc. dia ${pm.due_day}${pm.closing_date ? ` · Fecha ${fmtClosing(pm.closing_date)}` : ''}</p>`
                    : '';
                return `<div class="pm-item" data-id="${pm.id}" style="background:#f1f3f4;border-radius:12px;padding:12px;margin-bottom:8px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 1px 2px rgba(0,0,0,0.1);">
                    <div style="display:flex;align-items:center;gap:10px;flex:1;min-width:0;">
                        <span style="font-size:16px;color:#9aa0a6;cursor:grab;padding:4px;flex-shrink:0;">☰</span>
                        ${imgHtml}
                        <div style="min-width:0;">
                            <p style="font-weight:500;margin:0;font-size:14px;line-height:1.4;">${pm.description}${badge}</p>
                            ${dueInfo}
                        </div>
                    </div>
                    <div style="display:flex;align-items:center;gap:8px;flex-shrink:0;">
                        ${pm.is_card ? `<button onclick="togglePmClosed(${pm.id})" title="${pm.is_closed ? 'Fatura fechada — clique para abrir' : 'Fatura aberta — clique para fechar'}"
                            style="background:none;border:none;cursor:pointer;padding:2px;display:flex;align-items:center;justify-content:center;">
                            <img src="/icons/system/${pm.is_closed ? 'lock' : 'unlock'}.png" style="width:18px;height:18px;object-fit:contain;opacity:0.7;">
                        </button>` : ''}
                        ${pm.color ? `<div style="width:20px;height:20px;border-radius:4px;background:${pm.color};flex-shrink:0;"></div>` : ''}
                        <button onclick="showPaymentMethodModal(${pm.id})" style="background:none;border:none;cursor:pointer;font-size:14px;">✏️</button>
                        <button onclick="deleteItem('payment-methods',${pm.id})" style="background:none;border:none;cursor:pointer;font-size:14px;">🗑️</button>
                    </div>
                </div>`;
            }).join('');

            // Drag-and-drop reorder
            if (window.Sortable) {
                if (window._pmSortable && window._pmSortable.el !== list) {
                    try { window._pmSortable.destroy(); } catch(e) {}
                    window._pmSortable = null;
                }
                if (!window._pmSortable) window._pmSortable = Sortable.create(list, {
                    animation: 150,
                    handle: 'span[style*="cursor:grab"]',
                    onEnd: async function() {
                        const ids = Array.from(list.querySelectorAll('.pm-item')).map(el => parseInt(el.dataset.id)).filter(Boolean);
                        try { await api(`${API}/payment-methods/reorder`, { method: 'PUT', body: JSON.stringify({ payment_method_ids: ids }) }); }
                        catch(e) { console.error('reorder pm:', e); }
                    }
                });
            }
        }

        async function togglePmClosed(pmId) {
            const pm = byId(paymentMethods, pmId);
            if (!pm) return;
            const action = pm.is_closed ? 'abrir' : 'fechar';
            const actionLabel = pm.is_closed ? 'Abrir fatura' : 'Fechar fatura';
            const msg = pm.is_closed
                ? `Deseja abrir a fatura de "${pm.description}"?\nNovos lançamentos de hoje voltarão para o mês corrente.`
                : `Deseja fechar a fatura de "${pm.description}"?\nNovos lançamentos de hoje serão direcionados para o próximo mês.`;
            if (!confirm(msg)) return;
            try {
                const updated = await api(`${API}/payment-methods/${pmId}/toggle-closed`, { method: 'POST' });
                const idx = paymentMethods.findIndex(p => p.id === pmId);
                if (idx !== -1) paymentMethods[idx] = updated;
                loadSidebarPaymentMethods();
                renderPmFilterButtons();
            } catch(e) {
                alert('Erro ao alterar fatura: ' + e.message);
            }
        }

        async function showPaymentMethodModal(pmId = null) {
            const pm = pmId ? byId(paymentMethods, pmId) : null;
            const isDark = document.body.classList.contains('dark-mode');
            const modalBg    = isDark ? '#2d2e30' : 'white';
            const headerBg   = isDark ? '#35363a' : '#e8f0fe';
            const labelColor = isDark ? '#9aa0a6' : '#5f6368';
            const textColor  = isDark ? '#e8eaed' : '#202124';
            const inputBg    = isDark ? '#3c4043' : 'white';
            const inputBorder= isDark ? '#5f6368' : '#dadce0';
            const checkboxBg = isDark ? '#3c4043' : '#f1f3f4';

            const _savedScrollY = window.scrollY;
            document.body.classList.add('modal-open');
            document.body.style.top = `-${_savedScrollY}px`;
            document.getElementById('modalContainer').innerHTML = `
                <div class="fixed inset-0 flex items-center justify-center z-50" style="background:rgba(0,0,0,0.32);backdrop-filter:blur(4px);padding:1rem;">
                    <div class="w-full max-w-md overflow-hidden flex flex-col" style="border-radius:28px;background:${modalBg};box-shadow:0 4px 8px 3px rgba(60,64,67,0.15),0 1px 3px rgba(60,64,67,0.3);max-height:calc(100dvh - 2rem);">
                        <div style="background:${headerBg};padding:1.25rem 1.5rem;border-radius:28px 28px 0 0;flex-shrink:0;">
                            <div class="flex justify-between items-center">
                                <div class="flex items-center gap-3">
                                    <div style="width:40px;height:40px;background:#d2e3fc;border-radius:50%;display:flex;align-items:center;justify-content:center;"><span style="font-size:1.1rem;">💳</span></div>
                                    <h2 style="font-size:1.25rem;font-weight:500;color:${textColor};margin:0;">${pm ? 'Editar' : 'Novo'} método</h2>
                                </div>
                                <button onclick="closeModal()" style="width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;background:transparent;border:none;cursor:pointer;"><span style="font-size:1.5rem;color:${labelColor};">✕</span></button>
                            </div>
                        </div>
                        <form id="pmForm" class="flex flex-col" style="flex:1;overflow:hidden;">
                            <div class="p-6 space-y-4" style="overflow-y:auto;flex:1;">
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${labelColor};">Nome *</label>
                                    <input type="text" id="pm_desc" required value="${pm?.description||''}" class="w-full px-4 py-2 border rounded-lg" style="background:${inputBg};color:${textColor};border-color:${inputBorder};">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${labelColor};">Ícone</label>
                                    <div style="display:flex;align-items:center;gap:12px;">
                                        <div id="pm_icon_preview" style="width:44px;height:44px;border-radius:12px;background:${checkboxBg};display:flex;align-items:center;justify-content:center;flex-shrink:0;border:1px solid ${inputBorder};">
                                            ${pm?.icon_path ? `<img src="${pm.icon_path}" style="width:30px;height:30px;object-fit:contain;">` : '<span style="font-size:1.3rem;">💳</span>'}
                                        </div>
                                        <div style="flex:1;display:flex;flex-direction:column;gap:5px;">
                                            <div style="display:flex;gap:8px;">
                                                <button type="button" onclick="document.getElementById('pm_icon_file').click()"
                                                    style="flex:1;height:36px;border-radius:10px;border:1px solid ${inputBorder};background:${checkboxBg};color:${textColor};font-size:13px;cursor:pointer;">
                                                    📁 Arquivo
                                                </button>
                                                <button type="button" id="pm_gallery_btn" onclick="togglePmGallery()"
                                                    style="flex:1;height:36px;border-radius:10px;border:1px solid ${inputBorder};background:${checkboxBg};color:${textColor};font-size:13px;cursor:pointer;">
                                                    🖼️ Galeria
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <input type="file" id="pm_icon_file" accept="image/png,image/jpeg,image/svg+xml,image/webp" class="sr-only">
                                    <input type="hidden" id="pm_icon_path" value="${pm?.icon_path||''}">
                                    <!-- Galeria de ícones -->
                                    <div id="pm_gallery" class="hidden" style="margin-top:10px;border:1px solid ${inputBorder};border-radius:12px;overflow:hidden;background:${inputBg};">
                                        <div style="padding:10px;max-height:320px;overflow-y:auto;overflow-x:hidden;">
                                        <div id="pm_gallery_grid" style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;">
                                            <span style="font-size:12px;color:${labelColor};">Carregando...</span>
                                        </div>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:${labelColor};">Cor</label>
                                    <input type="color" id="pm_color" value="${pm?.color||'#1a73e8'}" class="w-full px-2 border rounded-lg" style="height:42px;border-color:${inputBorder};">
                                </div>
                                <div class="flex items-center gap-3 p-3 rounded-lg" style="background:${checkboxBg};">
                                    <input type="checkbox" id="pm_is_card" class="w-5 h-5" style="accent-color:#1a73e8;" ${pm?.is_card?'checked':''} onchange="document.getElementById('pm_due_row').classList.toggle('hidden',!this.checked)">
                                    <label for="pm_is_card" style="color:${textColor};">Cartão de crédito</label>
                                </div>
                                <div id="pm_due_row" class="${pm?.is_card?'':'hidden'}">
                                    <label class="block text-sm font-medium mb-2" style="color:${labelColor};">Dia de vencimento (1–31)</label>
                                    <input type="number" id="pm_due_day" min="1" max="31" value="${pm?.due_day||1}" class="w-full px-4 border rounded-lg" style="height:42px;background:${inputBg};color:${textColor};border-color:${inputBorder};">
                                </div>
                                <div id="pmError" class="hidden text-red-600 text-sm"></div>
                            </div>
                            <div class="p-4 flex gap-3" style="border-top:1px solid ${inputBorder};flex-shrink:0;">
                                <button type="button" onclick="closeModal()" class="flex-1 py-3" style="background:#f1f3f4;color:#1a73e8;font-weight:500;border-radius:20px;border:none;">Cancelar</button>
                                <button type="submit" class="flex-1 py-3" style="background:#1a73e8;color:white;font-weight:500;border-radius:20px;border:none;">Salvar</button>
                            </div>
                        </form>
                    </div>
                </div>`;

            // File input change ➔ preview + filename
            document.getElementById('pm_icon_file').onchange = function() {
                const file = this.files[0];
                if (!file) return;
                document.getElementById('pm_icon_path').value = '';
                const reader = new FileReader();
                reader.onload = e => {
                    document.getElementById('pm_icon_preview').innerHTML = `<img src="${e.target.result}" style="width:30px;height:30px;object-fit:contain;">`;
                };
                reader.readAsDataURL(file);
            };

            // Gallery toggle + load
            window.togglePmGallery = async function() {
                const gallery = document.getElementById('pm_gallery');
                const isHidden = gallery.classList.contains('hidden');
                gallery.classList.toggle('hidden', !isHidden);
                if (!isHidden) return;
                await loadPmGalleryGrid();
            };
            window.loadPmGalleryGrid = async function() {
                try {
                    const data = await api(`${API}/payment-methods/icons-library`);
                    const isDark2 = document.body.classList.contains('dark-mode');
                    const gridBg = isDark2 ? '#3c4043' : '#f8f9fa';
                    const selBorder = isDark2 ? '#8ab4f8' : '#1a73e8';
                    const sorted = [...data.icons].sort((a, b) => a.split('/').pop().toLowerCase().localeCompare(b.split('/').pop().toLowerCase()));
                    document.getElementById('pm_gallery_grid').innerHTML = sorted.map(path => {
                        const isSelected = document.getElementById('pm_icon_path').value === path;
                        const delBadge = user.is_admin
                            ? `<div id="gallery_del_${_galleryPathId(path)}" class="gallery-del-badge"
                                onclick="deletePmGalleryIcon(event,'${path}')"
                                style="display:none;position:absolute;top:-5px;right:-5px;width:18px;height:18px;border-radius:50%;background:#d93025;color:white;font-size:11px;font-weight:700;align-items:center;justify-content:center;cursor:pointer;z-index:3;box-shadow:0 1px 3px rgba(0,0,0,0.4);line-height:1;">✕</div>`
                            : '';
                        const longPressAttrs = user.is_admin
                            ? `onmousedown="startGalleryLongPress('${path}')" onmouseup="cancelGalleryLongPress()" onmouseleave="cancelGalleryLongPress()" ontouchstart="startGalleryLongPress('${path}')" ontouchend="cancelGalleryLongPress()" ontouchmove="cancelGalleryLongPress()"`
                            : '';
                        return `<div style="position:relative;padding:5px;">
                            <div onclick="selectPmGalleryIcon('${path}')" id="gallery_${_galleryPathId(path)}"
                                ${longPressAttrs}
                                style="height:52px;border-radius:10px;border:2px solid ${isSelected?selBorder:'transparent'};background:${gridBg};display:flex;align-items:center;justify-content:center;cursor:pointer;transition:border .15s;user-select:none;">
                                <img src="${path}" style="width:34px;height:34px;object-fit:contain;pointer-events:none;">
                            </div>
                            ${delBadge}
                        </div>`;
                    }).join('');
                } catch(e) { document.getElementById('pm_gallery_grid').innerHTML = '<span style="font-size:12px;color:#d93025;">Erro ao carregar</span>'; }
            };
            const _galleryPathId = path => btoa(path).replace(/[+=\/]/g, '_');
            window._pmLongPressTimer = window._pmLongPressTimer ?? null;
            window.startGalleryLongPress = function(path) {
                window._pmLongPressTimer = setTimeout(() => {
                    window._pmLongPressTimer = null;
                    _exitGalleryJiggle();
                    const iconEl = document.getElementById('gallery_' + _galleryPathId(path));
                    if (iconEl) iconEl.classList.add('gallery-jiggling');
                    const badgeEl = document.getElementById('gallery_del_' + _galleryPathId(path));
                    if (badgeEl) badgeEl.style.display = 'flex';
                    setTimeout(() => document.addEventListener('click', _exitGalleryJiggle, { once: true }), 10);
                }, 600);
            };
            window.cancelGalleryLongPress = function() {
                if (window._pmLongPressTimer) { clearTimeout(window._pmLongPressTimer); window._pmLongPressTimer = null; }
            };
            window._exitGalleryJiggle = function() {
                document.querySelectorAll('.gallery-jiggling').forEach(el => el.classList.remove('gallery-jiggling'));
                document.querySelectorAll('.gallery-del-badge').forEach(el => el.style.display = 'none');
            };
            window.deletePmGalleryIcon = async function(evt, path) {
                evt.stopPropagation();
                _exitGalleryJiggle();
                const filename = path.split('/').pop();
                try {
                    await api(`${API}/payment-methods/icons-library/${filename}`, { method: 'DELETE' });
                    if (document.getElementById('pm_icon_path').value === path) {
                        document.getElementById('pm_icon_path').value = '';
                        document.getElementById('pm_icon_preview').innerHTML = '<span style="font-size:1.3rem;">💳</span>';
                    }
                    await loadPmGalleryGrid();
                } catch(e) { alert(e.message); }
            };

            window.selectPmGalleryIcon = function(path) {
                document.getElementById('pm_icon_path').value = path;
                document.getElementById('pm_icon_file').value = '';
                document.getElementById('pm_icon_preview').innerHTML = `<img src="${path}" style="width:30px;height:30px;object-fit:contain;">`;
                // highlight selected
                const isDark2 = document.body.classList.contains('dark-mode');
                document.querySelectorAll('#pm_gallery_grid [id^="gallery_"]').forEach(el => {
                    const active = el.id === `gallery_${_galleryPathId(path)}`;
                    el.style.border = `2px solid ${active ? (isDark2?'#8ab4f8':'#1a73e8') : 'transparent'}`;
                });
            };

            document.getElementById('pmForm').onsubmit = async (e) => {
                e.preventDefault();
                const btn = e.target.querySelector('[type=submit]');
                btn.disabled = true; btn.textContent = 'Salvando...';
                try {
                    // Upload icon if selected
                    let iconPath = document.getElementById('pm_icon_path').value;
                    const fileInput = document.getElementById('pm_icon_file');
                    if (fileInput.files[0]) {
                        const fd = new FormData();
                        fd.append('file', fileInput.files[0]);
                        const res = await fetch(`${API}/payment-methods/upload-icon`, {
                            method: 'POST',
                            headers: { 'Authorization': `Bearer ${token}` },
                            body: fd
                        });
                        if (!res.ok) throw new Error('Erro no upload do ícone');
                        const j = await res.json();
                        iconPath = j.icon_path;
                    }
                    const payload = {
                        description: document.getElementById('pm_desc').value,
                        color: document.getElementById('pm_color').value,
                        is_card: document.getElementById('pm_is_card').checked,
                        due_day: document.getElementById('pm_is_card').checked ? (parseInt(document.getElementById('pm_due_day').value)||null) : null,
                        icon_path: iconPath || null,
                    };
                    if (pm) {
                        await api(`${API}/payment-methods/${pm.id}`, { method: 'PUT', body: JSON.stringify(payload) });
                    } else {
                        await api(`${API}/payment-methods`, { method: 'POST', body: JSON.stringify(payload) });
                    }
                    // Refresh PM list from server to ensure local state is in sync
                    const freshPms = await api(`${API}/payment-methods`);
                    paymentMethods = [...paymentMethods.filter(p => p.user_id !== user.id), ...freshPms];
                    closeModal();
                    loadSidebarPaymentMethods();
                    renderPmFilterButtons();
                } catch(err) {
                    document.getElementById('pmError').textContent = err.message;
                    document.getElementById('pmError').classList.remove('hidden');
                    btn.disabled = false; btn.textContent = 'Salvar';
                }
            };
        }

        function backToSidebarMenu() {
            // Esconder todos os painéis
            document.querySelectorAll('.sidebar-panel').forEach(p => p.classList.remove('active'));
            
            // Mostrar menu
            document.getElementById('sidebarMenu').style.display = 'block';
            
            // Ocultar botão de voltar e restaurar título
            const backBtn = document.getElementById('sidebarBackBtn');
            const title = document.getElementById('sidebarTitle');
            if (backBtn) backBtn.style.display = 'none';
            if (title) title.textContent = 'Configurações';
        }
        
        // Carregar notificações na sidebar
        function loadSidebarNotifications() {
            loadNotificationSettings();
            
            const container = document.getElementById('sidebarNotificationsContent');
            if (!container) return;
            
            const enabled = notificationSettings.enabled;
            const permission = 'Notification' in window ? Notification.permission : 'unsupported';
            
            container.innerHTML = `
                <!-- Status de Permissão -->
                <div style="padding: 12px; background: ${permission === 'granted' ? '#e6f4ea' : '#fef7e0'}; border-radius: 12px; margin-bottom: 16px;">
                    <p style="font-size: 13px; color: ${permission === 'granted' ? '#137333' : '#b06000'}; margin: 0;">
                        ${permission === 'granted' ? '✅ Permissão concedida' : '⚠️ Permissão: ' + permission}
                    </p>
                </div>
                
                <!-- Toggle Notificações -->
                <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px; background: #f1f3f4; border-radius: 12px; margin-bottom: 16px;">
                    <div>
                        <p style="font-weight: 500; margin: 0;">Notificações ativas</p>
                        <p style="font-size: 12px; color: #5f6368; margin: 4px 0 0 0;">Ative para receber alertas</p>
                    </div>
                    <div id="sidebarNotifToggle" class="toggle-switch ${enabled ? 'active' : ''}" onclick="toggleSidebarNotifications()"></div>
                </div>
                
                <!-- Tipos de Notificação -->
                <div style="margin-bottom: 16px;">
                    <p style="font-weight: 500; margin-bottom: 12px;">Tipos de notificação</p>
                    
                    <label style="display: flex; align-items: flex-start; gap: 12px; padding: 10px; cursor: pointer; border-radius: 8px;" onmouseover="this.style.background='#f1f3f4'" onmouseout="this.style.background='transparent'">
                        <input type="checkbox" id="sidebar_notify_new" style="accent-color: #1a73e8; margin-top: 2px;" ${notificationSettings.new_expense ? 'checked' : ''}>
                        <div>
                            <p style="font-weight: 500; margin: 0; font-size: 14px;">Despesa adicionada</p>
                            <p style="font-size: 12px; color: #5f6368; margin: 2px 0 0 0;">Quando alguém adiciona nova despesa</p>
                        </div>
                    </label>
                    
                    <label style="display: flex; align-items: flex-start; gap: 12px; padding: 10px; cursor: pointer; border-radius: 8px;" onmouseover="this.style.background='#f1f3f4'" onmouseout="this.style.background='transparent'">
                        <input type="checkbox" id="sidebar_notify_edit" style="accent-color: #1a73e8; margin-top: 2px;" ${notificationSettings.edit_expense ? 'checked' : ''}>
                        <div>
                            <p style="font-weight: 500; margin: 0; font-size: 14px;">Despesa editada</p>
                            <p style="font-size: 12px; color: #5f6368; margin: 2px 0 0 0;">Quando alguém edita uma despesa</p>
                        </div>
                    </label>
                    
                    <label style="display: flex; align-items: flex-start; gap: 12px; padding: 10px; cursor: pointer; border-radius: 8px;" onmouseover="this.style.background='#f1f3f4'" onmouseout="this.style.background='transparent'">
                        <input type="checkbox" id="sidebar_notify_delete" style="accent-color: #1a73e8; margin-top: 2px;" ${notificationSettings.delete_expense ? 'checked' : ''}>
                        <div>
                            <p style="font-weight: 500; margin: 0; font-size: 14px;">Despesa deletada</p>
                            <p style="font-size: 12px; color: #5f6368; margin: 2px 0 0 0;">Quando alguém remove uma despesa</p>
                        </div>
                    </label>
                    
                    <label style="display: flex; align-items: flex-start; gap: 12px; padding: 10px; cursor: pointer; border-radius: 8px;" onmouseover="this.style.background='#f1f3f4'" onmouseout="this.style.background='transparent'">
                        <input type="checkbox" id="sidebar_notify_reminders" style="accent-color: #1a73e8; margin-top: 2px;" ${notificationSettings.reminders ? 'checked' : ''}>
                        <div>
                            <p style="font-weight: 500; margin: 0; font-size: 14px;">Lembretes mensais</p>
                            <p style="font-size: 12px; color: #5f6368; margin: 2px 0 0 0;">Resumo do mês toda primeira segunda-feira</p>
                        </div>
                    </label>
                </div>
                
                <!-- Horário -->
                <div style="margin-bottom: 16px;">
                    <label style="font-weight: 500; font-size: 13px; color: #5f6368;">Horário preferencial</label>
                    <input type="time" id="sidebar_notify_time" value="${notificationSettings.time || '08:00'}" style="width: 100%; padding: 10px; border: 1px solid #dadce0; border-radius: 8px; margin-top: 8px;">
                    <p style="font-size: 12px; color: #5f6368; margin: 4px 0 0 0;">Horário para receber lembretes</p>
                </div>
                
                <!-- Botões -->
                <div style="display: flex; gap: 12px;">
                    <button onclick="backToSidebarMenu()" style="flex: 1; padding: 12px; background: #f1f3f4; color: #1a73e8; border: none; border-radius: 20px; cursor: pointer; font-size: 14px; font-weight: 500;">
                        Cancelar
                    </button>
                    <button onclick="saveSidebarNotifications()" style="flex: 1; padding: 12px; background: #1a73e8; color: white; border: none; border-radius: 20px; cursor: pointer; font-size: 14px; font-weight: 500;">
                        Salvar
                    </button>
                </div>
            `;
        }
        
        async function toggleSidebarNotifications() {
            const toggle = document.getElementById('sidebarNotifToggle');
            const isActive = toggle.classList.contains('active');
            
            if (!isActive) {
                // Ativar
                if ('Notification' in window) {
                    const permission = await Notification.requestPermission();
                    if (permission === 'granted') {
                        notificationSettings.enabled = true;
                        localStorage.setItem('notificationEnabled', 'true');
                        toggle.classList.add('active');
                        
                        // Registrar token FCM
                        if (typeof registerFCMToken === 'function') {
                            registerFCMToken();
                        }
                        
                        // Recarregar conteúdo
                        loadSidebarNotifications();
                    } else {
                        alert('⚠️ Permissão negada.');
                    }
                }
            } else {
                // Desativar
                notificationSettings.enabled = false;
                localStorage.setItem('notificationEnabled', 'false');
                toggle.classList.remove('active');
                loadSidebarNotifications();
            }
        }
        
        function testSidebarNotification() {
            if (!notificationSettings.enabled || Notification.permission !== 'granted') {
                alert('⚠️ Ative as notificações primeiro.');
                return;
            }
            
            const title = '🧪 Notificação de Teste';
            const body = 'Se você viu isso, as notificações estão funcionando!';
            
            if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
                navigator.serviceWorker.ready.then(registration => {
                    registration.showNotification(title, { body, icon: '/icon-192.png' });
                });
            } else {
                new Notification(title, { body, icon: '/icon-192.png' });
            }
        }
        
        async function saveSidebarNotifications() {
            // Atualizar configurações
            notificationSettings.new_expense = document.getElementById('sidebar_notify_new')?.checked || false;
            notificationSettings.edit_expense = document.getElementById('sidebar_notify_edit')?.checked || false;
            notificationSettings.delete_expense = document.getElementById('sidebar_notify_delete')?.checked || false;
            notificationSettings.reminders = document.getElementById('sidebar_notify_reminders')?.checked || false;
            notificationSettings.time = document.getElementById('sidebar_notify_time')?.value || '08:00';
            
            // Salvar localmente
            localStorage.setItem('notificationSettings', JSON.stringify(notificationSettings));
            
            // Salvar no servidor
            try {
                await fetch(`${API}/notification-preferences`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${token}`
                    },
                    body: JSON.stringify({
                        notify_new_expense: notificationSettings.new_expense,
                        notify_edit_expense: notificationSettings.edit_expense,
                        notify_delete_expense: notificationSettings.delete_expense,
                        notify_reminders: notificationSettings.reminders,
                        reminder_time: notificationSettings.time
                    })
                });
                console.log('✅ Preferências salvas no servidor');
            } catch (err) {
                console.error('Erro ao salvar no servidor:', err);
            }
            
            alert('✅ Configurações salvas!');
        }
        
        // Carregar categorias na sidebar (com drag and drop)
        async function loadSidebarCategories() {
            if (!isStaticCacheValid() || !categories.length) {
                const list = await api(`${API}/categories`);
                categories = list;
            }
            
            const container = document.getElementById('sidebarCategoriesList');
            if (!container) return;
            
            container.innerHTML = categories.map(c => {
                const hidden = isCatHidden(c.id);
                return `
                <div class="category-item" data-id="${c.id}" style="background: #f1f3f4; border-radius: 12px; padding: 12px; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 2px rgba(0,0,0,0.1); opacity: ${hidden ? '0.5' : '1'};">
                    <div style="display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0;">
                        ${user.is_admin ? '<span style="font-size: 16px; color: #9aa0a6; cursor: grab; padding: 4px; flex-shrink: 0;">☰</span>' : ''}
                        <span style="font-size: 1.5rem; flex-shrink: 0;">${c.icon || '📁'}</span>
                        <div style="min-width: 0;">
                            <p style="font-weight: 500; margin: 0; font-size: 14px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${c.name}</p>
                            ${c.description ? `<p style="font-size: 12px; color: #5f6368; margin: 2px 0 0 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${c.description}</p>` : ''}
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px; flex-shrink: 0;">
                        <div style="width: 20px; height: 20px; border-radius: 4px; background: ${c.color};"></div>
                        <button onclick="toggleCatVisibility(${c.id})" title="${hidden ? 'Mostrar categoria' : 'Ocultar categoria'}"
                            style="background: none; border: none; cursor: pointer; padding: 2px; display: flex; align-items: center; opacity: ${hidden ? '0.4' : '0.6'};">
                            <img src="${hidden ? '/icons/system/unseen-black.png' : '/icons/system/seen-black.png'}" class="dark-invert-icon" style="width:18px;height:18px;"></button>
                        ${user.is_admin ? `
                            <button onclick="editCategory(${c.id})" style="background: none; border: none; cursor: pointer; font-size: 14px;">✏️</button>
                            <button onclick="deleteItem('categories', ${c.id})" style="background: none; border: none; cursor: pointer; font-size: 14px;">🗑️</button>
                        ` : ''}
                    </div>
                </div>`;
            }).join('');
            
            // Drag and drop
            if (user.is_admin && window.Sortable) {
                if (window.sidebarCategoriesSortable && window.sidebarCategoriesSortable.el !== container) {
                    try { window.sidebarCategoriesSortable.destroy(); } catch(e) {}
                    window.sidebarCategoriesSortable = null;
                }
                if (!window.sidebarCategoriesSortable) window.sidebarCategoriesSortable = Sortable.create(container, {
                    animation: 150,
                    handle: 'span[style*="cursor: grab"]',
                    onEnd: async function(evt) {
                        const items = Array.from(container.querySelectorAll('.category-item'));
                        const categoryIds = items.map(item => parseInt(item.dataset.id));
                        
                        try {
                            await api(`${API}/categories/reorder`, {
                                method: 'PUT',
                                body: JSON.stringify({ category_ids: categoryIds })
                            });
                            
                            // Atualizar array local
                            const newOrder = [];
                            categoryIds.forEach(id => {
                                const cat = byId(categories, id);
                                if (cat) newOrder.push(cat);
                            });
                            categories = newOrder;
                            invalidateStaticCache();
                            console.log('✅ Categorias reordenadas');
                        } catch (err) {
                            console.error('Erro ao reordenar:', err);
                            alert('Erro ao salvar ordem');
                        }
                    }
                });
            }
        }
        
        // Carregar perfis na sidebar (com drag and drop)
        async function loadSidebarProfiles() {
            // Garantir que profiles e users estejam carregados
            if (!isStaticCacheValid() || !profiles.length || !users.length) {
                await fetchStaticData();
            }
            
            const container = document.getElementById('sidebarProfilesList');
            if (!container) return;
            
            const sortedProfiles = [...profiles].sort((a, b) => (a.display_order || 0) - (b.display_order || 0));
            
            container.innerHTML = sortedProfiles.map(p => `
                <div class="profile-item" data-id="${p.id}" style="background: #f1f3f4; border-radius: 12px; padding: 12px; margin-bottom: 8px; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            ${user.is_admin ? '<span style="font-size: 16px; color: #9aa0a6; cursor: grab; padding: 4px;">☰</span>' : ''}
                            <span style="font-size: 1.25rem;">${p.emoji || '⚖️'}</span>
                            <p style="font-weight: 500; margin: 0; font-size: 14px;">${p.name}</p>
                        </div>
                        ${user.is_admin ? `
                            <div style="display: flex; gap: 8px;">
                                <button onclick="editProfile(${p.id})" style="background: none; border: none; cursor: pointer; font-size: 14px;">✏️</button>
                                <button onclick="deleteItem('profiles', ${p.id})" style="background: none; border: none; cursor: pointer; font-size: 14px;">🗑️</button>
                            </div>
                        ` : ''}
                    </div>
                    <div style="background: #f8f9fa; border-radius: 8px; padding: 8px;">
                        ${p.users.map(u => {
                            const usr = users.find(x => x.id === u.user_id);
                            return `<div style="display: flex; justify-content: space-between; font-size: 13px; padding: 4px 0;">
                                <span>${usr?.emoji || '👤'} ${usr?.name || 'Usuário ' + u.user_id}</span>
                                <span style="font-weight: 500; color: #1a73e8;">${formatBRL(u.percentage * 100)}%</span>
                            </div>`;
                        }).join('')}
                    </div>
                </div>
            `).join('');
            
            // Drag and drop
            if (user.is_admin && window.Sortable) {
                if (window.sidebarProfilesSortable && window.sidebarProfilesSortable.el !== container) {
                    try { window.sidebarProfilesSortable.destroy(); } catch(e) {}
                    window.sidebarProfilesSortable = null;
                }
                if (!window.sidebarProfilesSortable) window.sidebarProfilesSortable = Sortable.create(container, {
                    animation: 150,
                    handle: 'span[style*="cursor: grab"]',
                    onEnd: async function(evt) {
                        const items = Array.from(container.children);
                        for (let i = 0; i < items.length; i++) {
                            const profileId = parseInt(items[i].dataset.id);
                            await api(`${API}/profiles/${profileId}/reorder`, {
                                method: 'PUT',
                                body: JSON.stringify({ display_order: i })
                            });
                        }
                        invalidateStaticCache();
                        console.log('✅ Perfis reordenados');
                    }
                });
            }
        }
        
        // Carregar usuários na sidebar (com drag and drop)
        async function loadSidebarUsers() {
            if (!isStaticCacheValid() || !users.length) {
                const list = await api(`${API}/users`);
                users = list;
            }
            
            const container = document.getElementById('sidebarUsersList');
            if (!container) return;
            
            const sortedUsers = [...users].sort((a, b) => (a.display_order || 0) - (b.display_order || 0));
            
            container.innerHTML = sortedUsers.map(u => `
                <div class="user-item" data-id="${u.id}" style="background: #f1f3f4; border-radius: 12px; padding: 12px; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
                    <div style="display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0;">
                        ${user.is_admin ? '<span style="font-size: 16px; color: #9aa0a6; cursor: grab; padding: 4px; flex-shrink: 0;">☰</span>' : ''}
                        <span style="font-size: 1.25rem; flex-shrink: 0;">${u.emoji || '👤'}</span>
                        <div style="width: 16px; height: 16px; border-radius: 4px; background: ${u.color || '#3B82F6'}; flex-shrink: 0;"></div>
                        <div style="min-width: 0;">
                            <p style="font-weight: 500; margin: 0; font-size: 14px; display: flex; align-items: center; gap: 6px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                ${u.name}
                                ${u.is_admin ? '<span style="font-size: 10px; background: #e8f0fe; color: #1a73e8; padding: 2px 6px; border-radius: 10px; flex-shrink: 0;">Admin</span>' : ''}
                            </p>
                            <p style="font-size: 12px; color: #5f6368; margin: 2px 0 0 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${u.email}</p>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        ${(user.is_admin || u.id === user.id) ? `
                            <button onclick="editUser(${u.id})" style="background: none; border: none; cursor: pointer; font-size: 14px;">✏️</button>
                        ` : ''}
                        ${user.is_admin && u.id !== user.id ? `
                            <button onclick="deleteItem('users', ${u.id})" style="background: none; border: none; cursor: pointer; font-size: 14px;">🗑️</button>
                        ` : ''}
                    </div>
                </div>
            `).join('');
            
            // Drag and drop
            if (user.is_admin && window.Sortable) {
                if (window.sidebarUsersSortable && window.sidebarUsersSortable.el !== container) {
                    try { window.sidebarUsersSortable.destroy(); } catch(e) {}
                    window.sidebarUsersSortable = null;
                }
                if (!window.sidebarUsersSortable) window.sidebarUsersSortable = Sortable.create(container, {
                    animation: 150,
                    handle: 'span[style*="cursor: grab"]',
                    onEnd: async function(evt) {
                        const items = Array.from(container.children);
                        for (let i = 0; i < items.length; i++) {
                            const userId = parseInt(items[i].dataset.id);
                            await api(`${API}/users/${userId}/reorder`, {
                                method: 'PUT',
                                body: JSON.stringify({ display_order: i })
                            });
                        }
                        invalidateStaticCache();
                        console.log('✅ Usuários reordenados');
                    }
                });
            }
        }
        
        // ============================================
