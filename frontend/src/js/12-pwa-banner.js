    (function() {
        const ua = navigator.userAgent;
        const isIOS = /iPhone|iPad|iPod/.test(ua);
        if (!isIOS) return;
        const isStandalone = navigator.standalone === true;
        if (isStandalone) return;
        const dismissed = sessionStorage.getItem('pwa-banner-dismissed');
        if (dismissed) return;

        const isChrome = /CriOS/.test(ua);
        const isSafari = !isChrome && /Safari/.test(ua) && !/FxiOS|EdgiOS|OPiOS/.test(ua);

        const isDark = () => document.body.classList.contains('dark-mode');

        const banner = document.createElement('div');
        banner.id = 'pwa-ios-banner';
        banner.style.cssText = [
            'position:fixed', 'bottom:0', 'left:0', 'right:0', 'z-index:10000',
            'padding:12px 16px 12px 16px',
            'display:flex', 'align-items:flex-start', 'gap:10px',
            'font-size:13px', 'line-height:1.45',
            'box-shadow:0 -2px 12px rgba(0,0,0,0.18)',
            'transition:background 0.2s,color 0.2s'
        ].join(';');

        function applyTheme() {
            const dark = isDark();
            banner.style.background = dark ? '#2d2f31' : '#fff';
            banner.style.color      = dark ? '#e8eaed' : '#202124';
            banner.style.borderTop  = `1px solid ${dark ? '#5f6368' : '#dadce0'}`;
        }
        applyTheme();

        const observer = new MutationObserver(applyTheme);
        observer.observe(document.body, { attributes: true, attributeFilter: ['class'] });

        let msg, icon;
        if (isChrome) {
            icon = '🌐';
            msg  = '<b>Abra no Safari</b> para instalar o fisc.io na tela inicial do iPhone.';
        } else if (isSafari) {
            icon = '📲';
            msg  = 'Instale o fisc.io: toque em <b>Compartilhar</b> <span style="font-size:15px;">⎙</span> e depois <b>Adicionar à Tela de Início</b>.';
        } else {
            return;
        }

        banner.innerHTML = `
            <span style="font-size:20px;flex-shrink:0;margin-top:1px;">${icon}</span>
            <span style="flex:1;">${msg}</span>
            <button onclick="sessionStorage.setItem('pwa-banner-dismissed','1');this.closest('#pwa-ios-banner').remove();"
                    style="background:none;border:none;cursor:pointer;font-size:18px;line-height:1;padding:0 0 0 4px;flex-shrink:0;opacity:0.6;">✕</button>`;

        document.body.appendChild(banner);
    })();
