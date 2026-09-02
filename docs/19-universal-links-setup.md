# Universal links — setting up `brewpath.maximsan.dev`

The one-time human setup that makes a tapped BrewPath link open the app. About
20 minutes, and **nothing to buy** — `maximsan.dev` is already owned and a
subdomain of it is free.

- **Ruling:** [#34](https://github.com/maximsan/brewpath/issues/34) — universal
  links with an App Store fallback, on a dedicated subdomain, landing page
  deferred.
- **Build ticket:** [#171](https://github.com/maximsan/brewpath/issues/171).
- **Owner:** you. Steps 1–5 are the part no agent can do; step 6 hands over.

**Why any of this is needed.** Apple will not let an app claim a URL on a
domain that has not vouched for it — otherwise any app could hijack links to
your bank. The vouching is one small JSON file served from the domain. That is
the whole reason a domain is involved.

## Before you start

- Access to DNS for `maximsan.dev`
- A Vercel account
- An Apple Developer account

## Step 1 — Get your Apple Team ID

1. Sign in at **[developer.apple.com/account](https://developer.apple.com/account)**.
2. Open **Membership details**.
3. Copy **Team ID** — ten characters, like `A1B2C3D4E5`.

Already have the project open in Xcode? It is also at **Runner → Signing &
Capabilities → Team**. Keep it to hand; step 2 needs it.

## Step 2 — Make the site (three files)

A new, separate repo — this is not the Flutter app. Call it `brewpath-links`.

```
brewpath-links/
├── .well-known/
│   └── apple-app-site-association     ← no .json extension, ever
├── vercel.json
└── index.html
```

### `.well-known/apple-app-site-association`

Replace `<TEAM_ID>` with the ten characters from step 1. Nothing else changes.

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["<TEAM_ID>.dev.maximsan.brewPath"],
        "components": [
          { "/": "/", "comment": "the marketing entry" },
          { "/": "/card/*", "comment": "a shared collectible" }
        ]
      }
    ]
  }
}
```

⚠️ **The filename has no extension.** Not `.json`, not anything. Apple looks for
this exact name and silently ignores the file otherwise.

### `vercel.json`

Use this one **now, before the app is on the App Store**:

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "headers": [
    {
      "source": "/.well-known/apple-app-site-association",
      "headers": [{ "key": "Content-Type", "value": "application/json" }]
    }
  ]
}
```

The header is not optional decoration: the file has no extension, so without it
the server guesses, iOS receives the wrong content type and the link silently
never works.

**At launch**, once the app has a real App Store id, add the fallback so a
recipient without the app lands in the Store.

**What an App Store id is, and where to get it.** The number in every App Store
URL — `apps.apple.com/app/id6448123456`. It names the *listing*, not a build,
and you get it the moment you create the app record in **App Store Connect**.
The app does not have to be submitted, let alone live, so you can have it early.

It is a **third** id, separate from the two already in play, and they are easy
to confuse:

| Id | Looks like | Where it goes |
| --- | --- | --- |
| Team ID | `A1B2C3D4E5` | the AASA file |
| Bundle id | `dev.maximsan.brewPath` | the AASA file, beside the Team ID |
| App Store id | `6448123456` | this redirect, and nowhere else |

Swapping it in is one file and one redeploy — no DNS change, no app rebuild, and
every link shared before it keeps working.

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "headers": [
    {
      "source": "/.well-known/apple-app-site-association",
      "headers": [{ "key": "Content-Type", "value": "application/json" }]
    }
  ],
  "redirects": [
    {
      "source": "/:path((?!\\.well-known/).*)",
      "destination": "https://apps.apple.com/app/id<APP_STORE_ID>",
      "permanent": false
    }
  ]
}
```

Two things in that rule are load-bearing:

- **`(?!\\.well-known/)`** — redirects run *before* the filesystem on Vercel, so
  a plain `/(.*)` catch-all would redirect Apple's request for the AASA file
  too, and **Apple does not follow redirects**. The whole feature would fail
  with everything apparently configured.
- **`"permanent": false`** — a 307, not a 308. A 308 is cached by browsers
  indefinitely, and this redirect gets replaced by the real landing page later.

### `index.html`

Anything; it is only what a browser shows before the App Store redirect exists.

```html
<!doctype html>
<meta charset="utf-8" />
<title>BrewPath</title>
<p>BrewPath — coming to the App Store.</p>
```

## Step 3 — Deploy it

```bash
npm i -g vercel
vercel login
cd brewpath-links
vercel deploy --prod
```

When asked, choose framework preset **Other**, no build command, and the
repository root as the source directory.

## Step 4 — Point the subdomain at it

1. Vercel dashboard → the project → **Settings → Domains → Add**.
2. Enter `brewpath.maximsan.dev`. Vercel shows the DNS record it wants.
3. At whoever manages `maximsan.dev`, add exactly that record — normally:

   | Type | Name | Value |
   | --- | --- | --- |
   | CNAME | `brewpath` | `cname.vercel-dns.com` (use whatever Vercel shows) |

⚠️ **Touch nothing for `maximsan.dev` itself.** The CV site keeps every record
it has. Claiming the root domain is the mistake this whole subdomain exists to
avoid — it would make every link to your CV open BrewPath instead, for anyone
with the app installed.

DNS usually takes minutes.

## Step 5 — Verify, before any app work starts

```bash
curl -sI https://brewpath.maximsan.dev/.well-known/apple-app-site-association
```

All three must hold:

- `HTTP/2 200`
- `content-type: application/json`
- **no `location:` header** — any redirect here breaks it

Then check the content is really your file:

```bash
curl -s https://brewpath.maximsan.dev/.well-known/apple-app-site-association
```

It must print the JSON with your real Team ID in it.

Finally, what **Apple** actually fetched — this is the copy iOS uses, and it can
lag behind yours by a while:

```
https://app-site-association.cdn-apple.com/a/v1/brewpath.maximsan.dev
```

## Step 6 — Hand over

The app half of [#171](https://github.com/maximsan/brewpath/issues/171) needs
two things from you:

- the **Team ID**, and
- confirmation that step 5 passed.

The entitlement (`applinks:brewpath.maximsan.dev`), the router work and the
tests are the agent's part.

## When it doesn't work

| Symptom | Cause |
| --- | --- |
| The file downloads instead of displaying | The `Content-Type` header rule is missing or the path does not match |
| `404` | `.well-known/` was not deployed — move the files under `public/` and set `"outputDirectory": "public"` |
| A `location:` header on the AASA URL | The catch-all redirect is swallowing it — check the `(?!\.well-known/)` guard |
| Links stop working after an edit | Apple's CDN caches aggressively; give it time, and reinstall the app on the test device |

## What this deliberately does not do

- **No designed landing page.** Deferred by #34; the same URLs upgrade in place
  later with nothing reissued.
- **No claim on `maximsan.dev`.** Only the subdomain is claimed.
- **No product domain.** `brewpath.maximsan.dev` is right for v1 and free.
  Switching later is non-breaking — the entitlement accepts several domains, so
  links already shared keep working.
