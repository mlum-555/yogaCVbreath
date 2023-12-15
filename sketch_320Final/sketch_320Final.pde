import processing.serial.*;
import processing.video.Capture;
import processing.sound.*;
import java.util.*;


//New implemented stuff, pose class, add more pose images and detection points
//press N to switch to next pose, press D to clear detection points.

//Notes on the pose class stuff are in the labeled class.
//Analog readings are taken from A0 on the circuit playground, if you want to test the breathing sensor stuff.
//breathing visualization is calibrated with min & max sensor readings from a range, the "rangeLow/High" values in it - change these if you want

import processing.serial.*;

import processing.video.Capture;
import java.util.*;



import ch.bildspur.vision.DeepVision;
import ch.bildspur.vision.SingleHumanPoseNetwork;
// OpenCV is used in this network
import ch.bildspur.vision.result.HumanPoseResult;

import ch.bildspur.vision.result.KeyPointResult;



SoundFile bgm;

PImage yogaPose;
Serial myPort;  // Serial port
String[] sensorValues;  // Store acceleration data read from the serial port

// Global variables
DetectionPoint[] detectionPoints; // Array to store all detection points


// Moving average filter parameters
int numReadings = 10;
float[] readingsX = new float[numReadings];  // Array to store readings
float[] readingsY = new float[numReadings];
int readIndex = 0;  // Current reading index
float totalX = 0;  // Total of X readings
float totalY = 0;  // Total of Y readings
float averageX = 0;  // Average of X readings
float averageY = 0;  // Average of Y readings


BreathingVis breathingCircles;


//state switching:

int currState = 1;

//states:
final int STARTSCREEN = 0;
final int SELECTIONSCREEN = 1;
final int POSESCREEN = 2;
final int FEEDBACKSCREEN = 3;
//put a high level switch function in


Pose[] yogaPoses;
int currentPoseIndex = 0; // 当前显示的瑜伽姿势索引




//pose estimation stuff
DeepVision vision = new DeepVision(this);

SingleHumanPoseNetwork pose;
HumanPoseResult result;

float threshold = 0.5;

ArrayList<Integer> visKeys = new ArrayList<Integer>(); 

boolean calibrationDone = false;
boolean inPose = false;

String c = "complete";
String in = "incomplete";
String comp;
Capture cam;

int skelePointSize = 20;

float camScale = 1.3;


int prevTime;
int maxPoseLoss=5000; //max time a pose can be "lost" before uh breathing circles fade

int poseLossTimer = 0;


boolean circleFadeTest = true;
 /*
Total of 16 Keypoints: Their number Id
 getNose(0)
 getLeftEye(1)
 getRightEye(2)
 getLeftEar(3)
 getRightEar(4)
 getLeftShoulder(5)
 getRightShoulder(6)
 getLeftElbow(7)
 getRightElbow(8)
 getLeftWrist(9)
 getRightWrist(10)
 getLeftHip(11)
 getRightHip(12)
 getLeftKnee(13)
 getRightKnee(14)
 getLeftAnkle(15)
 getRightAnkle(16)
 */
 
 //if we change to a different model with different output poses, change the number to its new one; don't change its position in the list

  int[] pointList = new int[17];
  

  int[][] pointCoords=new int[17][2];

String[] overlayFiles = {"bg0.png","bg1.png","bg2.png","bg3.png","bg4.png","bg5.png"};

OverlayHandler overlay;


int skeleTransparency = 100;


SoundFile goodSound;

