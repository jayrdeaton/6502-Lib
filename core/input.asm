; =============================================================================
;   input.asm - shared joystick-first, keyboard-fallback input primitives
; =============================================================================
; Caller contract:
; - Consuming project defines HW_PRESENT, HW_GPIO, ReadJoystick1,
;   ReadJoystick2, Chrin (all Kernal-provided) before including this file.
; - Consuming project defines its own DIR_UP/DIR_DOWN constants (and
;   DIR_LEFT/DIR_RIGHT, only if it's a 4-directional game) at whatever
;   numeric values it already uses - this file references them by name
;   only, so Snake/LightCycles' 0/1/2/3 and Pong's 1/2 both work unchanged.
; - Consuming project defines the zero-page output bytes each routine
;   below documents (JOY_STATE, JOY_STATE2, KB_DIR, KB_DIR_P1, KB_DIR_P2,
;   KB_FIRE, and - only if calling DrainKeyboardSplit - KB_FIRE_P1,
;   KB_FIRE_P2) before including this file, at whatever address is free.
;
; Exported routines:
; - PollJoyCombined      both ports AND-combined (single-player, either port)
; - PollJoy1 / PollJoy2  a single port, gated on HW_GPIO
; - DrainKeyboardCombined  single-player keyboard fallback (WASD or arrows)
; - DrainKeyboardSplit     two-player keyboard fallback (WASD=P1, arrows=P2)
;
; This file intentionally does NOT resolve a final NEXT_DIR/START_PRESSED -
; that composition (joystick-first priority, A-button-or-space, edge
; detection) is project-specific glue that stays in each game's own
; input.asm, since the exact target variables differ per game (NEXT_DIR vs
; NEXT_P1/NEXT_P2, single-player vs split). See docs/INPUT.md for the
; priority rule every caller should follow.
; =============================================================================

; --- Joystick bits (active-low on the wire: 0 = pressed) ---
JOY_A     = %00000001
JOY_B     = %00000010
JOY_X     = %00000100
JOY_Y     = %00001000
JOY_UP    = %00010000
JOY_DOWN  = %00100000
JOY_LEFT  = %01000000
JOY_RIGHT = %10000000

; --- Keyboard fallback scancodes ---
; Kernal delivers uppercase ASCII for letter keys; arrow keys are control
; codes, not printable characters.
KEY_W           = 'W'
KEY_A           = 'A'
KEY_S           = 'S'
KEY_D           = 'D'
KEY_UP_ARROW    = $1E
KEY_DOWN_ARROW  = $1F
KEY_LEFT_ARROW  = $1C
KEY_RIGHT_ARROW = $1D
KEY_FIRE        = ' '     ; space bar: P1's fire fallback (thumb-reachable
                           ; from WASD's resting position; also the
                           ; traditional single-player shooter fire key)
KEY_FIRE2       = $0D     ; enter/return (CHAR_CR): P2's fire fallback,
                           ; sits right next to the arrow-key cluster on
                           ; nearly every layout. Deliberately not a
                           ; modifier key (Ctrl/Shift) -- Chrin is a plain
                           ; character buffer, and modifier keys generally
                           ; don't produce their own readable character,
                           ; nor could left/right variants be told apart
                           ; even if they did.

KB_DIR_NONE = $FF          ; sentinel: no direction seen in this drain

.segment "CART"

; -----------------------------------------------------------------------------
; PollJoyCombined - read both joystick ports and AND-combine them
; (active-low AND = logical OR of "pressed"), so either port drives a
; single-player game regardless of which one it's plugged into.
; Out: JOY_STATE = combined active-low byte, or $FF (idle) if no GPIO card.
; Clobbers: A
; -----------------------------------------------------------------------------
PollJoyCombined:
  lda HW_PRESENT
  and #HW_GPIO
  bne @haveGpio
  lda #$FF
  sta JOY_STATE
  rts
@haveGpio:
  jsr ReadJoystick1
  sta JOY_STATE
  jsr ReadJoystick2
  and JOY_STATE
  sta JOY_STATE
  rts

; -----------------------------------------------------------------------------
; PollJoy1 / PollJoy2 - read a single joystick port, gated on HW_GPIO
; (ReadJoystick1/2 do not check hardware presence themselves - a floating
; bus reads as meaningless data with no GPIO card fitted).
; Out: JOY_STATE / JOY_STATE2, or $FF (idle) if no GPIO card.
; Clobbers: A
; -----------------------------------------------------------------------------
PollJoy1:
  lda HW_PRESENT
  and #HW_GPIO
  bne @haveGpio
  lda #$FF
  sta JOY_STATE
  rts
@haveGpio:
  jsr ReadJoystick1
  sta JOY_STATE
  rts

PollJoy2:
  lda HW_PRESENT
  and #HW_GPIO
  bne @haveGpio
  lda #$FF
  sta JOY_STATE2
  rts
@haveGpio:
  jsr ReadJoystick2
  sta JOY_STATE2
  rts

; -----------------------------------------------------------------------------
; DrainKeyboardCombined - single-player keyboard fallback: WASD or arrow
; keys both work, whichever was pressed most recently in this call wins.
; Drains every pending Chrin character each call (not just one), so a
; burst typed between polls doesn't leave stale characters for next time.
; LEFT/RIGHT checks compile out entirely for a 2-directional caller that
; never defines DIR_LEFT/DIR_RIGHT (e.g. Pong).
; Out: KB_DIR = last recognized direction this call, or KB_DIR_NONE.
;      KB_FIRE = 1 if space or enter was seen this call, else 0. Both
;      fire keys work interchangeably here, matching how WASD and arrows
;      both work interchangeably for movement in this single-player case.
; Clobbers: A
; -----------------------------------------------------------------------------
DrainKeyboardCombined:
  lda #KB_DIR_NONE
  sta KB_DIR
  stz KB_FIRE
