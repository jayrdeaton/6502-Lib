; =============================================================================
;   rng.asm - shared 8-bit Galois LFSR pseudo-random generator
; =============================================================================
; Caller contract:
; - RNG_STATE must be defined by the consuming project.
; - RNG_STATE must never be zero (0 locks LFSR state).
;
; Exported labels:
; - AdvanceRng
; - RollInRange
;
; Register behavior:
; - AdvanceRng: clobbers A, flags.
; - RollInRange: input A=range size (1..255), output A in [0, range-1], clobbers X, flags.
;
; Notes:
; - Polynomial matches existing Snake/Pong behavior for compatibility.
; =============================================================================

.segment "CART"

; -----------------------------------------------------------------------------
; AdvanceRng - step LFSR one bit (maximal-length, period 255)
; -----------------------------------------------------------------------------
AdvanceRng:
  lda RNG_STATE
  lsr a
  bcc @noeor
  eor #$B4
@noeor:
  sta RNG_STATE
  rts

; -----------------------------------------------------------------------------
; RollInRange - bounded roll
; In:  A = range size N (1..255)
; Out: A in [0, N-1]
; -----------------------------------------------------------------------------
RollInRange:
  tax
  beq @zero
  cpx #$01
  beq @zero
  jsr AdvanceRng
  txa
  sta @range
  lda RNG_STATE
@reduce:
  cmp @range
  bcc @done
  sec
  sbc @range
  jmp @reduce
@zero:
  lda #$00
  rts
@range:
  .byte $01
@done:
  rts
