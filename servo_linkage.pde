/*
* Servo linkage simulation
* Author: Damjan Adamic <projectkk2glider@gmail.com>
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

/*
  Changelog:

  Version 1.4:
    * Added vertical marker
    * Added top hinged control surface simulation

  Version 1.3:
    * Better indication of which parameter is being changed
    * Added save window contents to .png file with CTRL+p
    * Add ability to save and restore settings from file

  Version 1.2:
    * Visual improvements
    * Enabled adjustment of dimensions in simulation view

  Version 1.1:
    * Improved graphics
    * Added dimensions
    * Better display of horn angles
    * Code cleanup
    * simpler start-up setup

  Version 1.0:
    * first version
*/

/* ------------------------------------------------------------------------------------------*\
    START OF CONFIGURATION SECTION

    USAGE

      * configure starting dimensions if needed
      * run simulation (CTRL+R), inside simulation window:
        * use mouse to position servo horn (left mouse button down orients servo horn towards current mouse pointer)
        * use 's' key to make a snapshot of current position
        * use 'c' key to clear all snapshots
        * use 't' key to toggle linkage solution
        * use keys form '1' to '5' to select which parameter to adjust. The selected parameter
          is displayed RED in legend and emphasized in the diagram
        * use UP and DOWN arrow keys to adjust selected parameter in small steps. Use SHIFT+UP and
          SHIFT+DOWN arrow keys to adjust selected parameter in big steps
        * use CTRL+p to make a screenshot of window and save it to .PNG file in sketch folder
        * use CTRL+l key to load existing setup
        * use CTRL+s key to save current setup to file

      * exit simulation, adjust parameters and re-run simulation until desired configuration is achieved


    CONFIGURATION

      Edit values to achieve desired result.

      It is best to make a copy of a group of settings and edit them. Comment all other
      groups of settings. You can toggle comment with the CTRL+/ key combination.

      Units are arbitrary, you can use floating numbers (ie 3.456) if needed.
\* ------------------------------------------------------------------------------------------*/

/* ------------------------------------------------------------------------------------------*\
  default setup 2 (bottom hinged, bottom driven linkage)
\* ------------------------------------------------------------------------------------------*/
float distanceServoHingeX = 80;          //distance from servo pivot point to the surface pivot point in X axis
float distanceServoHingeY = -10;         //distance from servo pivot point to the surface pivot point in Y axis
float servoHornLen = 12;                 //length of servo horn
float controlHornLen = 12;               //length of control horn
float pushrodLen = 80.6;                   //length of push-rod
float surfaceHornAngle = radians(-90);   //angle between control surface and control horn
float surfaceLen = 49;                   //length of control surface
float wingHeightAtServo = 22;            //wing height (distance in Y axis) at the servo pivot point
float wingHeightAtHinge = 11;            //wing height (distance in Y axis) at the control surface hinge point
boolean otherSolution = true;            //which solution to use when calculating surface position (start  value).
                                         //You can toggle this when running with the press of 't' key.
float verticalMarkerLocation = 10;       // A optional vertical marker that can be used to measure something
                                         // (for example the location of the pushrod exit hole)
                                         // set to zero to hide it
int hingePosition = 0;                   // Hinge position: 0 bottom, 1 top


/* ------------------------------------------------------------------------------------------*\
   example setup 1 (bottom hinged, bottom driven flap linkage)
\* ------------------------------------------------------------------------------------------*/
// float distanceServoHingeX = 85;
// float distanceServoHingeY = -13;
// float servoHornLen = 11;
// float controlHornLen = 14;
// float pushrodLen = 88;
// float surfaceHornAngle = radians(-45);
// float surfaceLen = 49;
// float wingHeightAtServo = 22;
// float wingHeightAtHinge = 11;
// boolean otherSolution = true;
// float verticalMarkerLocation = 10;       // A optional vertical marker that can be used to measure something
//                                          // (for example the location of the pushrod exit hole)
//                                          // set to zero to hide it
// int hingePosition = 0;                   // Hinge position: 0 bottom, 1 top


