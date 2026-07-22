# Private Rails Project CI Validator

This public repository runs explicit, exact-commit validation for an allow-listed set of private Rails repositories when their own GitHub Actions runners are unavailable.

The repository name is retained to avoid disrupting the existing PashamCrafts integration. The validator supports multiple approved projects without mirroring private source into this repository.

## Approved projects

| Project input | Private repository | Read-only secret | Optional status secret |
| --- | --- | --- | --- |
| `pashamcrafts` | `faheemKamboh/pashamcrafts` | `PASHAMCRAFTS_READ_TOKEN` | `PASHAMCRAFTS_STATUS_TOKEN` |
| `taleemi_idara` | `Ustaad-Ji/taleemi_idara` | `TALEEMI_IDARA_READ_TOKEN` | `TALEEMI_IDARA_STATUS_TOKEN` |
| `greensvilla` | `GreensVilla/greensvilla` | `GREENSVILLA_READ_TOKEN` | `GREENSVILLA_STATUS_TOKEN` |

Repository names, checkout commands, test commands, and tokens are selected only from this fixed allow-list. A request cannot supply an arbitrary repository or shell command.

## Security contract

- Every request must provide an exact 40-character commit SHA.
- Checkout credentials are separate read-only fine-grained tokens for each private repository.
- Private source exists only in the temporary runner checkout and is never committed to this repository.
- Checkout credentials are not persisted.
- Workflow permissions default to read-only.
- Diagnostic logs are encrypted before upload.
- Raw logs, screenshots, database dumps, generated assets, Docker images, and application artifacts are never uploaded.
- Encrypted diagnostic artifacts expire after one day.
- The public workflow never accepts secret values, repository names, or commands from request files.
- Statuses are always published on this public validator repository.
- Private target commit statuses are published only when the matching optional status token is configured.

## Request methods

### Manual dispatch

Run **Dispatch approved private-project checks** and provide:

- `project`
- `target_sha`
- `checks`
- optional `request_id`
- optional test paths in `specs` for a targeted run

GreensVilla also has a dedicated convenience workflow: **Validate GreensVilla request**. It hardcodes `project: greensvilla`, accepts the same `target_sha`, `checks`, `request_id`, and `specs` fields, and delegates to the shared verifier.

### Committed requests

Existing project-specific request channels remain separate:

- `ci/request.json` — legacy PashamCrafts channel
- `ci/requests/taleemi_idara.json` — isolated Taleemi Idara channel

GreensVilla uses explicit `workflow_dispatch`, which avoids creating or updating a public request file merely to validate a private commit.

## GreensVilla examples

### Full verification

```text
project: greensvilla
request_id: greensvilla-full-e154a533
target_sha: e154a533217faa045dfedc3f09102129c21f83f6
checks: full
specs:
```

The GreensVilla `full` preset runs:

- non-system RSpec
- system RSpec
- RuboCop
- Brakeman, Bundler Audit, and Yarn audit
- JavaScript, CSS, Tailwind, and production asset verification
- production Docker image build and inspection
- seed replant and repeat seed execution

### Targeted verification

```text
project: greensvilla
target_sha: e154a533217faa045dfedc3f09102129c21f83f6
checks: targeted
specs: spec/models/farm_spec.rb,spec/requests/admin/farms_spec.rb:42
```

Targeted GreensVilla paths must match `spec/..._spec.rb` with an optional line number.

## Supported checks

| Check | PashamCrafts | Taleemi Idara | GreensVilla |
| --- | --- | --- | --- |
| `schema` | Yes | Yes | `db/structure.sql` |
| `tests` | RSpec with coverage gate | Rails/Minitest | Non-system RSpec |
| `system-tests` | No | Rails Chrome system tests | System RSpec |
| `targeted` | `spec/**/*_spec.rb` | `test/**/*_test.rb` | `spec/**/*_spec.rb` |
| `lint` | RuboCop | RuboCop | RuboCop |
| `security` | Brakeman | Brakeman and Bundler Audit | Brakeman, Bundler Audit, Yarn audit |
| `assets` | No | No | Build and precompile |
| `docker` | No | No | Production image build |
| `seeds` | No | No | Replant and repeat seed |
| `restore` | Backup/restore drill | No | No |
| `full` | Schema, tests, lint, security, restore | Schema, tests, system tests, lint, security | Tests, system tests, lint, security, assets, Docker, seeds |

The `full` preset cannot be combined with individual checks. Complete tests and targeted tests cannot be requested together.

## Secret setup

Each checkout token must be a fine-grained personal access token with read-only **Contents** access to only its corresponding private repository.

For GreensVilla, add this repository Actions secret:

```text
GREENSVILLA_READ_TOKEN
```

Grant it access only to `GreensVilla/greensvilla` with **Contents: Read-only**. Do not grant Actions, Administration, Issues, Pull requests, Secrets, or write permissions.

To publish verifier results directly on GreensVilla commits and PRs, also add:

```text
GREENSVILLA_STATUS_TOKEN
```

Use a separate fine-grained token limited to `GreensVilla/greensvilla` with **Commit statuses: Read and write**. If GitHub requires contents access for repository lookup, grant **Contents: Read-only** as well. Do not reuse the checkout token for status writes.
