let size = 10;

let showVision = false;
let visionSize = size * 4;

const nestSize = size * 3;
let nestPos;
let colonySize = 200;
let colony = [];

let foodCount = 100;
let foodPatches = 2;
let totalFood = foodCount * foodPatches;
let foodSize = size / 2;
let foodClaimed = 0;
let foodTree;
let foodPoints = [];

let showHomePheramone = false;
let homePheramoneDecay = 0.001;
let homePheramoneTree;
let homePheramonePoints = [];

let showFoodPheramone = false;
let foodPheramoneDecay = 0.001;
let foodPheramoneTree;
let foodPheramonePoints = [];

let w;
let h;

function createColony(size) {
  for (let i = 0; i < size; i++) {
    colony.push(new Ant(width / 2, height / 2));
  }
}

function createFood(amount, patches) {
  foodTree = new QT.QuadTree(new QT.Box(0, 0, width, height), {capacity: amount});
  for (let p = 0; p < patches; p ++) {
    let foodPoint = createVector(round(random(0, width)), round(random(0, height)));
    for (let i = 0; i < amount; i ++) {
      foodPoints[i] = new QT.Point(foodPoint.x + random(-10, 10),
                                   foodPoint.y + random(-10, 10));
    }
    foodTree.insert(foodPoints);
  }
}


function createHomePheramone() {
  homePheramoneTree = new QT.QuadTree(new QT.Box(0, 0, width, height), {capacity: 1000000000});
  foodPheramoneTree = new QT.QuadTree(new QT.Box(0, 0, width, height), {capacity: 1000000000});
}

function setup() {
  createCanvas(window.innerWidth, window.innerHeight);

  w = floor(width / size);
  h = floor(height / size);

  nestPos = createVector(round(width / 2), round(height / 2));
  createColony(colonySize);
  createFood(foodCount, foodPatches);
  createHomePheramone()
}

function updateAll() {
  for (let i = 0; i < colonySize; i++) {
    colony[i].update();
    colony[i].show();
  }
}

function showNest() {
  fill(197, 147, 45);
  circle(nestPos.x, nestPos.y, nestSize);
  fill(0, 0, 0);
  textSize(round(nestSize / 8));
  textAlign(CENTER, CENTER);
  let foodOnFloor = foodTree.getAllPoints().length;
  let theText = "In nest: " + foodClaimed;
  theText += "\nCarried: " + (totalFood - foodOnFloor - foodClaimed);
  theText += "\nOn floor: " + foodOnFloor;
  text(theText, nestPos.x, nestPos.y);
  if (foodOnFloor == 0) {
    createFood(foodCount, foodPatches);
    totalFood += foodCount * foodPatches;
  }
}

function showFood() {
  let points = foodTree.getAllPoints();
  for (let i = 0; i < points.length; i++){
    fill(0, 255, 0);
    circle(points[i].x, points[i].y, foodSize);
  }
}

function updatePheramone() {
  let home = homePheramoneTree.getAllPoints();
  for (let i = home.length - 1; i >= 0; i --) {
    if (showHomePheramone) {
      fill(0, 0, 255);
      circle(home[i].x, home[i].y, (home[i].strength * 5));
    }
    home[i].strength -= homePheramoneDecay;
    if (home[i].strength <= 0) {
      homePheramoneTree.remove(home[i])
    }
  }

  let food = foodPheramoneTree.getAllPoints();
  for (let i = food.length - 1; i >= 0; i --) {
    if (showFoodPheramone) {
      fill(255, 0, 0);
      circle(food[i].x, food[i].y, (food[i].strength * 5));
    }
    food[i].strength -= foodPheramoneDecay;
    if (food[i].strength <= 0) {
      foodPheramoneTree.remove(food[i])
    }
  }
}

function draw() {
  background(56);
  showNest();
  showFood();
  updatePheramone();
  updateAll();
}
