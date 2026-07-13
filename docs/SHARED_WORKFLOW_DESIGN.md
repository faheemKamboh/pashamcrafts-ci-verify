# Shared verification workflow design

The explicit dispatcher in `.github/workflows/verify.yml` validates an exact PashamCrafts commit and an allowlisted set of checks from `ci/request.json` or `workflow_dispatch`.

Database-backed checks share one reusable workflow and PostgreSQL environment. RuboCop and Brakeman share a separate reusable static workflow. Only requested checks run. The `full` preset expands to schema, complete tests with the 98% coverage gate, lint, security, and backup/restore.

Targeted test requests accept only validated `spec/...` paths and do not weaken the full-suite coverage merge gate. Failure details are exported only as short-lived encrypted artifacts.

The dev-container smoke workflow remains independent because it validates the development toolchain rather than normal application changes.
