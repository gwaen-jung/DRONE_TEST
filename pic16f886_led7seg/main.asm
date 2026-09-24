; PIC16F886 - Dem tang/giam 3 bang nut nhan, hien thi LED 7 doan 4 so
; Ban Assembly (gpasm) cung logic voi main.c, dung de tao main.hex
;   RB0: tang 3 | RB1: giam 3 (keo len 10k, nhan = 0)
;   RC0..RC7 = a..g,dp (anode chung, muc 0 = sang)
;   RA0..RA3: chon so qua PNP 2N3906 (muc 0 = so sang)
;   Thach anh HS 20 MHz
        list    p=16f886, r=dec
        #include <p16f886.inc>
        errorlevel -302

        __CONFIG _CONFIG1, _HS_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
        __CONFIG _CONFIG2, _BOR40V & _WRT_OFF

DEBOUNCE equ    3               ; so vong quet (~8 ms/vong) de xac nhan nhan

        cblock  0x20
        D0, D1, D2, D3          ; hang nghin, tram, chuc, don vi (BCD)
        DB0, DB1                ; bo dem chong doi phim RB0, RB1
        FLAGS                   ; bit0: RB0 da xu ly, bit1: RB1 da xu ly
        DL1, DL2                ; bien tam / delay
        endc

        org     0x000
        goto    START

; Ma LED 7 doan anode chung 0..9 (nam trong 256 word dau, PCLATH = 0)
SEG:    addwf   PCL, f
        retlw   b'11000000'     ; 0
        retlw   b'11111001'     ; 1
        retlw   b'10100100'     ; 2
        retlw   b'10110000'     ; 3
        retlw   b'10011001'     ; 4
        retlw   b'10010010'     ; 5
        retlw   b'10000010'     ; 6
        retlw   b'11111000'     ; 7
        retlw   b'10000000'     ; 8
        retlw   b'10010000'     ; 9

START:
        banksel ANSEL           ; tat analog: RA0..RA3, RB0 (AN12), RB1 (AN10)
        clrf    ANSEL
        clrf    ANSELH
        banksel TRISA
        movlw   0xF0
        movwf   TRISA
        movlw   0xFF
        movwf   TRISB
        clrf    TRISC
        banksel PORTA
        movlw   0x0F            ; tat het cac so
        movwf   PORTA
        movlw   0xFF
        movwf   PORTC

        movlw   2               ; gia tri ban dau 2007
        movwf   D0
        clrf    D1
        clrf    D2
        movlw   7
        movwf   D3
        clrf    DB0
        clrf    DB1
        clrf    FLAGS

LOOP:
        call    NUT_B0
        call    NUT_B1
        call    HIENTHI
        goto    LOOP

; ---------- Nut RB0: tang 3 (1 lan / 1 lan nhan) ----------
NUT_B0:
        btfsc   PORTB, 0
        goto    NHA_B0
        movlw   DEBOUNCE
        subwf   DB0, w          ; C = 1 neu DB0 >= DEBOUNCE
        btfss   STATUS, C
        incf    DB0, f
        movlw   DEBOUNCE
        xorwf   DB0, w
        btfss   STATUS, Z
        return
        btfsc   FLAGS, 0
        return
        bsf     FLAGS, 0
        goto    CONG3
NHA_B0: clrf    DB0
        bcf     FLAGS, 0
        return

; ---------- Nut RB1: giam 3 ----------
NUT_B1:
        btfsc   PORTB, 1
        goto    NHA_B1
        movlw   DEBOUNCE
        subwf   DB1, w
        btfss   STATUS, C
        incf    DB1, f
        movlw   DEBOUNCE
        xorwf   DB1, w
        btfss   STATUS, Z
        return
        btfsc   FLAGS, 1
        return
        bsf     FLAGS, 1
        goto    TRU3
NHA_B1: clrf    DB1
        bcf     FLAGS, 1
        return

; ---------- Cong 3 dang BCD, quay vong 9999 -> 0000 ----------
CONG3:  movlw   3
        addwf   D3, f
        movlw   10
        subwf   D3, w
        btfss   STATUS, C
        return
        movwf   D3
        incf    D2, f
        movlw   10
        subwf   D2, w
        btfss   STATUS, C
        return
        movwf   D2
        incf    D1, f
        movlw   10
        subwf   D1, w
        btfss   STATUS, C
        return
        movwf   D1
        incf    D0, f
        movlw   10
        subwf   D0, w
        btfss   STATUS, C
        return
        movwf   D0
        return

; ---------- Tru 3 dang BCD, quay vong 0000 -> 9999 ----------
TRU3:   movlw   3
        subwf   D3, f
        btfsc   STATUS, C       ; C = 1: khong muon
        return
        movlw   10
        addwf   D3, f
        decf    D2, f
        incf    D2, w           ; Z = 1 neu D2 vua thanh 0xFF
        btfss   STATUS, Z
        return
        movlw   9
        movwf   D2
        decf    D1, f
        incf    D1, w
        btfss   STATUS, Z
        return
        movlw   9
        movwf   D1
        decf    D0, f
        incf    D0, w
        btfss   STATUS, Z
        return
        movlw   9
        movwf   D0
        return

; ---------- Quet 4 so, moi so ~2 ms ----------
HIENTHI:
        movf    D0, w
        call    SEG
        movwf   DL1
        movlw   b'1110'
        call    XUAT
        movf    D1, w
        call    SEG
        movwf   DL1
        movlw   b'1101'
        call    XUAT
        movf    D2, w
        call    SEG
        movwf   DL1
        movlw   b'1011'
        call    XUAT
        movf    D3, w
        call    SEG
        movwf   DL1
        movlw   b'0111'
        call    XUAT
        movlw   0x0F
        movwf   PORTA
        return

; W = mat na chon so, DL1 = ma 7 doan
XUAT:   movwf   DL2
        movlw   0x0F            ; tat het so truoc -> chong bong ma
        movwf   PORTA
        movf    DL1, w
        movwf   PORTC
        movf    DL2, w
        movwf   PORTA
        ; delay ~2 ms @ 20 MHz (13 x 255 x 3 chu ky lenh x 0.2 us)
        movlw   13
        movwf   DL2
DLY_O:  movlw   255
        movwf   DL1
DLY_I:  decfsz  DL1, f
        goto    DLY_I
        decfsz  DL2, f
        goto    DLY_O
        return

        end