/* ------------------------------------------------------------------------------------------*\
   example setup 2 (bottom hinged, top driven flap linkage)
\* ------------------------------------------------------------------------------------------*/
// float distanceServoHingeX = 85;          //distance from servo pivot point to the surface pivot point in X axis
// float distanceServoHingeY = -13;         //distance from servo pivot point to the surface pivot point in Y axis
// float servoHornLen = 12;                 //length of servo horn
// float controlHornLen = 12;               //length of control horn
// float pushrodLen = 85;                   //length of push-rod
// float surfaceHornAngle = radians(135);   //angle between control surface and control horn
// float surfaceLen = 49;                   //length of control surface
// float wingHeightAtServo = 22;            //wing height (distance in Y axis) at the servo pivot point
// float wingHeightAtHinge = 11;            //wing height (distance in Y axis) at the control surface hinge point
// boolean otherSolution = false;           //which solution to use when calculating surface position (start  value).
//                                         //You can toggle this when running with the press of 't' key.
// float verticalMarkerLocation = 10;       // A optional vertical marker that can be used to measure something
//                                          // (for example the location of the pushrod exit hole)
//                                          // set to zero to hide it
// int hingePosition = 0;                   // Hinge position: 0 bottom, 1 top


/* ------------------------------------------------------------------------------------------*\
   default setup 3 (top hinged, bottom driven linkage)
\* ------------------------------------------------------------------------------------------*/
// float distanceServoHingeX = 80;          //distance from servo pivot point to the surface pivot point in X axis
// float distanceServoHingeY = -10;         //distance from servo pivot point to the surface pivot point in Y axis
// float servoHornLen = 12;                 //length of servo horn
// float controlHornLen = 24;               //length of control horn
// float pushrodLen = 81;                   //length of push-rod
// float surfaceHornAngle = radians(-90);   //angle between control surface and control horn
// float surfaceLen = 49;                   //length of control surface
// float wingHeightAtServo = 22;            //wing height (distance in Y axis) at the servo pivot point
// float wingHeightAtHinge = 11;            //wing height (distance in Y axis) at the control surface hinge point
// boolean otherSolution = true;            //which solution to use when calculating surface position (start  value).
//                                          //You can toggle this when running with the press of 't' key.
// float verticalMarkerLocation = 0 ;       // A optional vertical marker that can be used to measure something
//                                          // (for example the location of the pushrod exit hole)
//                                          // set to zero to hide it
// int hingePosition = 1;                   // Hinge position: 0 bottom, 1 top


/* ------------------------------------------------------------------------------------------*\
    General settings
\* ------------------------------------------------------------------------------------------*/
float diagramScale = 4.3;      //drawing scale (all measurements above are multiplied with this number to covert them to pixels)
float defaultTextSize = 14;    //preferred test size
int windowHeight = 600;        //simulation window height (pixels)
int windowWidth = 800;         //simulation window width (pixels)
float defaultOpacity = 150;    //transparency of linkage diagram 0-255 (bigger number -> more opaque, less transparent)
float snapshotOpacity = 70;    //transparency of shapshot diagram

/* ------------------------------------------------------------------------------------------*\
    END OF CONFIGURATION SECTION

    DO NOT EDIT BELOW IF YOU DON'T KNOW WHAT YOU ARE DOING!
\* ------------------------------------------------------------------------------------------*/

import java.util.Properties;

float originX;
float originY;
float servoHornAngle = radians(90);
float linkageOpacity;
boolean makeSnapshot = false;
ArrayList<Snapshot> snapshots = new ArrayList<Snapshot>();
int changeMode = 0;
boolean keyShiftPressed = false;
boolean keyControlPressed = false;
SegmentStyle servoHornStyle, controlHornStyle, controlSurfaceStyle, pushrodStyle;
String userMessage = "";
int userMessageEndTime = 0;

void setup() {
  size(windowWidth, windowHeight);
  originX = width/(6*diagramScale);
  originY = height/(2*diagramScale);
  noLoop();
  //setUserMessage("Test user message", 1000);
}

