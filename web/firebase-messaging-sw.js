/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

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

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw] background message', payload);
});
