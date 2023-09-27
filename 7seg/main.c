#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define DELAY 200

volatile uint8_t pos;

const uint8_t seg[10] = {0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F};

void actualizar_7seg(uint8_t pos){
    uint8_t display = seg[pos];
    PORTD = (display & (0b11111011)) | (0b00000100);
    PORTB = (display & (0b00000100)) | (0b00000001);
}

ISR (PCINT0_vect){
    if((PINB & 0x01) == 0x01){
        return;
    }
    _delay_ms(DELAY);
    if(pos == 9){
        pos = 0;
    } else{
        pos++;
    }
    actualizar_7seg(pos);
}

ISR (INT0_vect){
    if((PIND & 0x04) == 0x04){
        return;
    }
    _delay_ms(DELAY);
    if(pos == 0){
        pos = 9;
    } else{
        pos--;
    }
    actualizar_7seg(pos);
}

void init_irq_pin_change(void){
    PCICR = 1<<PCIE0;
    PCMSK0 = 1<<PCINT0;
}

void init_irq_pin0(void){
    EICRA = (1<<ISC01)|(0<<ISC00);
    EIMSK = 1<<INT0;
}

void reset(void){
    init_irq_pin_change();
    init_irq_pin0();
    DDRB = 0x04;
    DDRD = 0xFB;
    sei();
}

int main(void){
    reset();
    pos = 0;
    actualizar_7seg(pos);
    while(1){
    }
    return 0;
}