void incDecVar(int varIndex, boolean up, boolean largeStep) {
  float amount = largeStep ? 1.0 : 0.1;
  if (!up) amount = -amount;
  if (changeMode == 1)  servoHornLen += amount;
  if (changeMode == 2)  pushrodLen += amount;
  if (changeMode == 3)  controlHornLen += amount;
  if (changeMode == 4)  surfaceHornAngle += radians(amount);
  if (changeMode == 5)  verticalMarkerLocation += amount;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) keyShiftPressed = true;
    if (keyCode == CONTROL) keyControlPressed = true;
    if (keyCode == UP) incDecVar(changeMode, true, keyShiftPressed);
    if (keyCode == DOWN) incDecVar(changeMode, false, keyShiftPressed);
  }
  else {
    if (key == 't') otherSolution = !otherSolution;
    if (key == 's') makeSnapshot= true;
    if (key == 'c') snapshots.clear();
    if ((key >= '1') && (key <= '9')) {
      int mode = key- '1' + 1;
      if (mode == changeMode) changeMode = 0; //disable change
      else changeMode = mode;
    }
    if ( keyControlPressed ) {
      if (keyCode == 'P') {
        saveFrame("linkage-######.png"); println("screenshot saved.");
        setUserMessage("Screenshot saved", 1000);
      }
      if (keyCode == 'L') { selectInput("Load setup from file", "settingsLoad"); keyControlPressed = false; }
      if (keyCode == 'S') { selectInput("Save setup to file", "settingsSave"); keyControlPressed = false; }
    }
  }
  redraw();
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) keyShiftPressed = false;
    if (keyCode == CONTROL) keyControlPressed = false;
  }
}

void mousePressed() {
  redraw();
}

void mouseDragged() {
  redraw();
}

void setUserMessage(String message, int duration) {
  userMessage = message;
  userMessageEndTime = millis() + duration;
  loop();
}

/**
 * simple convenience wrapper object for the standard
 * Properties class to return pre-typed numerals
 */
class P5Properties extends Properties {

  boolean getBooleanProperty(String id, boolean defState) {
    return boolean(getProperty(id,""+defState));
  }

  int getIntProperty(String id, int defVal) {
    return int(getProperty(id,""+defVal));
  }

  float getFloatProperty(String id, float defVal) {
    return float(getProperty(id,""+defVal));
  }
}

// This is called when user selects load settings from file
void settingsLoad(File selection) {
  if (selection == null) return;
  try {
    P5Properties props=new P5Properties();
    InputStream in = createInput(selection.getAbsolutePath());
    if (in == null) {
      println("can't open " + selection.getAbsolutePath());
      setUserMessage("Error opening file " + selection.getAbsolutePath(), 2000);
      return;
    }
    props.load(in);
    int w=props.getIntProperty("distanceServoHingeX",640);
    distanceServoHingeX = props.getFloatProperty("distanceServoHingeX",80);
    distanceServoHingeY = props.getFloatProperty("distanceServoHingeY",-10);
    servoHornLen = props.getFloatProperty("servoHornLen",12);
    controlHornLen = props.getFloatProperty("controlHornLen",12);
    pushrodLen = props.getFloatProperty("pushrodLen",80.6);
    surfaceHornAngle = props.getFloatProperty("surfaceHornAngle",-90);
    surfaceLen = props.getFloatProperty("surfaceLen",50);
    wingHeightAtServo = props.getFloatProperty("wingHeightAtServo",22);
    wingHeightAtHinge = props.getFloatProperty("wingHeightAtHinge",11);
    servoHornAngle = radians(90);
    println("Settings loaded from " + selection.getAbsolutePath());
    setUserMessage("Settings loaded from " + selection.getAbsolutePath(), 1000);
  }
  catch(IOException e) {
    println("Error load settings from file " + selection.getAbsolutePath());
    e.printStackTrace();
    setUserMessage("Error load settings from file " + selection.getAbsolutePath(), 2000);
  }
  redraw();
}

