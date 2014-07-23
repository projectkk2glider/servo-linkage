/*
* Servo linkage simulation
* Author: Damjan Adamic <projectkk2glider@gmail.com>
* Version: 1.0 
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License version 2 as
* published by the Free Software Foundation.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*/


/* ------------------------------------------------------------------------------------------*\
    START OF CONFIGURATION SECTION
    
    USAGE
    
      * configure dimensions
      * run simulation (Ctrl+R), inside simulation window:
        * use mouse to position servo horn (left mouse button down orients servo horn towards current mouse pointer)
        * use 's' key to make a snapshot of current position
        * use 'c' key to clear all shapshots
        * use 't' key to toogle linkage solution
      * exit simulation, adjust parameters and re-run simulation until desired configuration is achieved
    
    
    CONFIGURATION
    
      Edit values to achive desired result
      
      It is best to make a copy of a group of settings and edit them. Comment all other 
      groups of settings. You can toogle comment with the Ctrl+/ key combination.
      
      Units are arbitrary, you can use floating numbers (ie 3.456) if needed.
\* ------------------------------------------------------------------------------------------*/

// example setup 1 (bottom hinged, bottom driven flap linkage)
float distanceServoHingeX = 85;
float distanceServoHingeY = -13;
float servoHornLen = 11;
float controlHornLen = 14;
float pushrodLen = 88;
float surfaceHornAngle = radians(-45);
float surfaceLen = 49;
float wingHeightAtServo = 22;
float wingHeightAtHinge = 11;
boolean otherSolution = true;

//// example setup 2 (bottom hinged, top driven flap linkage)
//float distanceServoHingeX = 85;          //distance from servo pivot point to the surface pivot point in X axis
//float distanceServoHingeY = -13;         //distance from servo pivot point to the surface pivot point in Y axis
//float servoHornLen = 12;                 //length of servo horn
//float controlHornLen = 12;               //length of control horn
//float pushrodLen = 85;                   //length of push-rod
//float surfaceHornAngle = radians(135);   //angle between control surface and control horn
//float surfaceLen = 49;                   //lenght of control surface
//float wingHeightAtServo = 22;            //wing height (distance in Y axis) at the servo pivot point
//float wingHeightAtHinge = 11;            //wing height (distance in Y axis) at the control surface hinge point
//boolean otherSolution = false;           //which solution to use when calculating surface position (start  value). 
//                                         //You can toogle this when runnitg with the press of 't' key. 

/*
    General settings
*/
float scale = 4.3;             //drawing scale (all measurements above are multiplied with this number to covert them to pixels)
float defaultTextSize = 14;    //preferred test size 
int windowHeight = 400;        //simulation window height (pixels)
int windowWidth = 800;         //simulation window width (pixels)
float defaultOpacity = 150;    //transparency of linkage diagram 0-255 (bigger number -> more opaque, less transparent)
float snapshotOpacity = 70;    //transparency of shapshot diagram 

/* ------------------------------------------------------------------------------------------*\
    END OF CONFIGURATION SECTION
    
    DO NOT EDIT BELOW IF YOU DON'T KNOW WHAT YOU ARE DOING!
\* ------------------------------------------------------------------------------------------*/

float originX;
float originY;
float servoHornAngle = radians(90);
float linkageOpacity;
boolean makeSnapshot = false;
ArrayList<Snapshot> snapshots = new ArrayList<Snapshot>();

void setup() {
  size(windowWidth, windowHeight);
  originX = width/(6*scale);
  originY = height/(2*scale);
}

void keyPressed() {
  if (key == 't') {
    otherSolution = !otherSolution;
  } 
  if (key == 's') {
    makeSnapshot= true;
  } 
  if (key == 'c') {
    snapshots.clear();
  } 
}

class Snapshot {
  Point A, B, C, D, E;
  Snapshot(Point a, Point b, Point c, Point d, Point e) {
    A = a; 
    B = b;
    C = c;
    D = d;
    E = e;
  }
}

class Point {
  float x;
  float y;
  Point(float _x, float _y) {
    x = _x;
    y = _y;
  }
  Point() {
    x = 0;
    y = 0;
  }
  Point(Point start, float angle, float distance) {
    x = start.x + cos(angle)* distance;
    y = start.y + sin(angle)* distance;
  }
  Point(Point A, Point B, float r1, float r2, boolean other) {
    //calculate intersection point between two circles
    float d = A.distance(B);
    float a = (r1*r1 - r2*r2 + d*d)/(2*d); // h is a common leg for two right triangles.
    float h = sqrt(r1*r1 - a*a);
    float P0x = A.x + a*(B.x - A.x)/d;        // locate midpoint between intersections along line of centers
    float P0y = A.y + a*(B.y - A.y)/d;
    if (other) {
      x = P0x - h*(B.y - A.y)/d;
      y = P0y + h*(B.x - A.x)/d;
    }
    else
    {
      x = P0x + h*(B.y - A.y)/d;
      y = P0y - h*(B.x - A.x)/d;
    }
  }
  void display(String txt) {
    textSize(defaultTextSize/scale);
    text(txt+"("+nf(x-originX,1,1)+","+nf(y-originY,1,1)+")", x+2, y+2);
    textSize(defaultTextSize);
  }
  float distance(Point b) {
    float distX = x - b.x;
    float distY = y - b.y;
    return sqrt(pow(distX, 2) + pow(distY,2));
  }
  float angle(Point b) {
    return atan2(b.y - y, b.x - x);
  }
}