@drain:
  jsr Chrin
  bcc @done                 ; C=0 = no character waiting, buffer empty
                             ; (Chrin signals this via carry, NOT via A=0 --
                             ; A holds a character even when C=0 is possible,
                             ; so checking A for zero here would loop forever)

  cmp #KEY_W
  beq @setUp
  cmp #KEY_UP_ARROW
  beq @setUp
  cmp #KEY_S
  beq @setDown
  cmp #KEY_DOWN_ARROW
  beq @setDown
.ifdef DIR_LEFT
  cmp #KEY_A
  beq @setLeft
  cmp #KEY_LEFT_ARROW
  beq @setLeft
.endif
.ifdef DIR_RIGHT
  cmp #KEY_D
  beq @setRight
  cmp #KEY_RIGHT_ARROW
  beq @setRight
.endif
  cmp #KEY_FIRE
  beq @setFire
  cmp #KEY_FIRE2
  bne @drain
@setFire:
  lda #1
  sta KB_FIRE
  jmp @drain

@setUp:
  lda #DIR_UP
  sta KB_DIR
  jmp @drain
@setDown:
  lda #DIR_DOWN
  sta KB_DIR
  jmp @drain
.ifdef DIR_LEFT
@setLeft:
  lda #DIR_LEFT
  sta KB_DIR
  jmp @drain
.endif
.ifdef DIR_RIGHT
@setRight:
  lda #DIR_RIGHT
  sta KB_DIR
  jmp @drain
.endif

@done:
  rts

; -----------------------------------------------------------------------------
; DrainKeyboardSplit - two-player keyboard fallback: WASD drives P1 only,
; arrow keys drive P2 only, so one player's keypresses can never move the
; other's paddle/cycle. Drains every pending Chrin character ONCE per
; call, checking both keysets in the same pass (so both players' presses
; in the same drain window are captured, not just whichever keyset was
; checked first). LEFT/RIGHT checks compile out for a 2-directional caller
; that never defines DIR_LEFT/DIR_RIGHT (e.g. Pong).
; Out: KB_DIR_P1 = last WASD direction seen this call, or KB_DIR_NONE.
;      KB_DIR_P2 = last arrow-key direction seen this call, or KB_DIR_NONE.
;      KB_FIRE = 1 if EITHER fire key was seen this call, else 0 - kept
;      for callers with only one shared fire/start/pause action (every
;      game as of this writing: "did anyone press it" is all that
;      matters, mirroring how either joystick's A button already
;      triggers the same shared action today).
;      KB_FIRE_P1 = 1 if space (P1's fire key) was seen this call, else 0.
;      KB_FIRE_P2 = 1 if enter (P2's fire key) was seen this call, else 0.
;      A future game with independent per-player fire (e.g. a two-player
;      shooter) reads KB_FIRE_P1/KB_FIRE_P2 instead of the combined flag.
; Clobbers: A
; -----------------------------------------------------------------------------
DrainKeyboardSplit:
  lda #KB_DIR_NONE
  sta KB_DIR_P1
  sta KB_DIR_P2
  stz KB_FIRE
  stz KB_FIRE_P1
  stz KB_FIRE_P2
@drain:
  jsr Chrin
  bcc @done                 ; C=0 = no character waiting, buffer empty
                             ; (Chrin signals this via carry, NOT via A=0)

  cmp #KEY_W
  beq @p1Up
  cmp #KEY_S
  beq @p1Down
.ifdef DIR_LEFT
  cmp #KEY_A
  beq @p1Left
.endif
.ifdef DIR_RIGHT
  cmp #KEY_D
  beq @p1Right
.endif
  cmp #KEY_UP_ARROW
  beq @p2Up
  cmp #KEY_DOWN_ARROW
  beq @p2Down
.ifdef DIR_LEFT
  cmp #KEY_LEFT_ARROW
  beq @p2Left
.endif
.ifdef DIR_RIGHT
  cmp #KEY_RIGHT_ARROW
  beq @p2Right
.endif
  cmp #KEY_FIRE
  beq @p1Fire
  cmp #KEY_FIRE2
  bne @drain
  lda #1
  sta KB_FIRE
  sta KB_FIRE_P2
  jmp @drain
@p1Fire:
  lda #1
  sta KB_FIRE
  sta KB_FIRE_P1
  jmp @drain

@p1Up:
  lda #DIR_UP
  sta KB_DIR_P1
  jmp @drain
@p1Down:
  lda #DIR_DOWN
  sta KB_DIR_P1
  jmp @drain
.ifdef DIR_LEFT
@p1Left:
  lda #DIR_LEFT
  sta KB_DIR_P1
  jmp @drain
.endif
.ifdef DIR_RIGHT
@p1Right:
  lda #DIR_RIGHT
  sta KB_DIR_P1
  jmp @drain
.endif
@p2Up:
  lda #DIR_UP
  sta KB_DIR_P2
  jmp @drain
@p2Down:
  lda #DIR_DOWN
  sta KB_DIR_P2
  jmp @drain
.ifdef DIR_LEFT
@p2Left:
  lda #DIR_LEFT
  sta KB_DIR_P2
  jmp @drain
.endif
.ifdef DIR_RIGHT
@p2Right:
  lda #DIR_RIGHT
  sta KB_DIR_P2
  jmp @drain
.endif

@done:
  rts
