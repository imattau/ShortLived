# Minimal Web Push server (example)
- Use **Cloudflare Worker** or **Node** with `web-push` to store subscriptions and send pushes.
- Keep it privacy-first: store only the subscription JSON; no user PII.

## Generate VAPID keys
```bash
npx web-push generate-vapid-keys
```

Record:

* Public Key  -> used by app (PushConfig.vapidPublicKey)
* Private Key -> kept on the server

## Example: Cloudflare Worker (TypeScript)

See `worker.ts`. Deploy to a HTTPS URL and set it as `PUSH_SUBSCRIBE_URL`.
