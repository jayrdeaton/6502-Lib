6502-Lib
========

Reusable 6502 assembly modules shared across game cartridges.

See PLAN.md for phased extraction and verification strategy.

Initial folders:
- core
- graphics
- include
- examples
- docs

## Modules

| Module | Files | Docs |
|--------|-------|------|
| RNG | `core/rng.asm`, `include/rng.inc` | `docs/RNG.md` |
| VDP | `core/vdp.asm`, `include/vdp.inc` | `docs/VDP.md` |
| Input | `core/input.asm`, `include/input.inc` | `docs/INPUT.md` |

Modules are shared by `.include`, not linked as a compiled library: each
consuming project's own zero-page and constant definitions flow through at
assemble time, so e.g. Snake's `DIR_UP=0` and Pong's `DIR_UP=1` both work
against the same `core/input.asm` source unmodified.
