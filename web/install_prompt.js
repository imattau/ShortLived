/* Non-blocking PWA install prompt stub for debug and release. */
(function () {
  try {
    window.__pwaDeferredPrompt = null;
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      window.__pwaDeferredPrompt = e; // call prompt() later from UI
    });
  } catch (_) {
    // Never block startup
  }
})();
