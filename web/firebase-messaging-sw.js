/* eslint-disable no-undef */
// Must match firebase_core_web supportedFirebaseJsSdkVersion (11.7.0).
importScripts('https://www.gstatic.com/firebasejs/11.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBoLEvc5Qo_dolZ1uK8GwTQ1J6dJkKOBh4',
  appId: '1:537584520795:web:6d64971b7337b957e2797e',
  messagingSenderId: '537584520795',
  projectId: 'poptaxi-ae8fd',
  authDomain: 'poptaxi-ae8fd.firebaseapp.com',
  storageBucket: 'poptaxi-ae8fd.firebasestorage.app',
  measurementId: 'G-7508CB7VPX',
});

const messaging = firebase.messaging();

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

function _lc(v) {
  return (v || '').toString().toLowerCase();
}

function isBookingCancellation(payload) {
  const n = payload.notification || {};
  const d = payload.data || {};
  const title = _lc(n.title || d.title);
  const body = _lc(n.body || d.body);
  return (
    title.includes('booking cancel') ||
    title.includes('cancelled') ||
    title.includes('canceled') ||
    body.includes('booking cancel') ||
    body.includes('cancelled')
  );
}

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw] background message', payload);
  const n = payload.notification || {};
  const d = payload.data || {};
  const title = n.title || d.title || 'POP Driver';
  const body = n.body || d.body || d.message || '';
  const options = {
    body: body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: d,
    tag: isBookingCancellation(payload) ? 'booking-cancel' : 'booking',
    renotify: true,
  };
  return self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ('focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    }),
  );
});
