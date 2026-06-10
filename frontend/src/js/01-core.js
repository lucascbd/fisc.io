        // Unregister datalabels globally — only use per-chart in inflation tab
        if (window.ChartDataLabels) Chart.unregister(ChartDataLabels);

        const API = '/api/v1';
        let token = localStorage.getItem('token');
        let user = null;
        let users = [], categories = [], profiles = [], months = [], targets = [];

        // ── Visibilidade de categorias por usuário (backend) ──
        function getHiddenCatIds() {
            return user?.hidden_category_ids || [];
        }
        function isCatHidden(catId) { return getHiddenCatIds().includes(catId); }
        async function toggleCatVisibility(catId) {
            try {
                const res = await api(`${API}/users/me/toggle-category/${catId}`, { method: 'POST' });
                user.hidden_category_ids = res.hidden_category_ids;
                localStorage.setItem('user', JSON.stringify(user));
                loadSidebarCategories();
            } catch(e) { console.error('Erro ao alterar visibilidade:', e); }
        }
        function visibleCategories() {
            const hidden = getHiddenCatIds();
            return categories.filter(c => !hidden.includes(c.id));
        }
        
        // ============================================
        // CACHE SYSTEM - Otimizado com 2 níveis
        // ============================================
        
        // Cache de dados ESTÁTICOS (users, categories, profiles) - 5 minutos
        let staticCacheTimestamp = 0;
        const STATIC_CACHE_TTL = 300000;  // 5 minutos
        
        // Cache de dados DINÂMICOS (expenses, balances) - 30 segundos
        let cachedExpenses = null;
        let cachedBalances = null;
        let cachedMonth = null;
        let dynamicCacheTimestamp = 0;
        const DYNAMIC_CACHE_TTL = 30000;  // 30 segundos
        
        // Verifica se cache estático é válido
        function isStaticCacheValid() {
            return users.length > 0 && 
                   categories.length > 0 && 
                   profiles.length > 0 &&
                   (Date.now() - staticCacheTimestamp) < STATIC_CACHE_TTL;
        }
        
        // Verifica se cache dinâmico é válido
        function isDynamicCacheValid(month) {
            return cachedExpenses !== null && 
                   cachedMonth === month && 
                   (Date.now() - dynamicCacheTimestamp) < DYNAMIC_CACHE_TTL;
        }
        
        // Cache por mês para os gráficos multi-mês (5 minutos)
        const _monthDataCache = new Map();
        const _MONTH_DATA_TTL = 300000;

        async function fetchMonthExpenses(month) {
            const hit = _monthDataCache.get(month);
            if (hit && (Date.now() - hit.ts) < _MONTH_DATA_TTL) return hit.expenses;
            const { expenses } = await fetchExpensesWithCache(month);
            _monthDataCache.set(month, { expenses, ts: Date.now() });
            return expenses;
        }

        // Invalida cache (chamar após criar/editar/deletar)
        function invalidateCache() {
            cachedExpenses = null;
            cachedBalances = null;
            cachedMonth = null;
            dynamicCacheTimestamp = 0;
            _monthDataCache.clear();
            chartsNeedReload = true;
            console.log('🗑️ Cache dinâmico invalidado');
        }
        
        // Invalida cache estático (chamar após editar users/categories/profiles)
        function invalidateStaticCache() {
            users = [];
            categories = [];
            profiles = [];
            targets = [];
            staticCacheTimestamp = 0;
            console.log('🗑️ Cache estático invalidado');
        }
        
        // Busca TUDO via endpoint agregado /dashboard
        async function fetchDashboard(month) {
            // Se cache dinâmico é válido E estático também, usar cache
            if (isDynamicCacheValid(month) && isStaticCacheValid()) {
                console.log('📦 Usando cache completo');
                return { 
                    users, categories, profiles,
                    expenses: cachedExpenses, 
                    balances: cachedBalances, 
                    fromCache: true 
                };
            }
            
            console.log('🌐 Buscando /dashboard do servidor');
            const monthParam = month ? `?month=${month}` : '';
            
            const [data, targetsData] = await Promise.all([
                api(`${API}/dashboard${monthParam}`),
                api(`${API}/targets`).catch(() => []),
            ]);
            targets = targetsData;
            
            // Atualizar cache estático
            users = data.users;
            categories = data.categories;
            profiles = data.profiles;
            if (data.payment_methods) paymentMethods = data.payment_methods;
            if (data.current_user_id) window._myUserId = data.current_user_id;
            staticCacheTimestamp = Date.now();
            
            // Atualizar cache dinâmico
            cachedExpenses = data.expenses;
            cachedBalances = data.balances;
            cachedMonth = month;
            dynamicCacheTimestamp = Date.now();
            
            return { 
                users: data.users,
                categories: data.categories,
                profiles: data.profiles,
                expenses: data.expenses, 
                balances: data.balances,
                totals: data.totals,
                fromCache: false 
            };
        }
        
        // Busca dados com cache (para funções que só precisam de expenses/balances)
        async function fetchExpensesWithCache(month) {
            if (isDynamicCacheValid(month)) {
                console.log('📦 Usando cache de expenses');
                return { expenses: cachedExpenses, balances: cachedBalances, fromCache: true };
            }
            
            // Se não tem cache, busca via /dashboard para aproveitar
            const data = await fetchDashboard(month);
            return { expenses: data.expenses, balances: data.balances, fromCache: false };
        }
        
        // Busca dados estáticos com cache
        async function fetchStaticData() {
            if (isStaticCacheValid()) {
                console.log('📦 Usando cache estático');
                return { users, categories, profiles };
            }
            
            console.log('🌐 Buscando dados estáticos');
            const [u, c, p, t, pm] = await Promise.all([
                api(`${API}/users`),
                api(`${API}/categories`),
                api(`${API}/profiles`),
                api(`${API}/targets`).catch(() => []),
                api(`${API}/payment-methods`).catch(() => [])
            ]);

            users = u;
            categories = c;
            profiles = p;
            targets = t;
            paymentMethods = pm;
            staticCacheTimestamp = Date.now();

            return { users, categories, profiles };
        }
        
        let categoriesSortable = null, profilesSortable = null, usersSortable = null;

        // ── O(1) lookup por id com WeakMap ───────────────────────────────────
        const _idMapCache = new WeakMap();
        function byId(arr, id) {
            if (!arr) return undefined;
            let m = _idMapCache.get(arr);
            if (!m) { m = new Map(arr.map(o => [o.id, o])); _idMapCache.set(arr, m); }
            return m.get(id);
        }

        // ── Debounce ──────────────────────────────────────────────────────────
        function debounce(fn, ms) {
            let t;
            return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
        }

        // ── Reuso de charts (update in-place em vez de destroy/recreate) ──────
        function upsertChart(chart, ctx, config) {
            const canvas = typeof ctx === 'string' ? document.getElementById(ctx) : (ctx.canvas || ctx);
            if (chart && chart.canvas === canvas && chart.config.type === config.type) {
                chart.data = config.data;
                chart.options = config.options || {};
                chart.update('none');
                return chart;
            }
            if (chart) { try { chart.destroy(); } catch (e) {} }
            const context = canvas.nodeName === 'CANVAS' ? canvas.getContext('2d') : canvas;
            return new Chart(context, config);
        }

        // Versões debounced das funções de filtro pesado
        const loadInflationDebounced        = debounce(() => loadInflation(), 250);
        const updatePieChartDebounced       = debounce(() => updatePieChart(), 250);
        const updatePmBarChartDebounced     = debounce(() => updatePmBarChart(), 250);
        const updateBarChartFiltersDebounced= debounce(() => updateBarChartFilters(), 250);

        // Helpers para métodos de pagamento
        function pmById(id) { return byId(paymentMethods, id) || null; }
        function userPms(userId) { return paymentMethods.filter(pm => pm.user_id === userId); }
        function pmIcon(pm) {
            if (!pm) return '';
            if (pm.icon_path) return `<img src="${pm.icon_path}" style="width:16px;height:16px;object-fit:contain;flex-shrink:0;">`;
            return `<span style="width:16px;height:16px;display:inline-flex;align-items:center;justify-content:center;border-radius:50%;background:${pm.color||'#999'};font-size:9px;flex-shrink:0;">💳</span>`;
        }

        // ✅ 7️⃣ Formato brasileiro para números
        // ── Total expenses visibility toggle ──────────────────────────────────
        let _totalExpensesValue = 'R$ 0,00';
        function _updateTotalVisibilityIcon() {
            const visible = localStorage.getItem('totalExpensesVisible') !== 'false';
            const dark = document.body.classList.contains('dark-mode');
            const icon = document.getElementById('totalVisibilityIcon');
            if (icon) icon.src = visible
                ? (dark ? '/icons/system/seen-white.png'   : '/icons/system/seen-black.png')
                : (dark ? '/icons/system/unseen-white.png' : '/icons/system/unseen-black.png');
        }
        function _setTotalExpenses(val) {
            _totalExpensesValue = val;
            const visible = localStorage.getItem('totalExpensesVisible') !== 'false';
            const el = document.getElementById('totalExpenses');
            if (el) el.textContent = visible ? val : '••••••';
            _updateTotalVisibilityIcon();
        }
        window._toggleTotalVisibility = function() {
            const visible = localStorage.getItem('totalExpensesVisible') !== 'false';
            localStorage.setItem('totalExpensesVisible', visible ? 'false' : 'true');
            _setTotalExpenses(_totalExpensesValue);
        };
        // Init icon on load
        document.addEventListener('DOMContentLoaded', _updateTotalVisibilityIcon);
        // ──────────────────────────────────────────────────────────────────────

        function formatBRL(value) {
            return parseFloat(value).toLocaleString('pt-BR', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        }
        // Format a percentage with comma as decimal separator
        function fmtPct(value, decimals = 2) {
            return parseFloat(value).toLocaleString('pt-BR', {
                minimumFractionDigits: decimals,
                maximumFractionDigits: decimals
            });
        }

        async function api(url, opts = {}) {
            const headers = { 'Authorization': `Bearer ${token}` };
            if (opts.body) headers['Content-Type'] = 'application/json';
            
            const res = await fetch(url, { ...opts, headers });
            if (!res.ok) {
                const text = await res.text();
                let message = `Erro ${res.status}`;
                try {
                    const json = JSON.parse(text);
                    message = json.detail || json.message || message;
                } catch (e) {
                    if (text) message = text;
                }
                throw new Error(message);
            }
            return await res.json();
        }

        document.getElementById('loginForm').onsubmit = async (e) => {
            e.preventDefault();
            const errEl = document.getElementById('loginError');
            errEl.classList.add('hidden');
            try {
                const form = new URLSearchParams();
                form.append('username', document.getElementById('loginEmail').value);
                form.append('password', document.getElementById('loginPassword').value);

                let res;
                try {
                    res = await fetch(`${API}/auth/login`, {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: form
                    });
                } catch (networkErr) {
                    errEl.textContent = 'Erro de rede: backend inacessível (' + networkErr.message + ')';
                    errEl.classList.remove('hidden');
                    return;
                }

                if (!res.ok) {
                    let detail = 'Erro ' + res.status;
                    try { const d = await res.json(); detail = d.detail || detail; } catch (_) {}
                    if (res.status === 401) detail = 'Email ou senha incorretos';
                    errEl.textContent = detail;
                    errEl.classList.remove('hidden');
                    return;
                }

                const data = await res.json();
                token = data.access_token;
                user = data.user;

                localStorage.setItem('token', token);
                localStorage.setItem('user', JSON.stringify(user));

                showDashboard();
            } catch (err) {
                errEl.textContent = 'Erro inesperado: ' + err.message;
                errEl.classList.remove('hidden');
            }
        };

        function showDashboard() {
            document.getElementById('loginScreen').classList.add('hidden');
            document.getElementById('dashboardScreen').classList.remove('hidden');
            document.getElementById('userName').textContent = user.name;
            
            // Mostrar botão de ingestão IPCA apenas para admins
            if (user.is_admin) {
                document.getElementById('ipcaIngestBtn').style.display = 'flex';
            }

            // Ocultar funcionalidades de admin para usuários normais
            if (!user.is_admin) {
                document.getElementById('usersBtn')?.classList.add('hidden');
                document.getElementById('btnAddCategory')?.classList.add('hidden');
                document.getElementById('btnAddProfile')?.classList.add('hidden');
                // Sidebar: esconder adicionar, mas manter acesso a Usuários (pode editar o próprio)
                document.getElementById('sidebarBtnAddCategory')?.classList.add('hidden');
                document.getElementById('sidebarBtnAddProfile')?.classList.add('hidden');
            }
            
            // Carregar tema salvo (dark mode é padrão quando não há preferência)
            const savedTheme = localStorage.getItem('darkMode');
            if (savedTheme === null || savedTheme === 'true') {
                document.body.classList.add('dark-mode');
                document.getElementById('darkModeToggle')?.classList.add('active');
                const themeColor = document.getElementById('themeColorMeta');
                if (themeColor) themeColor.setAttribute('content', '#1f1f1f');
            }
            
            // Mostrar FAB na aba inicial (home) - delay para garantir que existe no DOM
            setTimeout(() => {
                const fab = document.getElementById('fabNewExpense');
                if (fab) fab.style.display = 'flex';
            }, 150);
            
            loadMonths();
        }

        function logout() {
            localStorage.clear();
            location.reload();
        }

        function showTab(tab, button) {
            // Ocultar tooltips externos ao trocar de aba
            ['inflTooltip','catInflTooltip','pvTooltip','mvmTooltip'].forEach(id => {
                const el = document.getElementById(id);
                if (el) el.style.opacity = '0';
            });

            // Controlar FAB
            const fab = document.getElementById('fabNewExpense');
            if (fab) {
                fab.style.display = (tab === 'home' || tab === 'expenses') ? 'flex' : 'none';
            }

            // Esconder todos os conteúdos
            document.querySelectorAll('.tab-content').forEach(t => t.classList.add('hidden'));

            // Resetar todos os botões para estilo não selecionado
            const allTabs = ['tabHome', 'tabExpenses', 'tabOpenfinance', 'tabCharts', 'tabInflation', 'tabIncome', 'tabAgent'];
            allTabs.forEach(id => {
                const btn = document.getElementById(id);
                if (btn) {
                    btn.style.backgroundColor = 'transparent';
                    btn.style.color = '#5f6368';
                    btn.style.fontWeight = '400';
                }
            });
            
            // Mostrar conteúdo selecionado
            document.getElementById(tab + 'Tab').classList.remove('hidden');
            
            // Aplicar estilo selecionado ao botão clicado
            if (button) {
                button.style.backgroundColor = '#e8f0fe';
                button.style.color = '#1a73e8';
                button.style.fontWeight = '500';
            }
            
            // Carregar dados da aba
            if (tab === 'home') loadDashboardData();
            else if (tab === 'expenses') loadExpenses();
            else if (tab === 'charts') loadCharts();
            else if (tab === 'inflation') loadInflation();
            else if (tab === 'income') loadIncome();
            // agent tab needs no initial load
            else if (tab === 'openfinance') loadOpenFinance();
        }

        // ✅ 8️⃣ Carregar meses e iniciar no mês vigente
        async function loadMonths() {
            try {
                const _md=await api(`${API}/expenses/months`);
                months=[..._md].reverse();
                const currentMonth=new Date().toISOString().slice(0,7);
                const homeSelect=document.getElementById('homeMonthFilter');
                const expenseSelect=document.getElementById('expenseMonthFilter');
                const prevHome=homeSelect.value;
                const prevExpense=expenseSelect.value;
                const options=months.map(m=>`<option value="${m.value}">${m.label}</option>`).join('');
                homeSelect.innerHTML=options;expenseSelect.innerHTML=options;
                const homeTarget=prevHome&&months.find(m=>m.value===prevHome)?prevHome:currentMonth;
                const expenseTarget=prevExpense&&months.find(m=>m.value===prevExpense)?prevExpense:currentMonth;
                homeSelect.value=homeTarget||(months.length>0?months[months.length-1].value:'');
                expenseSelect.value=expenseTarget||(months.length>0?months[months.length-1].value:'');
                // Populate income month filter with same list
                const incomeSelect=document.getElementById('incomeMonthFilter');
                if(incomeSelect){
                    const prevIncome=incomeSelect.value;
                    incomeSelect.innerHTML=options;
                    const incomeTarget=prevIncome&&months.find(m=>m.value===prevIncome)?prevIncome:currentMonth;
                    incomeSelect.value=incomeTarget||(months.length>0?months[months.length-1].value:'');
                }
                
                // ✅ Atualizar filtros dependentes do mês
                await updateExpenseFilters();
                
                loadDashboardData();
            } catch (err) {
                console.error('Erro ao carregar meses:', err);
            }
        }


        function stepMonth(id,dir){const s=document.getElementById(id);if(!s)return;const n=s.selectedIndex+dir;if(n>=0&&n<s.options.length){s.selectedIndex=n;s.dispatchEvent(new Event('change'));}}

        let paymentMethods = []; // todos os métodos de pagamento de todos os usuários
        let activePmFilter=[]; // [] = all selected (IDs inteiros)
        let activeDailyPmFilter=[]; // [] = all selected (IDs inteiros)
        let activeExpensePmFilter=[]; // [] = all selected (IDs inteiros)
        let selectedDailyCatIds=null; // null = nunca inicializado (selecionar tudo); [] = usuário desmarcou tudo
        let dailyTargetInitialized=false;
        let dailyCatMonth='';
        let dailyChartMode='dia';

        function setDailyChartMode(mode) {
            dailyChartMode = mode;
            document.querySelectorAll('.daily-mode-btn').forEach(btn => btn.classList.remove('active'));
            const activeBtn = document.getElementById('dailyModeBtn_' + mode);
            if (activeBtn) activeBtn.classList.add('active');
            updateDailyChart();
        }

        function toggleDailyCatFilterDropdown(){
            const dd=document.getElementById('dailyCatFilterDropdown');
            dd.classList.toggle('hidden');
        }
        function updateDailyCatFilterText(){
            const total=document.querySelectorAll('.daily-cat-filter').length;
            const sel=selectedDailyCatIds===null?total:(selectedDailyCatIds.length);
            document.getElementById('dailyCatFilterText').textContent=sel>=total?'Todas':sel===0?'Nenhuma':sel+' sel.';
        }
        function toggleDailyCatFilter(catId){
            if(selectedDailyCatIds===null) selectedDailyCatIds=Array.from(document.querySelectorAll('.daily-cat-filter')).map(cb=>parseInt(cb.value));
            const idx=selectedDailyCatIds.indexOf(catId);
            if(idx>-1) selectedDailyCatIds.splice(idx,1); else selectedDailyCatIds.push(catId);
            const allCb=document.getElementById('dailyCatFilterAll');
            if(allCb) allCb.checked=selectedDailyCatIds.length===document.querySelectorAll('.daily-cat-filter').length;
            updateDailyCatFilterText();
            updateDailyChart();
        }
        function toggleAllDailyCategories(checked){
            selectedDailyCatIds=checked?Array.from(document.querySelectorAll('.daily-cat-filter')).map(cb=>parseInt(cb.value)):[];
            document.querySelectorAll('.daily-cat-filter').forEach(cb=>{ cb.checked=checked; });
            updateDailyCatFilterText();
            updateDailyChart();
        }
        // Fechar dropdown ao clicar fora
        document.addEventListener('click', e=>{
            const dd=document.getElementById('dailyCatFilterDropdown');
            const btn=document.getElementById('dailyCatFilterBtn');
            if(dd&&btn&&!dd.contains(e.target)&&!btn.contains(e.target)) dd.classList.add('hidden');
        });

        function renderPmFilterButtons() {
            // Filtra métodos do usuário logado
            const myPms = userPms(user.id);
            const isDark = document.body.classList.contains('dark-mode');
            const db = isDark ? '#3c4043' : '#f1f3f4';
            const sg = isDark ? '#1e3a5f' : '#e8f0fe';

            // Botões principais (só PMs com despesas no mês atual)
            const cont = document.getElementById('pmFiltersContainer');
            if (cont) {
                const visiblePms = window._pmIdsInicio ? myPms.filter(pm => window._pmIdsInicio.has(pm.id)) : myPms;
                cont.innerHTML = visiblePms.map(pm => {
                    const on = activePmFilter.length > 0 && activePmFilter.includes(pm.id);
                    const iconHtml = pm.icon_path
                        ? `<img src="${pm.icon_path}" style="width:20px;height:20px;object-fit:contain;">`
                        : `<span style="font-size:12px;">💳</span>`;
                    const lockBtn = pm.is_card
                        ? `<button onclick="togglePmClosed(${pm.id})" title="${pm.is_closed ? 'Fatura fechada — clique para abrir' : 'Fatura aberta — clique para fechar'}"
                            style="width:20px;height:20px;border:none;background:transparent;cursor:pointer;display:flex;align-items:center;justify-content:center;padding:0;flex-shrink:0;">
                            <img src="/icons/system/${pm.is_closed ? 'lock' : 'unlock'}.png" style="width:16px;height:16px;object-fit:contain;opacity:0.65;">
                          </button>`
                        : `<div style="width:20px;height:20px;"></div>`;
                    return `<div style="display:flex;flex-direction:column;align-items:center;gap:2px;flex-shrink:0;">
                        ${lockBtn}
                        <button onclick="togglePmFilter(${pm.id})" id="pmFilter_${pm.id}" title="${pm.description}"
                            style="width:38px;height:38px;border-radius:50%;border:2px solid ${on?'#1a73e8':'transparent'};background:${on?sg:db};padding:4px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:border-color .15s,background .15s;">${iconHtml}</button>
                    </div>`;
                }).join('');
            }

            // Botões daily chart (só PMs com despesas no mês atual)
            const dcont = document.getElementById('dailyPmFiltersContainer');
            if (dcont) {
                const visibleDiaryPms = window._pmIdsDiary ? myPms.filter(pm => window._pmIdsDiary.has(pm.id)) : myPms;
                dcont.innerHTML = visibleDiaryPms.map(pm => {
                    const on = activeDailyPmFilter.length > 0 && activeDailyPmFilter.includes(pm.id);
                    const iconHtml = pm.icon_path
                        ? `<img src="${pm.icon_path}" style="width:18px;height:18px;object-fit:contain;">`
                        : `<span style="font-size:11px;">💳</span>`;
                    return `<button onclick="toggleDailyPmFilter(${pm.id})" id="dailyPmFilter_${pm.id}" title="${pm.description}"
                        style="width:34px;height:34px;border-radius:50%;border:2px solid ${on?'#1a73e8':'transparent'};background:${on?sg:db};padding:4px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:border-color .15s,background .15s;">${iconHtml}</button>`;
                }).join('');
            }

            // Botões aba Despesas (apenas PMs com despesas no mês filtrado)
            const econt = document.getElementById('expensePmFiltersContainer');
            if (econt) {
                const visibleExpPms = window._pmIdsExpense ? myPms.filter(pm => window._pmIdsExpense.has(pm.id)) : myPms;
                econt.innerHTML = visibleExpPms.map(pm => {
                    const on = activeExpensePmFilter.length > 0 && activeExpensePmFilter.includes(pm.id);
                    const iconHtml = pm.icon_path
                        ? `<img src="${pm.icon_path}" style="width:18px;height:18px;object-fit:contain;">`
                        : `<span style="font-size:11px;">💳</span>`;
                    return `<button onclick="toggleExpensePmFilter(${pm.id})" id="expensePmFilter_${pm.id}" title="${pm.description}"
                        style="width:34px;height:34px;border-radius:50%;border:2px solid ${on?'#1a73e8':'transparent'};background:${on?sg:db};padding:4px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:border-color .15s,background .15s;">${iconHtml}</button>`;
                }).join('');
            }
        }

        function toggleExpensePmFilter(id) {
            id = parseInt(id);
            const idx = activeExpensePmFilter.indexOf(id);
            if (idx > -1) activeExpensePmFilter.splice(idx, 1); else activeExpensePmFilter.push(id);
            const visibleCount = window._pmIdsExpense ? userPms(user.id).filter(p => window._pmIdsExpense.has(p.id)).length : userPms(user.id).length;
            if (activeExpensePmFilter.length === visibleCount) activeExpensePmFilter = [];
            applyExpensePmFilterStyles();
            loadExpenses();
        }
        function applyExpensePmFilterStyles() {
            const isDark = document.body.classList.contains('dark-mode');
            const sb = '#1a73e8', sg = isDark ? '#1e3a5f' : '#e8f0fe', db = isDark ? '#3c4043' : '#f1f3f4';
            userPms(user.id).forEach(pm => {
                const btn = document.getElementById('expensePmFilter_' + pm.id);
                if (!btn) return;
                const on = activeExpensePmFilter.length > 0 && activeExpensePmFilter.includes(pm.id);
                btn.style.borderColor = on ? sb : 'transparent';
                btn.style.background = on ? sg : db;
            });
        }

        function toggleDailyPmFilter(id){
            id = parseInt(id);
            const idx=activeDailyPmFilter.indexOf(id);
            if(idx>-1) activeDailyPmFilter.splice(idx,1); else activeDailyPmFilter.push(id);
            const visibleCount = window._pmIdsDiary ? userPms(user.id).filter(pm => window._pmIdsDiary.has(pm.id)).length : userPms(user.id).length;
            if(activeDailyPmFilter.length === visibleCount) activeDailyPmFilter=[];
            applyDailyPmFilterStyles();
            updateDailyChart();
        }
        function applyDailyPmFilterStyles(){
            const isDark=document.body.classList.contains('dark-mode');
            const sb='#1a73e8',sg=isDark?'#1e3a5f':'#e8f0fe',db=isDark?'#3c4043':'#f1f3f4';
            userPms(user.id).forEach(pm=>{
                const btn=document.getElementById('dailyPmFilter_'+pm.id);
                if(!btn)return;
                const on=activeDailyPmFilter.length>0&&activeDailyPmFilter.includes(pm.id);
                btn.style.borderColor=on?sb:'transparent';btn.style.background=on?sg:db;
            });
        }
        function onDailyTargetChange(){
            const sel=document.getElementById('dailyTargetSelect');
            const tgtId=sel?parseInt(sel.value):NaN;
            const tgt=!isNaN(tgtId)&&tgtId?(targets||[]).find(t=>t.id===tgtId):null;
            if(tgt&&tgt.payment_methods&&tgt.payment_methods.length>0){
                activeDailyPmFilter=[...tgt.payment_methods];
            } else {
                activeDailyPmFilter=[];
            }
            selectedDailyCatIds=null;
            applyDailyPmFilterStyles();
            updateDailyChart();
        }
        function togglePmFilter(id){
            id = parseInt(id);
            const idx=activePmFilter.indexOf(id);
            if(idx>-1) activePmFilter.splice(idx,1); else activePmFilter.push(id);
            const visibleCount = window._pmIdsInicio ? userPms(user.id).filter(pm => window._pmIdsInicio.has(pm.id)).length : userPms(user.id).length;
            if(activePmFilter.length === visibleCount) activePmFilter=[];
            applyPmFilterStyles();
            loadDashboardData();
        }
        function applyPmFilterStyles(){
            const isDark=document.body.classList.contains('dark-mode');
            const sb='#1a73e8',sg=isDark?'#1e3a5f':'#e8f0fe',db=isDark?'#3c4043':'#f1f3f4';
            userPms(user.id).forEach(pm=>{
                const btn=document.getElementById('pmFilter_'+pm.id);
                if(!btn)return;
                const on=activePmFilter.length>0&&activePmFilter.includes(pm.id);
                btn.style.borderColor=on?sb:'transparent';btn.style.background=on?sg:db;
            });
        }

