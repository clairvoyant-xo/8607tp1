.include "./m328Pdef.inc"

segmentos_decimales:
.db 0x3F,0x06,0x5B,0x4F,0x66
.db 0x6D,0x7D,0x08,0x7F,0x6F

.org 0
		rjmp Reset 

.org INT0addr
		rjmp IntV0 

.org PCI0addr
		rjmp IntVC0    

reset:	ldi R31,low(RAMEND) 
	  	out SPL,R31
        ldi R31, high(RAMEND)
        out SPH, R31
		
		call INIT_IRQ_INT0
		call INIT_IRQ_PIN_CHANGE
					
 		ldi r16,0xFB						
		out DDRD, R16
		ldi r16, 0x04
		out DDRB, R16
		sei	          

main:
    ldi r16,0
	mov r0,r16
    call actualizar_7segmentos
    loop:
        rjmp loop      

setear_0:
    ldi r16,0xFF
	mov r0,r16
    ret

setear_9:
    ldi r16,10
	mov r0,r16
    ret

IntV0:  
		
        push r16 
		
		in   r16,sreg
		push r16 
		
        cpi r0,9
        breq setear_0
        inc r0
        call actualizar_7segmentos
		
		pop r16 
		out sreg,r16

		pop r16 
		reti

IntVC0:	

        push r16 
		
		in   r16,sreg
		push r16 
		
		cpi r0,0
        breq setear_9
        dec r0
        call actualizar_7segmentos
		
		pop r16 
		out sreg,r16

		pop r16 
		reti

INIT_IRQ_PIN_CHANGE:	
		ldi R16, (1<<PCIE0) 				
		STS PCICR, R16
		ldi R16, (1 << PCINT0) | (1 << PCINT1)
		STS PCMSK0, R16 
		RET

INIT_IRQ_INT0:
		ldi R16, (1<<ISC01)|(0<<ISC00)  
		sts EICRA, R16					
		ldi R16, (1<<INT0)				
		out EIMSK, R16					
		RET    

; actualizar_7segmentos:
; Muestra un dígito en un display de 7 segmentos
; (dp,g,f,e,d,c,b,a) = (PD7,PD6,PD5,PD4,PD3,PB2,PD1,PD0)
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
    lpm r16, z
	mov r17, r16
	andi r17, 0b11111011
	ori r17, 0b00000100
    out portd, r17
	mov r17, r16
    andi r17, 0b00000100
	ori r17, 0b00000011
    out portb, r17
    ret
