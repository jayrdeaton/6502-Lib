; =============================================================================
;   rng_harness.asm — minimal harness for shared RNG module
; =============================================================================

.setcpu "65C02"

.include "../6502.inc"

RNG_STATE := $3A

.include "../core/rng.asm"

.segment "CART"

CartReset:
  jsr KernalInit

  lda #$5A
  sta RNG_STATE

  ; Exercise both exports.
  jsr AdvanceRng
  lda #16
  jsr RollInRange

@loop:
  jmp @loop

IrqTrampoline:
  rti

NmiTrampoline:
  rti

.segment "VECTORS"
.word NmiTrampoline
.word CartReset
.word IrqTrampoline
