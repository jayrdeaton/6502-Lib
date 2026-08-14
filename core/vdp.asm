; =============================================================================
;   vdp.asm — shared TMS9918 Graphics I primitives
; =============================================================================
; Caller contract:
; - Consuming project defines VC_REG, VC_DATA, OCCUPANCY, OFFSET_LO, OFFSET_HI,
;   WORK_PTR, and any tile constants it wants to use with EraseTile.
;
; Exported labels:
; - VdpWriteReg
; - VdpSetAddr
; - ComputeOffset
; - VdpSetOffsetAddr
; - DrawTile
; - EraseTile
; - OccupancyPtr
; - OccupancySet
; - OccupancyGet
; - InitOccupancy
;
; Behavior:
; - All multi-byte VDP register/address writes are wrapped with PHP/SEI/PLP.
; - DrawTile and EraseTile are atomic end-to-end.
; =============================================================================

.segment "CART"

VdpWriteReg:
  php
  sei
  sta VC_REG
  txa
  ora #$80
  sta VC_REG
  plp
  rts

VdpSetAddr:
  php
  sei
  sta VC_REG
  txa
  ora #$40
  sta VC_REG
  plp
  rts

ComputeOffset:
  sta OFFSET_LO
  stz OFFSET_HI
  ldy #5
@shift:
  asl OFFSET_LO
  rol OFFSET_HI
  dey
  bne @shift
  txa
  clc
  adc OFFSET_LO
  sta OFFSET_LO
  bcc @done
  inc OFFSET_HI
@done:
  rts

VdpSetOffsetAddr:
  lda OFFSET_LO
  ldx OFFSET_HI
  jmp VdpSetAddr

DrawTile:
  php
  sei
  phy
  jsr ComputeOffset
  jsr VdpSetOffsetAddr
  ply
  tya
  sta VC_DATA
  plp
  rts

EraseTile:
  jmp DrawTile

OccupancyPtr:
  jsr ComputeOffset
  lda OFFSET_HI
  clc
  adc #>OCCUPANCY
  sta WORK_PTR+1
  lda OFFSET_LO
  sta WORK_PTR
  rts

OccupancySet:
  phy
  jsr OccupancyPtr
  ply
  tya
  ldy #0
  sta (WORK_PTR),y
  rts

OccupancyGet:
  jsr OccupancyPtr
  ldy #0
  lda (WORK_PTR),y
  rts

InitOccupancy:
  lda #<OCCUPANCY
  sta WORK_PTR
  lda #>OCCUPANCY
  sta WORK_PTR+1
  ldx #3
  lda #0
@pageLoop:
  ldy #0
@byteLoop:
  sta (WORK_PTR),y
  iny
  bne @byteLoop
  inc WORK_PTR+1
  dex
  bne @pageLoop
  rts
