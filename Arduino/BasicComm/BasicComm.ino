int incomingByte = 0; // for incoming serial data
int second=0;

void setup() {
  Serial.begin(9600); // opens serial port, sets data rate to 9600 bps
  UDR0=1;
}

void loop() {
  // send data only when you receive data:
  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();
    if (incomingByte=!second) {
        second=incomingByte;
    }
    
    // say what you got:
    Serial.print("I received: ");
    Serial.println(second, DEC);
  }
  else {
    Serial.println("Nothing received");
    delay(500);
  }
  
  
  
}
