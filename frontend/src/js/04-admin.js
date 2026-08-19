        async function loadCategories() {
            // Usar cache se válido, senão buscar
            if (!isStaticCacheValid() || !categories.length) {
                const list = await api(`${API}/categories`);
                categories = list;
            }
            
            document.getElementById('categoriesList').innerHTML = categories.map(c => `
                <div class="bg-white rounded-lg shadow p-4 mb-3 flex justify-between items-center category-item" data-id="${c.id}">
                    <div class="flex items-center gap-3 flex-1">
                        ${user.is_admin ? '<span class="text-2xl text-gray-400 cursor-move" style="cursor: grab; padding: 8px; margin: -8px;">☰</span>' : ''}
                        <span class="text-3xl">${c.icon || '📁'}</span>
                        <div>
                            <p class="font-bold">${c.name}</p>
                            <p class="text-sm text-gray-600">${c.description || ''}</p>
                        </div>
                    </div>
                    <div class="flex items-center gap-3">
                        <div class="w-8 h-8 rounded" style="background:${c.color}"></div>
                        ${user.is_admin ? `
                            <button onclick="editCategory(${c.id})" class="text-blue-600 text-sm">✏️</button>
                            <button onclick="deleteItem('categories', ${c.id})" class="text-red-600 text-sm">🗑️</button>
                        ` : ''}
                    </div>
                </div>
            `).join('');
            
            // Adicionar drag-and-drop se for admin
            if (user.is_admin) {
                const categoriesList = document.getElementById('categoriesList');
                if (categoriesList && window.Sortable) {
                    if (categoriesSortable && categoriesSortable.el !== categoriesList) {
                        try { categoriesSortable.destroy(); } catch(e) {}
                        categoriesSortable = null;
                    }
                    if (!categoriesSortable) categoriesSortable = Sortable.create(categoriesList, {
                        animation: 150,
                        handle: '.cursor-move',
                        onEnd: async function(evt) {
                            const items = Array.from(categoriesList.querySelectorAll('.category-item'));
                            const categoryIds = items.map(item => parseInt(item.dataset.id));
                            
                            console.log('Reordenando categorias:', categoryIds);
                            
                            try {
                                const response = await api(`${API}/categories/reorder`, {
                                    method: 'PUT',
                                    body: JSON.stringify({ category_ids: categoryIds })
                                });
                                
                                console.log('Resposta do servidor:', response);
                                
                                // Atualizar array local de categories para refletir nova ordem
                                const newOrder = [];
                                categoryIds.forEach(id => {
                                    const cat = byId(categories, id);
                                    if (cat) newOrder.push(cat);
                                });
                                categories = newOrder;
                                
                                console.log('✅ Ordem salva com sucesso!');
                            } catch (err) {
                                console.error('❌ Erro ao reordenar:', err);
                                console.error('Detalhes:', err.message);
                                alert('Erro ao salvar ordem: ' + err.message);
                            }
                        }
                    });
                }
            }
        }

        async function loadProfiles() {
            // Usar cache se válido, senão buscar
            if (!isStaticCacheValid() || !profiles.length) {
                const list = await api(`${API}/profiles`);
                profiles = list;
            }
            
            // Ordenar por display_order
            const sortedProfiles = [...profiles].sort((a, b) => (a.display_order || 0) - (b.display_order || 0));
            
            document.getElementById('profilesList').innerHTML = sortedProfiles.map(p => `
                <div class="bg-white rounded-lg shadow p-4 mb-4 profile-item" data-id="${p.id}" data-emoji="${p.emoji || '⚖️'}">
                    <div class="flex justify-between items-start mb-3">
                        <div class="flex items-center gap-3 flex-1">
                            ${user.is_admin ? '<span class="text-2xl text-gray-400 cursor-move" style="cursor: grab; padding: 10px; margin: -10px;">☰</span>' : ''}
                            <span class="text-2xl">${p.emoji || '⚖️'}</span>
                            <div>
                                <p class="font-bold text-lg">${p.name}</p>
                            </div>
                        </div>
                        ${user.is_admin ? `
                            <div class="flex gap-2">
                                <button onclick="editProfile(${p.id})" class="text-blue-600 text-sm">✏️</button>
                                <button onclick="deleteItem('profiles', ${p.id})" class="text-red-600 text-sm">🗑️</button>
                            </div>
                        ` : ''}
                    </div>
                    <div class="bg-gray-50 rounded p-3 space-y-2">
                        ${p.users.map(u => {
                            const usr = users.find(x => x.id === u.user_id);
                            return `<div class="flex justify-between text-sm">
                                <span>${usr?.emoji || '👤'} ${usr?.name || 'Usuário ' + u.user_id}</span>
                                <span class="font-bold text-blue-600">${formatBRL(u.percentage * 100)}%</span>
                            </div>`;
                        }).join('')}
                    </div>
                </div>
            `).join('');
            
            // Adicionar drag-and-drop se for admin
            if (user.is_admin) {
                const profilesList = document.getElementById('profilesList');
                if (profilesSortable && profilesSortable.el !== profilesList) {
                    try { profilesSortable.destroy(); } catch(e) {}
                    profilesSortable = null;
                }
                if (!profilesSortable) profilesSortable = new Sortable(profilesList, {
                    animation: 150,
                    handle: '.cursor-move',
                    onEnd: async function(evt) {
                        const items = Array.from(profilesList.children);
                        for (let i = 0; i < items.length; i++) {
                            const profileId = parseInt(items[i].dataset.id);
                            await api(`${API}/profiles/${profileId}/reorder`, {
                                method: 'PUT',
                                body: JSON.stringify({ display_order: i })
                            });
                        }
                    }
                });
            }
        }

        async function loadUsers() {
            // Usar cache se válido, senão buscar
            if (!isStaticCacheValid() || !users.length) {
                const list = await api(`${API}/users`);
                users = list;
            }
            
            // Ordenar por display_order
            const sortedUsers = [...users].sort((a, b) => (a.display_order || 0) - (b.display_order || 0));
            
            document.getElementById('usersList').innerHTML = sortedUsers.map(u => `
                <div class="bg-white rounded-lg shadow p-4 mb-3 flex justify-between items-center user-item" data-id="${u.id}">
                    <div class="flex items-center gap-3 flex-1">
                        ${user.is_admin ? '<span class="text-2xl text-gray-400 cursor-move" style="cursor: grab; padding: 8px; margin: -8px;">☰</span>' : ''}
                        <span class="text-2xl">${u.emoji || '👤'}</span>
                        <div class="w-6 h-6 rounded" style="background:${u.color || '#3B82F6'}"></div>
                        <div>
                            <p class="font-bold flex items-center gap-2">
                                ${u.name}
                                ${u.is_admin ? '<span class="text-xs bg-blue-100 text-blue-800 px-2 py-0.5 rounded-full">Admin</span>' : ''}
                            </p>
                            <p class="text-sm text-gray-600">${u.email}</p>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <button onclick="editUser(${u.id})" class="text-blue-600 text-lg">✏️</button>
                        ${u.id !== user.id ? `
                            <button onclick="deleteItem('users', ${u.id})" class="text-red-600 text-lg">🗑️</button>
                        ` : ''}
                    </div>
                </div>
            `).join('');
            
            // Adicionar drag-and-drop se for admin
            if (user.is_admin) {
                const usersList = document.getElementById('usersList');
                if (usersSortable && usersSortable.el !== usersList) {
                    try { usersSortable.destroy(); } catch(e) {}
                    usersSortable = null;
                }
                if (!usersSortable) usersSortable = new Sortable(usersList, {
                    animation: 150,
                    handle: '.cursor-move',
                    onEnd: async function(evt) {
                        const items = Array.from(usersList.children);
                        for (let i = 0; i < items.length; i++) {
                            const userId = parseInt(items[i].dataset.id);
                            await api(`${API}/users/${userId}/reorder`, {
                                method: 'PUT',
                                body: JSON.stringify({ display_order: i })
                            });
                        }
                    }
                });
            }
        }

        async function deleteItem(type, id) {
            if (!confirm('Excluir?')) return;
            
            try {
                const result = await api(`${API}/${type}/${id}`, {method: 'DELETE'});
                
                if (result.soft_delete) {
                    alert('Item desativado. Mantido no histórico pois possui despesas.');
                }
                
                if (type === 'income') {
                    window._incomeCache = null;
                    loadIncome();
                    return;
                }
                else if (type === 'expenses') {
                    invalidateCache();
                    if (typeof sendExpenseNotification === 'function') {
                        sendExpenseNotification('delete', { id });
                    }
                    await loadMonths();
                    loadExpenses();
                }
                else if (type === 'categories') {
                    invalidateStaticCache();
                    loadCategories();
                    loadSidebarCategories();
                }
                else if (type === 'profiles') {
                    invalidateStaticCache();
                    loadProfiles();
                    loadSidebarProfiles();
                }
                else if (type === 'users') {
                    invalidateStaticCache();
                    loadUsers();
                    loadSidebarUsers();
                }
                else if (type === 'payment-methods') {
                    paymentMethods = paymentMethods.filter(p => p.id !== id);
                    loadSidebarPaymentMethods();
                }
                loadDashboardData();
            } catch (error) {
                alert(error.message || 'Erro ao deletar');
            }
        }

        function closeModal() {
            // Fechar modal imediatamente
            document.getElementById('modalContainer').innerHTML = '';
            
            // Restaurar scroll do fundo na posição salva
            const savedTop = document.body.style.top;
            document.body.classList.remove('modal-open');
            document.body.style.top = '';
            if (savedTop) window.scrollTo(0, -parseInt(savedTop || '0'));
            
            // Mostrar FAB apenas se sidebar NÃO está aberta E está em aba apropriada
            const sidebar = document.getElementById('sidebar');
            const sidebarOpen = sidebar && sidebar.classList.contains('open');
            
            if (!sidebarOpen) {
                const fab = document.getElementById('fabNewExpense');
                const homeTab = document.getElementById('homeTab');
                const expTab = document.getElementById('expensesTab');
                if (fab && ((homeTab && !homeTab.classList.contains('hidden')) || (expTab && !expTab.classList.contains('hidden')))) {
                    fab.style.display = 'flex';
                }
            }
        }

        // ✅ 9️⃣ Modal não fecha ao clicar fora - REMOVIDO onclick do overlay

        // Função para selecionar categoria no modal de despesas
        function _stepInst(delta) {
            const i = document.getElementById('exp_inst');
            if (i) i.value = Math.max(1, parseInt(i.value || 1) + delta);
        }

        function selectCategory(catId) {
            document.getElementById('exp_cat').value = catId;
            const isDark = document.body.classList.contains('dark-mode');
            document.querySelectorAll('.cat-option').forEach(el => {
                if (parseInt(el.dataset.catId) === catId) {
                    el.classList.add('selected');
                    el.style.background = isDark ? '#8ab4f8' : '#e8f0fe';
                    el.style.borderColor = isDark ? '#8ab4f8' : '#1a73e8';
                    el.style.boxShadow = isDark ? '0 0 0 2px rgba(138, 180, 248, 0.3)' : 'none';
                    // Texto escuro quando selecionado no dark mode
                    el.querySelectorAll('span').forEach(s => s.style.color = isDark ? '#202124' : '');
                } else {
                    el.classList.remove('selected');
                    el.style.background = isDark ? '#3c4043' : '#f8f9fa';
                    el.style.borderColor = 'transparent';
                    el.style.boxShadow = 'none';
                    el.querySelectorAll('span').forEach(s => s.style.color = '');
                }
            });
        }
        
        // Função para selecionar quem pagou
        function selectPaidBy(userId) {
            document.getElementById('exp_paid').value = userId;
            const isDark = document.body.classList.contains('dark-mode');
            document.querySelectorAll('.paid-option').forEach(el => {
                if (parseInt(el.dataset.userId) === userId) {
                    el.classList.add('selected');
                    el.style.background = isDark ? '#8ab4f8' : '#e8f0fe';
                    el.style.borderColor = isDark ? '#8ab4f8' : '#1a73e8';
                    el.style.boxShadow = isDark ? '0 0 0 2px rgba(138, 180, 248, 0.3)' : 'none';
                    el.querySelectorAll('span').forEach(s => s.style.color = isDark ? '#202124' : '');
                } else {
                    el.classList.remove('selected');
                    el.style.background = isDark ? '#3c4043' : '#f8f9fa';
                    el.style.borderColor = 'transparent';
                    el.style.boxShadow = 'none';
                    el.querySelectorAll('span').forEach(s => s.style.color = '');
                }
            });
            renderExpensePmOptions(userId);
            updateCartaoHint();
        }
        
        // Função para selecionar perfil
        function selectProfile(profId) {
            document.getElementById('exp_prof').value = profId;
            const isDark = document.body.classList.contains('dark-mode');
            document.querySelectorAll('.prof-option').forEach(el => {
                if (parseInt(el.dataset.profId) === profId) {
                    el.classList.add('selected');
                    el.style.background = isDark ? '#8ab4f8' : '#e8f0fe';
                    el.style.borderColor = isDark ? '#8ab4f8' : '#1a73e8';
                    el.style.boxShadow = isDark ? '0 0 0 2px rgba(138, 180, 248, 0.3)' : 'none';
                    el.querySelectorAll('span').forEach(s => s.style.color = isDark ? '#202124' : '');
                } else {
                    el.classList.remove('selected');
                    el.style.background = isDark ? '#3c4043' : '#f8f9fa';
                    el.style.borderColor = 'transparent';
                    el.style.boxShadow = 'none';
                    el.querySelectorAll('span').forEach(s => s.style.color = '');
                }
            });
        }

        // Renderizar opções de método de pagamento do pagador selecionado
        function renderExpensePmOptions(paidById) {
            const container = document.getElementById('expPmOptionsContainer');
            if (!container) return;
            const pms = activePms(paidById || user.id);
            const isDark = document.body.classList.contains('dark-mode');
            const optionBg = isDark ? '#3c4043' : '#f8f9fa';
            const optionSelectedBg = isDark ? '#8ab4f8' : '#e8f0fe';
            const optionBorder = isDark ? '#8ab4f8' : '#1a73e8';
            const optionTextColor = isDark ? '#9aa0a6' : '#5f6368';
            const curId = parseInt(document.getElementById('exp_payment_method_id')?.value) || null;
            // Se o método atual não pertence ao novo pagador, resetar para o preferido dele
            const curPm = pms.find(p => p.id === curId);
            const paidByUser = byId(users, paidById) || user;
            const prefPmId = paidByUser?.preferred_payment_method || null;
            const selId = curPm ? curId : (pms.find(p => p.id === prefPmId)?.id || pms[0]?.id || null);
            if (document.getElementById('exp_payment_method_id')) document.getElementById('exp_payment_method_id').value = selId || '';
            container.innerHTML = pms.map(pm => {
                const isSel = pm.id === selId;
                const imgHtml = pm.icon_path
                    ? `<img src="${pm.icon_path}" style="width:26px;height:26px;object-fit:contain;">`
                    : `<span style="font-size:1.3rem;">💳</span>`;
                return `<div onclick="selectPaymentMethod(${pm.id})" id="pm_opt_${pm.id}"
                    class="pm-option flex flex-col items-center justify-center cursor-pointer ${isSel?'selected':''}"
                    style="width:60px;height:55px;gap:5px;flex-shrink:0;border:2px solid ${isSel?optionBorder:'transparent'};background:${isSel?optionSelectedBg:optionBg};border-radius:12px;transition:.15s;">
                    ${imgHtml}
                    <span style="font-size:9px;line-height:1;color:${isSel&&isDark?'#202124':optionTextColor};max-width:56px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${pm.description}</span>
                </div>`;
            }).join('');
        }

        function _selectUserPmButtons(pmId, inputId, btnClass) {
            const inp = document.getElementById(inputId);
            if (inp) inp.value = pmId ?? '';
            const isDark = document.body.classList.contains('dark-mode');
            const selBg     = isDark ? '#8ab4f8' : '#e8f0fe';
            const selBorder = isDark ? '#8ab4f8' : '#1a73e8';
            const defBg     = isDark ? '#3c4043' : '#f8f9fa';
            document.querySelectorAll(`.${btnClass}`).forEach(el => {
                const id = el.dataset.pmId ? parseInt(el.dataset.pmId) : null;
                const active = id === pmId;
                el.classList.toggle('selected', active);
                el.style.background = active ? selBg : defBg;
                el.style.border     = `2px solid ${active ? selBorder : 'transparent'}`;
                el.style.boxShadow  = active && isDark ? '0 0 0 2px rgba(138,180,248,0.3)' : 'none';
            });
        }
        function selectUserPayment(pmId) { _selectUserPmButtons(parseInt(pmId), 'usr_payment_value', 'usr-pay-btn'); }
        function selectUserBalance(pmId) { _selectUserPmButtons(pmId ? parseInt(pmId) : null, 'usr_balance_method', 'usr-bal-btn'); }

        // Função para selecionar método de pagamento no modal de despesas
        function selectPaymentMethod(pmId) {
            pmId = parseInt(pmId);
            document.getElementById('exp_payment_method_id').value = pmId;
            const isDark = document.body.classList.contains('dark-mode');
            const selectedBg = isDark ? '#8ab4f8' : '#e8f0fe';
            const selectedBorder = isDark ? '#8ab4f8' : '#1a73e8';
            const defaultBg = isDark ? '#3c4043' : '#f8f9fa';
            document.querySelectorAll('.pm-option[id^="pm_opt_"]').forEach(el => {
                const active = parseInt(el.id.replace('pm_opt_', '')) === pmId;
                el.classList.toggle('selected', active);
                el.style.background = active ? selectedBg : defaultBg;
                el.style.borderColor = active ? selectedBorder : 'transparent';
                el.style.boxShadow = active && isDark ? '0 0 0 2px rgba(138,180,248,0.3)' : 'none';
                el.querySelectorAll('span').forEach(s => s.style.color = active && isDark ? '#202124' : '');
            });
            updateCartaoHint();
        }

        // Atualiza o hint do cartão com base na data selecionada e dia de fechamento
        function updateCartaoHint() {
            const hint = document.getElementById('pm_cartao_hint');
            if (!hint) return;
            const pmId = parseInt(document.getElementById('exp_payment_method_id')?.value) || null;
            const pm = pmById(pmId);
            if (!pm || !pm.is_card || !pm.due_day) { hint.style.display = 'none'; return; }
            const dateVal = document.getElementById('exp_date')?.value;
            if (!dateVal) { hint.style.display = 'none'; return; }
            const dueDay = pm.due_day;
            const expDate = new Date(dateVal + 'T00:00:00');
            const nextDue = new Date(expDate.getFullYear(), expDate.getMonth() + 1, dueDay);
            const closing = new Date(nextDue);
            closing.setDate(closing.getDate() - 7);
            if (expDate > closing) {
                const destMonth = nextDue.toLocaleDateString('pt-BR', { month: 'short', year: 'numeric' });
                const closingStr = closing.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
                hint.textContent = `⚠️ Após fechamento (${closingStr}) ➡️ ${destMonth}`;
                hint.style.display = '';
            } else {
                hint.style.display = 'none';
            }
        }

        async function showExpenseModal(expenseId = null) {
            // Esconder FAB
            const fab = document.getElementById('fabNewExpense');
            if (fab) fab.style.display = 'none';
            
            // Impedir scroll do fundo preservando posição
            const _savedScrollY = window.scrollY;
            document.body.classList.add('modal-open');
            document.body.style.top = `-${_savedScrollY}px`;
            
            // Detectar dark mode
            const isDark = document.body.classList.contains('dark-mode');
            const optionBg = isDark ? '#3c4043' : '#f8f9fa';
            const optionSelectedBg = isDark ? '#8ab4f8' : '#e8f0fe';
            const optionBorder = isDark ? '#8ab4f8' : '#1a73e8';
            const optionTextColor = isDark ? '#9aa0a6' : '#5f6368';
            
            try {
                // Usar cache de dados estáticos
                await fetchStaticData();
                
                let expense = null;
                if (expenseId) {
                    // Tentar buscar do cache primeiro
                    if (cachedExpenses) {
                        expense = cachedExpenses.find(e => e.id === expenseId);
                    }
                    if (!expense) {
                        const list = await api(`${API}/expenses`);
                        expense = list.find(e => e.id === expenseId);
                    }
                }
                
                // Data de hoje no timezone local (evita offset UTC)
                const now = new Date();
                const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
                
                document.getElementById('modalContainer').innerHTML = `
                    <div id="expenseModalOverlay" class="modal-overlay fixed inset-0 flex items-center justify-center z-50" style="background: rgba(0,0,0,0.32); backdrop-filter: blur(4px); padding: 2rem 1rem;">
                        <div class="modal-content bg-white w-full max-w-lg overflow-hidden flex flex-col" style="border-radius: 28px; box-shadow: 0 4px 8px 3px rgba(60,64,67,0.15), 0 1px 3px rgba(60,64,67,0.3); max-height: calc(100vh - 4rem); max-height: calc(100dvh - 4rem);">
                            <!-- Header -->
                            <div style="background: #e8f0fe; padding: 1.25rem 1.5rem; border-radius: 28px 28px 0 0; flex-shrink: 0;">
                                <div class="flex justify-between items-center">
                                    <div class="flex items-center gap-3">
                                        <div style="width: 40px; height: 40px; background: #d2e3fc; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                            <span style="font-size: 1.1rem;">💸</span>
                                        </div>
                                        <h2 style="font-size: 1.25rem; font-weight: 500; color: #202124;">${expense ? 'Editar' : 'Adicionar'} despesa</h2>
                                    </div>
                                    <button onclick="closeModal()" style="width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: transparent; border: none; cursor: pointer;">
                                        <span style="font-size: 1.5rem; color: #5f6368;">✕</span>
                                    </button>
                                </div>
                            </div>
                            
                            <!-- Body -->
                            <form id="expenseForm" class="flex flex-col" style="flex: 1; overflow: hidden;">
                                <div class="p-5 space-y-4" style="overflow-y: auto; flex: 1; scrollbar-width: thin; scrollbar-color: #dadce0 transparent;">
                                    <!-- Erro no topo -->
                                    <div id="expError" class="hidden text-red-600 text-sm bg-red-50 p-3 rounded-lg"></div>
                                    <!-- 1. Data -->
                                    <div>
                                        <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Data *</label>
                                        <input type="date" id="exp_date" required value="${expense ? (expense.original_date || expense.expense_date) : today}"
                                            class="w-full px-4 py-2 border rounded-lg" onchange="updateCartaoHint()">
                                    </div>
                                    <!-- 2. Descrição -->
                                    <div>
                                        <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Descrição *</label>
                                        <input type="text" id="exp_desc" required value="${expense?.description || ''}"
                                            class="w-full px-4 py-2 border rounded-lg" placeholder="Ex: Conta de luz"
                                            enterkeyhint="next" 
                                            onkeydown="if(event.key==='Enter'){event.preventDefault();document.getElementById('exp_amt').focus();}">
                                    </div>
                                    <!-- 3. Valor e Parcelas -->
                                    <div class="grid grid-cols-2 gap-4">
                                        <div>
                                            <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Valor *</label>
                                            <input type="number" id="exp_amt" required step="0.01" value="${expense?.total_amount ? parseFloat(expense.total_amount).toFixed(2) : ''}"
                                                class="w-full px-4 py-2 border rounded-lg" placeholder="0,00"
                                                inputmode="decimal" enterkeyhint="next"
                                                onkeydown="if(event.key==='Enter'){event.preventDefault();document.getElementById('exp_inst').focus();}">
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Parcelas</label>
                                            <div style="display:flex;align-items:stretch;gap:6px;height:42px;">
                                                <input type="text" id="exp_inst" required value="${expense?.installments || 1}"
                                                    style="flex:1;padding:0 8px;text-align:center;border:1px solid #dadce0;outline:none;background:transparent;font-size:14px;min-width:0;border-radius:8px;"
                                                    inputmode="numeric" pattern="[0-9]*" enterkeyhint="done"
                                                    onkeydown="if(event.key==='Enter'){event.preventDefault();this.blur();}">
                                                <div style="display:flex;flex-direction:column;border:1px solid #dadce0;width:28px;flex-shrink:0;border-radius:8px;overflow:hidden;">
                                                    <button type="button" onclick="_stepInst(1)" ontouchstart="event.preventDefault();_stepInst(1);" style="flex:1;border:none;border-bottom:1px solid #dadce0;background:transparent;cursor:pointer;font-size:9px;line-height:1;-webkit-tap-highlight-color:transparent;">▲</button>
                                                    <button type="button" onclick="_stepInst(-1)" ontouchstart="event.preventDefault();_stepInst(-1);" style="flex:1;border:none;background:transparent;cursor:pointer;font-size:9px;line-height:1;-webkit-tap-highlight-color:transparent;">▼</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- 4. Categoria - Seletor visual compacto -->
                                    <div>
                                        <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Categoria *</label>
                                        <input type="hidden" id="exp_cat" value="${expense?.category_id || ''}" required>
                                        <div class="flex flex-wrap gap-2 justify-center">
                                            ${(() => {
                                                const cats = visibleCategories();
                                                // Always include the current expense's category even if hidden
                                                if (expense?.category_id && !cats.find(c => c.id === expense.category_id)) {
                                                    const hidden = byId(categories, expense.category_id);
                                                    if (hidden) cats.unshift(hidden);
                                                }
                                                return cats;
                                            })().map(c => {
                                                const isSelected = expense?.category_id === c.id;
                                                const textColor = isSelected && isDark ? '#202124' : optionTextColor;
                                                return `
                                                <div onclick="selectCategory(${c.id})" 
                                                     class="cat-option flex flex-col items-center justify-center rounded-xl cursor-pointer transition-all ${isSelected ? 'selected' : ''}"
                                                     data-cat-id="${c.id}"
                                                     style="background: ${isSelected ? optionSelectedBg : optionBg}; 
                                                            border: 2px solid ${isSelected ? optionBorder : 'transparent'}; 
                                                            ${isSelected && isDark ? 'box-shadow: 0 0 0 2px rgba(138, 180, 248, 0.3);' : ''}
                                                            width: 60px; height: 55px; flex-shrink: 0;">
                                                    <span style="font-size: 1.3rem; ${isSelected && isDark ? 'color: #202124;' : ''}">${c.icon || '📁'}</span>
                                                    <span style="font-size: 9px; color: ${textColor}; margin-top: 2px; max-width: 56px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${c.name}</span>
                                                </div>`;
                                            }).join('')}
                                        </div>
                                    </div>
                                    <!-- 5. Perfil - Seletor visual (logo abaixo da Categoria) -->
                                    ${(() => {
                                        const visibleProfs = user.is_admin ? profiles : profiles.filter(p => p.users?.some(u => u.user_id === user.id));
                                        const defaultProfId = expense?.split_profile_id || user.preferred_split_profile_id || (visibleProfs.length === 1 ? visibleProfs[0].id : null) || '';
                                        if (visibleProfs.length <= 1) {
                                            return `<input type="hidden" id="exp_prof" value="${defaultProfId}" required>`;
                                        }
                                        return `<div>
                                        <label class="block text-sm font-medium mb-2" style="color: ${optionTextColor};">Perfil *</label>
                                        <input type="hidden" id="exp_prof" value="${defaultProfId}" required>
                                        <div class="flex flex-wrap gap-2 justify-center">
                                            ${visibleProfs.map(p => {
                                                const isSelected = defaultProfId === p.id;
                                                const textColor = isSelected && isDark ? '#202124' : optionTextColor;
                                                return `
                                                <div onclick="selectProfile(${p.id})"
                                                     class="prof-option flex flex-col items-center justify-center rounded-xl cursor-pointer transition-all ${isSelected ? 'selected' : ''}"
                                                     data-prof-id="${p.id}"
                                                     style="background: ${isSelected ? optionSelectedBg : optionBg};
                                                            border: 2px solid ${isSelected ? optionBorder : 'transparent'};
                                                            ${isSelected && isDark ? 'box-shadow: 0 0 0 2px rgba(138, 180, 248, 0.3);' : ''}
                                                            width: 60px; height: 55px; flex-shrink: 0;">
                                                    <span style="font-size: 1.3rem; ${isSelected && isDark ? 'color: #202124;' : ''}">${p.emoji || '⚖️'}</span>
                                                    <span style="font-size: 9px; color: ${textColor}; margin-top: 2px; max-width: 56px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${p.name}</span>
                                                </div>`;
                                            }).join('')}
                                        </div>
                                    </div>`;
                                    })()}
                                    <!-- 6. Quem Pagou - apenas usuário logado (não-admin) ou todos (admin) -->
                                    ${(() => {
                                        const visibleUsers = user.is_admin ? users : users.filter(u => u.id === user.id);
                                        const defaultPaidId = expense?.paid_by_user_id || user.id;
                                        if (visibleUsers.length <= 1) {
                                            return `<input type="hidden" id="exp_paid" value="${defaultPaidId}" required>`;
                                        }
                                        return `<div>
                                        <label class="block text-sm font-medium mb-2" style="color: ${optionTextColor};">Quem pagou *</label>
                                        <input type="hidden" id="exp_paid" value="${defaultPaidId}" required>
                                        <div class="flex flex-wrap gap-2 justify-center">
                                            ${visibleUsers.map(u => {
                                                const isSelected = expense ? expense.paid_by_user_id === u.id : u.id === user.id;
                                                const textColor = isSelected && isDark ? '#202124' : optionTextColor;
                                                return `
                                                <div onclick="selectPaidBy(${u.id})"
                                                     class="paid-option flex flex-col items-center justify-center rounded-xl cursor-pointer transition-all ${isSelected ? 'selected' : ''}"
                                                     data-user-id="${u.id}"
                                                     style="background: ${isSelected ? optionSelectedBg : optionBg};
                                                            border: 2px solid ${isSelected ? optionBorder : 'transparent'};
                                                            ${isSelected && isDark ? 'box-shadow: 0 0 0 2px rgba(138, 180, 248, 0.3);' : ''}
                                                            width: 60px; height: 55px; flex-shrink: 0;">
                                                    <span style="font-size: 1.3rem; ${isSelected && isDark ? 'color: #202124;' : ''}">${u.emoji || '👤'}</span>
                                                    <span style="font-size: 9px; color: ${textColor}; margin-top: 2px; max-width: 56px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${u.name}</span>
                                                </div>`;
                                            }).join('')}
                                        </div>
                                    </div>`;
                                    })()}
                                    <!-- 7. Método de Pagamento -->
                                    <div>
                                        <label class="block text-sm font-medium mb-2" style="color: ${optionTextColor};">Método de pagamento</label>
                                        <input type="hidden" id="exp_payment_method_id" value="${expense?.payment_method_id || user.preferred_payment_method || ''}">
                                        <div class="flex gap-2 flex-wrap justify-center" id="expPmOptionsContainer"></div>
                                        <p id="pm_cartao_hint" class="text-xs mt-2" style="color: #e8710a; display:none;"></p>
                                    </div>
                                    <!-- 8. Observações -->
                                    <div>
                                        <label class="block text-sm font-medium mb-2" style="color: ${optionTextColor};">Observações</label>
                                        <textarea id="exp_notes" rows="2" class="w-full px-4 py-2 border rounded-lg" enterkeyhint="done">${expense?.notes || ''}</textarea>
                                    </div>
                                </div>
                                
                                <!-- Footer -->
                                <div class="p-4 flex gap-3" style="border-top: 1px solid #dadce0; flex-shrink: 0;">
                                    <button type="button" onclick="closeModal()" class="flex-1 py-3" style="background: #f1f3f4; color: #1a73e8; font-weight: 500; border-radius: 20px; border: none;">Cancelar</button>
                                    <button type="submit" class="flex-1 py-3" style="background: #1a73e8; color: white; font-weight: 500; border-radius: 20px; border: none;">${expense ? 'Salvar' : 'Salvar'}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                `;
                
                // Evitar autofocus do navegador - blur múltiplo
                requestAnimationFrame(() => {
                    document.activeElement?.blur();
                    setTimeout(() => { document.activeElement?.blur(); }, 10);
                    setTimeout(() => { document.activeElement?.blur(); }, 50);
                });
                // Renderizar métodos de pagamento para o pagador padrão
                { const _iId=parseInt(document.getElementById('exp_paid')?.value)||user.id; renderExpensePmOptions(_iId); }
                updateCartaoHint();

                document.getElementById('expenseForm').onsubmit = async (e) => {
                    e.preventDefault();
                    
                    // Prevenir duplo clique - desabilitar botão
                    const submitBtn = e.target.querySelector('button[type="submit"]');
                    if (submitBtn.disabled) return;
                    
                    // ✅ Validação amigável dos campos de seleção
                    const errorDiv = document.getElementById('expError');
                    const catVal = document.getElementById('exp_cat').value;
                    const paidVal = document.getElementById('exp_paid').value;
                    const profVal = document.getElementById('exp_prof').value;
                    
                    // Função para mostrar erro e rolar para o topo
                    const showError = (msg) => {
                        errorDiv.textContent = msg;
                        errorDiv.classList.remove('hidden');
                        errorDiv.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    };
                    
                    if (!catVal) {
                        showError('⚠️ Selecione uma categoria');
                        return;
                    }
                    if (!paidVal) {
                        showError('⚠️ Selecione quem pagou');
                        return;
                    }
                    if (!profVal) {
                        showError('⚠️ Selecione um perfil de divisão');
                        return;
                    }
                    // Validar envolvimento do usuário logado
                    const selectedProfile = byId(profiles, parseInt(profVal));
                    const userInProfile = selectedProfile?.users?.some(u => u.user_id === user.id);
                    const userIsPayer = parseInt(paidVal) === user.id;
                    if (!userIsPayer && !userInProfile) {
                        showError('⚠️ Você não tem envolvimento nessa despesa. Selecione um perfil do qual você faz parte ou defina você como quem pagou.');
                        return;
                    }
                    errorDiv.classList.add('hidden');
                    
                    submitBtn.disabled = true;
                    const originalText = submitBtn.textContent;
                    submitBtn.textContent = 'Salvando...';
                    
                    try {
                        // Corrigir timezone da data para evitar offset de -1 dia
                        const expenseDate = document.getElementById('exp_date').value;
                        const paymentMethodId = parseInt(document.getElementById('exp_payment_method_id')?.value) || null;

                        const data = {
                            description: document.getElementById('exp_desc').value,
                            total_amount: parseFloat(document.getElementById('exp_amt').value),
                            installments: parseInt(document.getElementById('exp_inst').value),
                            expense_date: expenseDate,
                            category_id: parseInt(catVal),
                            paid_by_user_id: parseInt(paidVal),
                            split_profile_id: parseInt(profVal),
                            notes: document.getElementById('exp_notes').value || null,
                            payment_method_id: paymentMethodId
                        };
                        
                        const url = expense ? `${API}/expenses/${expense.id}` : `${API}/expenses`;
                        const method = expense ? 'PUT' : 'POST';
                        
                        await api(url, { method, body: JSON.stringify(data) });
                        
                        // ✅ Invalidar cache após salvar
                        invalidateCache();
                        
                        // ✅ Enviar notificação
                        console.log('🔔 Despesa salva, enviando notificação...');
                        if (typeof sendExpenseNotification === 'function') {
                            sendExpenseNotification(expense ? 'edit' : 'new', data);
                        } else {
                            console.error('❌ sendExpenseNotification não definida!');
                        }
                        
                        closeModal();

                        // ✅ Atualizar lista de meses disponíveis (preserva seleção atual)
                        await loadMonths();

                        loadExpenses();
                        loadDashboardData();
                    } catch (err) {
                        const errDiv = document.getElementById('expError');
                        errDiv.textContent = err.message;
                        errDiv.classList.remove('hidden');
                        errDiv.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        // Reabilitar botão em caso de erro
                        submitBtn.disabled = false;
                        submitBtn.textContent = originalText;
                    }
                };
            } catch (err) {
                alert('Erro: ' + err.message);
            }
        }

        async function editExpense(id) {
            await showExpenseModal(id);
        }

        async function showCategoryModal(categoryId = null) {
            // Garantir que categories está carregado antes de buscar pelo id
            if (categoryId && !categories.length) {
                try {
                    categories = await api(`${API}/categories`);
                } catch(e) {}
            }
            const category = categoryId ? byId(categories, categoryId) : null;
            
            // Carregar opções IPCA (lazy, cache simples)
            if (!window._ipcaCategories) {
                try {
                    window._ipcaCategories = await api(`${API}/ipca/categories`);
                } catch(e) {
                    window._ipcaCategories = [];
                }
            }
            const ipcaOpts = window._ipcaCategories;

            // Calcular nível de indentação pelo prefixo numérico do nome
            function ipcaLevel(name) {
                const m = name.match(/^(\d+)\./);
                if (!m) return 0;
                const digits = m[1].length;
                if (digits <= 1) return 1;
                if (digits <= 2) return 2;
                if (digits <= 4) return 3;
                return 4;
            }
            
            const _savedScrollY = window.scrollY;
            document.body.classList.add('modal-open');
            document.body.style.top = `-${_savedScrollY}px`;
            document.getElementById('modalContainer').innerHTML = `
                <div class="fixed inset-0 flex items-center justify-center z-50" style="background: rgba(0,0,0,0.32); backdrop-filter: blur(4px); padding: 2rem 1rem;">
                    <div class="bg-white w-full max-w-md overflow-hidden flex flex-col" style="border-radius: 28px; box-shadow: 0 4px 8px 3px rgba(60,64,67,0.15), 0 1px 3px rgba(60,64,67,0.3); max-height: calc(100vh - 4rem); max-height: calc(100dvh - 4rem);">
                        <!-- Header -->
                        <div style="background: #e8f0fe; padding: 1.25rem 1.5rem; border-radius: 28px 28px 0 0; flex-shrink: 0;">
                            <div class="flex justify-between items-center">
                                <div class="flex items-center gap-3">
                                    <div style="width: 40px; height: 40px; background: #d2e3fc; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                        <span style="font-size: 1.1rem;">🛍️</span>
                                    </div>
                                    <h2 style="font-size: 1.25rem; font-weight: 500; color: #202124;">${category ? 'Editar' : 'Adicionar'} categoria</h2>
                                </div>
                                <button onclick="closeModal()" style="width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: transparent; border: none; cursor: pointer;">
                                    <span style="font-size: 1.5rem; color: #5f6368;">✕</span>
                                </button>
                            </div>
                        </div>
                        
                        <!-- Body -->
                        <form id="categoryForm" class="flex flex-col" style="flex: 1; overflow: hidden;">
                            <div class="p-6 space-y-4" style="overflow-y: auto; flex: 1; scrollbar-width: thin; scrollbar-color: #dadce0 transparent;">
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Nome *</label>
                                    <input type="text" id="cat_name" required value="${category?.name || ''}" class="w-full px-4 py-2 border rounded-lg">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Descrição</label>
                                    <input type="text" id="cat_desc" value="${category?.description || ''}" class="w-full px-4 py-2 border rounded-lg">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Ícone (emoji)</label>
                                    <input type="text" id="cat_icon" maxlength="2" value="${category?.icon || ''}" class="w-full px-4 py-2 border rounded-lg">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Cor</label>
                                    <input type="color" id="cat_color" value="${category?.color || '#999999'}" class="h-10 w-full border rounded">
                                </div>
                                
                                <!-- Categoria IPCA -->
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Categoria IPCA <span style="font-size: 11px; font-weight: 400; color: #9aa0a6;">(opcional)</span></label>
                                    <input type="hidden" id="cat_ipca_code" value="${category?.ipca_category_code || ''}">
                                    <input type="hidden" id="cat_ipca_name" value="${category?.ipca_category_name || ''}">
                                    <div class="relative">
                                        <button type="button" id="ipcaDropdownBtn"
                                            onclick="toggleIpcaDropdown()"
                                            class="w-full px-3 py-2 text-sm bg-white flex items-center justify-between gap-2 border rounded-lg"
                                            style="border-color: #dadce0; text-align: left;">
                                            <span id="ipcaSelectedText" class="truncate">
                                                ${category?.ipca_category_name || 'Selecionar categoria IPCA...'}
                                            </span>
                                            <span style="flex-shrink:0;">▼</span>
                                        </button>
                                        <div id="ipcaDropdown"
                                            class="hidden absolute left-0 mt-1 bg-white z-20 border rounded-lg overflow-hidden"
                                            style="border-color: #dadce0; box-shadow: 0 1px 2px 0 rgba(60,64,67,0.3), 0 2px 6px 2px rgba(60,64,67,0.15); width: 100%;">
                                            <!-- Search bar fixa no topo -->
                                            <div style="padding: 8px; border-bottom: 1px solid #dadce0; position: sticky; top: 0; background: white; z-index: 1;">
                                                <input type="text" id="ipcaSearchInput"
                                                    placeholder="🔍 Buscar..."
                                                    autocomplete="off"
                                                    oninput="filterIpcaOptions(this.value)"
                                                    class="w-full px-3 py-1.5 text-sm border rounded-lg"
                                                    style="border-color: #dadce0; outline: none;">
                                            </div>
                                            <!-- Opção de limpar (quando há seleção) -->
                                            <div id="ipcaClearOpt" class="${category?.ipca_category_name ? '' : 'hidden'}"
                                                style="padding: 8px 12px; cursor: pointer; font-size: 13px; color: #ea4335; border-bottom: 1px solid #f1f3f4;"
                                                onclick="clearIpcaSelection()">
                                                ✕ Remover seleção
                                            </div>
                                            <!-- Lista de opções -->
                                            <div id="ipcaOptionsList" style="max-height: 240px; overflow-y: auto;">
                                                ${ipcaOpts.map(opt => {
                                                    const level = ipcaLevel(opt.name);
                                                    const indent = level * 12;
                                                    const isHeader = level <= 2;
                                                    const isSelected = category?.ipca_category_code === opt.code;
                                                    return `<div class="ipca-opt${isSelected ? ' ipca-selected' : ''}"
                                                        data-code="${opt.code}"
                                                        data-name="${opt.name.replace(/"/g, '&quot;')}"
                                                        onclick="selectIpcaOption(${opt.code}, '${opt.name.replace(/'/g, "\\'")}')"
                                                        style="padding: 7px 12px 7px ${12 + indent}px; cursor: pointer; font-size: 13px; font-weight: ${isHeader ? '600' : '400'}; display: flex; align-items: center; gap: 6px;">
                                                        ${isSelected ? '<span style="color:#1a73e8;font-size:11px;">✓</span>' : '<span style="width:17px;display:inline-block;"></span>'}
                                                        <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${opt.name}</span>
                                                    </div>`;
                                                }).join('')}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <div id="catError" class="hidden text-red-600 text-sm"></div>
                            </div>
                            
                            <!-- Footer -->
                            <div class="p-4 flex gap-3" style="border-top: 1px solid #dadce0; flex-shrink: 0;">
                                <button type="button" onclick="closeModal()" class="flex-1 py-3" style="background: #f1f3f4; color: #1a73e8; font-weight: 500; border-radius: 20px; border: none;">Cancelar</button>
                                <button type="submit" class="flex-1 py-3" style="background: #1a73e8; color: white; font-weight: 500; border-radius: 20px; border: none;">Salvar</button>
                            </div>
                        </form>
                    </div>
                </div>
            `;
            
            document.getElementById('categoryForm').onsubmit = async (e) => {
                e.preventDefault();
                const submitBtn = e.target.querySelector('button[type="submit"]');
                if (submitBtn.disabled) return;
                submitBtn.disabled = true;
                const originalText = submitBtn.textContent;
                submitBtn.textContent = 'Salvando...';
                
                try {
                    const ipcaCode = document.getElementById('cat_ipca_code').value;
                    const ipcaName = document.getElementById('cat_ipca_name').value;
                    const data = {
                        name: document.getElementById('cat_name').value,
                        description: document.getElementById('cat_desc').value || null,
                        icon: document.getElementById('cat_icon').value || null,
                        color: document.getElementById('cat_color').value,
                        ipca_category_code: ipcaCode ? parseInt(ipcaCode) : null,
                        ipca_category_name: ipcaName || null
                    };
                    
                    const url = category ? `${API}/categories/${category.id}` : `${API}/categories`;
                    const method = category ? 'PUT' : 'POST';
                    
                    await api(url, { method, body: JSON.stringify(data) });
                    closeModal();
                    invalidateStaticCache();
                    loadCategories();
                    loadSidebarCategories();
                    loadDashboardData();
                } catch (err) {
                    document.getElementById('catError').textContent = err.message;
                    document.getElementById('catError').classList.remove('hidden');
                    submitBtn.disabled = false;
                    submitBtn.textContent = originalText;
                }
            };
        }

        function toggleIpcaDropdown() {
            const dd = document.getElementById('ipcaDropdown');
            const input = document.getElementById('ipcaSearchInput');
            if (!dd) return;
            const isHidden = dd.classList.contains('hidden');
            if (isHidden) {
                dd.classList.remove('hidden');
                setTimeout(() => {
                    input?.focus();
                    // Scroll o container .p-6 do modal para mostrar o dropdown
                    const btn = document.getElementById('ipcaDropdownBtn');
                    const modalScrollContainer = btn?.closest('.p-6');
                    if (modalScrollContainer) {
                        modalScrollContainer.scrollTop = modalScrollContainer.scrollHeight;
                    }
                    // Scroll para a opção selecionada, se houver
                    const selectedCode = document.getElementById('cat_ipca_code')?.value;
                    if (selectedCode) {
                        const list = document.getElementById('ipcaOptionsList');
                        const sel = list?.querySelector(`.ipca-opt[data-code="${selectedCode}"]`);
                        if (sel) sel.scrollIntoView({ block: 'nearest' });
                    }
                }, 50);
            } else {
                dd.classList.add('hidden');
            }
        }
        function filterIpcaOptions(query) {
            const q = query.toLowerCase().trim();
            document.querySelectorAll('.ipca-opt').forEach(el => {
                el.style.display = !q || el.dataset.name.toLowerCase().includes(q) ? '' : 'none';
            });
        }
        function selectIpcaOption(code, name) {
            document.getElementById('cat_ipca_code').value = code;
            document.getElementById('cat_ipca_name').value = name;
            const btn = document.getElementById('ipcaSelectedText');
            if (btn) { btn.textContent = name; }
            // Mostrar opção de limpar
            document.getElementById('ipcaClearOpt')?.classList.remove('hidden');
            // Atualizar checked visual
            document.querySelectorAll('.ipca-opt').forEach(el => {
                const isThis = parseInt(el.dataset.code) === code;
                el.classList.toggle('ipca-selected', isThis);
                const tick = el.querySelector('span:first-child');
                if (tick) { tick.textContent = isThis ? '✓' : ''; tick.style.color = '#1a73e8'; }
            });
            // Fechar dropdown
            document.getElementById('ipcaDropdown')?.classList.add('hidden');
            // Limpar search
            const si = document.getElementById('ipcaSearchInput');
            if (si) si.value = '';
            filterIpcaOptions('');
        }
        function clearIpcaSelection() {
            document.getElementById('cat_ipca_code').value = '';
            document.getElementById('cat_ipca_name').value = '';
            const btn = document.getElementById('ipcaSelectedText');
            if (btn) { btn.textContent = 'Selecionar categoria IPCA...'; btn.style.color = '#9aa0a6'; }
            document.getElementById('ipcaClearOpt')?.classList.add('hidden');
            document.querySelectorAll('.ipca-opt').forEach(el => {
                el.classList.remove('ipca-selected');
                const tick = el.querySelector('span:first-child');
                if (tick) tick.textContent = '';
            });
            document.getElementById('ipcaDropdown')?.classList.add('hidden');
        }
        // Fechar dropdown IPCA ao clicar fora
        document.addEventListener('click', function(e) {
            const btn = document.getElementById('ipcaDropdownBtn');
            const dd = document.getElementById('ipcaDropdown');
            if (btn && dd && !btn.contains(e.target) && !dd.contains(e.target)) {
                dd.classList.add('hidden');
            }
        });

        function editCategory(id) {
            showCategoryModal(id);
        }

        async function showProfileModal(profileId = null) {
            // Usar cache de dados estáticos
            await fetchStaticData();
            const profile = profileId ? byId(profiles, profileId) : null;
            
            const _savedScrollY = window.scrollY;
            document.body.classList.add('modal-open');
            document.body.style.top = `-${_savedScrollY}px`;
            document.getElementById('modalContainer').innerHTML = `
                <div class="fixed inset-0 flex items-center justify-center z-50" style="background: rgba(0,0,0,0.32); backdrop-filter: blur(4px); padding: 2rem 1rem;">
                    <div class="bg-white w-full max-w-md overflow-hidden flex flex-col" style="border-radius: 28px; box-shadow: 0 4px 8px 3px rgba(60,64,67,0.15), 0 1px 3px rgba(60,64,67,0.3); max-height: calc(100vh - 4rem); max-height: calc(100dvh - 4rem);">
                        <!-- Header -->
                        <div style="background: #e8f0fe; padding: 1.25rem 1.5rem; border-radius: 28px 28px 0 0; flex-shrink: 0;">
                            <div class="flex justify-between items-center">
                                <div class="flex items-center gap-3">
                                    <div style="width: 40px; height: 40px; background: #d2e3fc; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                        <span style="font-size: 1.1rem;">⚖️</span>
                                    </div>
                                    <h2 style="font-size: 1.25rem; font-weight: 500; color: #202124;">${profile ? 'Editar' : 'Adicionar'} perfil</h2>
                                </div>
                                <button onclick="closeModal()" style="width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: transparent; border: none; cursor: pointer;">
                                    <span style="font-size: 1.5rem; color: #5f6368;">✕</span>
                                </button>
                            </div>
                        </div>
                        
                        <!-- Body -->
                        <form id="profileForm" class="flex flex-col" style="flex: 1; overflow: hidden;">
                            <div class="p-6 space-y-4" style="overflow-y: auto; flex: 1; scrollbar-width: thin; scrollbar-color: #dadce0 transparent;">
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Nome *</label>
                                    <input type="text" id="prof_name" required value="${profile?.name || ''}" style="height:42px;" class="w-full px-4 py-2 border rounded-lg">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Emoji</label>
                                    <input type="text" id="prof_emoji" value="${profile?.emoji || '⚖️'}" maxlength="10" 
                                        style="height:42px;" class="w-20 px-4 py-2 border rounded-lg text-center text-xl" placeholder="⚖️">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: #5f6368;">Divisão *</label>
                                    <div class="space-y-3">
                                        ${users.map((u, i) => {
                                            const pu = profile?.users.find(x => x.user_id === u.id);
                                            const checked = profile ? !!pu : i < 2;
                                            const pct = pu ? formatBRL(pu.percentage * 100) : (i < 2 ? '50,00' : '0,00');
                                            return `
                                            <div class="flex items-center gap-3 p-3 rounded-lg" style="background: #f1f3f4;">
                                                <input type="checkbox" id="u_${u.id}" class="w-5 h-5" style="accent-color: #1a73e8;" ${checked ? 'checked' : ''}>
                                                <label for="u_${u.id}" class="flex-1">${u.name}</label>
                                                <input type="text" id="p_${u.id}" value="${pct}" 
                                                    class="w-24 px-3 py-2 border rounded-lg text-right">
                                                <span>%</span>
                                            </div>`;
                                        }).join('')}
                                    </div>
                                    <p class="text-sm mt-2" style="color: #5f6368;">Total: <span id="totPct" class="font-bold">100,00</span>%</p>
                                </div>
                                <div id="profError" class="hidden text-red-600 text-sm"></div>
                            </div>
                            
                            <!-- Footer -->
                            <div class="p-4 flex gap-3" style="border-top: 1px solid #dadce0; flex-shrink: 0;">
                                <button type="button" onclick="closeModal()" class="flex-1 py-3" style="background: #f1f3f4; color: #1a73e8; font-weight: 500; border-radius: 20px; border: none;">Cancelar</button>
                                <button type="submit" class="flex-1 py-3" style="background: #1a73e8; color: white; font-weight: 500; border-radius: 20px; border: none;">${profile ? 'Salvar' : 'Salvar'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            `;
            
            const updateTotal = () => {
                let tot = 0;
                users.forEach(u => {
                    if (document.getElementById(`u_${u.id}`).checked) {
                        const val = document.getElementById(`p_${u.id}`).value.replace(/\./g, '').replace(',', '.');
                        tot += parseFloat(val) || 0;
                    }
                });
                document.getElementById('totPct').textContent = formatBRL(tot);
                document.getElementById('totPct').className = Math.abs(tot - 100) < 0.1 ? 'font-bold text-green-600' : 'font-bold text-red-600';
            };
            
            users.forEach(u => {
                document.getElementById(`u_${u.id}`).onchange = updateTotal;
                document.getElementById(`p_${u.id}`).oninput = updateTotal;
            });
            
            document.getElementById('profileForm').onsubmit = async (e) => {
                e.preventDefault();
                
                const submitBtn = e.target.querySelector('button[type="submit"]');
                if (submitBtn.disabled) return;
                submitBtn.disabled = true;
                const originalText = submitBtn.textContent;
                submitBtn.textContent = 'Salvando...';
                
                try {
                    const profileUsers = users
                        .filter(u => document.getElementById(`u_${u.id}`).checked)
                        .map(u => {
                            const val = document.getElementById(`p_${u.id}`).value.replace(/\./g, '').replace(',', '.');
                            return {
                                user_id: u.id,
                                percentage: parseFloat(val) / 100
                            };
                        });
                    
                    const total = profileUsers.reduce((s, u) => s + u.percentage, 0);
                    if (Math.abs(total - 1) > 0.001) throw new Error('Soma deve ser 100%');
                    if (!profileUsers.length) throw new Error('Selecione um usuário');
                    
                    const data = {
                        name: document.getElementById('prof_name').value,
                        description: '',
                        emoji: document.getElementById('prof_emoji').value || '⚖️',
                        users: profileUsers
                    };
                    
                    // Se é edição, verificar se os percentuais mudaram
                    if (profile) {
                        const pctChanged = profileUsers.some(pu => {
                            const orig = profile.users.find(x => x.user_id === pu.user_id);
                            return !orig || Math.abs(orig.percentage - pu.percentage) > 0.0001;
                        }) || profile.users.some(ou => !profileUsers.find(pu => pu.user_id === ou.user_id));
                        
                        if (pctChanged) {
                            // Buscar meses com despesas neste perfil
                            submitBtn.textContent = 'Buscando meses...';
                            let expenseMonths = [];
                            try {
                                expenseMonths = await api(`${API}/profiles/${profile.id}/expense-months`);
                            } catch (_) {}
                            
                            if (expenseMonths.length > 0) {
                                // Mostrar seletor de mês inline
                                submitBtn.disabled = false;
                                submitBtn.textContent = originalText;
                                
                                // Inserir seletor após o profError
                                const errorDiv = document.getElementById('profError');
                                const existing = document.getElementById('fromMonthSection');
                                if (existing) existing.remove();
                                
                                const section = document.createElement('div');
                                section.id = 'fromMonthSection';
                                section.style.cssText = 'margin-top:12px; padding:16px; border-radius:12px; border:1px solid #f9ab00; background:#fff8e1;';
                                section.setAttribute('data-dark-aware', '1');
                                section.innerHTML = `
                                    <p class="from-month-title" style="font-size:13px; font-weight:500; color:#b06000; margin:0 0 10px 0;">
                                        ⚠️ Os percentuais foram alterados. A partir de qual mês aplicar a mudança?
                                    </p>
                                    <p style="font-size:12px; color:#5f6368; margin:0 0 10px 0;">
                                        Splits anteriores ao mês escolhido serão mantidos como histórico.
                                    </p>
                                    <div style="display:flex; gap:10px; align-items:center;">
                                        <select id="fromMonthSelect" style="flex:1; padding:8px 12px; border:1px solid #dadce0; border-radius:8px; font-size:14px; background:white; color:#202124;">
                                            ${expenseMonths.map(m => `<option value="${m.value}">${m.label}</option>`).join('')}
                                        </select>
                                        <button type="button" id="confirmFromMonthBtn"
                                            style="padding:8px 20px; background:#1a73e8; color:white; border:none; border-radius:12px; font-size:14px; font-weight:500; cursor:pointer; white-space:nowrap; flex-shrink:0;">
                                            Confirmar
                                        </button>
                                    </div>
                                `;
                                errorDiv.parentNode.insertBefore(section, errorDiv);
                                section.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                                
                                // Capturar dados antes do onclick
                                const capturedProfileId = profile.id;
                                const capturedData = data;
                                
                                document.getElementById('confirmFromMonthBtn').onclick = async () => {
                                    const fromMonth = document.getElementById('fromMonthSelect').value;
                                    const confirmBtn = document.getElementById('confirmFromMonthBtn');
                                    const errorDiv2 = document.getElementById('profError');
                                    confirmBtn.disabled = true;
                                    confirmBtn.textContent = 'Salvando...';
                                    try {
                                        // Um único PUT com from_month — backend faz tudo numa transação
                                        await api(`${API}/profiles/${capturedProfileId}`, {
                                            method: 'PUT',
                                            body: JSON.stringify({ ...capturedData, from_month: fromMonth })
                                        });
                                        closeModal();
                                        invalidateStaticCache();
                                        invalidateCache();
                                        loadProfiles();
                                        loadSidebarProfiles();
                                        loadDashboardData();
                                    } catch (err) {
                                        errorDiv2.textContent = err.message;
                                        errorDiv2.classList.remove('hidden');
                                        confirmBtn.disabled = false;
                                        confirmBtn.textContent = 'Confirmar';
                                    }
                                };
                                return; // Aguardar confirmação do usuário
                            }
                            // Sem despesas: salva normalmente (apenas muda o perfil)
                        }
                    }
                    
                    // Criação ou edição sem mudança de %: salvar normalmente
                    const url = profile ? `${API}/profiles/${profile.id}` : `${API}/profiles`;
                    const method = profile ? 'PUT' : 'POST';
                    await api(url, { method, body: JSON.stringify(data) });
                    closeModal();
                    invalidateStaticCache();
                    loadProfiles();
                    loadSidebarProfiles();
                    loadDashboardData();
                } catch (err) {
                    document.getElementById('profError').textContent = err.message;
                    document.getElementById('profError').classList.remove('hidden');
                    submitBtn.disabled = false;
                    submitBtn.textContent = originalText;
                }
            };
        }

        function editProfile(id) {
            showProfileModal(id);
        }

        async function showUserModal(userId = null) {
            // Se for o próprio usuário, buscar dados frescos do servidor
            let usr = userId ? byId(users, userId) : null;
            if (userId) {
                try {
                    const freshList = await api(`${API}/users`);
                    const freshUsr = freshList.find(u => u.id === userId);
                    if (freshUsr) usr = freshUsr;
                } catch(e) { /* usa cache */ }
            }
            const isOwnProfile = usr && usr.id === user.id;
            const canEditAdmin = user.is_admin;
            const isDark = document.body.classList.contains('dark-mode');

            // Dark-mode aware colors
            const modalBg     = isDark ? '#2d2e30' : 'white';
            const headerBg    = isDark ? '#35363a' : '#e8f0fe';
            const labelColor  = isDark ? '#9aa0a6' : '#5f6368';
            const textColor   = isDark ? '#e8eaed' : '#202124';
            const inputBg     = isDark ? '#3c4043' : 'white';
            const inputBorder = isDark ? '#5f6368' : '#dadce0';
            const optBg       = isDark ? '#3c4043' : '#f8f9fa';
            const optSelBg    = isDark ? '#8ab4f8' : '#e8f0fe';
            const optBorder   = isDark ? '#8ab4f8' : '#1a73e8';
            const optSelText  = isDark ? '#202124' : '#1a73e8';
            const dividerColor= isDark ? '#5f6368' : '#dadce0';
            const checkboxBg  = isDark ? '#3c4043' : '#f1f3f4';

            const prefPaymentId = usr?.preferred_payment_method || null;
            const prefBalanceId = usr?.preferred_balance_method || null;

            const _savedScrollY = window.scrollY;
            document.body.classList.add('modal-open');
            document.body.style.top = `-${_savedScrollY}px`;
            document.getElementById('modalContainer').innerHTML = `
                <div class="fixed inset-0 flex items-center justify-center z-50" style="background: rgba(0,0,0,0.32); backdrop-filter: blur(4px); padding: 2rem 1rem;">
                    <div class="w-full max-w-md overflow-hidden flex flex-col" style="border-radius: 28px; background: ${modalBg}; box-shadow: 0 4px 8px 3px rgba(60,64,67,0.15), 0 1px 3px rgba(60,64,67,0.3); max-height: calc(100vh - 4rem); max-height: calc(100dvh - 4rem);">
                        <!-- Header -->
                        <div style="background: ${headerBg}; padding: 1.25rem 1.5rem; border-radius: 28px 28px 0 0; flex-shrink: 0;">
                            <div class="flex justify-between items-center">
                                <div class="flex items-center gap-3">
                                    <div style="width: 40px; height: 40px; background: #d2e3fc; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                        <span style="font-size: 1.1rem;">👤</span>
                                    </div>
                                    <h2 style="font-size: 1.25rem; font-weight: 500; color: ${textColor};">${usr ? 'Editar' : 'Adicionar'} usuário</h2>
                                </div>
                                <button onclick="closeModal()" style="width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: transparent; border: none; cursor: pointer;">
                                    <span style="font-size: 1.5rem; color: ${labelColor};">✕</span>
                                </button>
                            </div>
                        </div>
                        
                        <!-- Body -->
                        <form id="userForm" class="flex flex-col" style="flex: 1; overflow: hidden;">
                            <div class="p-6 space-y-4" style="overflow-y: auto; flex: 1; scrollbar-width: thin; scrollbar-color: #dadce0 transparent;">
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Nome *</label>
                                    <input type="text" id="usr_name" required value="${usr?.name || ''}" class="w-full px-4 py-2 border rounded-lg" style="background: ${inputBg}; color: ${textColor}; border-color: ${inputBorder};">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Email *</label>
                                    <input type="email" id="usr_email" required value="${usr?.email || ''}" class="w-full px-4 py-2 border rounded-lg" style="background: ${inputBg}; color: ${textColor}; border-color: ${inputBorder};">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Emoji</label>
                                    <input type="text" id="usr_emoji" value="${usr?.emoji || '👤'}" maxlength="10" 
                                        class="w-20 px-4 border rounded-lg text-center text-xl" placeholder="👤" style="height:42px;background: ${inputBg}; color: ${textColor}; border-color: ${inputBorder};">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Senha ${usr ? '(deixe vazio para manter)' : '*'}</label>
                                    <input type="password" id="usr_pass" ${usr ? '' : 'required'} minlength="6" class="w-full px-4 py-2 border rounded-lg" style="background: ${inputBg}; color: ${textColor}; border-color: ${inputBorder};">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Cor</label>
                                    <input type="color" id="usr_color" value="${usr?.color || '#3B82F6'}" class="w-full px-2 border rounded-lg" style="height:42px;border-color: ${inputBorder};">
                                </div>
                                ${canEditAdmin ? `
                                <div class="flex items-center gap-3 p-3 rounded-lg" style="background: ${checkboxBg};">
                                    <input type="checkbox" id="usr_admin" class="w-5 h-5" style="accent-color: #1a73e8;" ${usr?.is_admin ? 'checked' : ''}>
                                    <label for="usr_admin" style="color: ${textColor};">Administrador</label>
                                </div>` : ''}

                                <!-- Preferências do usuário -->
                                <div style="border-top: 1px solid ${dividerColor}; padding-top: 1rem; margin-top: 0.5rem;">
                                    <p class="text-sm font-medium mb-3" style="color: ${textColor};">⚙️ Preferências</p>

                                    <!-- Método de pagamento preferencial -->
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Método de pagamento preferencial</label>
                                        <input type="hidden" id="usr_payment_value" value="${prefPaymentId || ''}">
                                        <div class="flex gap-2 flex-wrap">
                                            ${userPms(usr?.id || user.id).map(pm => {
                                                const on = pm.id === prefPaymentId;
                                                const imgHtml = pm.icon_path ? `<img src="${pm.icon_path}" style="width:26px;height:26px;object-fit:contain;">` : `<span style="width:26px;height:26px;display:inline-flex;align-items:center;justify-content:center;border-radius:50%;background:${pm.color||'#999'};font-size:12px;">💳</span>`;
                                                return `<label class="flex flex-col items-center gap-1 cursor-pointer tgt-pm-label" onclick="event.stopPropagation()">
                                                    <div class="pm-option usr-pay-btn ${on?'selected':''}" data-pm-id="${pm.id}"
                                                         style="width:44px;height:44px;border-radius:12px;border:2px solid ${on?optBorder:'transparent'};display:flex;align-items:center;justify-content:center;background:${on?optSelBg:optBg};transition:.15s;"
                                                         onclick="selectUserPayment(${pm.id})">
                                                        ${imgHtml}
                                                    </div>
                                                    <span class="text-xs" style="max-width:48px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${pm.description}</span>
                                                </label>`;
                                            }).join('')}
                                        </div>
                                    </div>

                                    <!-- Método de saldo preferencial -->
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Método de saldo / reembolso</label>
                                        <input type="hidden" id="usr_balance_method" value="${prefBalanceId || ''}">
                                        <div class="flex gap-2 flex-wrap">
                                            ${userPms(usr?.id || user.id).map(pm => {
                                                const on = pm.id === prefBalanceId;
                                                const imgHtml = pm.icon_path ? `<img src="${pm.icon_path}" style="width:26px;height:26px;object-fit:contain;">` : `<span style="width:26px;height:26px;display:inline-flex;align-items:center;justify-content:center;border-radius:50%;background:${pm.color||'#999'};font-size:12px;">💳</span>`;
                                                return `<label class="flex flex-col items-center gap-1 cursor-pointer tgt-pm-label" onclick="event.stopPropagation()">
                                                    <div class="pm-option usr-bal-btn ${on?'selected':''}" data-pm-id="${pm.id}"
                                                         style="width:44px;height:44px;border-radius:12px;border:2px solid ${on?optBorder:'transparent'};display:flex;align-items:center;justify-content:center;background:${on?optSelBg:optBg};transition:.15s;"
                                                         onclick="selectUserBalance(${pm.id})">
                                                        ${imgHtml}
                                                    </div>
                                                    <span class="text-xs" style="max-width:48px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${pm.description}</span>
                                                </label>`;
                                            }).join('')}
                                        </div>
                                    </div>

                                    <!-- Perfil de divisão preferencial -->
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Perfil preferencial</label>
                                        <select id="usr_pref_profile" class="w-full px-4 py-2 border rounded-lg" style="background: ${inputBg}; color: ${textColor}; border-color: ${inputBorder};">
                                            <option value="">Nenhum</option>
                                            ${profiles.filter(p => p.users?.some(u => u.user_id === (usr?.id || user.id))).map(p => '<option value="' + p.id + '" ' + (p.id === (usr?.preferred_split_profile_id || null) ? 'selected' : '') + '>' + (p.emoji || '⚖️') + ' ' + p.name + '</option>').join('')}
                                        </select>
                                    </div>

                                    <!-- Localidade IPCA preferencial -->
                                    <div class="mb-2">
                                        <label class="block text-sm font-medium mb-2" style="color: ${labelColor};">Localidade IPCA</label>
                                        <select id="usr_ipca_location" class="w-full px-4 py-2 border rounded-lg" style="background: ${inputBg}; color: ${textColor}; border-color: ${inputBorder};">
                                            <option value="">Carregando...</option>
                                        </select>
                                    </div>
                                </div>

                                <div id="usrError" class="hidden text-red-600 text-sm"></div>
                            </div>
                            
                            <!-- Footer -->
                            <div class="p-4 flex gap-3" style="border-top: 1px solid ${dividerColor}; flex-shrink: 0;">
                                <button type="button" onclick="closeModal()" class="flex-1 py-3" style="background: #f1f3f4; color: #1a73e8; font-weight: 500; border-radius: 20px; border: none;">Cancelar</button>
                                <button type="submit" class="flex-1 py-3" style="background: #1a73e8; color: white; font-weight: 500; border-radius: 20px; border: none;">Salvar</button>
                            </div>
                        </form>
                    </div>
                </div>
            `;
            
            // Carregar localidades IPCA no select
            api(`${API}/inflation/locations`).then(locs => {
                const sel = document.getElementById('usr_ipca_location');
                if (!sel) return;
                const currentLoc = usr?.preferred_ipca_location || 1;
                sel.innerHTML = locs.map(l => `<option value="${l.code}" ${l.code === currentLoc ? 'selected' : ''}>${l.name}</option>`).join('');
            }).catch(() => {
                const sel = document.getElementById('usr_ipca_location');
                if (sel) sel.innerHTML = '<option value="1">Brasil</option>';
            });

            document.getElementById('userForm').onsubmit = async (e) => {
                e.preventDefault();
                
                const submitBtn = e.target.querySelector('button[type="submit"]');
                if (submitBtn.disabled) return;
                submitBtn.disabled = true;
                const originalText = submitBtn.textContent;
                submitBtn.textContent = 'Salvando...';
                
                try {
                    if (usr) {
                        const data = {
                            name: document.getElementById('usr_name').value,
                            email: document.getElementById('usr_email').value,
                            color: document.getElementById('usr_color').value,
                            emoji: document.getElementById('usr_emoji').value || '👤',
                            preferred_payment_method: parseInt(document.getElementById('usr_payment_value')?.value) || null,
                            preferred_balance_method: parseInt(document.getElementById('usr_balance_method')?.value) || null,
                            preferred_ipca_location: parseInt(document.getElementById('usr_ipca_location').value) || 1,
                            preferred_split_profile_id: parseInt(document.getElementById('usr_pref_profile')?.value) || null,
                        };
                        if (canEditAdmin) data.is_admin = document.getElementById('usr_admin').checked;
                        const pass = document.getElementById('usr_pass').value;
                        if (pass) data.password = pass;
                        
                        await api(`${API}/users/${usr.id}`, {
                            method: 'PUT',
                            body: JSON.stringify(data)
                        });
                    } else {
                        const params = new URLSearchParams({
                            name: document.getElementById('usr_name').value,
                            email: document.getElementById('usr_email').value,
                            password: document.getElementById('usr_pass').value,
                            color: document.getElementById('usr_color').value,
                            emoji: document.getElementById('usr_emoji').value || '👤',
                            is_admin: document.getElementById('usr_admin')?.checked || false
                        });
                        await api(`${API}/users?${params}`, { method: 'POST' });
                    }
                    closeModal();
                    invalidateStaticCache();
                    // Se salvou o próprio perfil, atualiza objeto user em memória
                    if (usr && usr.id === user.id) await refreshUserFromServer();
                    loadUsers();
                    loadSidebarUsers();
                    loadDashboardData();
                } catch (err) {
                    document.getElementById('usrError').textContent = err.message;
                    document.getElementById('usrError').classList.remove('hidden');
                    submitBtn.disabled = false;
                    submitBtn.textContent = originalText;
                }
            };
        }

        function editUser(id) {
            showUserModal(id);
        }

        // ============================================================================
