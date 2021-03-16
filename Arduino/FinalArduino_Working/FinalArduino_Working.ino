byte x;
int j = 0;
int state=0;


void setup() {
 Serial.begin(115200);
 pinMode(10, OUTPUT);
 delay(100);
}

void loop() 
{
  if(Serial.available()>0)
  {
    //Serial.print("I am reading this: ");
    j=Serial.read();
    //Serial.println(j);
    Execute(j);
    //Serial.flush();
  }

  delay(100);  
}

void Execute(int t) {
  switch (t)
  {
    case 1:
      Serial.println("Dark");
      state=1;
      digitalWrite(10, HIGH);
      break;
    case 2:
      state=2;
      Serial.println("Light");
      digitalWrite(10, LOW);
      break;
    case 3:
      Serial.print("Last State: ");
      Serial.println(state);
      break;
    default:
      state=0;
      Serial.println("Unknown command");
      break;  
  }   
}
