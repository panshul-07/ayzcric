# Google Play Release Guide

This repository is prepared for Play Store release builds.

## 1) Set signing keys
1. Create an upload key:
   ```bash
   ./scripts/create_keystore.sh ~/keys/cricket-upload.jks upload
   ```
2. Copy and fill:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
3. Update `android/key.properties` with your real values.

## 2) Build release bundle (AAB)
```bash
./scripts/build_playstore_bundle.sh
```

Output:
- `build/app/outputs/bundle/release/app-release.aab`

## 3) Play Console setup
1. Create app in Play Console.
2. Complete app content declarations (Data Safety, Ads, target audience).
3. Upload `app-release.aab` to an internal testing track first.
4. Add store listing assets:
   - App name: Cricket Dynasty Manager
   - Short description (80 chars)
   - Full description
   - Screenshots (phone/tablet)
   - Feature graphic (1024x500)
   - App icon (512x512)
5. Configure countries/pricing.
6. Roll out to production after internal and closed testing pass.

## 4) Required before production
- Privacy Policy URL
- Support email/contact
- Crash monitoring (recommended)
- App signing by Google Play (recommended)

## 5) What I can do next automatically
- Generate launch icon + splash updates
- Prepare production/release checklist in CI
- Add app versioning and changelog flow
- Create Play Store listing draft text and screenshot shot-list

Final publish button must be clicked from your Play Console account.
