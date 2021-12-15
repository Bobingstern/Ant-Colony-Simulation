float size = 15;
float obsSize = 15;
boolean showVision = false;
float visionSize = size * 4;

float nestSize = size * 3;
PVector nestPos;
public int colonySize = 1000;

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

float pheroLife = 1000;

int framesUntilPheramone = 10;
boolean showQureyPos = false;
boolean mouseHeld = false;
float w;
float h;
boolean obstacleMode = false;

PImage img;
int on = 0;
int antLife = 3000;
int s = 1;
Colony c;
Colony c2;

Ant ant;
void setup() {
  size(2200, 1300);
  
  
  w = floor(width / size);
  h = floor(height / size);
  
  foodTree = new QuadTree(new Rectangle(0, 0, width, height), 1000000000);
  obstacles = new QuadTree(new Rectangle(0, 0, width, height), 1000000000);
  ArrayList<Integer> col = new ArrayList<Integer>();
  col.add(255);
  col.add(255);
  col.add(0);
  c = new Colony(nestSize*4, nestSize*4, colonySize, col);
  
  ArrayList<Integer> col2 = new ArrayList<Integer>();
  col2.add(0);
  col2.add(255);
  col2.add(255);
  c2 = new Colony(width-nestSize, height-nestSize, colonySize, col2);
  frameRate(240);
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
  //c2.update();
  showObstacles();
  
  if (!pause){
    if (frameCount % s == 0){
      String f;
      if (on < 10){
        f="frames_000"+on+".png";
      }
      else if (on < 100){
        f="frames_00"+on+".png";
      }
      else if (on < 1000){
        f="frames_0"+on+".png";
      }
      else{
        f="frames_"+on+".png";
      }
      
     //saveFrame("E:/Ant Out/"+f);
    }
  }
  
  
  //---
  if (obstacleMode){
    int thickness = 5;
    float[] data = {0, 0};
    for (int x=0;x<thickness;x++){
      for (int y=0;y<thickness;y++){
        Particle p = new Particle(round(mouseX / (obsSize*thickness)) * (obsSize*thickness)+x*obsSize, round(mouseY / (obsSize*thickness)) * (obsSize*thickness)+y*obsSize, data);
        obstacles.insert(p);
      }
    }
    

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
    float[] data = {0, 0};
    Particle p = new Particle(pos.x, pos.y, data);
    foodTree.insert(p);
  }
}