void setup() {
  size(800,600); //should be first call, no matter what
  bgm = new SoundFile(this,"bgm.mp3");
  goodSound = new SoundFile(this,"goodSound.wav");
  bgm.amp(0.5);
  bgm.loop();
  
  overlay = new OverlayHandler(overlayFiles);
  prevTime=millis();
  
  for(int i=0; i<17; i++){ //messy quick function for instantiating points list
    pointList[i] = i;
    
    pointCoords[i][0]=0;
    pointCoords[i][1]=0; //this is the x & y used for calls and such
    
    
    //wait maybe send the pointscoord list in entirety to a new detectpoint update
    
    
  }
  
  
  
  
  println("creating network...");
  pose = vision.createSingleHumanPoseEstimation();

  println("loading model...");
  pose.setup();

  println("setup camera...");
  //cam = new Capture(this,1280,720, "pipeline:autovideosrc");
  //cam.start();
  
 
  
  String[] cameras = Capture.list();
   if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }
      
      // The camera can be initialized directly using an 
      // element from the array returned by list():
      cam = new Capture(this, cameras[0]);
      cam.start();     
     }
  
  yogaPoses = new Pose[] {
    
    new Pose("Pose 0", "p5.png", new DetectionPoint[] { //sitting 1
      new DetectionPoint(315, 530, 13),
      new DetectionPoint(475, 530, 14),
      new DetectionPoint(350, 240, 9),
      new DetectionPoint(450, 240, 10),
    }, 100, 0, 600, 600),
    new Pose("Pose 0.0", "p0.png", new DetectionPoint[] { //sun salutation
      new DetectionPoint(400, 50, 9),
      new DetectionPoint(400, 140, 0),
    }, 100, 0, 600, 600),
    
    new Pose("Pose 0.2", "p2.png", new DetectionPoint[] {//warrior 1
      new DetectionPoint(400, 110, 9),
      new DetectionPoint(530, 430, 13),
      new DetectionPoint(220, 525, 16),
    }, 100, 0, 600, 600),
    
    new Pose("Pose 0.1", "p1.png", new DetectionPoint[] {//tree
      new DetectionPoint(260, 370, 13),
      new DetectionPoint(390, 550, 16),
      new DetectionPoint(390, 55, 10),
    }, 100, 0, 600, 600),
    new Pose("Pose 0.3", "p3.png", new DetectionPoint[] { //warrior 2
      new DetectionPoint(230, 525, 15),
      new DetectionPoint(525, 525, 16),
      new DetectionPoint(565, 275, 10),
      new DetectionPoint(230, 275, 9),
    }, 100, 0, 600, 600),
    new Pose("Pose 6", "p6.png", new DetectionPoint[] { //sitting 2
      new DetectionPoint(315, 530, 13),
      new DetectionPoint(475, 530, 14),
      new DetectionPoint(390, 410, 9),
    }, 100, 0, 600, 600)
  };

  println(Serial.list());
  if(Serial.list().length==0){
    println("no serial ports available");
  }
  else{
    myPort = new Serial(this, Serial.list()[0], 9600);
    myPort.bufferUntil('\n');
  
    // Initialize the readings array
    for (int i = 0; i < numReadings; i++) {
      readingsX[i] = 0;
      readingsY[i] = 0;
    }
  }

  breathingCircles = new BreathingVis((cam.width/2)*camScale, (cam.height/2)*camScale, 0.7);

}



void draw() {
  //run base code here; sensor values

  //ignore this for now - basic state switcher setup for later
  switch(currState) {
  case STARTSCREEN:
    break;
  case SELECTIONSCREEN:
    break;
  case POSESCREEN:
    break;
  }

 background(255);
 
 //flip stuff here
 
  pushMatrix();
    //translate(height/4,width/4);
    //scale(2);
    //ohh ok wait no nvm what
    
    //flipped stuff:
    
    scale(1);
    
      pushMatrix();
        scale(camScale,camScale);
        translate(cam.width,0);
        
        //push matrix into an individual scale for the camera
        //wait no you've already scaled it here. uh
        scale(-1,1);
        drawCam(0,0,camScale);
        
      popMatrix();
      
      drawPoseScreen();
      
      
      
    //  drawTruePoints();
      
      textSize(40);
      fill(255, 255, 255);
      text("Breathing Ratio: "+breathingCircles.scaleRatio()+" : 1",50,50);
      text("average breath speed:"+nf(breathingCircles.speedAvg,0,2),50,100);
     // text("Visible Points: "+ visKeys.size(), 0, 80);
      
     
      checkPoseLoss();
     overlay.drawOverlay();
    fill(255,breathingCircles.transparency);
    text("Breathe slowly while you hold the pose.",50,200);
    
    popMatrix();
    
    checkPoseCompletion();
    breathingCircles.setLastTime();
}