void drawSegment(Point start, Point end, color colr, float weight, boolean endPoint) {
  stroke(colr, linkageOpacity);
  strokeWeight(1);
  ellipse(start.x, start.y, 2, 2);
  strokeWeight(weight);
  line(start.x, start.y, end.x, end.y);
  strokeWeight(1);
  if (endPoint) ellipse(end.x, end.y, 2, 2);
}


void displayAngle(float angle, Point at) {
  textSize(defaultTextSize/scale);
  text(nf(degrees(angle), 1,1)+"°", (at.x+3), (at.y-3));
  textSize(defaultTextSize);
}

void drawLinkages(Snapshot curr, boolean canCalculate, String errorMsg) { 
  drawSegment(curr.A, curr.B, #00ff40, 5, true);      //servo horn
  if ( canCalculate ) {
    drawSegment(curr.C, curr.D, #00ff40, 5, true);    //control horn
    drawSegment(curr.D, curr.E, #D04040, 2, false);   //control surface
    drawSegment(curr.B, curr.C, #F00060, 2, true);    //push rod
    displayAngle(curr.D.angle(curr.E), curr.E);
  }
  else {
    textSize(defaultTextSize*2/scale);
    text(errorMsg, originX, originY);
    textSize(defaultTextSize);
  }
  displayAngle(curr.A.angle(curr.B), curr.B);
}

void drawAxis(float x, float y, String label, float angle) {
  pushMatrix();
  translate(x,y);
  rotate(radians(angle));
  int len = 50;
  int arrowlen = 5;
  line(0,0,len,0);
  line(len-arrowlen,-arrowlen,len,0);
  line(len-arrowlen,arrowlen,len,0);
  text(label, len,4);
  popMatrix();
}

void draw() {
  background(0);
  linkageOpacity = defaultOpacity;

  boolean canCalculate = true;
  String errorMsg =  "";
  Point C = new Point();
  Point E = new Point();
  
  // calc point A - servo horn pivot
  Point A = new Point(originX, originY + distanceServoHingeY);
  
  //get servo angle from mouse position
  if (mousePressed == true) {
    float dx = mouseX - A.x * scale;
    float dy = mouseY - A.y * scale;
    servoHornAngle = atan2(dy, dx);
  }
  
  // calc point B - servo horn end
  Point B = new Point(A, servoHornAngle, servoHornLen);
  
  // calc point D - control horn pivot
  Point D = new Point(originX + distanceServoHingeX, originY);

  // check if calculation possible
  if (B.distance(D) > (pushrodLen + controlHornLen)) {
    errorMsg = "Push rod too short by "+nf(( B.distance(D) - pushrodLen - controlHornLen ), 1, 1);
    canCalculate = false;
  }
  if (B.distance(D) < (pushrodLen - controlHornLen)) {
    errorMsg = "Push rod too long by "+nf((pushrodLen - controlHornLen - B.distance(D)), 1, 1);
    canCalculate = false;
  }
  if ( canCalculate ) {
    // calc point C - control horn end
    C = new Point(B, D, pushrodLen, controlHornLen, otherSolution);
  
    // calc point E - control surface end
    float surfaceAngle = D.angle(C) + surfaceHornAngle;
    E = new Point(D, surfaceAngle, surfaceLen);
  }
  
  Snapshot curr = new Snapshot(A,B,C,D,E);
  
  if (makeSnapshot) {
    makeSnapshot = false;
    if (canCalculate) {
      snapshots.add(curr);
    }
  }
  
  //draw grid
  scale(scale);
  strokeWeight(1.0/scale);
  stroke(#ff3080, 150);
  line(0, originY, width, originY);
  line(originX, 0, originX, height);
  line(originX+distanceServoHingeX, 0, originX+distanceServoHingeX, height);
  stroke(#FFFFFF, 150);
  strokeWeight(1.0);
  scale(1/scale);
  drawAxis(10, 10, "x", 0);
  drawAxis(10, 10, "y", 90);
  scale(scale);


  //draw wing outline
  strokeWeight(2.0/scale);
  stroke(#FF8000, 160);
  line(0, originY, D.x, D.y);
  line(D.x, D.y, D.x, D.y-wingHeightAtHinge);
  line(D.x, D.y-wingHeightAtHinge, originX, originY - wingHeightAtServo);

  //draw snapshots
  linkageOpacity = snapshotOpacity;
  for (int i = 0; i < snapshots.size(); i++) {
    drawLinkages(snapshots.get(i), true, "");  
  }
  
  //draw current state
  linkageOpacity = defaultOpacity;
  drawLinkages(curr, canCalculate, errorMsg); 
}



