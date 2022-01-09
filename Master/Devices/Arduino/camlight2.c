/* stty -F /dev/ttyUSB0 clocal cread -crtscts cs8 -cstopb hup -parenb parodd -brkint -icrnl ignbrk -igncr ignpar imaxbel -inlcr inpck -istrip -iuclc -ixany ixoff -ixon bs0 cr0 ff0 nl0 -ocrnl -ofdel -ofill -olcuc -onlcr -onlret onocr -opost tab0 vt0 -crterase crtkill -ctlecho -echo -echok -echonl -echoprt -icanon -iexten -isig -noflsh -tostop -xcase time 5 min 1 9600 */
#define EXPDELAY 200


#define F_CPU 16000000UL

#define LIGHTRED_DDR DDRB
#define LIGHTRED_PORT PORTB
#define LIGHTRED_BIT PB0


#define LIGHTGREEN_DDR DDRB
#define LIGHTGREEN_PORT PORTB
#define LIGHTGREEN_BIT PB1


#define LIGHTBLUE_DDR DDRB
#define LIGHTBLUE_PORT PORTB
#define LIGHTBLUE_BIT PB2


#define LED1_DDR DDRD
#define LED1_PORT PORTD
#define LED1_BIT PD4

#define LED2_DDR DDRD
#define LED2_PORT PORTD
#define LED2_BIT PD5

#define LED3_DDR DDRD
#define LED3_PORT PORTD
#define LED3_BIT PD6

#define LED4_DDR DDRD
#define LED4_PORT PORTD
#define LED4_BIT PD7







#include <avr/io.h>
#include <util/delay.h>
#include <avr/sfr_defs.h>
#include <avr/interrupt.h>


#define sbi(port, bit) (port) |= (1 << (bit))
#define cbi(port, bit) (port) &= ~(1 << (bit))

volatile uint32_t intrcount = 0;
volatile int next_ts = 0;


void led(int light){
    if (light) sbi(PORTB, PB5);
    else cbi(PORTB, PB5);
}






void lightR(uint8_t light){
    if (light) sbi(LIGHTRED_PORT, LIGHTRED_BIT);
    else cbi(LIGHTRED_PORT, LIGHTRED_BIT);
}



void lightG(uint8_t light){
    if (light) sbi(LIGHTGREEN_PORT, LIGHTGREEN_BIT);
    else cbi(LIGHTGREEN_PORT, LIGHTGREEN_BIT);
}


void lightB(uint8_t light){
    if (light) sbi(LIGHTBLUE_PORT, LIGHTBLUE_BIT);
    else cbi(LIGHTBLUE_PORT, LIGHTBLUE_BIT);
}


void LED1(uint8_t light){
    if (light) sbi(LED1_PORT, LED1_BIT);
    else cbi(LED1_PORT, LED1_BIT);
}


void LED2(uint8_t light){
    if (light) sbi(LED2_PORT, LED2_BIT);
    else cbi(LED2_PORT, LED2_BIT);
}

void LED3(uint8_t light){
    if (light) sbi(LED3_PORT, LED3_BIT);
    else cbi(LED3_PORT, LED3_BIT);
}

void LED4(uint8_t light){
    if (light) sbi(LED4_PORT, LED4_BIT);
    else cbi(LED4_PORT, LED4_BIT);
}


void init(void){
    sbi(DDRB, PB5); /* LED */


    sbi(LIGHTRED_DDR, LIGHTRED_BIT);
    sbi(LIGHTGREEN_DDR, LIGHTGREEN_BIT);
    sbi(LIGHTBLUE_DDR, LIGHTBLUE_BIT);

    lightR(0);
    lightG(0);
    lightB(0);


    sbi(LED1_DDR, LED1_BIT);
    sbi(LED2_DDR, LED2_BIT);
    sbi(LED3_DDR, LED3_BIT);
    sbi(LED4_DDR, LED4_BIT);

    LED1(0);
    LED2(0);
    LED3(0);
    LED4(0);




    TCCR0B = 4; /* Clock/256 */
    /* sbi(TIMSK0, TOIE0); */ /* timer 0 overflow interrupt enable */
    sbi(TIMSK0, OCIE0A); /* timer 0 compare A interrupt enable */
    OCR0A = 250; /* (16e6/1024/250) = 250 interrupts per second. */
    OCR0A--; /* avoid off by one error */
    TCCR0A = 2; /* CTC, clear on compare match */


    cbi(DDRD, PD2);
    sbi(PORTD, PD2);

    sei();


}




