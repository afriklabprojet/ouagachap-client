importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyBpSsJdAWJ0e8dlRiJKYLlvZzHf_c1n9oo",
    authDomain: "ouaga-chap.firebaseapp.com",
    projectId: "ouaga-chap",
    storageBucket: "ouaga-chap.firebasestorage.app",
    messagingSenderId: "441145504200",
    appId: "1:441145504200:web:86e6b752010969baa810fd"
});

const messaging = firebase.messaging();

// Background message handler
messaging.onBackgroundMessage((message) => {
    console.log("Background message received:", message);

    const notificationTitle = message.notification?.title || "OUAGA CHAP";
    const notificationOptions = {
        body: message.notification?.body || "Vous avez un nouveau message",
        icon: "/icons/Icon-192.png",
        badge: "/icons/Icon-192.png",
        data: message.data
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});
