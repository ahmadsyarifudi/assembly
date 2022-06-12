                 .INCLUDE "m128def.inc" ; <m128def.inc>
				 .DEF counter = R18     ; define R18 counter
				 .DEF bindata = R20     ; R20 = binary data
				 .DEF bcddata = R21     ; R21 = bcd data
				 .DEF puluhan = R22     ; R22 = dozens data
				 .ORG 0x0000
				 RJMP main

				 .ORG 0x0002
				 RJMP tambah

				 .ORG 0x0004
				 RJMP kurang

				 .ORG 0x0046
main:            LDI R16, low(RAMEND)   ; set stack pointer
                 OUT SPL, R16
				 LDI R16, high(RAMEND)
				 OUT SPH, R16
				 LDI R16, 0x00
				 OUT DDRD, R16          ; set PORTD = input
				 LDI R16, 0xFF          ;
				 OUT PORTD, R16         ; activate pullup in PORTD
				 OUT DDRE, R16
				 STS DDRF, R16          ; PORTF = output
				 LDI R16, 0x03
				 OUT EIMSK, R16         ; enable INT3
				 LDI R16, 0x0A
				 STS EICRA, R16         ; INT0 & INT1 active because falling edge
				 SEI 
				 LDI counter, 0x00
				 MOV bindata,counter
				 RCALL bin2bcd          ;call conversion binary program to bcd
				 RCALL display          ; display to 7 segment display
				 OUT PORTE, counter
				 STS PORTF, counter
 
loop:            RJMP loop              ; always looping

tambah:          INC counter            ; counter = counter +1
                 MOV bindata,counter
                 RCALL bin2bcd
				 RCALL display
                 RETI

kurang:          DEC counter            ; counter = counter - 1
                 MOV bindata,counter
                 RCALL bin2bcd
				 RCALL display
                 RETI
bin2bcd:         LDI puluhan,0           ;inisialisasi puluhan = 0

ulang:           CPI bindata,10          ;compare data binary to 10
				 BRMI selesai            ;jump to selesai if minus
				 INC puluhan             ;puluhan = puluhan + 1
				 SUBI bindata,10         ;kurangi angka biner dgn 10
				 RJMP ulang
selesai:         SWAP puluhan
                 OR puluhan,bindata
				 MOV bcddata,puluhan
				 RET
display:         PUSH bcddata
                 ANDI bcddata,0x0f
				 RCALL bcd27segment
				 STS PORTF,R0
				 POP bcddata
				 SWAP bcddata
				 ANDI bcddata,0x0F
				 RCALL bcd27segment
				 OUT PORTE,R0
bcd27segment:    LDI ZH, high(Tabel<<1)			; ambil alamat tertinggi dari Tabel
				 LDI ZL, low(Tabel<<1)			; ambil alamat terbawah dari Tabel
				 ADD ZL, bcddata					; alamat Tabel = Tabel + bcddata
				 LPM R0, Z						; load from program memory
				 RET
Tabel:	.DB 0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF	