void drawTruePoints(){
 for(int[] points : pointCoords){
   fill(0,255,0);
   ellipse(points[0],points[1],50,50);
 }
  
}


void checkPoseLoss(){
  
  if(yogaPoses[currentPoseIndex].checkPoints()){
    
    poseLossTimer = 0;
    breathingCircles.fadeInVis();
  }
  else{
    poseLossTimer+=(millis()-prevTime);
    if(poseLossTimer>maxPoseLoss){
     breathingCircles.fadeOutVis(); 
    }
    
  }
  
  prevTime=millis();
}

void resetBreathVis(){
  breathingCircles.fadeOutVis();
  poseLossTimer=0;
  
}


void drawCam(int xPos, int yPos, float scale){
  if (cam.available() == true) {
    cam.read();
  }
  
  pushMatrix();
    //translate(xPos,yPos);
    //translate(cam.width*scale,0);
    

    //note: cam.resize does not work well here
    image(cam, 0,0);
    
    runPoseEstimation();
    
    //set(0, 0, cam);
    //apparently this is a bit faster but can't be scaled or anything
  
  popMatrix();
  
  surface.setTitle("Pose Estimation Test - FPS: " + Math.round(frameRate));
  
  
}



void runPoseEstimation(){
 if (cam.width == 0) {
    return;
  }

  result = pose.run(cam);


  // draw result
  stroke(180, 80, 100);
  noFill();
  drawHuman(result);

  if (calibrationDone == false) {
    calibrate(result);
  } else if (calibrationDone == true) {
    //treeP(result);
  } 
}





void drawPoseScreen() {
 
  

  noStroke();
  // current yoga pose
  Pose currentPose = yogaPoses[currentPoseIndex];
  currentPose.display();
  // Update and display all detection points
  for (DetectionPoint dp : currentPose.detectionPoints) {
    dp.update(pointCoords);
  }

  // Draw a dot representing the position of the accelerometer sensor
  //fill(0, 0, 255); // Set the color of the moving dot to blue
  //ellipse(averageX, averageY, 20, 20); // Map the averages to screen coordinates
  
  breathingCircles.drawBreathingVis(); //drawing breathing circles; rest is for drawing pose & such)
  
}



void getSensorVals() {
}


// go to next pose in pose list
void nextPose() {
  yogaPoses[currentPoseIndex].resetTimer();
  goodSound.play();
  if(circleFadeTest){
    if(breathingCircles.transparency>0) breathingCircles.fadeOutVis();
    else breathingCircles.fadeInVis();
  }
  else breathingCircles.fadeOutVis();
  currentPoseIndex++;
  if (currentPoseIndex >= yogaPoses.length) {
    currentPoseIndex = 0;
  }
  yogaPoses[currentPoseIndex].resetTimer();
  
  overlay.startTransition();
}



void checkPoseCompletion(){ //goes to next pose if complete
  if(yogaPoses[currentPoseIndex].timeCheck()){
    nextPose();
    
  }
}




void keyPressed() { //press N to go next
  if (key == 'n' || key == 'N') {
    nextPose();
  }
  if (key == 'd' || key == 'D') {
    yogaPoses[currentPoseIndex].toggleDetectionPoints();
  }
}

void serialEvent(Serial myPort) {
  // Read data from the serial port
  String dataString = myPort.readStringUntil('\n');
  if (dataString != null) {
    sensorValues = split(trim(dataString), ",");  // Split the read string into an array
    if (sensorValues.length >= 4) {
      // Assuming the first two values of the sensor array are X and Y
      float x = float(sensorValues[0]);
      float y = float(sensorValues[1]);

      float s = float(sensorValues[3]);
      breathingCircles.inputData(s);
       println(s);
      //println(s);


      // Update the moving average filter
      totalX -= readingsX[readIndex];
      totalY -= readingsY[readIndex];

      readingsX[readIndex] = x;
      readingsY[readIndex] = y;

      totalX += readingsX[readIndex];
      totalY += readingsY[readIndex];

      readIndex++;

      if (readIndex >= numReadings) {
        readIndex = 0;
      }

      averageX = totalX / numReadings;
      averageY = totalY / numReadings;

      // Map the accelerometer data to screen coordinates
      averageX = map(averageX, -10, 10, 0, width);
      averageY = map(averageY, -10, 10, 0, height);
    }
  }
}







