# PashamCrafts Mobile Validation

The `pashamcrafts-mobile` repository runs its own GitHub Actions while private-repository Actions quota is available. This public verifier is retained only as a fallback for exact-commit validation after that quota is exhausted or private Actions are otherwise unavailable.

## Credentials

- `PASHAMCRAFTS_READ_TOKEN`: Contents read-only for `faheemKamboh/pashamcrafts` and `faheemKamboh/pashamcrafts-mobile`.
- `PASHAMCRAFTS_STATUS_TOKEN`: Commit statuses read/write for the same repositories. Contents may remain no-access unless GitHub requires read-only repository lookup.

The checkout token is never used for status writes and neither token has source write access.

## Fallback request

Manually dispatch **Validate PashamCrafts mobile** with one exact 40-character `target_sha` only when the mobile repository's own Actions cannot be used.

Do not maintain an automatic committed request file while private mobile Actions remain available.

## Checks

The fallback workflow runs on Node.js 22 and validates dependency installation, strict TypeScript, Expo ESLint, Jest and React Native Testing Library tests, Expo Doctor, Android/iOS/web export, and the production dependency audit.

Failure logs are encrypted before upload. Generated bundles and private source are never uploaded.
