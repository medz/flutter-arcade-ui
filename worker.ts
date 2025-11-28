export default {
  async fetch(req, env) {
    const res = await env.ASSETS.fetch(req);
    if (res.status !== 404) return res;

    return env.ASSETS.fetch("index.html", req);
  },
} satisfies ExportedHandler<Cloudflare.Env>;
