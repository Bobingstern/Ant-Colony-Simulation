let size = 10;

let showVision = false;
let visionSize = size * 4;

let nestSize = size * 3;
let nestPos;
let colonySize = 100;
let colony = [];

let pause = true
let foodCount = 0;
let foodPatches = 1;
let totalFood = foodCount * foodPatches;
let foodSize = size / 2;
let foodClaimed = 0;
let foodTree;
let obstacles;
let foodPoints = [];

let showHomePheramone = false;
let homePheramoneDecay = 0.003;

let showFoodPheramone = false;
let foodPheramoneDecay = 0.003;


let framesUntilPheramone = 10;
let showQureyPos = false
let mouseHeld = false
let w;
let h;
let obstacleMode = false


let c
let c2

function setup() {
  createCanvas(window.innerWidth, window.innerHeight);

  w = floor(width / size);
  h = floor(height / size);
  foodTree = new QT.QuadTree(new QT.Box(0, 0, width, height), {capacity: 1000000000});
  obstacles = new QT.QuadTree(new QT.Box(0, 0, width, height), {capacity: 1000000000});
  c = new Colony(100, 100)

}


function showObstacles(){

  let points = obstacles.getAllPoints();
  for (let i = 0; i < points.length; i++){
    rectMode(CORNER)
    fill(117, 98, 35);
    rect(points[i].x, points[i].y, size, size);
  }

}

function draw(){
  background(56);
  c.update()
  showObstacles()
  textSize(10)
  if (pause){
    text('paused', 100, 10)
  }
  else{
    text('running', 100, 10)
  }

  if (obstacleMode){
    text('obstacle Mode', 200, 10)
  }
  else{
    text('food mode', 200, 10)
  }

  if (mouseHeld && frameCount % 5 == 0 && !obstacleMode && !keyIsDown(8)){
    let foodPoint
    for (let i = 0; i < 10; i ++) {
      foodPoint = new QT.Point(mouseX + random(-10, 10),
                                   mouseY + random(-10, 10));
      foodTree.insert(foodPoint)
    }
  }

  if (obstacleMode && mouseHeld && !keyIsDown(8)){
    let ob

    ob = new QT.Point(round(mouseX / size) * size, round(mouseY / size) * size);
    obstacles.insert(ob)

  }
  if (mouseHeld && keyIsDown(8)){
    let pos = createVector(round(mouseX / size) * size, round(mouseY / size) * size);
    let all = obstacles.getAllPoints()
    for (var i=all.length-1;i>=0;i--){

      if (pos.x == all[i].x && pos.y == all[i].y){
        obstacles.remove(all[i])
      }
    }
  }
  //---

}


function mousePressed(){
  mouseHeld = true
}
function mouseReleased(){
  mouseHeld = false
}
function keyPressed(key){
  if (keyCode === 79){
    if (obstacleMode){
      obstacleMode = false
    }
    else{
      obstacleMode = true
    }
  }
  if (keyCode === 80){
    if (pause){
      pause = false
    }
    else{
      pause = true
    }
  }
}