// This is called when user selects save settings to file
void settingsSave(File selection) {
  if (selection == null) return;
  try {
    ArrayList<String> config = new ArrayList<String>();
    config.add("#servo_linkage configuration file");
    config.add("distanceServoHingeX = "+distanceServoHingeX);
    config.add("distanceServoHingeY = "+distanceServoHingeY);
    config.add("servoHornLen = "+servoHornLen);
    config.add("controlHornLen = "+controlHornLen);
    config.add("pushrodLen = "+pushrodLen);
    config.add("surfaceHornAngle = "+surfaceHornAngle);
    config.add("surfaceLen = "+surfaceLen);
    config.add("wingHeightAtServo = "+wingHeightAtServo);
    config.add("wingHeightAtHinge = "+wingHeightAtHinge);
    String[] data = new String[config.size()];
    config.toArray(data);
    saveStrings(selection.getAbsolutePath(), data);
    println("Settings saved to file " + selection.getAbsolutePath());
    setUserMessage("Settings saved to file " + selection.getAbsolutePath(), 1000);
  }
  catch(Exception e) {
    println("couldn't save settings to file " + selection.getAbsolutePath());
    e.printStackTrace();
    setUserMessage("Error saving settings to file " + selection.getAbsolutePath(), 2000);
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
    pushMatrix();
    translate(x, y);
    textSize(defaultTextSize/diagramScale);
    text(txt+"("+nf(x-originX,1,1)+","+nf(y-originY,1,1)+")", 2, 2);
    popMatrix();
  }
  float distance(Point b) {
    return dist(x, y, b.x, b.y);
  }
  float angle(Point b) {
    return atan2(b.y - y, b.x - x);
  }
}

class SegmentStyle {
  color clr;
  float weight;
  float opacity;
  boolean startPivot;
  boolean endPivot;
  SegmentStyle(color _color, float _weight, float _opacity, boolean sp, boolean ep) {
    clr = _color;
    weight = _weight;
    opacity = _opacity;
    startPivot = sp;
    endPivot = ep;
  }
}

void drawSegment(Point start, Point end, SegmentStyle style) {
  stroke(style.clr, style.opacity);
  strokeWeight(1);
  if (style.startPivot) ellipse(start.x, start.y, 2, 2);
  if (style.endPivot) ellipse(end.x, end.y, 2, 2);
  strokeWeight(style.weight);
  line(start.x, start.y, end.x, end.y);
}


void displayAngle(float angle, Point at, float distance) {
  pushMatrix();
  textSize(defaultTextSize/diagramScale);
  translate(at.x, at.y);
  rotate(angle);
  translate(3+distance, 0);
  if ((degrees(angle) > 90) || (degrees(angle) < -90))  {
    rotate(PI);
    textAlign(RIGHT, CENTER);
  }
  else {
    textAlign(LEFT, CENTER);
  }
  text(nf(degrees(angle), 1,1)+"°", 0, -1);
  popMatrix();
}

