# Web/PWA notes

## Build
```bash
# dev
flutter run -d chrome

# prod (installable PWA)
flutter build web --release --pwa-strategy=offline-first
# if debugging service worker issues:
# flutter build web --release --pwa-strategy=none
```

## Notes
- Remote videos from relays/media hosts are fetched network-first and are not cached by the service worker.
- `web/index.html` captures `beforeinstallprompt` so you can show an install button if desired.
