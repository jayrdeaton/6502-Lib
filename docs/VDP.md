# VDP Module

Shared Graphics I primitives for cartridges that use the TMS9918.

Files:
- core/vdp.asm
- include/vdp.inc

Exports:
- register/address write helpers
- row/column offset computation
- tile drawing/erasing
- occupancy grid helpers

Notes:
- Game-specific border layouts, tile constants, and overlay rendering remain in the cartridge.
- All multi-byte VDP writes remain interrupt-safe.
