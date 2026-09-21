# LifeOS Omi VPS deployment

This directory is the deployment boundary for the LifeOS-owned Omi fork.

## Architecture

The Omi fork is the capture/device subsystem. It is not the canonical LifeOS memory store.

```
Omi wearable / iPhone
        |
        v
https://<OMI_HOST>
        |
      Caddy
        |
    Omi FastAPI
      /      \
 Redis      Firebase/Firestore (Omi operational state)
        \
         -> LifeOS ingestion/synthesis -> canonical LifeOS storage
```

The first deploy intentionally preserves Omi's Firebase expectations so the mobile app can work without a risky rewrite. Durable LifeOS records should be projected into LifeOS/Supabase; Firestore is operational compatibility state, not the long-term source of truth.

## VPS prerequisites

- Ubuntu/Debian VPS with Docker Engine + Docker Compose plugin
- DNS A/AAAA record for `OMI_HOST` pointed at the VPS
- inbound TCP 80/443; SSH restricted to the administrator
- a Firebase/GCP project owned by Jordan for Auth + Firestore
- Firebase service-account JSON stored only at:
  `backend/deploy/lifeos/secrets/firebase-service-account.json`

## Deploy

From the repository root on the VPS:

```bash
cd backend/deploy/lifeos
cp .env.example .env
mkdir -p secrets
# place firebase-service-account.json in ./secrets/
docker compose up -d --build
docker compose ps
curl -fsS "https://$OMI_HOST/"
```

Caddy obtains and renews TLS automatically after DNS resolves.

## Secrets

Never commit:
- `.env`
- `secrets/`
- Firebase service-account JSON
- Supabase service-role key
- model/provider API keys

## What is still gated on the VPS/Firebase setup

1. Fill the real hostname and secrets.
2. Bring up the stack and smoke-test the API.
3. Create the LifeOS projection/sink from completed Omi conversations into the existing LifeOS ingestion pipeline.
4. Build the iPhone app with `app/scripts/build-lifeos-ios.sh`.
5. Verify capture -> transcript -> Omi operational record -> LifeOS canonical record end-to-end.

## Apple Watch

This upstream repository currently has no native watchOS/WatchKit target. For V1, use the iPhone app plus an Omi wearable for always-on audio. A LifeOS Watch app can be added later as a control/capture trigger, but it should not block the always-on capture path.
