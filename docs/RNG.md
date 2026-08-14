# RNG Module

Module files:
- core/rng.asm
- include/rng.inc

Contract:
- Caller defines RNG_STATE in zero page.
- RNG_STATE must never be 0.

Compatibility intent:
- Maintain behavior parity with existing Snake and Pong LFSR usage.

Next extension:
- Add RollCol and RollRow style wrappers in consuming projects where board bounds are game-specific.
