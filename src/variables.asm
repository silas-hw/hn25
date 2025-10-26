; variables declared

.segment "ZEROPAGE"

in_nmi: .res 2
temp1: .res 2
temp2: .res 2
temp3: .res 2
temp4: .res 2
temp5: .res 2
temp6: .res 2

old_x: .res 1
old_y: .res 1

level: .res 2

pad1: .res 2

.segment "RODATA"
tilemap_table:
    .word .loword(Level1TM), .loword(Level2TM)

tilemap_bank_table:
    .byte ^Level1TM, ^Level2TM

.segment "BSS"

PAL_BUFFER: .res 512 ;palette

OAM_BUFFER: .res 512 ;low table
OAM_BUFFER2: .res 32 ;high table
