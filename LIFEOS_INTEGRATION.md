# Omi -> LifeOS integration

Status: **forked and prepared for self-hosting**

Upstream: `BasedHardware/omi`
LifeOS fork: `dkm90x/omi`
LifeOS customization branch: `lifeos`

## Role in LifeOS

Omi is the always-on sensing and capture layer: microphones, wearable connectivity, phone and Apple Watch capture, transcripts, screen capture where supported, and event generation.

LifeOS remains the system of record and synthesis layer. Omi data should arrive in LifeOS as immutable source material, then flow through LifeOS entity resolution, claims/memories/relationships, project assignment, summaries, search, and agent context.

## Data ownership rule

Do not let the Omi fork become a second independent "brain."

- Omi Firebase/Firestore: operational compatibility state for the Omi app/backend.
- Redis: queues/cache.
- LifeOS/Supabase: canonical durable structured memory and synthesis.
- Large raw audio/media: object storage when enabled.
- GitHub: code, schemas, operating instructions, and receipts; not raw personal capture.

## Mobile

The `lifeos` app profile added on this branch permits a signed production-flavor iOS build to use a LifeOS-owned HTTPS API endpoint and a LifeOS-owned Firebase project.

Build helper:

```bash
cd app
export LIFEOS_API_BASE_URL="https://omi.example.com/"
export LIFEOS_FIREBASE_PROJECT_ID="<our-firebase-project-id>"
export FIREBASE_SERVICE_ACCOUNT_KEY="/secure/path/firebase-service-account.json"
bash scripts/build-lifeos-ios.sh
```

After a successful build:

```bash
ios-deploy --bundle build/ios/iphoneos/Runner.app
```

The Xcode project embeds the native `omiWatchApp` target in the iPhone app. Its bundle ID is derived as `$(APP_BUNDLE_IDENTIFIER).watchapp`; Watch audio travels to the paired iPhone over WatchConnectivity and then into the same Omi capture pipeline. If the Watch companion does not auto-install, enable it from the Watch app on the paired iPhone.

## Deployment

See `backend/deploy/lifeos/README.md`.

## Remaining implementation after VPS provisioning

- set DNS/TLS endpoint
- configure owned Firebase project
- configure transcription/model providers
- deploy the Omi API + Redis stack
- add and test the LifeOS ingestion projection
- build/install the signed iPhone + Apple Watch apps
- run an end-to-end capture test
