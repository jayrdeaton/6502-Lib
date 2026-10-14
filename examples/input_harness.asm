; =============================================================================
;   input_harness.asm - minimal harness for shared input module
; =============================================================================
;   Exercises every exported routine at least once: PollJoyCombined,
;   PollJoy1, PollJoy2, DrainKeyboardCombined, DrainKeyboardSplit. Defines
;   all four directions, so this build also proves the DIR_LEFT/DIR_RIGHT
;   .ifdef branches assemble; the 2-directional (Pong-style) path is
;   proven separately by Pong's own build, which omits them.
; =============================================================================

.setcpu "65C02"

.include "../6502.inc"

DIR_UP    = 0
DIR_DOWN  = 1
DIR_LEFT  = 2
DIR_RIGHT = 3

JOY_STATE  := $3A
JOY_STATE2 := $3B
KB_DIR     := $3C
KB_DIR_P1  := $3D
KB_DIR_P2  := $3E
KB_FIRE    := $3F
KB_FIRE_P1 := $40
KB_FIRE_P2 := $41

.include "../core/input.asm"

.segment "CART"

CartReset:
  ldx #$ff
  txs
  jsr KernalInit
  cli

  jsr PollJoyCombined
  jsr PollJoy1
  jsr PollJoy2
  jsr DrainKeyboardCombined
  jsr DrainKeyboardSplit

@loop:
  jmp @loop

IrqTrampoline:
  jmp (IRQ_PTR)

NmiTrampoline:
  jmp (NMI_PTR)

.segment "VECTORS"
.word NmiTrampoline
.word CartReset
.word IrqTrampoline
