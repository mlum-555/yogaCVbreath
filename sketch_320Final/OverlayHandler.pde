class OverlayHandler {
  //basically this should be the handler of all overlay image related stuff. just to keep the main sketch clean
  
  PImage[] poseImgs;
  
  PImage currentImg;
 
  PImage nextImg;
  
  int activeImg;
  
  
  int mainOpacity = 150;
  
  int opacityChangeVal = 0; //added to new one, taken out of old one
  
  float opChangeRate = 4.0; //amount opacity changeval changes by per draw call
  
  boolean changingImg = false;
  
  int lastTime = 0;
  int xPos = 0;
  int yPos = 0; //in case we need to change the background image position for some reason
  
  OverlayHandler(String[] imgList){
   this.activeImg = 0;
    if(imgList !=null){
      this.poseImgs = new PImage[imgList.length];
      
      for(int i = 0; i<poseImgs.length;i++){
        poseImgs[i] = loadImage(imgList[i]); //loads an image for each one      
      }
    }
    else println("NO BACKGROUNDS LOADED");
    currentImg = poseImgs[0];
  }
  
  void startTransition(){
    println("CHANGING BACKGROUND");
    changingImg = true;
    activeImg++;
    if(activeImg>=poseImgs.length) activeImg=0;
    nextImg = poseImgs[activeImg];
  }
  
  
  
  //BASIC OVERLAY SIZE; RESOLUTION?
  
  
  
  
  
 void drawOverlay(){
   int timeDiff = lastTime - millis();
     opChangeRate = -1*(timeDiff/10);
   this.lastTime = millis();
  if(!changingImg){
    tint(255,mainOpacity);
    image(currentImg,xPos,yPos);
  }
  
  else{
    println(opacityChangeVal);
    checkTransition();
    
    tint(255,mainOpacity - opacityChangeVal);
    image(currentImg,xPos,yPos);
    
    tint(255,opacityChangeVal);
    image(nextImg,xPos,yPos);
    
   }
     
     tint(255); //tint call to not mess other stuff up
  }
  
  
  
  void checkTransition(){ //checks if transition is done, finishes up if so; also increases opacity change
    opacityChangeVal+=opChangeRate;
    
    if(opacityChangeVal>=mainOpacity){
      changingImg = false;
      currentImg = nextImg;
      opacityChangeVal=0;
    }
    
    
  }
  
  
}
