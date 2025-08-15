(function() {
  let deferred;
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferred = e;
    window.dispatchEvent(new Event('__pwa-install-available'));
  });

  window.__pwaPrompt = async function() {
    if (!deferred) return { ok: false, reason: 'not-available' };
    deferred.prompt();
    const { outcome } = await deferred.userChoice;
    deferred = null;
    return { ok: outcome === 'accepted', outcome };
  };
})();
