.include "./m328Pdef.inc"

segmentos_decimales:
.db 0x3F,0x06,0x5B,0x4F,0x66
.db 0x6D,0x7D,0x08,0x7F,0x6F

; Vector de reset
.org 0
		rjmp Reset 
; Vector de INT0 (pin PD2) 
.org INT0addr
		rjmp IntV0 

; Vector de PCINT0 (pines PB0 y PB1, en este caso)
.org PCI0addr
		rjmp IntVC0    

; Inicializa stack
Reset:	ldi R31,low(RAMEND) 
	  	out SPL,R31
        ldi R31, high(RAMEND)
        out SPH, R31
		
		call INIT_IRQ_INT0
		call INIT_IRQ_PIN_CHANGE
					
 		clr R16							
		out DDRD, R17 ; PORTD como entrada
		out DDRB, R17 ; PORTB como entrada
		sei	          ; Hab. global de interrupciones

main:
    ldi r0,0
    call actualizar_7segmentos
    loop:
        rjmp loop      

setear_0:
    ldi r0,0xFF
    ret

setear_9:
    ldi r0,9
    ret

IntV0:  
		
        push r16 ;****
		
		in   r16,sreg
		push r16 ;====
		
        cpi r0,9
        breq setear_0
        inc r0
        call actualizar_7segmentos
		
		pop r16 ;=====
		out sreg,r16

		pop r16 ;****
		reti

IntVC0:	

        push r16 ;****
		
		in   r16,sreg
		push r16 ;====
		
        dec r0
        call actualizar_7segmentos
		
		pop r16 ;=====
		out sreg,r16

		pop r16 ;****
		reti

; Configura PCINT0, PCINT1
INIT_IRQ_PIN_CHANGE:	;0b00000001
		ldi R16, (1<<PCIE0) 				
		STS PCICR, R16
		ldi R16, (1 << PCINT0) | (1 << PCINT1)
		STS PCMSK0, R16 
		RET

; Configura INT0
INIT_IRQ_INT0:
		ldi R16, (1<<ISC01)|(0<<ISC00)  ;flanco descendente	
		sts EICRA, R16					
		ldi R16, (1<<INT0)				
		out EIMSK, R16					; Habilita máscara
		RET    

; actualizar_7segmentos:
; Muestra un dígito en un display de 7 segmentos
; (dp,g,f,e,d,c,b,a) = (PD7,PD6,PB5,PB4,PB3,PB2,PB1,PB0)
; Entrada: r0 = digito decimal a mostrar en el display
; Salida: pines de salida del display actualizados
;---------------------------------------
actualizar_7segmentos:  
    ldi zh, high(2*segmentos_decimales)
    ldi zl, low(2*segmentos_decimales)                        
    add zl, r0
    brcc no_incrementar_zh
    inc zh
no_incrementar_zh:      
    lpm r0, z
    out portb, r0
    andi r0, 0b11100000
    out portd, r0
    ret