#define BAUDRATE 9600UL
#define BAUD_PRESCALE (((F_CPU / (BAUDRATE * 16UL))) - 1)

void initUART(void){


   UCSR0B = (1 << RXEN0) | (1 << TXEN0);   // Turn on the transmission and reception circuitry
   UCSR0C = (1 << UCSZ00) | (1 << UCSZ01); // Use 8-bit character sizes

   UBRR0H = (BAUD_PRESCALE >> 8); // Load upper 8-bits of the baud rate value into the high byte of the UBRR register
   UBRR0L = BAUD_PRESCALE; // Load lower 8-bits of the baud rate value into the low byte of the UBRR register



   /*
   UCSR0B |= (1 << RXCIE0); // Enable the USART Recieve Complete interrupt (USART_RXC)
   sei(); // Enable the Global Interrupt Enable flag so that interrupts can be processed
   */
}

void print (char *string){
  while (*string) {
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = *string;
  string++;
  }
  return;
}

void uart_putchar(char c) {
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
}

void print_uint32_dec (uint32_t i) {
  unsigned long int divisor = 1000000000L;
  if (!i){
      uart_putchar('0');
      return;
  }
  do {
    if (divisor <= i) {
      uart_putchar('0' + i/divisor%10);
    }
    divisor/=10;
  } while (divisor);
//  uart_putchar('\n');
}

void println_uint32_dec (uint32_t i){
    print_uint32_dec(i);
    uart_putchar('\n');
}

void print_uint32 (uint32_t value) {
    uint8_t i;
    uint32_t mask;
    mask = (uint32_t)1 << 31;
    for(i=1;i<33;i++){
        if (value & mask) uart_putchar('1');
        else uart_putchar('0');
        if (!(i%8)) uart_putchar(' ');
        mask = mask >> 1;
    }
    uart_putchar('\n');
}


ISR(TIMER0_COMPA_vect){
    intrcount++;
    if ((intrcount%25) == 0) next_ts = 0;

}




uint8_t delay_ts(uint8_t d){
    uint8_t i;
    for(i=0;i<d;i++){
        next_ts = 1;
        while(next_ts);
    }
    return 0;
}





void beep(void){
    uint8_t i;
    sbi(DDRD, PD2);
    for(i=0;i<4;i++){
        sbi(PORTD, PD2);
        _delay_ms(100);
        cbi(PORTD, PD2);
        _delay_ms(900);
    }
}

/* exposition duration */




uint8_t getint(void){
    uint8_t c, v = 0;

    while(1){
        loop_until_bit_is_set(UCSR0A, RXC0);
        c = UDR0;
        if (c == '\n') break;
        if ((c < '0') || (c > '9')) continue;
        c -= '0';
        v = v*10 + c;
    }

    return v;
}




int main (void){
    uint8_t i;

    init();
    initUART();
    print("This is a camera illumination unit controller\n");

    led(1);
    delay_ts(10);
    led(0);



    while(1){

        led(1);
        LED1(1);
        delay_ts(2);
        LED1(0);
        delay_ts(20);

        LED2(1);
        delay_ts(2);
        LED2(0);
        delay_ts(20);

        led(0);

        LED3(1);
        delay_ts(2);
        LED3(0);
        delay_ts(20);

        LED4(1);
        delay_ts(2);
        LED4(0);
        delay_ts(20);


    }



    while(1){
        i = getint();

        print_uint32_dec(i);
        print("   ");
        print_uint32_dec(255-i);
        uart_putchar('\n');
    }



    while(1){



        lightR(1);
        lightG(0);
        lightB(0);

        delay_ts(5);
        while bit_is_set(PIND, PD2);
        print("key\n");


        lightR(0);
        lightG(1);
        lightB(0);


        delay_ts(5);
        while bit_is_set(PIND, PD2);
        print("key\n");


        lightR(0);
        lightG(0);
        lightB(1);


        delay_ts(5);
        while bit_is_set(PIND, PD2);
        print("key\n");


        lightR(1);
        lightG(1);
        lightB(1);

        delay_ts(5);
        while bit_is_set(PIND, PD2);
        print("key\n");


        lightR(0);
        lightG(0);
        lightB(0);

        delay_ts(5);
        while bit_is_set(PIND, PD2);
        print("key\n");



    }


    return 0;
}
