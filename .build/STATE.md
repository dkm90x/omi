# Current State

Last updated: 2026-09-21

## Working now
- Fork contains mature mobile, desktop, backend, web, infrastructure, contracts, component-level AGENTS files, security tooling, and product invariants.

## Incomplete / broken / unverified
- The LifeOS-specific fork strategy and backend deployment/integration path are not proven complete by the current snapshot.
- Build-system adoption does not certify the current runtime, sync, or capture path.

## Current slice
- Treat Omi as an evaluated subsystem/foundation and preserve LifeOS-specific integration decisions in-repo.

## Blockers / risks
- Upstream complexity is high; broad edits can accidentally violate component-specific invariants.
- The first LifeOS integration path must be chosen by an end-to-end capture/memory outcome, not by repository breadth.

## Next verified step
- Identify the exact first always-on capture path to run on the interim server/mobile setup and verify it against existing Omi contracts before modifying architecture.