private void drawHuman(HumanPoseResult human) {
  // draw human
  connect(human.getLeftAnkle(), 
    human.getLeftKnee(), 
    human.getLeftHip(), 
    human.getLeftShoulder(), 
    human.getLeftElbow(), 
    human.getLeftWrist());

  connect(human.getRightAnkle(), 
    human.getRightKnee(), 
    human.getRightHip(), 
    human.getRightShoulder(), 
    human.getRightElbow(), 
    human.getRightWrist());

  connect(human.getLeftHip(), human.getRightHip());
  connect(human.getLeftShoulder(), human.getRightShoulder());

  connect(human.getLeftShoulder(), human.getNose(), human.getRightShoulder());
  connect(human.getLeftEar(), human.getLeftEye(), human.getRightEye(), human.getRightEar());
  connect(human.getLeftEye(), human.getNose(), human.getRightEye());

  // draw points
  int i = 0;
  fill(0);
  
  DetectionPoint[] decList = yogaPoses[currentPoseIndex].getPoints();
  
  for (KeyPointResult point : human.getKeyPoints()) {
    if (point.getProbability() < threshold)
      continue;

    //println("Drawn Points?: " + point.getId());

    //get the change color of the detection points; use that to modify the color if the ID matches
    //for amount of current detection points, check if this id matches detection point id
    //if so, change fill color based on stuff yeah
   
   stroke(255,0,0);
   
   for(int z=0; z<decList.length; z++){
    if(point.getId()==decList[z].getNum()){
      stroke(decList[z].getColor(),skeleTransparency);
    }
   }
    
   
    
    ellipse(point.getX(), point.getY(), skelePointSize, skelePointSize);
    //textSize(5);
    //text(i, point.getX() + 5, point.getY());
    i++;
    
    //assuming for now things will just go in the stated order
    
    int tempX = (int)(point.getX()*camScale);
    tempX = width-tempX;
    tempX+=40;
     pointCoords[point.getId()][0] = tempX;
   // pointCoords[point.getId()][0] = (int)(point.getX()*camScale)-40;
    pointCoords[point.getId()][1] = (int)(point.getY()*camScale);
    
  }
}




private void connect(KeyPointResult... keyPoints) {
  for (int i = 0; i < keyPoints.length - 1; i++) {
    KeyPointResult a = keyPoints[i];
    KeyPointResult b = keyPoints[i + 1];

    if (a.getProbability() < threshold || b.getProbability() < threshold)
      continue;
      
     
    strokeWeight(2);
    stroke(0,skeleTransparency);
    line(a.getX(), a.getY(), b.getX(), b.getY());
  }
}


//checking to see if all keyPoints are visible on screen (not dynamically, just counting them up)
private void calibrate(HumanPoseResult h) {
  for (KeyPointResult point : h.getKeyPoints()) {

    if (!visKeys.contains(point.getId())) {
      //only checking the points that are visible (pass the certainty threshold)
      if (point.getProbability() > threshold) {
        visKeys.add((int)point.getId()); 
        println("Key Point added: " + point.getId());
      }
    }   

    if (visKeys != null) {
      textSize(40);
      fill(0, 0, 255);
     // text("Visible Points: "+ visKeys.size(), 0, 80);
    }
    
    
    
  }

  if (visKeys.size() ==17) {
    calibrationDone = true;
  }
}





private void treeP(HumanPoseResult hu) {
  for (KeyPointResult point : hu.getKeyPoints()) {
    
  }
  
  if (inPose == true) {
    comp = c;
  } else {
    comp = in;
  }

  textSize(40);
  fill(0, 0, 255);
  text("Tree Pose: " + comp, 0, 80);
}
