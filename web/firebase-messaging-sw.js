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

function buildLaunchUrl(data) {
  const params = new URLSearchParams();
  params.set('fcm_click', '1');
  Object.keys(data || {}).forEach(function (key) {
    const value = data[key];
    if (value !== undefined && value !== null && String(value).length > 0) {
      params.set(key, String(value));
    }
  });
  return '/?' + params.toString();
}

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw] background message', payload);
  // FCM already shows a system banner when `notification` is in the payload.
  if (payload.notification) {
    return Promise.resolve();
  }
  const d = payload.data || {};
  const title = d.title || 'POP Driver';
  const body = d.body || d.message || '';
  const notificationData = Object.assign({}, d, {
    title: title,
    body: body,
  });
  const options = {
    body: body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: notificationData,
    tag: isBookingCancellation(payload) ? 'booking-cancel' : 'booking',
    renotify: true,
  };
  return self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', function (event) {
  console.log('[firebase-messaging-sw] Notification click', event.notification);
  event.notification.close();

  const data = event.notification.data || {};
  const title = data.title || event.notification.title || '';
  const body = data.body || event.notification.body || '';
  const message = {
    type: 'FIREBASE_NOTIFICATION_CLICK',
    title: title,
    body: body,
    data: data,
  };

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (clientList) {
      for (var i = 0; i < clientList.length; i++) {
        var client = clientList[i];
        if (new URL(client.url).origin === self.location.origin) {
          client.postMessage(message);
          if ('focus' in client) {
            return client.focus();
          }
          return undefined;
        }
      }

      if (clients.openWindow) {
        return clients.openWindow(buildLaunchUrl(data)).then(function (newClient) {
          if (!newClient) return undefined;
          return new Promise(function (resolve) {
            setTimeout(function () {
              newClient.postMessage(message);
              resolve();
            }, 2500);
          });
        });
      }

      return undefined;
    })
  );
});
