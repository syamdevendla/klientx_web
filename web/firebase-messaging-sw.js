importScripts('https://www.gstatic.com/firebasejs/7.14.2/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/7.14.2/firebase-messaging.js');
/*Update this config*/
var config = {
    apiKey: "AIzaSyD25yuE7LH0LIIK8nOqgrya2s5pl2X_QYY",
  authDomain: "klientx-app.firebaseapp.com",
  databaseURL: "https://klientx-app-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "klientx-app",
  storageBucket: "klientx-app.appspot.com",
  messagingSenderId: "277781236923",
  appId: "1:277781236923:web:5a600e52df27b52c4c6d9e",
  measurementId: "G-S4QKKMMB96"
  };
  firebase.initializeApp(config);

  const messaging = firebase.messaging();
  messaging.setBackgroundMessageHandler(function(payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    const notificationTitle = payload.data.title;
    const notificationOptions = {
      body: payload.data.body,
      icon: 'http://localhost/gcm-push/img/icon.png',
      image: 'http://localhost/gcm-push/img/d.png'
    };
  
    return self.registration.showNotification(notificationTitle,
        notificationOptions);
  });