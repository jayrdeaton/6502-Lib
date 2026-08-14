; =============================================================================
;   vdp.inc — interface contract for shared VDP primitives
; =============================================================================
;
; Required caller symbols:
;   VC_REG, VC_DATA
;   OFFSET_LO, OFFSET_HI, WORK_PTR
;   OCCUPANCY base address
;
; Exported routines:
;   VdpWriteReg
;   VdpSetAddr
;   ComputeOffset
;   VdpSetOffsetAddr
;   DrawTile
;   EraseTile
;   OccupancyPtr
;   OccupancySet
;   OccupancyGet
;   InitOccupancy
;
; Notes:
; - DrawTile is atomic end-to-end.
; - The caller owns all game-specific tile constants and screen geometry.
; =============================================================================
