# Project Constitution

## Outcome
Use this Omi fork as a serious always-on capture/memory foundation to evaluate and integrate into the broader LifeOS vision without losing upstream engineering discipline.

## Non-negotiables
- Preserve upstream component-specific AGENTS rules, invariants, compatibility contracts, and contribution/preflight discipline.
- Memory/capture reliability and provenance outrank flashy downstream features.
- Changes made for LifeOS must be explicit overlays or deliberate fork decisions, not accidental corruption of upstream assumptions.
- Mobile, desktop, backend, web, and infrastructure surfaces must be verified under their own relevant gates.
- Existing security and secret-handling rules remain authoritative.

## Non-goals
Do not rebuild Omi wholesale before proving which parts should be reused, replaced, or integrated with LifeOS.

## Definition of done
A LifeOS/Omi milestone is done only when the intended capture/memory path is demonstrated end-to-end, data authority is unambiguous, relevant upstream checks pass, and integration decisions are recorded.

## Canonical inheritance
This project follows https://github.com/dkm90x/builder-guide plus the existing Omi repository invariants. Where Omi's local rules are stricter, they remain authoritative.

## Deviations
None recorded at adoption.
