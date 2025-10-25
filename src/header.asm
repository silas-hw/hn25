;header for SNES
;ripped almost directly from nesdoug 'SNES_03'

.segment "SNESHEADER"
;$00FFC0-$00FFFF

.byte "Mushroom Madness '25 " ;rom name 21 chars
.byte $30  ;LoROM FastROM
.byte $00  ; extra chips in cartridge, 00: no extra RAM; 02: RAM with battery
.byte $08  ; ROM size (2^# in kB)
.byte $00  ; backup RAM size
.byte $01  ; US
.byte $33  ; publisher id
.byte $00  ; ROM revision number
.word $0000  ; checksum of all bytes
.word $0000  ; $FFFF minus checksum

;ffe0 not used
.word $0000
.word $0000

;ffe4 - native mode vectors
.addr IRQ_end  ;cop native **
.addr IRQ_end  ;brk native **
.addr $0000  ;abort native not used *
.addr NMI ;nmi native 
.addr RESET ;RESET native
.addr IRQ ;irq native


;fff0 not used
.word $0000
.word $0000

;fff4 - emulation mode vectors
.addr IRQ_end  ;cop emulation **
.addr $0000 ; not used
.addr $0000  ;abort not used *
.addr IRQ_end ;nmi emulation
.addr RESET ;RESET emulation
.addr IRQ_end ;irq/brk emulation **
