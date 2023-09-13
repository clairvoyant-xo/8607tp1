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
   ldi r20,0x0F
    loop_a:
        ldi r21,0xFF
        loop_b:
            ldi r22,0xFF
            loop_c:
                dec r22
                brne loop_c
            dec r21
            brne loop_b
        dec r20
        brne loop_a
    ret        