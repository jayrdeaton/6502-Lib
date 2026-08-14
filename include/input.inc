; =============================================================================
;   input.inc — interface contract for shared joystick-first input polling
; =============================================================================
;
; Required caller symbols (defined by the consuming project before this
; file is .include-d):
;   HW_PRESENT, HW_GPIO, ReadJoystick1, ReadJoystick2, Chrin  ; Kernal
;   DIR_UP, DIR_DOWN                        ; caller's own numeric values
;   DIR_LEFT, DIR_RIGHT                     ; omit both for a 2-directional
;                                            ; game (e.g. Pong) — LEFT/RIGHT
;                                            ; checks compile out
;   JOY_STATE                               ; zero page, for PollJoyCombined
;                                            ; and PollJoy1
;   JOY_STATE2                              ; zero page, for PollJoy2
;   KB_DIR, KB_FIRE                         ; zero page, for
;                                            ; DrainKeyboardCombined
;   KB_DIR_P1, KB_DIR_P2, KB_FIRE           ; zero page, for
;   KB_FIRE_P1, KB_FIRE_P2                  ; DrainKeyboardSplit
;                                            ; (KB_FIRE_P1/P2 only needed
;                                            ; by a caller that wants
;                                            ; independent per-player fire
;                                            ; — every game as of this
;                                            ; writing uses the combined
;                                            ; KB_FIRE instead)
;
; Exported routines:
;   PollJoyCombined       both joystick ports AND-combined (single-player)
;   PollJoy1 / PollJoy2   one joystick port, gated on HW_GPIO
;   DrainKeyboardCombined single-player keyboard fallback (WASD or arrows)
;   DrainKeyboardSplit    two-player keyboard fallback (WASD=P1, arrows=P2)
;
; Fire keys: space (KEY_FIRE) is P1's/the single-player fallback; enter
; (KEY_FIRE2) is P2's. DrainKeyboardCombined accepts either interchangeably
; into one KB_FIRE flag. DrainKeyboardSplit sets both the combined KB_FIRE
; (either key, for today's shared start/pause/confirm actions) and the
; per-player KB_FIRE_P1/KB_FIRE_P2 (for a future game with independent
; per-player fire, e.g. a two-player shooter).
;
; Priority rule every caller composes for itself (see docs/INPUT.md):
;   Joystick first. If the joystick shows a direction this poll, use it and
;   ignore the keyboard entirely this poll. Only consult the keyboard's
;   drained result when the joystick shows nothing. The fire/A button is
;   OR'd (joystick A or keyboard space, either triggers), independent of
;   the direction priority.
; =============================================================================
