class Pose {
    String name;
    PImage image;
    DetectionPoint[] detectionPoints;
    int imgX, imgY, imgWidth, imgHeight; 
    boolean showDetectionPoints = true; 
    
    int timeReq; //time to hold the pose for in total - probably better to do like this imo

    int lastTime; //time to start counting down from; taken at the end of each update call

    int totalTime; //overall time counter
    
    int transparency;
    
    PImage startImg;
    
    boolean startup;
    int startTime;
    
    int startLength;
    
    
    Pose(String name, String imagePath, DetectionPoint[] detectionPoints, int imgX, int imgY, int imgWidth, int imgHeight) {
        this.name = name;
        this.image = loadImage(imagePath);
        String tempString = imagePath.substring(0,imagePath.length()-4);
        tempString+="0.png";
        this.startImg = loadImage(tempString);
        if(this.startImg==null) this.startImg = this.image;
        
        this.detectionPoints = detectionPoints;
        this.imgX = imgX;
        this.imgY = imgY;
        this.imgWidth = imgWidth;
        this.imgHeight = imgHeight;
        this.transparency=200;
        this.timeReq = 10000; //miliseconds needed to change to the next pose
        this.totalTime = timeReq; //maybe this is redundant
        this.lastTime=millis();
        this.startTime=millis();
        
        
        this.startLength = 8000; //pose startup takes 7 seconds
        
        this.image.resize(imgWidth, imgHeight);
        this.startup = true;
    }

    void toggleDetectionPoints() {
        showDetectionPoints = !showDetectionPoints;
    }
    
    DetectionPoint[] getPoints(){
      return this.detectionPoints;
    }
    
    
    
    
    
    void updateTime(){
      if(this.checkPoints()){
        this.totalTime-=(millis()-this.lastTime);
      }
      this.lastTime=millis();
    }
    
    boolean timeCheck(){ //if total time is less than/equal to zero,return true; used for pose switching
      if(this.totalTime<=0) return true;
      return false;
    }
    
    
    void display() {
      if (startup){
        tint(255,this.transparency);
        image(startImg, imgX, imgY);
        tint(255);
        fill(255);
        text("Get into the position onscreen.",100,500);
        
        
        if(millis()>(this.startTime+this.startLength)) this.startup=false;
        
      }
      
      else{
        
        
      tint(255,this.transparency);
        image(image, imgX, imgY);
      tint(255);
        if (showDetectionPoints) {
            for (DetectionPoint dp : detectionPoints) {
                dp.display();
            }
        }
        
      }
      
        this.updateTime();//I know this probably shouldn't be here but it's the call for it anyways
    }
    
    boolean checkPoints(){ //returns true if all detection points are good
      if(startup) return false;
      for (DetectionPoint dp : detectionPoints) {
          if(dp.checkState()==false) return false;
      }
      return true;
    }
    
    void resetTimer(){
      this.startTime=millis();
    }
    
}
