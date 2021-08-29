


class Colony{
  constructor(x, y){
    this.colony = []
    this.colonySize = 100
    this.nestPos = createVector(x, y);
    this.foodPheramoneTree;
    this.homePheramoneTree;
    this.foodClaimed = [0]
    this.COLOR = [random(0, 255), random(0, 255), random(0, 255)]

    this.createColony(this.colonySize)
  }
  createColony(size) {
    nestSize = width/10
    nestPos = createVector(round(width / 2), round(height / 2));
    this.createHomePheramone()

    for (let i = 0; i < size; i++) {
      this.colony.push(new Ant(this.nestPos.x, this.nestPos.y, this.homePheramoneTree, this.foodPheramoneTree, this.nestPos, this.foodClaimed, this.COLOR));
    }
  }



  createHomePheramone() {
    this.homePheramoneTree = new QT.QuadTree(new QT.Box(0, 0, width, height), {capacity: 1000000000});
    this.foodPheramoneTree = new QT.QuadTree(new QT.Box(0, 0, width, height), {capacity: 1000000000});
  }


  updateAll() {
    for (let i = 0; i < this.colonySize; i++) {
      this.colony[i].update();
      this.colony[i].show();
    }
  }

  showNest() {
    fill(197, 147, 45);
    circle(this.nestPos.x, this.nestPos.y, nestSize);
    fill(0, 0, 0);
    textSize(round(nestSize / 5));
    textAlign(CENTER, CENTER);
    let foodOnFloor = foodTree.getAllPoints().length;
    let theText = "In nest: " + this.foodClaimed[0];

    text(theText, this.nestPos.x, this.nestPos.y);

  }

  showFood() {
    let points = foodTree.getAllPoints();
    for (let i = 0; i < points.length; i++){
      fill(0, 255, 0);
      circle(points[i].x, points[i].y, foodSize);
    }
  }

  updatePheramone() {
    let home = this.homePheramoneTree.getAllPoints();
    for (let i = home.length - 1; i >= 0; i --) {
      if (showHomePheramone) {
        fill(0, 0, 255);
        circle(home[i].x, home[i].y, (home[i].strength * 5));
      }
      home[i].strength -= homePheramoneDecay;
      if (home[i].strength <= 0) {
        this.homePheramoneTree.remove(home[i])
      }
    }

    let food = this.foodPheramoneTree.getAllPoints();
    for (let i = food.length - 1; i >= 0; i --) {
      if (showFoodPheramone) {
        fill(255, 0, 0);
        circle(food[i].x, food[i].y, (food[i].strength * 5));
      }
      food[i].strength -= foodPheramoneDecay;
      if (food[i].strength <= 0) {
        this.foodPheramoneTree.remove(food[i])
      }
    }
  }

  update() {

    this.showNest();
    this.showFood();
    this.updatePheramone();
    this.updateAll();
  }
}
