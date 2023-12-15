class BreathingVis{
 
  //position & scale
  float xPos, yPos;
 float scaleMult = 0.7;
 
 //baseSize
 float sensorReading;
 
 

 //focus on visualization first, then do 



//guide circle stuff:
float animSpeed = 1.0;
float baseSpeed = 1.0;

float decelRate = 0.5;

int guideSize = 100;
int maxSize = 300;
int minSize = 100;
boolean increasing = true;
  
int visSize = 200; // size of visualization circle

float baseAnimSpeed = 0.5;

int rangeLow = 230;
int rangeHigh = 270;


int transparency = 0;

 float actualEllipseSize = 100;
 
 //default constructor
 /*
 BreathingVis(){
   xPos = 250;
   yPos = 250;
   maxSize = 300;
   minSize = 100;
   visSize = 150;
   guideSize = minSize;
 }
 */
 
 
//stuff for checking average speed I guess

//speed is average change rate

//poll time? wait no I think you can just do like last millis value again

 int lastTime;
 float speedTotalVals;
 float speedAvg;
 
 //wait you need to calculate value difference, for one
 
 //like yknow. the actual difference between input & output vals
 
 float fadeSpeed;
 boolean visible;
 
 
 int maxTransparency = 100;


 //if fade speed >0, <0 or 0
float baseFadeSpeed = 0.1;
 
 BreathingVis(float xPos, float yPos, float scaleMult){
   this.xPos = xPos;
   this.yPos = yPos;
   this.scaleMult = scaleMult;
   maxSize = 300;
   minSize = 100;
   visSize = 150;
   guideSize = minSize;
   this.lastTime=millis();
   speedTotalVals = 0.0;
   
   fadeSpeed = 0;
   
 }
 
 
 
 
 void fadeInVis(){
   if(transparency!=maxTransparency)
   fadeSpeed = baseFadeSpeed;
   
 }
 
 void fadeOutVis(){
   if(transparency!=0)
   fadeSpeed = -baseFadeSpeed;
   
 }
 
 
 
 
 
 void updateAvg(float lastVal, float currentVal){
  
  
  float timeDiff = millis()-lastTime;
  //have it multiply everything based on time diff; or rather have timeDiff divide it? like expected change of 10ms,  sure go with that?  
  
  float valDif = abs(currentVal-lastVal); //absolute difference between last recorded value & current
  
  float tempAvg = valDif*(timeDiff/10); //multiplying that based on how much time has passed I guess (is the division neccessary here?)
  this.speedTotalVals+=tempAvg;
  
  this.speedAvg = speedTotalVals/millis();
  
  
 }
 
 
 //TO ADD: a default height/width for overlay images
 
 
 String scaleRatio(){
   float workingNum = -actualEllipseSize/guideSize;
      return nf(workingNum,0,2);
 }
 
 
 void updateVis(float data){
  
  inputData(data);
 }
 
 
 void setLastTime(){
   this.lastTime=millis();
 }
 
 
 void drawBreathingVis(){
   if(fadeSpeed!=0){
     transparency+=(fadeSpeed*(millis()-lastTime));
     
     if(transparency>=maxTransparency){
       transparency=maxTransparency;
       fadeSpeed = 0;
     }
     
     if(transparency<=0){
       transparency=0;
       fadeSpeed = 0;
     }
     
   }
  // transparency=maxTransparency;
   
   
   float timeDiff = millis()-lastTime;
   animSpeed = baseAnimSpeed*(timeDiff/10);
   
   
   this.lastTime = millis(); 
   if((guideSize > maxSize && increasing) || (guideSize<minSize && !increasing)){
    increasing = !increasing;
   // println(increasing);
    //animSpeed = baseSpeed;
  }
  
   if (animSpeed<0.03) animSpeed = 0.03;
  
  //should accelerate up during first 20% or so, accelerate down in the last 20% 
  //total range of 200 values
  
  int accelRange = 60;
  int compSize = guideSize-100;
  
  
  if(increasing){
    guideSize+=animSpeed;
  }
  else{
    guideSize -=animSpeed;
  }
  
  
   
  //function for drawing visualization thing
  //should have an expanding circle between min / max sizes
  //ellipse size will be + or -50 max; translate this to a percent
  
  
  
  pushMatrix();
  
  
    translate(xPos,yPos);
    scale(scaleMult);
    
    
    //drawing visualization circle
    stroke(0,0,135,transparency);
    strokeWeight(20);
    int ellipseSize = visSize;
    
    
//sensor value should be mapped to +/- 0.5 from 1, which is the middle value
//uhh, subtract min value from sensor reading, then divide values by base value?

//wait no divide values by the difference between high and low
    
    float middleVal = (rangeLow + rangeHigh) / 2;
    float mappedVal = (sensorReading-rangeLow) / (rangeHigh - rangeLow);
    //println(mappedVal);
    //so now it'll just be a percent of that value I think?
    mappedVal +=0.5;
    
    
    ellipseSize*=mappedVal;
    
    actualEllipseSize = ellipseSize;
    
   // println(mappedVal);
    fill(255,transparency);
    ellipse(0,0,ellipseSize,ellipseSize);
    
    
    //drawing guide circle
    noStroke();
    fill(255, 165, 120,transparency/2); //partial circle
    
    ellipse(0,0,guideSize,guideSize);
  
  popMatrix();
  

 }
 

 
  void inputData(float data){
    updateAvg(sensorReading,data);
    sensorReading = data;
  }
  
  void changePos(int x, int y){
   this.xPos = x;
   this.yPos = y;
  }
  
  
  void recalibrate(int low, int high){ //I'm still not 100% sure how we'd put this in / where to get the values from
    rangeLow = low;
    rangeHigh = high;
  }
  
}
