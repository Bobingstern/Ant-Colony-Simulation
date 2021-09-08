float size = 15;
float obsSize = 20;
boolean showVision = false;
float visionSize = size * 4;

float nestSize = size * 3;
PVector nestPos;
public int colonySize = 100;

boolean pause = false;
int foodCount = 0;
int foodPatches = 1;
int totalFood = foodCount * foodPatches;
float foodSize = size / 2;
int foodClaimed = 0;
QuadTree foodTree;
QuadTree obstacles;

boolean showHomePheramone = true;
float homePheramoneDecay = 0.001;

boolean showFoodPheramone = true;
float foodPheramoneDecay = 0.001;

float pheroLife = 700;

int framesUntilPheramone = 10;
boolean showQureyPos = false;
boolean mouseHeld = false;
float w;
float h;
boolean obstacleMode = false;

PImage img;
int on = 0000;

Colony c;
Colony c2;

Ant ant;
void setup() {
  size(2400, 1500);

  w = floor(width / size);
  h = floor(height / size);
  foodTree = new QuadTree(new Rectangle(0, 0, width, height), 1000000000);
  obstacles = new QuadTree(new Rectangle(0, 0, width, height), 1000000000);
  c = new Colony(nestSize*4, nestSize*4, colonySize);
}


void showObstacles(){

  ArrayList<Particle> points = obstacles.getAllPoints();
  for (int i = 0; i < points.size(); i++){
    rectMode(CORNER);
    fill(117, 98, 35);
    rect(points.get(i).x, points.get(i).y, obsSize, obsSize);
  }

}

void draw(){
  background(56);
  
    


  c.update();
  showObstacles();
  if (frameCount % 1 == 0){
     //saveFrame("output/frame_####.png");
  }
  
  
  //---
  if (obstacleMode){
    float[] data = {0, 0};
    Particle p = new Particle(round(mouseX / obsSize) * obsSize, round(mouseY / obsSize) * obsSize, data);
    obstacles.insert(p);

  }

}

void keyReleased() {
  if (char(keyCode) == 'O') obstacleMode = false;
}

void mousePressed(){
  mouseHeld = true;
}
void mouseReleased(){
  mouseHeld = false;
}
void keyPressed(){
  if (keyCode == 79){
    if (obstacleMode){
      obstacleMode = false;
    }
    else{
      obstacleMode = true;
    }
  }
  if (keyCode == 80){
    if (pause){
      pause = false;
    }
    else{
      pause = true;
    }
  }
  if (char(keyCode) == 'O') obstacleMode = true;
}

void mouseClicked(){
  
  for (int i=0;i<colonySize/2;i++){
    PVector pos = new PVector(mouseX + random(-size*2,size*2), mouseY + random(-size*2, size*2));
    float[] data = {0};
    Particle p = new Particle(pos.x, pos.y, data);
    foodTree.insert(p);
  }
}
