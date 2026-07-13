# Shared verification workflow design

The explicit dispatcher in `.github/workflows/verify.yml` validates an exact PashamCrafts commit and an allowlisted set of checks from `ci/request.json` or `workflow_dispatch`.

Database-backed checks run through `.github/workflows/shared-db-checks.yml`. RuboCop and Brakeman run through `.github/workflows/shared-static-checks.yml`. Only requested checks execute. The `full` preset expands to schema, complete tests with the 98% coverage gate, lint, security, and backup/restore.

Supported checks are `schema`, `tests`, `targeted`, `lint`, `security`, and `restore`. `full` cannot be combined with individual checks. Complete and targeted tests cannot be requested together. Targeted requests accept only validated `spec/...` paths and do not weaken the full-suite coverage merge gate.

Failure details are exported only as short-lived encrypted artifacts. Obsolete target-SHA diagnostic workflows have been removed. The dev-container smoke workflow remains independent because it validates the development toolchain rather than normal application changes.
