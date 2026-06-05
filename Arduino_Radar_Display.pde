import processing.serial.*;

Serial myPort;
String data    = "";
int iAngle     = 0;
int iDistance  = 0;
float pixsDistance;

void setup() {
  size(1200, 700);
  smooth();
  myPort = new Serial(this, "COM3", 9600); // Change COM port if needed
  myPort.bufferUntil('.');
}

void draw() {
  // Radar fade effect
  fill(0, 20);
  noStroke();
  rect(0, 0, width, height);

  drawRadar();
  drawSweep();
  drawObject();
  drawInfo();
}

void serialEvent(Serial myPort) {
  String incoming = myPort.readStringUntil('.');
  if (incoming != null) {
    incoming = trim(incoming);
    incoming = incoming.substring(0, incoming.length() - 1);
    int commaIndex = incoming.indexOf(',');
    if (commaIndex > 0) {
      iAngle    = int(incoming.substring(0, commaIndex));
      iDistance = int(incoming.substring(commaIndex + 1));
    }
  }
}

// ===================================================
// RADAR GRID
// ===================================================
void drawRadar() {
  pushMatrix();
  translate(width / 2, height - 40);
  stroke(0, 255, 0);
  strokeWeight(1);
  noFill();

  // Distance arcs
  arc(0, 0, 200, 200, PI, TWO_PI);
  arc(0, 0, 400, 400, PI, TWO_PI);
  arc(0, 0, 600, 600, PI, TWO_PI);
  arc(0, 0, 800, 800, PI, TWO_PI);

  // Angle lines
  for (int angle = 30; angle <= 150; angle += 30) {
    line(0, 0,
         400 * cos(radians(angle)),
        -400 * sin(radians(angle)));
  }

  // Base line
  line(-400, 0, 400, 0);
  popMatrix();
}

// ===================================================
// SWEEP LINE
// ===================================================
void drawSweep() {
  pushMatrix();
  translate(width / 2, height - 40);

  for (int i = 0; i < 8; i++) {
    stroke(0, 255, 0, 255 - i * 30);
    strokeWeight(3);
    float a = radians(iAngle - i * 4);
    line(0, 0,
         400 * cos(a),
        -400 * sin(a));
  }
  popMatrix();
}

// ===================================================
// OBJECT DISPLAY
// ===================================================
void drawObject() {
  if (iDistance > 40) return;

  pushMatrix();
  translate(width / 2, height - 40);

  pixsDistance = map(iDistance, 0, 40, 0, 400);
  float x =  pixsDistance * cos(radians(iAngle));
  float y = -pixsDistance * sin(radians(iAngle));

  fill(255, 50, 50);
  noStroke();
  ellipse(x, y, 14, 14);
  popMatrix();
}

// ===================================================
// TEXT INFORMATION
// ===================================================
void drawInfo() {
  // Status bar background
  fill(0);
  noStroke();
  rect(0, height - 40, width, 40);

  fill(0, 255, 0);
  textSize(18);

  // Status bar text
  text("Arduino Radar",                                      10,  height - 15);
  text("Angle: " + iAngle + "°",                           250,  height - 15);

  if (iDistance <= 40)
    text("Distance: " + iDistance + " cm",                 500,  height - 15);
  else
    text("Distance: Out of Range",                         500,  height - 15);

  String status = (iDistance <= 40) ? "In Range" : "Out of Range";
  text(status,                                             850,  height - 15);

  // Degree labels
  text("30°",  110,  260);
  text("60°",  280,  90);
  text("90°",  585,  40);
  text("120°", 890,  90);
  text("150°", 1060, 260);

  // Distance labels
  text("10cm", 650, height - 80);
  text("20cm", 750, height - 80);
  text("30cm", 850, height - 80);
  text("40cm", 950, height - 80);
}
