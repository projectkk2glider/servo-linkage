//all measurements in mm

//// current setup
//float distanceServoHingeX = 85;
//float distanceServoHingeY = -13;
//float servoHornLen = 11;
//float controlHornLen = 14;
//float pushrodLen = 88;
//float surfaceHornAngle = radians(-45);
//float surfaceLen = 49;
//boolean otherSolution = true;

//// new setup  1
//float distanceServoHingeX = 85;
//float distanceServoHingeY = -13;
//float servoHornLen = 12;
//float controlHornLen = 14;
//float pushrodLen = 85;
//float surfaceHornAngle = radians(120);
//float surfaceLen = 49;
//boolean otherSolution = false;

// new setup 2 
float distanceServoHingeX = 85;
float distanceServoHingeY = -13;
float servoHornLen = 12;
float controlHornLen = 12;
float pushrodLen = 85;
float surfaceHornAngle = radians(135);
float surfaceLen = 49;
float wingHeightAtServo = 22;
float wingHeightAtHinge = 11;
boolean otherSolution = false;


float scale = 4;
float originX = 10;
float originY = 200;

float servoHornAngle = 0;

float defaultTextSize = 14;
float linkageOpacity = 100;
boolean makeSnapshot = false;
ArrayList<Snapshot> snapshots = new ArrayList<Snapshot>();

void setup() {
  size(800, 400);
  strokeWeight(20.0);
  stroke(255, 100);
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
  float phiB, phiE;
  Snapshot(Point a, Point b, Point c, Point d, Point e, float aB, float aE) {
    A = a; 
    B = b;
    C = c;
    D = d;
    E = e;
    phiB = aB;
    phiE = aE;
  }
}

class Point {
  float x;
  float y;
  Point(float _x, float _y) {
    x = _x;
    y = +_y;
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
    float P1x = P0x + h*(B.y - A.y)/d;       // extend to intersection 1 from midpoint
    float P1y = P0y - h*(B.x - A.x)/d;
    Point X1 = new Point(P0x + h*(B.y - A.y)/d, P0y - h*(B.x - A.x)/d); 
    Point X2 = new Point(P0x - h*(B.y - A.y)/d, P0y + h*(B.x - A.x)/d); 
    if (other) {
      x = X2.x;
      y = X2.y;
    }
    else
    {
      x = X1.x;
      y = X1.y;
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
}

void drawSegment(Point start, Point end, color colr, float weight) {
  stroke(colr, linkageOpacity);
  strokeWeight(1);
  ellipse(start.x, start.y, 2, 2);
  strokeWeight(weight);
  line(start.x, start.y, end.x, end.y);
  strokeWeight(1);
  ellipse(end.x, end.y, 2, 2);
}


void displayAngle(float angle, Point at) {
  textSize(defaultTextSize/scale);
  text(nf(degrees(angle), 1,1)+"°", (at.x+3), (at.y-3));
  textSize(defaultTextSize);
}

void drawLinkages(Snapshot curr, boolean canCalculate, String errorMsg) { 
  drawSegment(curr.A, curr.B, #00ff40, 5);    //servo horn
  if ( canCalculate ) {
    drawSegment(curr.C, curr.D, #00ff40, 5);    //control horn
    drawSegment(curr.D, curr.E, #D04040, 2);    //control surface
    drawSegment(curr.B, curr.C, #F00060, 2);    //push rod
    displayAngle(curr.phiE, curr.E);
  }
  else {
    textSize(defaultTextSize*2/scale);
    text(errorMsg, originX, originY);
    textSize(defaultTextSize);
  }
  displayAngle(curr.phiB, curr.B);
}

void draw() {
  background(0);
  linkageOpacity = 100;

  boolean canCalculate = true;
  String errorMsg =  "";
  Point C = new Point();
  Point E = new Point();
  // calc point A - servo horn pivot
  Point A = new Point(originX, originY + distanceServoHingeY);
  float surfaceAngle = 0;
  
  //get servo angle from mouse position
  float dx = mouseX - A.x * scale;
  float dy = mouseY - A.y * scale;
  servoHornAngle = atan2(dy, dx);
  //text("Servo angle: "+nf(degrees(servoHornAngle), 1,1), 10, 90);

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
    float controlHornAngle = atan2(C.y - D.y, C.x - D.x);
    //text("controlHornAngle: "+nf(degrees(controlHornAngle), 1,1), 10, 100);
  
  
    // calc point E - control surface end
    surfaceAngle = controlHornAngle + surfaceHornAngle;
    E = new Point(D, surfaceAngle, surfaceLen);
  }
  
  Snapshot curr = new Snapshot(A,B,C,D,E, servoHornAngle, surfaceAngle);
  
  if (makeSnapshot) {
    makeSnapshot = false;
    if (canCalculate) {
      snapshots.add(curr);
    }
  }
  
  //draw grid
  scale(scale);
  //A.display("A");
  //B.display("B");
  strokeWeight(1.0/scale);
  stroke(#ff3080, 150);
  line(0, originY, width, originY);
  line(originX, 0, originX, height);
  line(originX+distanceServoHingeX, 0, originX+distanceServoHingeX, height);

  //draw wing outline
  strokeWeight(2.0/scale);
  stroke(#FF8000, 160);
  line(0, originY, D.x, D.y);
  line(D.x, D.y, D.x, D.y-wingHeightAtHinge);
  line(D.x, D.y-wingHeightAtHinge, originX, originY - wingHeightAtServo);

  //draw snapshots
  linkageOpacity = 80;
  for (int i = 0; i < snapshots.size(); i++) {
    drawLinkages(snapshots.get(i), true, "");  
  }
  
  //draw current state
  linkageOpacity = 150;
  drawLinkages(curr, canCalculate, errorMsg); 
}

void segment(float x, float y, float a) {
  pushMatrix();
  translate(x, y);
  rotate(a);
  line(0, 0, servoHornLen, 0);
  popMatrix();
} 
