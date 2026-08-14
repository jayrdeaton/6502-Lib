# Input Module

Module files:
- core/input.asm
- include/input.inc

Contract:
- Caller defines HW_PRESENT, HW_GPIO, ReadJoystick1, ReadJoystick2, Chrin (Kernal-provided).
- Caller defines its own DIR_UP/DIR_DOWN (and DIR_LEFT/DIR_RIGHT for 4-directional games) at whatever numeric values it already uses. This file references them by name only — no shared numbering is required across projects.
- Caller defines the zero-page output bytes each routine documents (JOY_STATE, JOY_STATE2, KB_DIR/KB_FIRE for the combined routine, or KB_DIR_P1/KB_DIR_P2/KB_FIRE/KB_FIRE_P1/KB_FIRE_P2 for the split routine) before including this file.

Fire keys:
- Space (`KEY_FIRE`) is P1's/the single-player fallback — thumb-reachable from WASD's resting position, and the traditional single-player shooter fire key besides.
- Enter/Return (`KEY_FIRE2`, ASCII $0D) is P2's — sits right next to the arrow-key cluster on nearly every layout. Deliberately not a modifier key (Ctrl/Shift): Chrin is a plain character buffer, and modifier keys generally don't produce their own readable character, nor could left/right variants be told apart even if they did.
- `DrainKeyboardCombined` accepts either key interchangeably into one `KB_FIRE` flag, matching how WASD and arrows are also interchangeable for movement in the single-player case.
- `DrainKeyboardSplit` sets both the combined `KB_FIRE` (either key — every game as of this writing only needs "did anyone press it," mirroring how either joystick's A button already triggers the same shared action) and the per-player `KB_FIRE_P1`/`KB_FIRE_P2` (space/enter respectively) for a future game that needs independent per-player fire, e.g. a two-player shooter. No current game reads the per-player flags yet.

Priority rule (composed by each caller's own input.asm, not baked into this module):
- Joystick first. If the joystick shows a direction this poll, use it and ignore the keyboard entirely this poll.
- Only consult the keyboard's drained result when the joystick shows nothing this poll.
- The fire/A button is OR'd — joystick A or keyboard space, either triggers — independent of the direction priority.
- Split (two-player) callers: WASD drives P1 only, arrow keys drive P2 only. One player's keypresses can never move the other's paddle/cycle.

Continuous-movement callers (e.g. Pong's paddle, which stops when nothing is pressed, unlike Snake/LightCycles which always advance forward): a raw single-shot keyboard read isn't enough to feel like a held key, since Chrin delivers discrete buffered characters, not a live "is this key down" state, and typematic repeat from the platform's keyboard hardware was not confirmed either way in headless testing. Callers with this shape should layer a short per-player hold-decay counter on top of DrainKeyboardSplit's result: refresh it on every fresh keyboard direction seen, decrement it once per tick otherwise, and keep treating the last-seen direction as held while it's nonzero. This module intentionally does not bake that decay in, since sticky-only callers (Snake, LightCycles) don't want it.

Compatibility intent:
- Preserve joystick-first behavior and existing joystick-only call sites' output exactly (PollJoyCombined/PollJoy1/PollJoy2 behave identically to each project's current inline joystick polling).

Known gap:
- Keyboard fallback could not be exercised end-to-end against the headless emulator CLI during development (`input key`/`input type` did not deliver characters to Chrin in headless mode, even with the console set to video and interrupts confirmed live) — verify against the real desktop app before relying on it.
