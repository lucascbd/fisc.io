        // ── OPEN FINANCE (Pluggy) ────────────────────────────────────────────
        let _ofAccounts = [];
        let _ofTxStore = {};

        function _ofNotify(msg, type) {
            const d = document.createElement('div');
            d.textContent = msg;
            const bg = type === 'error' ? '#d93025' : type === 'success' ? '#1e8e3e' : '#1a73e8';
            d.style.cssText = `position:fixed;bottom:80px;left:50%;transform:translateX(-50%);background:${bg};color:#fff;padding:10px 18px;border-radius:20px;font-size:13px;font-weight:500;z-index:9999;box-shadow:0 2px 8px rgba(0,0,0,0.3);pointer-events:none;`;
            document.body.appendChild(d);
            setTimeout(() => d.remove(), 3500);
        }

        async function loadOpenFinance() {
            await _ofLoadAccounts();
        }

        async function _ofLoadAccounts() {
            try {
                const data = await api(`${API}/openfinance/accounts`);
                _ofAccounts = data || [];
                const list = document.getElementById('ofAccountsList');
                if (!_ofAccounts.length) {
                    list.innerHTML = '<p class="text-gray-500 text-sm text-center py-2">Nenhuma conta conectada</p>';
                    document.getElementById('ofFiltersRow').style.display = 'none';
                    document.getElementById('ofTransactionsList').innerHTML = '';
                    return;
                }
                list.innerHTML = _ofAccounts.map(a => `
                    <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 10px;background:#f8f9fa;border-radius:8px;">
                        <div>
                            <div style="font-weight:500;font-size:13px;">${a.account_name}</div>
                            <div style="font-size:11px;color:#5f6368;">${a.account_type}</div>
                        </div>
                        <div style="display:flex;align-items:center;gap:8px;">
                            ${a.payment_method_icon
                                ? `<img src="${a.payment_method_icon}" style="width:22px;height:22px;object-fit:contain;border-radius:4px;" onerror="this.style.display='none'">`
                                : a.payment_method_color
                                    ? `<span style="display:inline-block;width:16px;height:16px;border-radius:50%;background:${a.payment_method_color};flex-shrink:0;"></span>`
                                    : '<span style="font-size:11px;color:#5f6368;">—</span>'}
                            <button onclick="_ofDeleteAccount(${a.id})" style="background:none;border:none;cursor:pointer;color:#d93025;font-size:16px;padding:0 2px;">✕</button>
                        </div>
                    </div>
                `).join('');
                const sel = document.getElementById('ofAccountSelect');
                sel.innerHTML = _ofAccounts.map(a => `<option value="${a.id}">${a.account_name}</option>`).join('');
                document.getElementById('ofFiltersRow').style.cssText = '';
                const today = new Date();
                const from = new Date(today);
                from.setDate(from.getDate() - 30);
                const toEl = document.getElementById('ofDateTo');
                const fromEl = document.getElementById('ofDateFrom');
                if (!toEl.value) toEl.value = today.toISOString().slice(0,10);
                if (!fromEl.value) fromEl.value = from.toISOString().slice(0,10);
                ofLoadTransactions();
            } catch(e) {
                _ofNotify('Erro ao carregar contas: ' + e.message, 'error');
            }
        }

        async function ofConnect() {
            try {
                if (typeof PluggyConnect === 'undefined') {
                    const urls = [
                        'https://cdn.pluggy.ai/pluggy-connect/v2.8.2/pluggy-connect.js',
                        'https://cdn.pluggy.ai/pluggy-connect/latest/pluggy-connect.js',
                    ];
                    let loaded = false;
                    for (const src of urls) {
                        try {
                            await new Promise((resolve, reject) => {
                                const s = document.createElement('script');
                                s.src = src;
                                s.onload = resolve;
                                s.onerror = reject;
                                document.head.appendChild(s);
                            });
                            if (typeof PluggyConnect !== 'undefined') { loaded = true; break; }
                        } catch(_) {}
                    }
                    if (!loaded) throw new Error('Widget Pluggy não disponível. Tente novamente mais tarde.');
                }
                const resp = await api(`${API}/openfinance/connect-token`);
                const connectToken = resp.access_token;
                new PluggyConnect({
                    connectToken,
                    onSuccess: async ({ item }) => { await _ofPickAccounts(item.id); },
                    onError: (err) => _ofNotify('Erro na conexão: ' + (err.message || err), 'error'),
                }).init();
            } catch(e) {
                _ofNotify('Erro: ' + e.message, 'error');
            }
        }

        async function _ofPickAccounts(itemId) {
            try {
                const data = await api(`${API}/openfinance/items/accounts`, { method: 'POST', body: JSON.stringify({ item_id: itemId }) });
                const accounts = data.accounts || [];
                if (!accounts.length) { _ofNotify('Nenhuma conta encontrada no item', 'error'); return; }
                const pms = await api(`${API}/payment-methods`);
                const pmOptions = pms.map(p => `<option value="${p.id}">${p.description}</option>`).join('');
                const rows = accounts.map(a => `
                    <div style="border:1px solid #e0e0e0;border-radius:8px;padding:10px;margin-bottom:8px;">
                        <div style="font-weight:500;font-size:13px;">${a.name}</div>
                        <div style="font-size:11px;color:#5f6368;margin-bottom:6px;">${a.type} • ${a.id}</div>
                        <select id="pmFor_${a.id}" style="width:100%;border:1px solid #ccc;border-radius:6px;padding:4px 8px;font-size:12px;">
                            <option value="">-- Método de pagamento (opcional) --</option>
                            ${pmOptions}
                        </select>
                        <button onclick="_ofSaveAccount('${itemId}','${a.id}','${a.name}','${a.type}')"
                            style="margin-top:6px;background:#1a73e8;color:#fff;border:none;border-radius:6px;padding:4px 12px;font-size:12px;cursor:pointer;width:100%;">
                            Salvar
                        </button>
                    </div>
                `).join('');
                document.getElementById('modalContainer').innerHTML = `
                    <div class="fixed inset-0 flex items-center justify-center z-50" style="background:rgba(0,0,0,0.32);backdrop-filter:blur(4px);padding:1rem;" onclick="if(event.target===this)this.remove()">
                        <div class="bg-white w-full max-w-sm overflow-auto flex flex-col" style="border-radius:20px;box-shadow:0 4px 24px rgba(0,0,0,0.2);max-height:80vh;padding:1.25rem;">
                            <h3 style="font-weight:600;font-size:1rem;margin-bottom:12px;">Contas encontradas</h3>
                            ${rows}
                            <button onclick="document.getElementById('modalContainer').innerHTML=''" style="margin-top:8px;background:#f1f3f4;border:none;border-radius:8px;padding:8px;font-size:13px;cursor:pointer;width:100%;">Fechar</button>
                        </div>
                    </div>`;
            } catch(e) {
                _ofNotify('Erro ao buscar contas: ' + e.message, 'error');
            }
        }

        async function _ofSaveAccount(itemId, accountId, accountName, accountType) {
            const pmId = document.getElementById('pmFor_' + accountId)?.value || null;
            try {
                await api(`${API}/openfinance/accounts`, { method: 'POST', body: JSON.stringify({
                    item_id: itemId,
                    pluggy_account_id: accountId,
                    account_name: accountName,
                    account_type: accountType,
                    payment_method_id: pmId ? parseInt(pmId) : null,
                }) });
                document.getElementById('modalContainer').innerHTML = '';
                _ofNotify('Conta salva!', 'success');
                await _ofLoadAccounts();
            } catch(e) {
                _ofNotify('Erro ao salvar conta: ' + e.message, 'error');
            }
        }

        async function _ofDeleteAccount(id) {
            if (!confirm('Remover esta conta?')) return;
            try {
                await api(`${API}/openfinance/accounts/${id}`, { method: 'DELETE' });
                _ofNotify('Conta removida', 'success');
                await _ofLoadAccounts();
            } catch(e) {
                _ofNotify('Erro: ' + e.message, 'error');
            }
        }

        async function ofLoadTransactions() {
            const accId = document.getElementById('ofAccountSelect').value;
            const from = document.getElementById('ofDateFrom').value;
            const to = document.getElementById('ofDateTo').value;
            if (!accId || !from || !to) return;
            const list = document.getElementById('ofTransactionsList');
            list.innerHTML = '<p class="text-center text-sm text-gray-500 py-4">Carregando...</p>';
            try {
                const data = await api(`${API}/openfinance/transactions?account_id=${accId}&date_from=${from}&date_to=${to}`);
                _ofTxStore = {};
                (data.transactions || []).forEach(tx => { _ofTxStore[tx.id] = tx; });
                _ofRenderTransactions(data.transactions || []);
            } catch(e) {
                list.innerHTML = `<p class="text-center text-sm py-4" style="color:#d93025;">${e.message}</p>`;
            }
        }

        function _ofRenderTransactions(txs) {
            const list = document.getElementById('ofTransactionsList');
            if (!txs.length) {
                list.innerHTML = '<p class="text-center text-sm text-gray-500 py-4">Nenhuma transação encontrada</p>';
                return;
            }
            const fmt = v => new Intl.NumberFormat('pt-BR', {style:'currency',currency:'BRL'}).format(v);
            const rows = txs.map(tx => {
                const isDebit = tx.type === 'DEBIT';
                const color = isDebit ? '#d93025' : '#1e8e3e';
                const sign = isDebit ? '-' : '+';
                let actionHtml;
                if (tx.already_imported) {
                    actionHtml = '<span class="of-tag" style="font-size:11px;padding:2px 8px;background:#f1f3f4;border-radius:10px;color:#5f6368;">importado</span>';
                } else if (tx.possible_duplicate) {
                    actionHtml = `<span class="of-tag" style="font-size:11px;padding:2px 8px;background:#fef7e0;border-radius:10px;color:#ea8600;cursor:pointer;" onclick="_ofShowImportExpense('${tx.id}')">⚠ duplicata?</span>`;
                } else if (isDebit) {
                    actionHtml = `<button onclick="_ofShowImportExpense('${tx.id}')" style="font-size:11px;background:#1a73e8;color:#fff;border:none;border-radius:10px;padding:2px 8px;cursor:pointer;">+ Despesa</button>`;
                } else {
                    actionHtml = `<button onclick="_ofImportIncome('${tx.id}')" style="font-size:11px;background:#1e8e3e;color:#fff;border:none;border-radius:10px;padding:2px 8px;cursor:pointer;">+ Receita</button>`;
                }
                return `<div style="display:flex;align-items:center;justify-content:space-between;padding:10px 12px;border-bottom:1px solid #f1f3f4;" id="ofRow_${tx.id}">
                    <div style="flex:1;min-width:0;margin-right:8px;">
                        <div class="of-desc" style="font-size:13px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${tx.description}</div>
                        <div class="of-date" style="font-size:11px;color:#5f6368;">${tx.date}</div>
                        <div style="font-size:11px;color:#5f6368;">${tx.type === 'CREDIT' ? 'CRÉDITO' : 'DÉBITO'}</div>
                    </div>
                    <div style="display:flex;align-items:center;gap:8px;flex-shrink:0;">
                        <span style="font-size:13px;font-weight:600;color:${color};">${sign}${fmt(Math.abs(tx.amount))}</span>
                        ${actionHtml}
                    </div>
                </div>`;
            }).join('');
            list.innerHTML = `<div class="bg-white rounded-lg shadow overflow-hidden">${rows}</div>`;
        }

        function _ofSelectCat(catId) {
            document.getElementById('ofExpCat').value = catId;
            const isDark = document.body.classList.contains('dark-mode');
            const bg = isDark ? '#3c4043' : '#f8f9fa';
            const selBg = isDark ? '#8ab4f8' : '#e8f0fe';
            const selBorder = isDark ? '#8ab4f8' : '#1a73e8';
            const textColor = isDark ? '#9aa0a6' : '#5f6368';
            document.querySelectorAll('.of-cat-option').forEach(el => {
                const isSel = parseInt(el.dataset.catId) === catId;
                el.classList.toggle('selected', isSel);
                el.style.background = isSel ? selBg : bg;
                el.style.borderColor = isSel ? selBorder : 'transparent';
                const spans = el.querySelectorAll('span');
                if (spans[1]) spans[1].style.color = isSel && isDark ? '#202124' : textColor;
            });
        }

        function _ofSelectProf(profId) {
            document.getElementById('ofExpProf').value = profId;
            const isDark = document.body.classList.contains('dark-mode');
            const bg = isDark ? '#3c4043' : '#f8f9fa';
            const selBg = isDark ? '#8ab4f8' : '#e8f0fe';
            const selBorder = isDark ? '#8ab4f8' : '#1a73e8';
            const textColor = isDark ? '#9aa0a6' : '#5f6368';
            document.querySelectorAll('.of-prof-option').forEach(el => {
                const isSel = parseInt(el.dataset.profId) === profId;
                el.classList.toggle('selected', isSel);
                el.style.background = isSel ? selBg : bg;
                el.style.borderColor = isSel ? selBorder : 'transparent';
                const spans = el.querySelectorAll('span');
                if (spans[1]) spans[1].style.color = isSel && isDark ? '#202124' : textColor;
            });
        }

        async function _ofShowImportExpense(txId) {
            const tx = _ofTxStore[txId];
            if (!tx) return;
            try {
                const fmt = v => new Intl.NumberFormat('pt-BR', {style:'currency',currency:'BRL'}).format(v);
                const [catsArr, profsArr] = await Promise.all([
                    api(`${API}/categories`),
                    api(`${API}/profiles`),
                ]);
                const isDark = document.body.classList.contains('dark-mode');
                const optionBg         = isDark ? '#3c4043' : '#f8f9fa';
                const optionSelectedBg = isDark ? '#8ab4f8' : '#e8f0fe';
                const optionBorder     = isDark ? '#8ab4f8' : '#1a73e8';
                const optionTextColor  = isDark ? '#9aa0a6' : '#5f6368';
                const modalBg   = isDark ? '#2d2e30' : '#ffffff';
                const titleColor = isDark ? '#e8eaed' : '#202124';
                const cancelBg  = isDark ? '#3c4043' : '#f1f3f4';

                const prefProfId = user?.preferred_split_profile_id || null;

                const catGrid = catsArr.map(c => `
                    <div onclick="_ofSelectCat(${c.id})"
                         class="of-cat-option flex flex-col items-center justify-center rounded-xl cursor-pointer transition-all"
                         data-cat-id="${c.id}"
                         style="background:${optionBg};border:2px solid transparent;width:60px;height:55px;flex-shrink:0;">
                        <span style="font-size:1.3rem;">${c.icon || '📁'}</span>
                        <span style="font-size:9px;color:${optionTextColor};margin-top:2px;max-width:56px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${c.name}</span>
                    </div>`).join('');

                const profGrid = profsArr.map(p => {
                    const isSel = p.id === prefProfId;
                    return `
                    <div onclick="_ofSelectProf(${p.id})"
                         class="of-prof-option flex flex-col items-center justify-center rounded-xl cursor-pointer transition-all${isSel ? ' selected' : ''}"
                         data-prof-id="${p.id}"
                         style="background:${isSel ? optionSelectedBg : optionBg};border:2px solid ${isSel ? optionBorder : 'transparent'};width:60px;height:55px;flex-shrink:0;">
                        <span style="font-size:1.3rem;">${p.emoji || '⚖️'}</span>
                        <span style="font-size:9px;color:${isSel && isDark ? '#202124' : optionTextColor};margin-top:2px;max-width:56px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${p.name}</span>
                    </div>`;
                }).join('');

                const dupWarning = tx.possible_duplicate
                    ? `<div style="background:#fef7e0;border-radius:8px;padding:8px 10px;font-size:12px;color:#7a5600;margin-bottom:10px;">⚠ Possível duplicata detectada — já existe uma despesa com mesmo valor e data neste método de pagamento.</div>`
                    : '';

                document.getElementById('modalContainer').innerHTML = `
                    <div class="fixed inset-0 flex items-center justify-center z-50" style="background:rgba(0,0,0,0.32);backdrop-filter:blur(4px);padding:1rem;" onclick="if(event.target===this)this.remove()">
                        <div class="w-full max-w-sm flex flex-col" style="background:${modalBg};border-radius:20px;box-shadow:0 4px 24px rgba(0,0,0,0.2);max-height:90vh;overflow:hidden;">
                            <div style="overflow-y:auto;flex:1;padding:1.25rem;">
                                <h3 style="font-weight:600;font-size:1rem;margin-bottom:4px;color:${titleColor};">Importar como Despesa</h3>
                                <p style="font-size:12px;color:${optionTextColor};margin-bottom:10px;">${tx.description} • ${fmt(Math.abs(tx.amount))} • ${tx.date}</p>
                                ${dupWarning}
                                <label class="block text-sm font-medium mb-2" style="color:${titleColor};">Categoria</label>
                                <input type="hidden" id="ofExpCat">
                                <div class="flex flex-wrap gap-2 justify-center" style="margin-bottom:16px;">${catGrid}</div>
                                <label class="block text-sm font-medium mb-2" style="color:${titleColor};">Perfil de divisão</label>
                                <input type="hidden" id="ofExpProf" value="${prefProfId || ''}">
                                <div class="flex flex-wrap gap-2 justify-center">${profGrid}</div>
                            </div>
                            <div class="flex gap-3 p-4" style="border-top:1px solid ${isDark ? '#5f6368' : '#dadce0'};flex-shrink:0;">
                                <button onclick="document.getElementById('modalContainer').innerHTML=''" class="flex-1 py-3" style="background:${cancelBg};border:none;border-radius:20px;font-size:14px;cursor:pointer;color:${titleColor};">Cancelar</button>
                                <button onclick="_ofDoImportExpense('${txId}')" class="flex-1 py-3" style="background:#1a73e8;color:#fff;border:none;border-radius:20px;font-size:14px;font-weight:500;cursor:pointer;">Importar</button>
                            </div>
                        </div>
                    </div>`;
            } catch(e) {
                _ofNotify('Erro ao abrir formulário: ' + e.message, 'error');
            }
        }

        async function _ofDoImportExpense(txId) {
            const tx = _ofTxStore[txId];
            const catId = parseInt(document.getElementById('ofExpCat').value);
            const profId = parseInt(document.getElementById('ofExpProf').value);
            if (isNaN(catId) || isNaN(profId)) {
                _ofNotify('Selecione categoria e perfil', 'error'); return;
            }
            const accId = document.getElementById('ofAccountSelect').value;
            const acc = _ofAccounts.find(a => String(a.id) === String(accId));
            try {
                await api(`${API}/openfinance/import/expense`, { method: 'POST', body: JSON.stringify({
                    pluggy_transaction_id: txId,
                    description: tx.description,
                    amount: tx.amount,
                    expense_date: tx.date,
                    category_id: catId,
                    split_profile_id: profId,
                    paid_by_user_id: user?.id || null,
                    payment_method_id: acc?.payment_method_id || null,
                }) });
                document.getElementById('modalContainer').innerHTML = '';
                _ofNotify('Despesa importada!', 'success');
                const row = document.getElementById('ofRow_' + txId);
                if (row) { const btn = row.querySelector('button'); if (btn) btn.outerHTML = '<span style="font-size:11px;color:#5f6368;padding:2px 8px;background:#f1f3f4;border-radius:10px;">importado</span>'; }
            } catch(e) {
                _ofNotify('Erro ao importar: ' + e.message, 'error');
            }
        }

        async function _ofImportIncome(txId) {
            const tx = _ofTxStore[txId];
            if (!tx) return;
            const fmt = v => new Intl.NumberFormat('pt-BR', {style:'currency',currency:'BRL'}).format(v);
            document.getElementById('modalContainer').innerHTML = `
                <div class="fixed inset-0 flex items-center justify-center z-50" style="background:rgba(0,0,0,0.32);backdrop-filter:blur(4px);padding:1rem;" onclick="if(event.target===this)this.remove()">
                    <div class="bg-white w-full max-w-sm overflow-auto flex flex-col" style="border-radius:20px;box-shadow:0 4px 24px rgba(0,0,0,0.2);max-height:90vh;padding:1.25rem;">
                        <h3 style="font-weight:600;font-size:1rem;margin-bottom:4px;">Importar como Receita</h3>
                        <p style="font-size:12px;color:#5f6368;margin-bottom:12px;">${tx.description} • ${fmt(tx.amount)} • ${tx.date}</p>
                        <label style="font-size:12px;font-weight:500;margin-bottom:3px;">Descrição</label>
                        <input id="ofIncDesc" value="${tx.description.replace(/"/g,'&quot;')}" style="border:1px solid #ccc;border-radius:6px;padding:6px 8px;font-size:13px;margin-bottom:8px;width:100%;box-sizing:border-box;">
                        <label style="font-size:12px;font-weight:500;margin-bottom:3px;">Valor</label>
                        <input id="ofIncAmt" type="number" step="0.01" value="${tx.amount}" style="border:1px solid #ccc;border-radius:6px;padding:6px 8px;font-size:13px;margin-bottom:8px;width:100%;box-sizing:border-box;">
                        <label style="font-size:12px;font-weight:500;margin-bottom:3px;">Data</label>
                        <input id="ofIncDate" type="date" value="${tx.date}" style="border:1px solid #ccc;border-radius:6px;padding:6px 8px;font-size:13px;margin-bottom:8px;width:100%;box-sizing:border-box;">
                        <button onclick="_ofDoImportIncome('${txId}')" style="background:#1e8e3e;color:#fff;border:none;border-radius:8px;padding:10px;font-size:14px;font-weight:500;cursor:pointer;width:100%;margin-top:4px;">Importar</button>
                        <button onclick="document.getElementById('modalContainer').innerHTML=''" style="background:#f1f3f4;border:none;border-radius:8px;padding:8px;font-size:13px;cursor:pointer;width:100%;margin-top:6px;">Cancelar</button>
                    </div>
                </div>`;
        }

        async function _ofDoImportIncome(txId) {
            const desc = document.getElementById('ofIncDesc').value.trim();
            const amt = parseFloat(document.getElementById('ofIncAmt').value);
            const date = document.getElementById('ofIncDate').value;
            if (!desc || isNaN(amt) || !date) { _ofNotify('Preencha todos os campos', 'error'); return; }
            try {
                await api(`${API}/openfinance/import/income`, { method: 'POST', body: JSON.stringify({
                    pluggy_transaction_id: txId,
                    description: desc,
                    amount: amt,
                    income_date: date,
                }) });
                document.getElementById('modalContainer').innerHTML = '';
                _ofNotify('Receita importada!', 'success');
                const row = document.getElementById('ofRow_' + txId);
                if (row) { const btn = row.querySelector('button'); if (btn) btn.outerHTML = '<span style="font-size:11px;color:#5f6368;padding:2px 8px;background:#f1f3f4;border-radius:10px;">importado</span>'; }
            } catch(e) {
                _ofNotify('Erro ao importar: ' + e.message, 'error');
            }
        }
