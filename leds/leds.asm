.include "./m328Pdef.inc"

inicio:
    ldi r16,0x0F
    out DDRC,r16

luces_1:    
    ldi r16,0xFA
    out PORTC,r16

check_1:
    call delay
    sbic PINC,4
    jmp check_1
    jmp luces_2

luces_2:
    ldi r16,0xF5
    out PORTC,r16  

check_2:
    call delay
    sbic PINC,4
    jmp check_2
    jmp luces_1

delay:
    ldi  r18, 17
    ldi  r19, 60
    ldi  r20, 204
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    ret        
