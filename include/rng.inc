; =============================================================================
;   rng.inc — interface contract for shared RNG routines
; =============================================================================
;
; Required caller symbols:
;   RNG_STATE := <zp_addr>   ; 8-bit LFSR state, must never be 0
;
; Exported routines (from core/rng.asm):
;   AdvanceRng
;     In:  none
;     Out: RNG_STATE advanced one step
;     Clobbers: A, flags
;
;   RollInRange
;     In:  A = range size N (1..255)
;     Out: A in [0, N-1]
;     Clobbers: A, X, flags
;
; Usage note:
; - Seed RNG_STATE with a non-zero value before first call.
; =============================================================================
