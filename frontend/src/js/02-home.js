        async function loadDashboardData() {
            try {
                const month = document.getElementById('homeMonthFilter')?.value || '';
                
                // ✅ OTIMIZADO - Usa endpoint /dashboard agregado (1 request)
                const data = await fetchDashboard(month);
                const { expenses, balances } = data;
                
                // ✅ Calcular total apenas das parcelas do período (sem duplicação)
                let totalPeriod = 0;
                const [year, mon] = month.split('-').map(Number);
                
                // ✅ OTIMIZADO - Expenses já vêm com splits incluídos!
                for (const expense of expenses) {
                    expense.date = expense.original_date || expense.expense_date;
                    
                    // Somar apenas uma vez o installment_amount de cada parcela do mês
                    const uniqueSplits = new Set();
                    expense.splits.forEach(split => {
                        const splitDate = new Date(split.due_date + 'T00:00:00');
                        if (splitDate.getFullYear() === year && splitDate.getMonth() + 1 === mon) {
                            const key = `${expense.id}-${split.installment_number}`;
                            if (!uniqueSplits.has(key)) {
                                uniqueSplits.add(key);
                                totalPeriod += parseFloat(split.installment_amount);
                            }
                        }
                    });
                }
                
                const myBalance=balances.find(b=>b.user_id===user.id);
                // effectivePm: se o usuário logado pagou  método da despesa
                //              se outro usuário pagou   método preferencial de balanço do usuário logado
                const effectivePm = (e) => e.paid_by_user_id === user.id
                    ? e.payment_method_id
                    : (user.preferred_balance_method || null);

                // PMs com despesas neste mês (para filtrar os botões exibidos)
                const _pmSetInicio = new Set();
                for (const e of expenses) {
                    const pmId = effectivePm(e);
                    if (pmId == null) continue;
                    const hasSplit = e.splits.some(s => {
                        const d = new Date(s.due_date + 'T00:00:00');
                        return d.getFullYear() === year && d.getMonth() + 1 === mon;
                    });
                    if (hasSplit) _pmSetInicio.add(pmId);
                }
                window._pmIdsInicio = _pmSetInicio.size > 0 ? _pmSetInicio : null;
                // Remove filtros ativos de PMs que não existem neste mês
                if (window._pmIdsInicio) activePmFilter = activePmFilter.filter(id => window._pmIdsInicio.has(id));

                renderPmFilterButtons();
                if(activePmFilter.length>0){
                    let ft=0;
                    for(const e of expenses){
                        if(!activePmFilter.includes(effectivePm(e)))continue;
                        for(const s of e.splits){
                            if(s.user_id!==user.id)continue;
                            const d=new Date(s.due_date+'T00:00:00');
                            if(d.getFullYear()===year&&d.getMonth()+1===mon){ft+=parseFloat(s.user_amount);}}}
                    _setTotalExpenses(`R$ ${formatBRL(ft)}`);
                }else{_setTotalExpenses(`R$ ${formatBRL(myBalance?(myBalance.total_owed||0):totalPeriod)}`);}


                // Classify: shared = another user also has splits in this month
                const isSharedExpense = (expense) => {
                    const usersThisMonth = new Set(
                        expense.splits
                            .filter(s => { const d = new Date(s.due_date + 'T00:00:00'); return d.getFullYear() === year && d.getMonth() + 1 === mon; })
                            .map(s => s.user_id)
                    );
                    return usersThisMonth.size > 1 || (usersThisMonth.size === 1 && !usersThisMonth.has(user.id));
                };
                const sharedExpenses = expenses.filter(e => isSharedExpense(e) && (!activePmFilter.length || activePmFilter.includes(effectivePm(e))));
                const personalExpenses = expenses.filter(e => !isSharedExpense(e) && (!activePmFilter.length || activePmFilter.includes(effectivePm(e))));

                // Ordenar usuário logado no topo
                const sortedBalances = [...balances].sort((a, b) => {
                    if (a.user_id === user.id) return -1;
                    if (b.user_id === user.id) return 1;
                    return 0;
                });
                
                const detailedBalancesHTML = await Promise.all(sortedBalances
                  .filter(b => b.user_id === user.id)
                  .map(async (balance) => {
                    const allSplits = [];
                    const [year, mon] = month.split('-').map(Number);
                    
                    // ✅ OTIMIZADO - Usar splits que já vêm com a despesa
                    for (const expense of personalExpenses) {
                        const userSplits = expense.splits.filter(s => {
                            const splitDate = new Date(s.due_date + 'T00:00:00');
                            return s.user_id === balance.user_id &&
                                   splitDate.getFullYear() === year &&
                                   splitDate.getMonth() + 1 === mon;
                        });
                        
                        userSplits.forEach(split => {
                            allSplits.push({
                                ...split,
                                expense_id: expense.id,
                                expense_description: expense.description,
                                expense_category: expense.category_name,
                                expense_date: expense.expense_date,
                                original_date: expense.original_date || expense.expense_date,
                                expense_installments: expense.installments,
                                expense_profile_name: expense.profile_name,
                                expense_total_amount: expense.total_amount,
                                category_emoji: expense.category_emoji
                            });
                        });
                    }
                    
                    // ✅ 6️⃣ Não exibir usuários sem despesas
                    if (allSplits.length === 0) {
                        return '';
                    }
                    
                    // Calcular total da parte do usuário (soma de user_amount)
                    const totalUserAmount = allSplits.reduce((sum, s) => sum + parseFloat(s.user_amount), 0);
                    
                    // Agrupar por categoria, depois por despesa
                    const groupedByCategory = {};
                    allSplits.forEach(split => {
                        const catKey = split.expense_category;
                        if (!groupedByCategory[catKey]) {
                            groupedByCategory[catKey] = {
                                category: split.expense_category,
                                category_emoji: split.category_emoji,
                                expenses: {}
                            };
                        }
                        
                        const expKey = `${split.expense_id}`;
                        if (!groupedByCategory[catKey].expenses[expKey]) {
                            groupedByCategory[catKey].expenses[expKey] = {
                                id: split.expense_id,
                                description: split.expense_description,
                                date: split.original_date||split.expense_date,
                                profile_name: split.expense_profile_name,
                                installments: split.expense_installments,
                                total_amount: split.expense_total_amount,
                                splits: []
                            };
                        }
                        groupedByCategory[catKey].expenses[expKey].splits.push(split);
                    });
                    
                    const categoriesArray = Object.values(groupedByCategory);
                    
                    // Ordenar categorias pela ordem definida no drag-and-drop
                    categoriesArray.sort((a, b) => {
                        const catA = categories.find(c => c.name === a.category);
                        const catB = categories.find(c => c.name === b.category);
                        const orderA = catA ? categories.indexOf(catA) : 999;
                        const orderB = catB ? categories.indexOf(catB) : 999;
                        return orderA - orderB;
                    });
                    
                    return `
                        <div class="bg-white rounded-lg shadow" style="overflow: hidden;">
                            <div class="p-6">
                                ${(() => {
                                    // Targets do usuário logado
                                    if (!targets.length) return '';

                                    const today = new Date();
                                    const lastDay = new Date(year, mon, 0).getDate();
                                    const isCurrentMonth = today.getFullYear() === year && today.getMonth() + 1 === mon;
                                    const isDark = document.body.classList.contains('dark-mode');
                                    const bgColor = isDark ? 'rgba(0,0,0,0.25)' : '#f1f3f4';
                                    const labelColor = isDark ? '#9aa0a6' : '#5f6368';
                                    const subColor = isDark ? '#9aa0a6' : '#5f6368';
                                    const trackColor = isDark ? 'rgba(255,255,255,0.15)' : '#dadce0';

                                    return targets.map((tgt, tgtIdx) => {
                                        const targetAmt = parseFloat(tgt.monthly_amount);
                                        if (!targetAmt) return '';
                                        const catIds = new Set(tgt.category_ids || []);

                                        const pmIds = new Set(tgt.payment_methods || []);
                                        let spent = 0;
                                        for (const expense of expenses) {
                                            if (catIds.size && !catIds.has(expense.category_id)) continue;
                                            if (pmIds.size && !pmIds.has(expense.payment_method_id)) continue;
                                            for (const s of expense.splits) {
                                                if (s.user_id !== balance.user_id) continue;
                                                const d = new Date(s.due_date + 'T00:00:00');
                                                if (d.getFullYear() === year && d.getMonth() + 1 === mon) {
                                                    spent += parseFloat(s.user_amount);
                                                }
                                            }
                                        }

                                        const remaining = targetAmt - spent;
                                        const pct = Math.min(100, Math.round((spent / targetAmt) * 100));
                                        const over = remaining < 0;
                                        const daysLeft = isCurrentMonth ? (lastDay - today.getDate() + 1) : 0;
                                        const dailyAllowance = (!over && daysLeft > 0) ? (remaining / daysLeft) : 0;
                                        const barColor = pct >= 100 ? '#ea4335' : pct >= 80 ? '#f9ab00' : '#34a853';
                                        const valueColor = over ? '#ea4335' : (isDark ? '#e8eaed' : '#202124');
                                        const currentMonthStr = `${year}-${String(mon).padStart(2,'0')}`;
                                        const cacheKey = `_tgtStats_${tgt.id}_${currentMonthStr}`;

                                        // Resolve bottom-right info
                                        let bottomInfo = '';
                                        if (tgt.display_mode === 'daily') {
                                            bottomInfo = isCurrentMonth && !over && daysLeft > 0
                                                ? `<span>R$ ${formatBRL(dailyAllowance)}/dia (${daysLeft}d)</span>` : '';
                                        } else if (tgt.display_mode === 'ticket' || tgt.display_mode === 'ticket_day') {
                                            const cached = window[cacheKey];
                                            if (cached && cached !== 'loading') {
                                                if (cached.avg_ticket_adj == null) {
                                                    bottomInfo = '<span style="margin-left:auto;">Sem histórico</span>';
                                                } else {
                                                    const label = tgt.display_mode === 'ticket_day' ? 'Ticket diário' : 'Ticket médio';
                                                    const timesStr = cached.times_left != null ? ` (${Math.round(cached.times_left)}x)` : '';
                                                    bottomInfo = `<span style="margin-left:auto;">${label}: R$ ${formatBRL(cached.avg_ticket_adj)}${timesStr}</span>`;
                                                }
                                            } else if (!cached) {
                                                window[cacheKey] = 'loading';
                                                api(`${API}/targets/${tgt.id}/stats?month=${currentMonthStr}`)
                                                    .then(s => { window[cacheKey] = s; loadDashboardData(); })
                                                    .catch(() => { window[cacheKey] = null; });
                                            }
                                        }

                                        return `
                                        <div style="margin-top: 10px; padding: 10px 12px; background: ${bgColor}; border-radius: 12px;">
                                            <div style="display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 6px;">
                                                <span style="font-size: 12px; font-weight: 600; color: ${labelColor};">${tgt.emoji} ${tgt.name}</span>
                                                <span style="font-size: 12px; font-weight: 600; color: ${valueColor};">
                                                    R$ ${formatBRL(spent)} <span style="font-weight: 400; color: ${isDark ? '#9aa0a6' : '#80868b'};">(${targetAmt > 0 ? (spent/targetAmt*100).toFixed(1).replace('.',',') : '0,0'}%)</span> / R$ ${formatBRL(targetAmt)}
                                                </span>
                                            </div>
                                            <div style="position:relative; height: 6px; background: ${trackColor}; border-radius: 3px; overflow: hidden; margin-bottom: 0px;">
                                                <div style="height: 100%; width: ${pct}%; background: ${barColor}; border-radius: 3px; transition: width 0.3s;"></div>
                                            </div>
                                            ${isCurrentMonth ? (() => {
                                                const dayPct = Math.round((today.getDate() / lastDay) * 100);
                                                const textColor2 = isDark ? 'rgba(255,255,255,0.45)' : 'rgba(0,0,0,0.45)';
                                                return `<div style="position:relative; height: 18px;">
                                                    <div style="position:absolute; left:${dayPct}%; top:1px; transform:translateX(-50%); font-size:10px; color:#ea4335; line-height:1;">▲</div>
                                                    ${tgtIdx === 0 ? `<div style="position:absolute; left:${dayPct}%; top:12px; transform:translateX(-50%); font-size:9px; color:${textColor2}; white-space:nowrap; line-height:1;">dia ${today.getDate()}</div>` : ''}
                                                </div>`;
                                            })() : '<div style="height:18px;"></div>'}
                                            <div style="display: flex; justify-content: space-between; font-size: 11px; color: ${subColor}; margin-top:2px;">
                                                <span>${over ? '⚠️ Estourou R$ ' + formatBRL(-remaining) : 'Disponível: R$ ' + formatBRL(remaining)}</span>
                                                ${bottomInfo}
                                            </div>
                                        </div>`;
                                    }).join('');
                                })()}
                                <div class="space-y-3" style="${balance.user_id === user.id && targets.length ? 'margin-top: 16px;' : ''}">
                                    ${categoriesArray.map(categoryGroup => {
                                        const expensesArray = Object.values(categoryGroup.expenses);
                                        const categoryTotal = expensesArray.reduce((sum, exp) => {
                                            return sum + exp.splits.reduce((s, split) => s + parseFloat(split.user_amount), 0);
                                        }, 0);
                                        const categoryBalance = expensesArray.reduce((sum, exp) => {
                                            return sum + exp.splits.reduce((s, split) => s + parseFloat(split.balance), 0);
                                        }, 0);
                                        
                                        return `
                                            <div class="border rounded-lg overflow-hidden">
                                                <!-- Cabeçalho da Categoria -->
                                                <div class="bg-gray-100 p-4 flex justify-between items-center">
                                                    <div class="flex items-center gap-3 flex-1">
                                                        <span class="text-2xl">${categoryGroup.category_emoji}</span>
                                                        <div>
                                                            <p class="font-bold text-lg">${categoryGroup.category}</p>
                                                            <p class="text-xs text-gray-600">${expensesArray.length} despesa(s)</p>
                                                        </div>
                                                    </div>
                                                    <div class="text-right">
                                                        <p class="font-bold text-lg">R$ ${formatBRL(categoryTotal)}</p>
                                                        <p class="text-xs font-bold ${categoryBalance >= 0 ? 'text-green-600' : 'text-red-600'}">
                                                            ${categoryBalance >= 0 ? '+' : ''}R$ ${formatBRL(categoryBalance)}
                                                        </p>
                                                    </div>
                                                </div>
                                                
                                                <!-- Despesas (expansível) -->
                                                <details class="group">
                                                    <summary class="cursor-pointer p-3 bg-gray-100 text-sm text-blue-600 font-medium">
                                                        Ver despesas (${expensesArray.length})
                                                    </summary>
                                                    <div class="p-4 space-y-3 bg-gray-100">
                                                        ${[...expensesArray].sort((a,b) => (b.date||"").localeCompare(a.date||"")).map(expense => {
                                                            const totalUserAmount = expense.splits.reduce((sum, s) => sum + parseFloat(s.user_amount), 0);
                                                            const totalPaidAmount = expense.splits.reduce((sum, s) => sum + parseFloat(s.paid_amount), 0);
                                                            const totalBalance = expense.splits.reduce((sum, s) => sum + parseFloat(s.balance), 0);
                                                            const parcelaValor = expense.splits.length > 0 ? parseFloat(expense.splits[0].user_amount) : 0;
                                                            
                                                            let displayName = expense.description;
                                                            if (expense.installments > 1 && expense.splits.length > 0) {
                                                                displayName = `${expense.description} (${expense.splits[0].installment_number}/${expense.installments})`;
                                                            }
                                                            
                                                            return `
                                                                <div class="border rounded-lg p-3">
                                                                    <div class="flex justify-between items-start mb-2">
                                                                        <div class="flex-1 min-w-0">
                                                                            <div class="flex items-center gap-2">
                                                                                <p class="font-medium" style="word-break:break-all;">${displayName}</p>
                                                                                <button onclick="editExpense(${expense.id})" style="flex-shrink:0;background:none;border:none;cursor:pointer;padding:0;font-size:13px;line-height:1;opacity:0.7;" title="Editar">✏️</button>
                                                                            </div>
                                                                            <p class="text-xs text-gray-500">${new Date((expense.original_date || expense.date) + 'T12:00:00').toLocaleDateString('pt-BR')}</p>
                                                                            <p class="text-xs text-gray-500">⚖️ ${expense.profile_name}</p>
                                                                        </div>
                                                                        <div class="text-right ml-4" style="flex-shrink:0;">
                                                                            <p class="font-bold" style="white-space:nowrap;">R$ ${formatBRL(parcelaValor)}</p>
                                                                            ${totalPaidAmount > 0 ? `
                                                                                <p class="text-xs text-blue-600" style="white-space:nowrap;">Pagou: R$ ${formatBRL(totalPaidAmount)}</p>
                                                                            ` : ''}
                                                                            <p class="text-xs font-bold ${totalBalance >= 0 ? 'text-green-600' : 'text-red-600'}" style="white-space:nowrap;">
                                                                                ${totalBalance >= 0 ? '+' : ''}R$ ${formatBRL(totalBalance)}
                                                                            </p>
                                                                        </div>
                                                                    </div>
                                                                    
                                                                    ${expense.installments > 1 ? `
                                                                        <details class="mt-2">
                                                                            <summary class="text-xs text-blue-600 cursor-pointer hover:underline">
                                                                                Ver parcelas (${expense.installments})
                                                                            </summary>
                                                                            <div class="mt-2 pl-3 border-l-2 border-gray-200">
                                                                                <p class="text-xs font-bold text-gray-700 mb-2">Valor Total: R$ ${formatBRL(expense.total_amount)}</p>
                                                                                <div class="flex flex-wrap">
                                                                                    ${Array.from({length: expense.installments}, (_, i) => {
                                                                                        const parcela = i + 1;
                                                                                        const split = expense.splits.find(s => s.installment_number === parcela);
                                                                                        if (split) {
                                                                                            return `
                                                                                                <span class="text-xs text-gray-600 bg-blue-50 px-2 py-1 rounded inline-block mr-1 mb-1">
                                                                                                    (${split.installment_number}/${expense.installments}): ${split.due_date.substring(0, 7)}
                                                                                                </span>
                                                                                            `;
                                                                                        } else {
                                                                                            const baseDate = new Date(expense.date + 'T12:00:00');
                                                                                            const parcelaDate = new Date(baseDate);
                                                                                            parcelaDate.setMonth(parcelaDate.getMonth() + parcela - 1);
                                                                                            return `
                                                                                                <span class="text-xs text-gray-400 bg-gray-50 px-2 py-1 rounded inline-block mr-1 mb-1">
                                                                                                    (${parcela}/${expense.installments}): ${parcelaDate.toISOString().substring(0, 7)}
                                                                                                </span>
                                                                                            `;
                                                                                        }
                                                                                    }).join('')}
                                                                                </div>
                                                                            </div>
                                                                        </details>
                                                                    ` : ''}
                                                                </div>
                                                            `;
                                                        }).join('')}
                                                    </div>
                                                </details>
                                            </div>
                                        `;
                                    }).join('')}
                                </div>
                            </div>
                        </div>
                    `;
                }));
                
                document.getElementById('detailedBalances').innerHTML = detailedBalancesHTML.filter(h => h !== '').join('');

                // ── Shared expenses section ──────────────────────────────────
                const sharedSection = document.getElementById('sharedExpensesSection');
                if (sharedExpenses.length === 0) {
                    sharedSection.classList.add('hidden');
                } else {
                    let sharedTotalAmt = 0;
                    const seenKeys = new Set();
                    for (const e of sharedExpenses) {
                        for (const s of e.splits) {
                            const d = new Date(s.due_date + 'T00:00:00');
                            if (d.getFullYear() === year && d.getMonth() + 1 === mon) {
                                const k = `${e.id}-${s.installment_number}`;
                                if (!seenKeys.has(k)) { seenKeys.add(k); sharedTotalAmt += parseFloat(s.installment_amount); }
                            }
                        }
                    }
                    document.getElementById('sharedTotal').textContent = `R$ ${formatBRL(sharedTotalAmt)}`;

                    // Render ALL users with shared expenses — same template as personal card
                    const sharedCardsHTML = await Promise.all(sortedBalances.map(async (balance) => {
                        const allSplits = [];
                        const [syear, smon] = month.split('-').map(Number);
                        for (const expense of sharedExpenses) {
                            expense.splits
                                .filter(s => { const d = new Date(s.due_date + 'T00:00:00'); return s.user_id === balance.user_id && d.getFullYear() === syear && d.getMonth() + 1 === smon; })
                                .forEach(split => allSplits.push({ ...split, expense_id: expense.id, expense_description: expense.description, expense_category: expense.category_name, expense_date: expense.expense_date, original_date: expense.original_date || expense.expense_date, expense_installments: expense.installments, expense_profile_name: expense.profile_name, expense_total_amount: expense.total_amount, category_emoji: expense.category_emoji }));
                        }
                        if (allSplits.length === 0) return '';
                        const totalUserAmount = allSplits.reduce((sum, s) => sum + parseFloat(s.user_amount), 0);
                        const pctShare = sharedTotalAmt > 0 ? ` (${fmtPct(totalUserAmount / sharedTotalAmt * 100, 1)}%)` : '';
                        const groupedByCategory = {};
                        allSplits.forEach(split => {
                            if (!groupedByCategory[split.expense_category]) groupedByCategory[split.expense_category] = { category: split.expense_category, category_emoji: split.category_emoji, expenses: {} };
                            const eid = `${split.expense_id}`;
                            if (!groupedByCategory[split.expense_category].expenses[eid]) {
                                groupedByCategory[split.expense_category].expenses[eid] = { id: split.expense_id, description: split.expense_description, date: split.original_date || split.expense_date, original_date: split.original_date || split.expense_date, profile_name: split.expense_profile_name, installments: split.expense_installments, total_amount: split.expense_total_amount, splits: [] };
                            }
                            groupedByCategory[split.expense_category].expenses[eid].splits.push(split);
                        });
                        const catsArr = Object.values(groupedByCategory).sort((a, b) => {
                            const oA = categories.findIndex(c => c.name === a.category);
                            const oB = categories.findIndex(c => c.name === b.category);
                            return (oA === -1 ? 999 : oA) - (oB === -1 ? 999 : oB);
                        });
                        return `
                            <div class="bg-white rounded-lg shadow" style="overflow: hidden;">
                                <div class="p-4 border-b" style="background: #e8f0fe; border-radius: 16px 16px 0 0;">
                                    <div class="flex justify-between items-center">
                                        <h2 class="text-xl font-bold">${balance.user_name}</h2>
                                        <div class="text-right">
                                            <p class="text-sm text-gray-600">Balanço Total</p>
                                            <p class="${balance.balance >= 0 ? 'text-green-600' : 'text-red-600'} text-2xl font-bold">R$ ${formatBRL(balance.balance)}</p>
                                            <p class="text-xs text-gray-500">Sua parte: <span class="font-bold">R$ ${formatBRL(totalUserAmount)}${pctShare}</span></p>
                                        </div>
                                    </div>
                                </div>
                                <div class="p-6"><div class="space-y-3">
                                    ${catsArr.map(cg => {
                                        const expArr = Object.values(cg.expenses);
                                        const catTotal = expArr.reduce((s, e) => s + e.splits.reduce((ss, sp) => ss + parseFloat(sp.user_amount), 0), 0);
                                        const catBal = expArr.reduce((s, e) => s + e.splits.reduce((ss, sp) => ss + parseFloat(sp.balance), 0), 0);
                                        return `<div class="border rounded-lg overflow-hidden">
                                            <div class="bg-gray-100 p-4 flex justify-between items-center">
                                                <div class="flex items-center gap-3 flex-1"><span class="text-2xl">${cg.category_emoji}</span><div><p class="font-bold text-lg">${cg.category}</p><p class="text-xs text-gray-600">${expArr.length} despesa(s)</p></div></div>
                                                <div class="text-right"><p class="font-bold text-lg">R$ ${formatBRL(catTotal)}</p><p class="text-xs font-bold ${catBal >= 0 ? 'text-green-600' : 'text-red-600'}">${catBal >= 0 ? '+' : ''}R$ ${formatBRL(catBal)}</p></div>
                                            </div>
                                            <details class="group">
                                                <summary class="cursor-pointer p-3 bg-gray-100 text-sm text-blue-600 font-medium">Ver despesas (${expArr.length})</summary>
                                                <div class="p-4 space-y-3 bg-gray-100">
                                                    ${[...expArr].sort((a,b) => (b.date||b.original_date||"").localeCompare(a.date||a.original_date||"")).map(exp => {
                                                        const expUsr = exp.splits.reduce((s, sp) => s + parseFloat(sp.user_amount), 0);
                                                        const expPaid = exp.splits.reduce((s, sp) => s + parseFloat(sp.paid_amount), 0);
                                                        const expBal = exp.splits.reduce((s, sp) => s + parseFloat(sp.balance), 0);
                                                        const pv = exp.splits.length > 0 ? parseFloat(exp.splits[0].user_amount) : 0;
                                                        let dn = exp.description;
                                                        if (exp.installments > 1 && exp.splits.length > 0) dn += ' (' + exp.splits[0].installment_number + '/' + exp.installments + ')';
                                                        const instSection = exp.installments > 1 ? `
                                                            <details class="mt-2">
                                                                <summary class="text-xs text-blue-600 cursor-pointer hover:underline">Ver parcelas (${exp.installments})</summary>
                                                                <div class="mt-2 pl-3 border-l-2 border-gray-200">
                                                                    <p class="text-xs font-bold text-gray-700 mb-2">Valor Total: R$ ${formatBRL(exp.total_amount)}</p>
                                                                    <div class="flex flex-wrap">
                                                                        ${Array.from({length: exp.installments}, (_, i) => {
                                                                            const num = i + 1;
                                                                            const sp = exp.splits.find(s => s.installment_number === num);
                                                                            if (sp) {
                                                                                return '<span class="text-xs text-gray-600 bg-blue-50 px-2 py-1 rounded inline-block mr-1 mb-1">(' + sp.installment_number + '/' + exp.installments + '): ' + sp.due_date.substring(0,7) + '</span>';
                                                                            } else {
                                                                                const bd = new Date(exp.date + 'T12:00:00');
                                                                                bd.setMonth(bd.getMonth() + num - 1);
                                                                                return '<span class="text-xs text-gray-400 bg-gray-50 px-2 py-1 rounded inline-block mr-1 mb-1">(' + num + '/' + exp.installments + '): ' + bd.toISOString().substring(0,7) + '</span>';
                                                                            }
                                                                        }).join('')}
                                                                    </div>
                                                                </div>
                                                            </details>` : '';
                                                        return '<div class="border rounded-lg p-3"><div class="flex justify-between items-start mb-2"><div class="flex-1 min-w-0"><div class="flex items-center gap-2"><p class="font-medium" style="overflow-wrap:break-word;word-break:break-all;">' + dn + '</p><button onclick="editExpense(' + exp.id + ')" style="flex-shrink:0;background:none;border:none;cursor:pointer;padding:0;font-size:13px;opacity:0.7;">✏️</button></div><p class="text-xs text-gray-500">' + new Date(exp.date + 'T12:00:00').toLocaleDateString('pt-BR') + '</p><p class="text-xs text-gray-500">⚖️ ' + exp.profile_name + '</p></div><div class="text-right ml-4" style="flex-shrink:0;"><p class="font-bold" style="white-space:nowrap;">R$ ' + formatBRL(pv) + '</p>' + (expPaid > 0 ? '<p class="text-xs text-blue-600" style="white-space:nowrap;">Pagou: R$ ' + formatBRL(expPaid) + '</p>' : '') + '<p class="text-xs font-bold ' + (expBal >= 0 ? 'text-green-600' : 'text-red-600') + '" style="white-space:nowrap;">' + (expBal >= 0 ? '+' : '') + 'R$ ' + formatBRL(expBal) + '</p></div></div>' + instSection + '</div>';
                                                    }).join('')}
                                                </div>
                                            </details>
                                        </div>`;
                                    }).join('')}
                                </div></div>
                            </div>`;
                    }));

                    document.getElementById('sharedBalances').innerHTML = sharedCardsHTML.filter(h => h).join('');
                    sharedSection.classList.remove('hidden');
                }
                
                // Marcar gráficos para recarregar
                chartsNeedReload = true;
                
            } catch (err) {
                console.error('Erro ao carregar dados:', err);
                alert('Erro ao carregar dados: ' + err.message);
            }
        }
        
        async function updateExpenseFilters() {
            const month = document.getElementById('expenseMonthFilter')?.value;
            if (!month) { loadExpenses(); return; }
            try {
                const { expenses } = await fetchExpensesWithCache(month);
                const [year, mon] = month.split('-').map(Number);
                const paidBySelect = document.getElementById('expensePaidByFilter');
                const profileSelect = document.getElementById('expenseProfileFilter');

                const involvedExpenses = expenses.filter(e => {
                    if (e.paid_by_user_id === user.id) return true;
                    return e.splits.some(s => {
                        const d = new Date(s.due_date + 'T00:00:00');
                        return s.user_id === user.id && d.getFullYear() === year && d.getMonth() + 1 === mon;
                    });
                });

                if (paidBySelect) {
                    const current = paidBySelect.value;
                    const payerIds = new Set(involvedExpenses.map(e => e.paid_by_user_id));
                    paidBySelect.innerHTML = '<option value="">Todos</option>' +
                        users.filter(u => payerIds.has(u.id)).map(u => `<option value="${u.id}">${u.emoji||'👤'} ${u.name}</option>`).join('');
                    if (current && payerIds.has(parseInt(current))) paidBySelect.value = current;
                }
                if (profileSelect) {
                    const current = profileSelect.value;
                    const profIds = new Set(involvedExpenses.map(e => e.split_profile_id).filter(Boolean));
                    profileSelect.innerHTML = '<option value="">Todos</option>' +
                        profiles.filter(p => profIds.has(p.id)).map(p => `<option value="${p.id}">${p.emoji||'⚖️'} ${p.name}</option>`).join('');
                    if (current && profIds.has(parseInt(current))) profileSelect.value = current;
                }
                // Métodos de pagamento com despesas no mês filtrado
                const pmIdsInMonth = new Set(expenses.filter(e => e.payment_method_id != null).map(e => e.payment_method_id));
                window._pmIdsExpense = pmIdsInMonth.size > 0 ? pmIdsInMonth : null;
                if (window._pmIdsExpense) activeExpensePmFilter = activeExpensePmFilter.filter(id => window._pmIdsExpense.has(id));
                renderPmFilterButtons();
            } catch (e) { console.log('Filtros fallback'); }
            loadExpenses();
        }

