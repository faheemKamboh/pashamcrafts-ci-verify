# Verifier reporting note

The reporter must never convert a successful database-backed targeted test run into a failed commit status because a reusable-workflow output is blank.

Current safe rule:

- explicit check outputs remain authoritative when present
- a blank output for a requested check must be diagnosed in the verifier, not treated as an application failure
- app branches must not be patched blindly from a reporter-only failure

This note documents the current issue seen while validating PashamCrafts PR #145. The targeted RSpec step completed successfully while the reporter published `pashamcrafts/targeted` as failed.
