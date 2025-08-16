/* pseudo-implementation outline */
import { Router } from 'itty-router'
import { Env, sendPush } from './wp'; // your helper using web-push-like lib

const router = Router();
router.post('/subscribe', async (req: Request, env: Env) => {
const sub = await req.json();
// persist in KV: key=sub.endpoint
await env.SUBS.put(sub.endpoint, JSON.stringify(sub));
return new Response('ok');
});

router.post('/send', async (req: Request, env: Env) => {
const { title, body, url } = await req.json();
const list = await env.SUBS.list();
let ok = 0;
for (const k of list.keys) {
const raw = await env.SUBS.get(k.name);
if (!raw) continue;
const sub = JSON.parse(raw);
const payload = JSON.stringify({ title, body, url });
const r = await sendPush(sub, payload, env); // uses VAPID private key
if (r) ok++;
}
return new Response(JSON.stringify({ sent: ok }), { headers: { 'content-type': 'application/json' }});
});

export default { fetch: (req: Request, env: Env, ctx: ExecutionContext) => router.handle(req, env, ctx) }
