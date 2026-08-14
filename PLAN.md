# Plan: Build 6502-Lib from Snake and Pong

## Goal
Extract a stable reusable 6502 assembly library from proven modules in Snake and Pong, with explicit contracts for memory ownership, register clobbers, hardware guards, and build integration.

## Scope
- Include only duplicated, battle-tested primitives.
- Exclude speculative abstractions not yet used by at least two games.
- Keep compatibility with cc65 cartridge-style projects.

## Platform Guardrails
- Preserve joystick-first behavior in shared input modules.
- Keep all multi-byte VDP register and address writes interrupt-safe.
- Keep hardware presence gating explicit for GPIO and RTC paths.
- Favor deterministic behavior under fixed seed and fixed input.

## Phase 0: Repository Bootstrap
1. Create structure:
   - core
   - graphics
   - include
   - examples
   - docs
2. Add a minimal top-level Makefile with library and harness targets.
3. Add README describing module inventory and integration model.

## Phase 1: Contract First
1. Define include contracts before moving code:
   - exported labels
   - required caller-provided zero-page symbols
   - clobbered registers and flags
   - routine preconditions and postconditions
   - self-guarded vs caller-guarded hardware access
2. Freeze naming conventions for symbols and files.

## Phase 2: Extract Core Modules
1. VDP primitives:
   - canonical register write routine
   - canonical address latch routine
   - row/column offset compute helper
   - tile write/erase helpers where reusable
2. Input polling:
   - menu polling across both controllers
   - gameplay polling with 1P and 2P routing
   - edge-detected action button helper
3. RNG:
   - non-zero-seeded 8-bit LFSR
   - bounded roll helpers

## Phase 3: Extract Secondary Shared Modules
1. HUD/Text:
   - DrawString-like tile text routines
   - decimal conversion and digit buffer rendering
2. Sound wrapper:
   - retain only game-agnostic wrapper behavior
   - preserve deferred silence pattern where required by SID envelope behavior

## Phase 4: Harness and Integration
1. Build a tiny harness under examples that calls every exported routine at least once.
2. Validate expected memory and register side effects.
3. Integrate one module into Snake and one into Pong without gameplay behavior changes.

## Verification Gates
1. Library assembles successfully as standalone target.
2. Harness passes expected routine smoke checks.
3. Snake compiles with at least one module sourced from 6502-Lib.
4. Pong compiles with at least one module sourced from 6502-Lib.
5. No regressions in VDP interrupt safety.

## Source References
- /Users/jay/Developer/6502-Snake/src/vdp.asm
- /Users/jay/Developer/6502-Snake/src/input.asm
- /Users/jay/Developer/6502-Snake/src/rng.asm
- /Users/jay/Developer/6502-Snake/src/sound.asm
- /Users/jay/Developer/6502-Snake/src/game.asm
- /Users/jay/Developer/6502-Pong/src/input.asm
- /Users/jay/Developer/6502-Pong/src/vdp.asm
- /Users/jay/Developer/6502-Pong/src/hud.asm
- /Users/jay/Developer/6502-Pong/src/screens.asm
- /Users/jay/Developer/6502-Pong/src/physics.asm

## Definition of Done
- 6502-Lib has documented public interfaces, buildable modules, and a passing harness.
- At least one production game consumes library code without behavior regression.
