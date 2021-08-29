let size = 10;

let showVision = false;
let visionSize = size * 4;

let nestSize = size * 3;
let nestPos;
let colonySize = 200;
let colony = [];

let foodCount = 0;
let foodPatches = 1;
let totalFood = foodCount * foodPatches;
let foodSize = size / 2;
let foodClaimed = 0;
let foodTree;
let foodPoints = [];

let showHomePheramone = false;
let homePheramoneDecay = 0.002;
let homePheramoneTree;
let homePheramonePoints = [];

let showFoodPheramone = false;
let foodPheramoneDecay = 0.002;
let foodPheramoneTree;
let foodPheramonePoints = [];

let framesUntilPheramone = 10;
let showQureyPos = false
let mouseHeld = false
let w;
let h;

let c
let c2

function setup() {
  createCanvas(window.innerWidth, window.innerHeight);

  w = floor(width / size);
  h = floor(height / size);
  foodTree = new QT.QuadTree(new QT.Box(0, 0, width, height), {capacity: 1000000000});
  c = new Colony(100, 100)

}



function draw(){
  background(56);
  c.update()

  if (mouseHeld && frameCount % 5 == 0){
    let foodPoint
    for (let i = 0; i < 10; i ++) {
      foodPoint = new QT.Point(mouseX + random(-10, 10),
                                   mouseY + random(-10, 10));
      foodTree.insert(foodPoint)
    }
  }

}


function mousePressed(){
  mouseHeld = true


}
function mouseReleased(){
  mouseHeld = false
}
