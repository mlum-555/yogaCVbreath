class DetectionPoint {
  int x, y; // Coordinates of the detection point
  int diameter; // Diameter of the detection point
  boolean isOverlapping; // Flag for overlap
  boolean hasTurnedGreen; // Flag for turning green
  int startTime; // Time when overlap starts
  color currentColor; // Current color of the detection point

  int requiredTime; // Required overlapping time, in milliseconds
  int pointNum; //what point on the skeleton it corresponds to & checks for

  int changeColor;
  int maxDist; //max distance for detection to start
  
  int transparency = 150;
  

  DetectionPoint(int x, int y, int pointNum) {
    this.x = x;
    this.y = y;
    this.pointNum = pointNum;
    this.diameter = 80; //every point will probably have the same diameter anyways
    this.maxDist = 180;
    this.requiredTime = 2000;
    this.isOverlapping = false;
    this.hasTurnedGreen = false;
    this.startTime = 0;
    this.currentColor = color(255, 0, 0); // Initially red
  }
  
  
  
  void proxUpdate(float sensorX, float sensorY){
    float tempDist = dist(sensorX, sensorY, this.x, this.y);
    if(tempDist<=this.maxDist){
      this.changeColor = (int) map(tempDist, maxDist, 0, 100,255); //maps color change value based on distance to center
    }
    else this.changeColor = 0;
    
  }
  
  
  
void update(int[][] coords){ //alternate call
     //if(this.pointNum==10) println(coords[pointNum]);
  
   if (dist(coords[pointNum][0], coords[pointNum][1], this.x, this.y) < this.diameter / 2) {
          this.currentColor = color(0, 255, 0); // Turn green  I KNOW this messes things up hold on
        if (!this.isOverlapping) {
          this.isOverlapping = true;
          this.startTime = millis();
        } else if (millis() - this.startTime >= requiredTime) {
          this.currentColor = color(0, 255, 0); // Turn green
          this.hasTurnedGreen = true;
        }
        
      } else {
        this.isOverlapping = false;
        proxUpdate(coords[pointNum][0], coords[pointNum][1]);
        this.currentColor = color(255,changeColor,0);
      }
      
    
  }
  
color getColor(){
 return(this.currentColor); 
}
int getNum(){
  
 return this.pointNum; 
}
  

  void update(float sensorX, float sensorY) {

    
    if (dist(sensorX, sensorY, this.x, this.y) < this.diameter / 2) {
          this.currentColor = color(0, 255, 0); // Turn green  I KNOW this messes things up hold on
        if (!this.isOverlapping) {
          this.isOverlapping = true;
          this.startTime = millis();
        } else if (millis() - this.startTime >= this.requiredTime) {
          this.currentColor = color(0, 255, 0); // Turn green
          this.hasTurnedGreen = true;
        }
        
      } else {
        this.isOverlapping = false;
        proxUpdate(sensorX, sensorY);
        this.currentColor = color(255,changeColor,0);
      }
      
  }
  
  boolean checkState(){ //checks if it's overlapped or not
   return this.isOverlapping; 
  }

  void display() {
    fill(currentColor,transparency);
    ellipse(this.x, this.y, this.diameter, this.diameter);
  }
}
