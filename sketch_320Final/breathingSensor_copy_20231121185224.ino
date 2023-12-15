#include "Adafruit_CircuitPlayground.h"

//smoothing code taken from: https://www.arduino.cc/en/Tutorial/BuiltInExamples/Smoothing


//smoothing vals
  const int numReadings = 10;

  int readings[numReadings];  // the readings from the analog input
  int readIndex = 0;          // the index of the current reading
  int total = 0;              // the running total
  int average = 0;            // the average

  int inputPin = 0;


//range values to map *from* for output; should be calibrated occasionally
  int minVal = 220;
  int maxVal = 280;

  int outputRange = 30; //amount + / - from 0 output values will be
  

void setup() {
  // put your setup code here, to run once:
  CircuitPlayground.begin();
  Serial.begin(9600);

  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    readings[thisReading] = 0;
  }
}



void loop() {

  //smoothing code:
      // subtract the last reading:
      total = total - readings[readIndex];
      // read from the sensor:
      readings[readIndex] = analogRead(inputPin);
      // add the reading to the total:
      total = total + readings[readIndex];
      // advance to the next position in the array:
      readIndex = readIndex + 1;

      // if we're at the end of the array...
      if (readIndex >= numReadings) {
        // ...wrap around to the beginning:
        readIndex = 0;
      }

      // calculate the average:
      average = total / numReadings;

      //int tempAvg = map(average,minVal,maxVal,-outputRange,outputRange);
      // send it to the computer as ASCII digits

      //float convertedVal = 1 + (tempAvg*0.01); //converts to a percent


      float convertedVal = average;
      //Serial.println(convertedVal);
      
     // delay(20);  // delay in between reads for stability

/*
things to do:

1. signal smoothing - done

2. map values between high and low, based on some range

3. some calibration on some condition (probably set it to a button for now)
---later down the line, have calibration done by breathing in and out, & taking the range there

*/

//delay(5);

  float x = CircuitPlayground.motionX(); 
  float y = CircuitPlayground.motionY(); 
  float z = CircuitPlayground.motionZ(); 

 // Serial.print(convertedVal); //stretch sensor reading
  //Serial.print(",");

//accelerometer stuff
  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
 Serial.print(z);
Serial.print(",");
 Serial.println(convertedVal);
  delay(20); 

}

//call to change the "target" value;
//or wait - maybe we should put recalibration in processing? it's probably bad to modify the sensor data itself
void recalibrate(){
//maybe calibration should be between like lowest and max; breathe in fully, then breathe out
//


}
