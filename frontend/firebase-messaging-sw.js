// Firebase Messaging Service Worker + PWA
// Este arquivo é OBRIGATÓRIO e deve estar na raiz do site

const CACHE_NAME = 'splitmate-v1.2';

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Configuração do Firebase
const firebaseConfig = {
  apiKey: "AIzaSyCKjBU5unmEXsd6O1UD9_ZGaUdtFX5fRaw",
  authDomain: "splitmate-e3053.firebaseapp.com",
  projectId: "splitmate-e3053",
  storageBucket: "splitmate-e3053.firebasestorage.app",
  messagingSenderId: "165892275443",
  appId: "1:165892275443:web:4716b42e6f64afc2e14b86"
};

// Inicializar Firebase
firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

console.log('[firebase-messaging-sw.js] 🔥 Firebase + PWA Service Worker carregado');

// ============================================================================
// PWA - INSTALAÇÃO
// ============================================================================
self.addEventListener('install', (event) => {
  console.log('[SW] 📦 Instalando...');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll([
          '/',
          '/index.html',
          '/manifest.json',
          '/icon-192.png',
          '/icon-512.png'
        ]).catch(err => {
          console.warn('[SW] ⚠️ Alguns arquivos não foram cacheados');
        });
      })
  );
  
  self.skipWaiting();
});

// ============================================================================
// PWA - ATIVAÇÃO
// ============================================================================
self.addEventListener('activate', (event) => {
  console.log('[SW] ⚡ Ativando...');
  
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('[SW] 🗑️ Deletando cache antigo:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      return self.clients.claim();
    })
  );
});

// ============================================================================
// PWA - FETCH (Cache Strategy)
// ============================================================================
self.addEventListener('fetch', (event) => {
  // Ignorar APIs e recursos externos
  if (event.request.url.includes('splitmate-backend') || 
      event.request.url.includes('firebasestorage') ||
      event.request.url.includes('googleapis') ||
      event.request.url.includes('gstatic')) {
    return;
  }
  
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        if (response && response.status === 200 && event.request.method === 'GET') {
          const responseToCache = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return response;
      })
      .catch(() => {
        return caches.match(event.request).then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }
          return new Response('Offline', {
            status: 503,
            statusText: 'Service Unavailable'
          });
        });
      })
  );
});

// ============================================================================
// FIREBASE - MENSAGENS EM BACKGROUND
// ============================================================================
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] 📩 Mensagem recebida:', payload);
  
  const notificationTitle = payload.notification?.title || payload.data?.title || '💸 SplitMate';
  const notificationOptions = {
    body: payload.notification?.body || payload.data?.body || 'Nova notificação',
    icon: '/icon-192.png',
    badge: '/icon-192.png',
    vibrate: [200, 100, 200],
    data: payload.data || {},
    tag: 'splitmate-notification',
    requireInteraction: false
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// ============================================================================
// CLIQUES EM NOTIFICAÇÕES
// ============================================================================
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] 👆 Notificação clicada');
  
  event.notification.close();
  
  event.waitUntil(
    clients.matchAll({
      type: 'window',
      includeUncontrolled: true
    }).then((clientList) => {
      for (const client of clientList) {
        if (client.url.includes('splitmate') && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});

console.log('[firebase-messaging-sw.js] ✅ Service Worker pronto (Firebase + PWA)');

