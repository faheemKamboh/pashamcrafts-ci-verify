# PashamCrafts Mobile Validation

The public verifier validates exact commits from `faheemKamboh/pashamcrafts-mobile` without mirroring private source.

## Credentials

- `PASHAMCRAFTS_READ_TOKEN`: Contents read-only for `faheemKamboh/pashamcrafts` and `faheemKamboh/pashamcrafts-mobile`.
- `PASHAMCRAFTS_STATUS_TOKEN`: Commit statuses read/write for the same repositories. Contents may remain no-access unless GitHub requires read-only repository lookup.

The checkout token is never used for status writes and neither token has source write access.

## Request

Update `ci/requests/pashamcrafts-mobile.json` with one exact 40-character mobile commit SHA, or manually dispatch **Validate PashamCrafts mobile** with `target_sha`.

## Checks

The workflow runs on Node.js 22 and validates dependency installation, strict TypeScript, Expo ESLint, Jest and React Native Testing Library tests, Expo Doctor, Android/iOS/web export, and the production dependency audit.

Failure logs are encrypted before upload. Generated bundles and private source are never uploaded. The initial bootstrap may upload only a generated `package-lock.json`, containing public dependency metadata, for one day so the lockfile can be committed and future runs can use `npm ci`.
