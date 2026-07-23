        async function loadExpenses() {
            const month=document.getElementById('expenseMonthFilter')?.value||'';
            const paidByFilter=document.getElementById('expensePaidByFilter')?.value||'';
            const profileFilter=document.getElementById('expenseProfileFilter')?.value||'';
            const searchQ=(document.getElementById('expenseSearch')?.value||'').trim().toLowerCase();
            const {expenses}=await fetchExpensesWithCache(month);
            let list=[...expenses];
            if(paidByFilter)list=list.filter(e=>e.paid_by_user_id===parseInt(paidByFilter));
            if(profileFilter)list=list.filter(e=>e.split_profile_id===parseInt(profileFilter));
            if(searchQ)list=list.filter(e=>e.description?.toLowerCase().includes(searchQ));
            if(activeExpensePmFilter.length>0){
                list=list.filter(e=>{
                    const effectivePmId=e.paid_by_user_id===user.id
                        ?e.payment_method_id
                        :user.preferred_balance_method;
                    return activeExpensePmFilter.includes(effectivePmId);
                });
            }
            
            // Separar passado/hoje de futuro — usa data LOCAL (toISOString seria UTC e quebraria perto da meia-noite)
            const _now = new Date();
            const _todayStr = `${_now.getFullYear()}-${String(_now.getMonth()+1).padStart(2,'0')}-${String(_now.getDate()).padStart(2,'0')}`;
            const pastList = [], futureList = [];
            list.forEach(e => {
                const dateStr = e.original_date || e.expense_date;
                (dateStr > _todayStr ? futureList : pastList).push(e);
            });

            // Passado: mais recentes primeiro; futuro: mais próximo primeiro
            const sortDesc = (a, b) => {
                const da = a.original_date || a.expense_date;
                const db = b.original_date || b.expense_date;
                const cmp = new Date(db + 'T12:00:00') - new Date(da + 'T12:00:00');
                return cmp !== 0 ? cmp : b.id - a.id;
            };
            pastList.sort(sortDesc);
            futureList.sort((a, b) => -sortDesc(a, b));

            const renderExpense = (e) => {
                // ✅ Emoji antes do nome
                const category = byId(categories, e.category_id);
                const emoji = category?.icon || '📁';
                
                // Buscar nome e emoji do perfil e do usuário pagador
                const profile = byId(profiles, e.split_profile_id);
                const profileName = profile?.name || 'Perfil desconhecido';
                const profileEmoji = profile?.emoji || '⚖️';
                const paidUser = byId(users, e.paid_by_user_id);
                const paidEmoji = paidUser?.emoji || '👤';
                
                const _ePm = pmById(e.payment_method_id);
                const pmIconHtml = _ePm && _ePm.icon_path
                    ? `<img src="${_ePm.icon_path}" style="width:20px;height:20px;object-fit:contain;vertical-align:middle;">`
                    : (_ePm ? `<span style="display:inline-flex;width:20px;height:20px;align-items:center;justify-content:center;border-radius:50%;background:${_ePm.color||'#999'};flex-shrink:0;vertical-align:middle;"></span>` : '');
                return `
                <div class="bg-white rounded-lg shadow p-4 mb-4">
                    <div class="flex justify-between items-stretch">
                        <div class="flex-1 min-w-0">
                            <p class="font-bold text-lg"><span class="expense-info-badge" style="font-size:14px;">${emoji}</span> ${e.description}</p>
                            <p class="text-sm text-gray-600">${new Date((e.original_date || e.expense_date) + 'T12:00:00').toLocaleDateString('pt-BR')}${e.is_recurring ? ' <span style="font-size:11px;">🔁</span>' : ''}${e.original_date && e.original_date !== e.expense_date ? ' <span style="font-size:11px;">➡️</span>' : ''}</p>
                            <div style="display:flex;flex-direction:column;gap:3px;margin-top:3px;align-items:flex-start;"><span class="expense-info-badge">${paidEmoji} ${e.paid_by_name}</span><span class="expense-info-badge">${profileEmoji} ${profileName}</span></div>
                            ${e.notes ? `<p class="text-sm text-gray-500 mt-2">${e.notes}</p>` : ''}
                        </div>
                        <div class="text-right ml-4 flex flex-col justify-between">
                            ${e.installments > 1
                                ? (() => {
                                    const [yr, mn] = month.split('-').map(Number);
                                    const split = e.splits?.find(s => { const d = new Date(s.due_date+'T00:00:00'); return d.getFullYear()===yr && d.getMonth()+1===mn && s.user_id===user.id; });
                                    const instNum = split?.installment_number || '';
                                    return `<div>
                                        <p class="text-2xl font-bold text-blue-600" style="display:flex;align-items:center;gap:5px;justify-content:flex-end;">
                                            ${instNum ? `<span class="inst-label" style="font-size:11px;font-weight:normal;">(${instNum} / ${e.installments})</span>` : ''}R$ ${formatBRL(e.total_amount / e.installments)} ${pmIconHtml}</p>
                                        <p class="text-sm text-gray-600">R$ ${formatBRL(e.total_amount)} · ${e.installments}x</p>
                                    </div>`;
                                })()
                                : `<p class="text-2xl font-bold text-blue-600" style="display:flex;align-items:center;gap:5px;justify-content:flex-end;">R$ ${formatBRL(e.total_amount)} ${pmIconHtml}</p>`
                            }
                            <div class="flex gap-2 justify-end">
                                ${(_ePm?.is_card && (user.is_admin || e.created_by_user_id === user.id)) ? `<button onclick="postponeExpense(${e.id})" class="text-gray-600 text-sm" title="Jogar pro próximo mês">➡️</button>` : ''}
                                ${(user.is_admin || e.created_by_user_id === user.id) ? `<button onclick="editExpense(${e.id})" class="text-blue-600 text-sm">✏️</button>` : ''}
                                ${(user.is_admin || e.created_by_user_id === user.id) ? `<button onclick="deleteItem('expenses', ${e.id})" class="text-red-600 text-sm">🗑️</button>` : ''}
                            </div>
                        </div>
                    </div>
                </div>
            `;
            };

            const futureDivider = futureList.length ? `
                <div class="flex items-center gap-2 my-4">
                    <div style="flex:1;height:1px;background:#dadce0;"></div>
                    <span class="text-sm font-semibold px-2 whitespace-nowrap" style="color:#5f6368;">📅 Lançamentos futuros</span>
                    <div style="flex:1;height:1px;background:#dadce0;"></div>
                </div>` : '';

            const allHtml = pastList.map(renderExpense).join('') + futureDivider + futureList.map(renderExpense).join('');
            document.getElementById('expensesList').innerHTML = allHtml || '<p class="text-gray-500 text-center py-8">Nenhuma despesa</p>';
        }

        window.postponeExpense = async function postponeExpense(id) {
            if (!confirm('Jogar essa despesa para o próximo mês?')) return;
            try {
                await api(`${API}/expenses/${id}/postpone`, { method: 'POST' });
                invalidateCache();
                await loadMonths();
                loadExpenses();
            } catch(e) { alert(e.message || 'Erro ao adiar despesa'); }
        }

        // ── Receitas ──────────────────────────────────────────────────────────

        window._incomeCache = null;

        async function loadIncome() {
            const month = document.getElementById('incomeMonthFilter')?.value || '';
            const searchQ = (document.getElementById('incomeSearch')?.value || '').trim().toLowerCase();

            // Fetch income
            if (!window._incomeCache || window._incomeCache.month !== month) {
                window._incomeCache = { month, items: await api(`${API}/income?month=${month}`) };
            }
            let list = [...window._incomeCache.items];
            if (searchQ) list = list.filter(i => i.description.toLowerCase().includes(searchQ));

            // Totalizador — receitas
            const totalIncome = window._incomeCache.items.reduce((s, i) => s + i.amount, 0);

            // Totalizador — despesas do mês (from existing cache)
            let totalExpenses = 0;
            try {
                const { expenses } = await fetchExpensesWithCache(month);
                totalExpenses = expenses.reduce((s, e) => {
                    const amt = e.installments > 1 ? e.total_amount / e.installments : e.total_amount;
                    return s + amt;
                }, 0);
            } catch(_) {}

            const balance = totalIncome - totalExpenses;
            const fmtG = v => formatBRL(Math.abs(v));

            const incEl = document.getElementById('incomeSumIncome');
            const expEl = document.getElementById('incomeSumExpenses');
            const balEl = document.getElementById('incomeSumBalance');
            if (incEl) incEl.textContent = fmtG(totalIncome);
            if (expEl) expEl.textContent = fmtG(totalExpenses);
            if (balEl) {
                balEl.textContent = (balance < 0 ? '-' : '') + fmtG(balance);
                balEl.style.cssText = `font-size:0.95rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;color:${balance >= 0 ? '#34a853' : '#ea4335'} !important;`;
            }

            const isDark = document.body.classList.contains('dark-mode');
            const cardBg = isDark ? '#3c4043' : '#fff';
            const txtColor = isDark ? '#e8eaed' : '#202124';
            const subColor = isDark ? '#9aa0a6' : '#5f6368';
            const borderColor = isDark ? '#5f6368' : '#e8eaed';

            document.getElementById('incomeList').innerHTML = list.length ? list.map(inc => `
                <div class="bg-white rounded-lg shadow p-4 mb-4">
                    <div class="flex justify-between items-stretch">
                        <div class="flex-1">
                            <p class="font-bold text-lg">${inc.description}</p>
                            <p class="text-sm text-gray-600">${new Date(inc.income_date+'T12:00:00').toLocaleDateString('pt-BR')}</p>
                            ${inc.notes ? `<p class="text-sm text-gray-500 mt-2">${inc.notes}</p>` : ''}
                        </div>
                        <div class="text-right ml-4 flex flex-col justify-between">
                            <p class="text-2xl font-bold text-blue-600">R$ ${formatBRL(inc.amount)}</p>
                            <div class="flex gap-2 justify-end">
                                <button onclick="showIncomeModal(${inc.id})" class="text-blue-600 text-sm">✏️</button>
                                <button onclick="deleteItem('income',${inc.id})" class="text-red-600 text-sm">🗑️</button>
                            </div>
                        </div>
                    </div>
                </div>
            `).join('') : '<p class="text-gray-500 text-center py-8">Nenhuma receita neste mês</p>';
        }

        // ── Agente ────────────────────────────────────────────────────────────

        let _agentHistory = [];

        function _agentMarkdown(text) {
            text = text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
            // Markdown tables: consecutive lines starting and ending with |
            text = text.replace(/((?:\|[^\n]+\|\n?)+)/g, block => {
                const lines = block.trim().split('\n').map(l => l.trim()).filter(Boolean);
                if (lines.length < 2 || !/^\|[\s|:_-]+\|$/.test(lines[1])) return block;
                const parseRow = l => l.replace(/^\||\|$/g,'').split('|').map(c => c.trim());
                const headers = parseRow(lines[0]);
                const rows = lines.slice(2).map(parseRow);
                const th = headers.map(h=>`<th>${h}</th>`).join('');
                const tr = rows.map(r=>`<tr>${r.map(c=>`<td>${c}</td>`).join('')}</tr>`).join('');
                return `<table class="agent-table"><thead><tr>${th}</tr></thead><tbody>${tr}</tbody></table>`;
            });
            return text
                .replace(/^#{1,3}\s+(.+)$/gm, '<strong>$1</strong>')
                .replace(/\*\*([^*\n]+)\*\*/g, '<strong>$1</strong>')
                .replace(/^[ \t]*[-*]\s+(.+)$/gm, '&nbsp;&nbsp;• $1')
                .replace(/^[ \t]*\d+\.\s+(.+)$/gm, (_, p1) => `&nbsp;&nbsp;• ${p1}`)
                .replace(/\n/g,'<br>');
        }

        function _renderAgentMessages() {
            const isDark = document.body.classList.contains('dark-mode');
            const container = document.getElementById('agentMessages');
            if (!container) return;
            const intro = container.querySelector('.agent-intro');
            const msgs = _agentHistory.map(m => {
                const isUser = m.role === 'user';
                const bg = isUser
                    ? (isDark ? '#1e3a5f' : '#e8f0fe')
                    : (isDark ? '#3c4043' : '#f1f3f4');
                const color = isDark ? '#e8eaed' : '#202124';
                const align = isUser ? 'flex-end' : 'flex-start';
                return `<div style="display:flex;justify-content:${align};">
                    <div style="max-width:85%;background:${bg};color:${color};border-radius:${isUser?'18px 18px 4px 18px':'18px 18px 18px 4px'};padding:10px 14px;font-size:14px;line-height:1.5;">${_agentMarkdown(m.text)}</div>
                </div>`;
            }).join('');
            container.innerHTML = (intro ? intro.outerHTML : '<div class="agent-intro" style="text-align:center;padding:24px 0 8px;"><span style="font-size:40px;">🤖</span><p style="font-size:14px;color:#5f6368;margin-top:8px;">Olá! Posso analisar suas despesas,<br>receitas e metas. O que quer saber?</p></div>') + msgs;
            container.scrollTop = container.scrollHeight;
        }

        function agentAutoResize(el) {
            el.style.height = 'auto';
            el.style.height = Math.min(el.scrollHeight, 100) + 'px';
            el.style.overflowY = el.scrollHeight > 100 ? 'auto' : 'hidden';
        }

        window.sendAgentMessage = async function sendAgentMessage() {
            const input = document.getElementById('agentInput');
            const btn = document.getElementById('agentSendBtn');
            const msg = (input.value || '').trim();
            if (!msg) return;
            input.value = '';
            input.style.height = 'auto';
            _agentHistory.push({ role: 'user', text: msg });
            _renderAgentMessages();
            btn.disabled = true;
            btn.style.opacity = '0.5';
            // Typing indicator
            const container = document.getElementById('agentMessages');
            const isDark = document.body.classList.contains('dark-mode');
            const typingBg = isDark ? '#3c4043' : '#f1f3f4';
            const typingDiv = document.createElement('div');
            typingDiv.id = 'agentTyping';
            typingDiv.style.cssText = 'display:flex;justify-content:flex-start;';
            typingDiv.innerHTML = `<div style="background:${typingBg};border-radius:18px 18px 18px 4px;padding:10px 16px;"><span style="display:inline-flex;gap:4px;align-items:center;"><span class="typing-dot"></span><span class="typing-dot"></span><span class="typing-dot"></span></span></div>`;
            container.appendChild(typingDiv);
            container.scrollTop = container.scrollHeight;
            try {
                const historyToSend = _agentHistory.slice(0, -1);
                const resp = await api(`${API}/agent/chat`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: msg, history: historyToSend })
                });
                _agentHistory.push({ role: 'model', text: resp.reply });
            } catch(e) {
                _agentHistory.push({ role: 'model', text: `Erro: ${e.message || 'Não foi possível contatar o agente.'}` });
            } finally {
                typingDiv.remove();
                btn.disabled = false;
                btn.style.opacity = '1';
                _renderAgentMessages();
            }
        }


        window.showIncomeModal = async function showIncomeModal(incomeId = null) {
            const _savedScrollY = window.scrollY;
            document.body.classList.add('modal-open');
            document.body.style.top = `-${_savedScrollY}px`;

            const isDark = document.body.classList.contains('dark-mode');
            const txt    = isDark ? '#e8eaed' : '#202124';
            const sub    = isDark ? '#9aa0a6' : '#5f6368';
            const border = isDark ? '#5f6368' : '#dadce0';
            const inputBg= isDark ? '#3c4043' : '#fff';

            let inc = null;
            if (incomeId) {
                const cached = window._incomeCache?.items?.find(i => i.id === incomeId);
                inc = cached || await api(`${API}/income/${incomeId}`).catch(() => null);
            }

            const now = new Date();
            const today = `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}-${String(now.getDate()).padStart(2,'0')}`;
            const inputStyle = `width:100%;padding:10px 14px;border:1px solid ${border};border-radius:10px;font-size:0.95rem;background:${inputBg};color:${txt};box-sizing:border-box;`;

            document.getElementById('modalContainer').innerHTML = `
            <div id="incomeModalOverlay" class="modal-overlay fixed inset-0 flex items-center justify-center z-50" style="background:rgba(0,0,0,0.32);backdrop-filter:blur(4px);padding:2rem 1rem;">
              <div class="modal-content bg-white w-full max-w-lg overflow-hidden flex flex-col" style="border-radius:28px;box-shadow:0 4px 8px 3px rgba(60,64,67,0.15),0 1px 3px rgba(60,64,67,0.3);max-height:calc(100vh - 4rem);max-height:calc(100dvh - 4rem);">
                <div style="background:#e8f0fe;padding:1.25rem 1.5rem;border-radius:28px 28px 0 0;flex-shrink:0;">
                  <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div style="display:flex;align-items:center;gap:12px;">
                      <div style="width:40px;height:40px;background:#d2e3fc;border-radius:50%;display:flex;align-items:center;justify-content:center;">
                        <span style="font-size:1.2rem;">💰</span>
                      </div>
                      <h2 style="font-size:1.1rem;font-weight:500;color:#202124;margin:0;">${inc ? 'Editar receita' : 'Adicionar receita'}</h2>
                    </div>
                    <button onclick="closeModal()" style="width:36px;height:36px;border-radius:50%;background:rgba(0,0,0,0.08);border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:1.1rem;color:#5f6368;">✕</button>
                  </div>
                </div>
                <div style="flex:1;overflow-y:auto;padding:1.5rem;">
                  <form onsubmit="saveIncome(event,${incomeId||'null'})" style="display:flex;flex-direction:column;gap:16px;">
                    <div>
                      <label style="font-size:0.82rem;color:${sub};display:block;margin-bottom:5px;">Data</label>
                      <input type="date" id="inc_date" value="${inc?.income_date || today}" required style="${inputStyle}">
                    </div>
                    <div>
                      <label style="font-size:0.82rem;color:${sub};display:block;margin-bottom:5px;">Descrição</label>
                      <input type="text" id="inc_desc" value="${inc?.description || ''}" placeholder="Ex: Salário, Freelance..." required style="${inputStyle}">
                    </div>
                    <div>
                      <label style="font-size:0.82rem;color:${sub};display:block;margin-bottom:5px;">Valor (R$)</label>
                      <input type="number" id="inc_amount" value="${inc?.amount || ''}" placeholder="0,00" step="0.01" min="0.01" required style="${inputStyle}">
                    </div>
                    <div>
                      <label style="font-size:0.82rem;color:${sub};display:block;margin-bottom:5px;">Notas (opcional)</label>
                      <textarea id="inc_notes" placeholder="Observações..." rows="2" style="${inputStyle};resize:vertical;">${inc?.notes || ''}</textarea>
                    </div>
                    <button type="submit" style="width:100%;padding:13px;border:none;border-radius:10px;background:#1a73e8;color:#fff;font-size:0.95rem;font-weight:600;cursor:pointer;margin-top:4px;">
                      ${inc ? 'Salvar alterações' : 'Adicionar receita'}
                    </button>
                  </form>
                </div>
              </div>
            </div>`;
        }

        window.saveIncome = async function saveIncome(event, incomeId) {
            event.preventDefault();
            const body = {
                description: document.getElementById('inc_desc').value.trim(),
                amount:      parseFloat(document.getElementById('inc_amount').value),
                income_date: document.getElementById('inc_date').value,
                notes:       document.getElementById('inc_notes').value.trim(),
                user_id:     user.id,
            };
            try {
                if (incomeId) {
                    await api(`${API}/income/${incomeId}`, { method: 'PUT', body: JSON.stringify(body) });
                } else {
                    await api(`${API}/income`, { method: 'POST', body: JSON.stringify(body) });
                }
                window._incomeCache = null;
                closeModal();
                loadIncome();
            } catch(e) { alert(e.message || 'Erro ao salvar'); }
        }