void setLinkageStyles(int activeItem, float opacity) {
  //default style
  servoHornStyle = new SegmentStyle(#00ff40,  5, opacity, true, true);
  controlHornStyle = new SegmentStyle(#00ff40,  5, opacity, true, true);
  controlSurfaceStyle = new SegmentStyle(#D04040,  2, opacity, true, false);
  pushrodStyle = new SegmentStyle(#F00060,  2, opacity, true, true);
  //sed different opacity for active segment
  if (activeItem == 1) servoHornStyle.opacity = 255;
  if (activeItem == 2) pushrodStyle.opacity = 255;
  if (activeItem == 3) controlHornStyle.opacity = 255;
  if (activeItem == 4) controlSurfaceStyle.opacity = 255;
}

void drawLinkages(Snapshot curr, boolean canCalculate, String errorMsg) {
  drawSegment(curr.A, curr.B, servoHornStyle);      //servo horn
  if ( canCalculate ) {
    drawSegment(curr.C, curr.D, controlHornStyle);    //control horn
    drawSegment(curr.D, curr.E, controlSurfaceStyle);   //control surface
    drawSegment(curr.B, curr.C, pushrodStyle);    //push rod
    displayAngle(curr.D.angle(curr.E), curr.E, 0);  //control surface angle
  }
  else {
    textSize(defaultTextSize*2/diagramScale);
    text(errorMsg, originX, originY);
  }
  displayAngle(curr.A.angle(curr.B), curr.B, 10);  //servo horn angle
}

// Draws coordinate system axis legend
void drawAxis(float x, float y, String label, float angle) {
  pushMatrix();
  translate(x,y);
  rotate(radians(angle));
  textSize(defaultTextSize);
  int len = 50;
  int arrowlen = 5;
  line(0, 0, len, 0);
  line(len-arrowlen, -arrowlen, len, 0);
  line(len-arrowlen,  arrowlen, len, 0);
  textAlign(LEFT);
  text(label, len + 4, 4);
  popMatrix();
}

// Draws a dimension
void drawDimension(float x1, float y1, float x2, float y2) {
  Point A = new Point(x1, y1);
  Point B = new Point(x2, y2);
  float distance = A.distance(B);
  pushMatrix();
  translate(A.x, A.y);
  rotate(A.angle(B));
  //line
  line(0, 0, distance, 0);
  pushMatrix();
  int arrowLen = 2;
  //arrow
  line(0,0, arrowLen, arrowLen);
  line(0,0, arrowLen, -arrowLen);
  translate(distance, 0);
  rotate(PI);
  //other arrow
  line(0,0, arrowLen, arrowLen);
  line(0,0, arrowLen, -arrowLen);
  popMatrix();
  //text - distance
  translate(distance/2, 0);
  textAlign(CENTER);
  textSize(defaultTextSize/diagramScale);
  text(nf(abs(distance), 1, 1), 0, -3);
  textAlign(LEFT);
  popMatrix();
}

void drawStaticGraphics(Snapshot curr) {
  //we start with scale(1)

  // draw axis legend
  stroke(#FFFFFF, 250);
  strokeWeight(1.0);
  drawAxis(10, 10, "x", 0);
  drawAxis(10, 10, "y", 90);

  //draw legend
  float legendWidth = 200;
  float legendHeight = 80;
  pushMatrix();
  textAlign(LEFT);
  translate(width - legendWidth - 10, 10 );
  stroke(#FFFFFF, 150);
  fill(255, 20);
  rect(0, 0, legendWidth, legendHeight);
  //noFill();
  stroke(#FFFFFF, 250);
  fill(255, 255);
  float fontSize = defaultTextSize/1.1;
  textSize(fontSize);
  translate(2, fontSize);
  if (changeMode == 1) fill(#E00707, 250);
  else fill(255, 255);
  text("1: servo horn len: "+nf(servoHornLen,1,1), 0, 0);
  translate(0, fontSize);
  if (changeMode == 2) fill(#E00707, 250);
  else fill(255, 255);
  text("2: push-rod len: "+nf(pushrodLen,1,1), 0, 0);
  translate(0, fontSize);
  if (changeMode == 3) fill(#E00707, 250);
  else fill(255, 255);
  text("3: control horn len: "+nf(controlHornLen,1,1), 0, 0);
  translate(0, fontSize);
  if (changeMode == 4) fill(#E00707, 250);
  else fill(255, 255);
  text("4: control horn angle: "+nf(degrees(surfaceHornAngle),1,1), 0, 0);
  translate(0, fontSize);
  if (changeMode == 5) fill(#E00707, 250);
  else fill(255, 255);
  text("5: v. marker: "+nf(verticalMarkerLocation,1,1), 0, 0);
  popMatrix();


  //draw grid
  pushMatrix();
  scale(diagramScale);
  stroke(#ff3080, 150);
  //fill(#FFFFFF, 255);
  strokeWeight(1.0/diagramScale);
  line(0, originY, width, originY);
  line(0, originY + distanceServoHingeY, originX, originY + distanceServoHingeY);
  line(originX, 0, originX, height);
  line(originX+distanceServoHingeX, 0, originX+distanceServoHingeX, height);
  //draw surface arc, servo circle and control horn circle
  noFill();
  stroke(#ff3080, 70);
  arc(curr.D.x, curr.D.y, surfaceLen*2, surfaceLen*2, radians(-90), radians(90));
  ellipse(curr.A.x, curr.A.y, servoHornLen*2, servoHornLen*2 );
  ellipse(curr.D.x, curr.D.y, controlHornLen*2, controlHornLen*2 );

  //draw vertical marker
  if (verticalMarkerLocation != 0.0) {
    float x = originX+distanceServoHingeX - verticalMarkerLocation;
    line(x, 0, x , height);
  }

  //draw dimensions
  stroke(#FFFFFF, 100);
  fill(#FFFFFF, 155);
  drawDimension(originX, originY/2, originX + distanceServoHingeX, originY/2);
  drawDimension(originX/2, originY, originX/2, originY + distanceServoHingeY);
  popMatrix();

  //draw use message
  if (userMessage.length() > 0) {
    if (millis() > userMessageEndTime) {
      userMessage = "";
      noLoop();
      redraw();
    }
    else {
      pushMatrix();
      translate(width/2, height/4);
      textSize(defaultTextSize);
      textAlign(CENTER, CENTER);
      rectMode(CENTER);
      noStroke();
      fill(255, 200);
      float msgWidth = width/2;
      float msgHeight = height/4;
      rect(0,0, msgWidth, msgHeight);
      fill(0, 255);
      text(userMessage, 0, 0, msgWidth, msgHeight);
      rectMode(CORNER);
      popMatrix();
    }
  }
}


void draw() {
  background(0);
  linkageOpacity = defaultOpacity;

  boolean canCalculate = true;
  String errorMsg =  "";
  Point C = new Point();
  Point E = new Point();
  Point D;

  // calc point A - servo horn pivot
  Point A = new Point(originX, originY + distanceServoHingeY);

  //get servo angle from mouse position
  if (mousePressed == true) {
    float dx = mouseX - A.x * diagramScale;
    float dy = mouseY - A.y * diagramScale;
    servoHornAngle = atan2(dy, dx);
  }

  // calc point B - servo horn end
  Point B = new Point(A, servoHornAngle, servoHornLen);

  // calc point D - control horn pivot
  if (hingePosition == 1) {
    D = new Point(originX + distanceServoHingeX, originY - wingHeightAtHinge);
  }
  else {
    D = new Point(originX + distanceServoHingeX, originY);
  }

  // check if calculation possible
  if (B.distance(D) > (pushrodLen + controlHornLen)) {
    errorMsg = "Push rod too short by "+nf(( B.distance(D) - pushrodLen - controlHornLen ), 1, 1);
    canCalculate = false;
  }
  else if (B.distance(D) < (pushrodLen - controlHornLen)) {
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

  //draw static graphics
  drawStaticGraphics(curr);  //leaves scale set to diagramScale;

  //draw wing outline
  scale(diagramScale);
  strokeWeight(2.0/diagramScale);
  stroke(#FF8000, 160);
  fill(#FFFFFF, 255);
  if (hingePosition == 1) {
    line(0, originY, D.x, originY);
    line(D.x, originY, D.x, D.y);
    line(D.x, D.y, originX, originY - wingHeightAtServo);
  }
  else {
    line(0, originY, D.x, D.y);
    line(D.x, D.y, D.x, D.y-wingHeightAtHinge);
    line(D.x, D.y-wingHeightAtHinge, originX, originY - wingHeightAtServo);
  }

  //draw snapshots
  setLinkageStyles(-1, snapshotOpacity);
  for (int i = 0; i < snapshots.size(); i++) {
    drawLinkages(snapshots.get(i), true, "");
  }

  //draw current state
  setLinkageStyles(changeMode, defaultOpacity);
  drawLinkages(curr, canCalculate, errorMsg);
}



