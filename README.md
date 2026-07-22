# Private Rails Project CI Validator

This public repository runs explicit, exact-commit validation for an allow-listed set of private Rails repositories when their own GitHub Actions runners are unavailable.

The repository name is retained to avoid disrupting the existing PashamCrafts integration. The validator itself supports multiple projects.

## Approved projects

| Project input | Private repository | Read-only secret |
| --- | --- | --- |
| `pashamcrafts` | `faheemKamboh/pashamcrafts` | `PASHAMCRAFTS_READ_TOKEN` |
| `taleemi_idara` | `Ustaad-Ji/taleemi_idara` | `TALEEMI_IDARA_READ_TOKEN` |

Repository names, checkout commands, test commands, and tokens are selected only from this fixed allow-list. A request cannot supply an arbitrary repository or shell command.

## Security contract

- Every request must provide an exact 40-character commit SHA.
- Checkout credentials are separate read-only fine-grained tokens for each private repository.
- Checkout credentials are not persisted.
- Workflow permissions default to read-only.
- Diagnostic logs and browser screenshots are encrypted before upload.
- Encrypted diagnostic artifacts expire after one day.
- The public workflow never accepts secret values, repository names, or commands from `ci/request.json`.
- Statuses are published only on this public validator repository; private repositories receive no write token.

## Request methods

### Manual dispatch

Run **Dispatch approved private-project checks** and provide:

- `project`
- `target_sha`
- `checks`
- optional `request_id`
- optional test paths in `specs` for a targeted run

### Committed request

Update `ci/request.json` on `main`. The workflow runs only when that file changes.

```json
{
  "project": "taleemi_idara",
  "request_id": "pr-218-full",
  "target_sha": "0123456789abcdef0123456789abcdef01234567",
  "checks": ["full"],
  "specs": []
}
```

## Supported checks

| Check | PashamCrafts | Taleemi Idara |
| --- | --- | --- |
| `schema` | Yes | Yes |
| `tests` | RSpec with coverage gate | Rails/Minitest |
| `system-tests` | No | Rails Chrome system tests |
| `targeted` | `spec/**/*_spec.rb` | `test/**/*_test.rb` |
| `lint` | RuboCop | RuboCop |
| `security` | Brakeman | Brakeman and Bundler Audit |
| `restore` | Backup/restore drill | No |
| `full` | Schema, tests, lint, security, restore | Schema, tests, system tests, lint, security |

The `full` preset cannot be combined with individual checks. Complete tests and targeted tests cannot be requested together.

## Secret setup

Each token must be a fine-grained personal access token with read-only **Contents** access to only its corresponding private repository.

Do not grant Actions, Administration, Issues, Pull requests, Secrets, or write permissions.
