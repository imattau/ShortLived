/* Standalone SW for web push (do not modify flutter_service_worker.js) */
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(self.clients.claim()));

self.addEventListener('push', event => {
  let payload = {};
  try { payload = event.data ? event.data.json() : {}; } catch (_) {}
  const title = payload.title || 'ShortLived';
  const options = {
    body: payload.body || '',
    icon: payload.icon || 'icons/Icon-192.png',
    badge: payload.badge || 'icons/Icon-192.png',
    data: { url: payload.url || '/' },
    tag: payload.tag || 'shortlived',
    renotify: !!payload.renotify,
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  const url = (event.notification.data && event.notification.data.url) || '/';
  event.waitUntil((async () => {
    const all = await clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const c of all) { if ('focus' in c) { c.focus(); if (url) c.navigate(url); return; } }
    if (clients.openWindow) await clients.openWindow(url);
  })());
});
