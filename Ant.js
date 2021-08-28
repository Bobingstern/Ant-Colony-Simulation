class Ant {
  constructor(ix, iy) {
    this.pos = createVector(ix, iy);
    this.vel = createVector();
    this.desiredDirection = createVector();
    this.moveRandom();
    this.target = createVector();
    //this.index = createVector(ix, iy)
    this.hasFood = false;
    this.food;
    this.wanderStrength = 0.1;
    this.angle = 0;
    this.maxSpeed = 0.6;
    this.steerStrength = 0.05;
    this.getCoolDown = 0;
    this.stopWanderingTime = 10000;
    this.canEnterNest = true
    //0 = up, 1 = right, 2 = down, 3 = left
  }

  show() {
    push();
    fill(0, 0, 0);
    translate(this.pos.x, this.pos.y);
    rectMode(CENTER);
    rotate(this.angle);
    rect(0, 0, size, size / 2);

    fill(255, 0, 0);
    circle(size / 2, -size / 5, size / 6);
    circle(size / 2, size / 5, size / 6);
    if (this.hasFood){
      fill(0, 255, 0)
      circle(size, 0, foodSize)
    }
    pop();
  }

  moveRandom() {
    let r = 1;
    let x = random(-r, r);
    let y = random(-1, 1) * sqrt((r * r) - x * x);
    this.target = createVector(x, y);
    this.target.mult(this.wanderStrength);
    this.desiredDirection = new p5.Vector.add(this.desiredDirection, this.target);
    this.desiredDirection.normalize();
  }

  followMouse() {
    this.target = createVector(mouseX, mouseY);
    this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
  }

  showVision() {
    let X = this.pos.x + size * 3;
    let Y = this.pos.y;

    let New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    let New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    push();
    noStroke();
    fill(255, 255, 255, 30);
    circle(New_X, New_Y, visionSize);
    pop();
  }

  handleFood() {
    let X = this.pos.x + visionSize;
    let Y = this.pos.y;

    let New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    let New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    if (showVision) {
      this.showVision();
    }

    const points = foodTree.query(new QT.Circle(New_X, New_Y, visionSize));
    let overlapping = [];
    let overlappingIndexes = []
    for (let i = 0; i < points.length; i++) {
      if (dist(points[i].x, points[i].y, New_X, New_Y) < visionSize + foodSize) {
        overlapping.push(points[i]);
        overlappingIndexes.push(i);
        this.food = points[i];
      }
    }

    if (overlapping.length > 0) {
      let best = 1000;
      let bestIndex = 0
      for (let i = 0; i < overlapping.length; i ++) {
        if (dist(this.pos.x, this.pos.y, overlapping[i].x, overlapping[i].y) < best) {
          best = dist(this.pos.x, this.pos.y, overlapping[i].x, overlapping[i].y);
          bestIndex = i;
        }
      }

      this.food = points[overlappingIndexes[bestIndex]];

      this.target = createVector(this.food.x, this.food.y);
      if (dist(this.pos.x, this.pos.y, this.target.x, this.target.y) < 5) {
        this.hasFood = true
        this.stopWanderingTime = 10000;
        this.desiredDirection = new p5.Vector.sub(nestPos, this.pos);
        this.getCoolDown = 1500
        foodTree.remove(this.food);
      } else {
        this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
      }
    }
  }

  handleNest() {
    let X = this.pos.x + visionSize;
    let Y = this.pos.y;

    let New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    let New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    if (dist(nestPos.x, nestPos.y, New_X, New_Y) < visionSize + nestSize) {
      this.target = createVector(nestPos.x, nestPos.y);
      if (dist(this.pos.x, this.pos.y, nestPos.x, nestPos.y) < nestSize){
        this.hasFood = false;
        this.food = undefined;
        foodClaimed ++;
        this.desiredDirection.mult(-1);
        this.getCoolDown = 1500
        this.stopWanderingTime = 10000;
      } else {
        this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
      }
    }
  }

  handlePheramoneHomeSteering() {
    let X = this.pos.x + visionSize;
    let Y = this.pos.y;

    let New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    let New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    if (showVision) {
      this.showVision();
    }

    const points = homePheramoneTree.query(new QT.Circle(New_X, New_Y, visionSize));
    let overlapping = [];
    for (let i = 0; i < points.length; i++) {
      if (dist(points[i].x, points[i].y, New_X, New_Y) < visionSize + points[i].strength*5) {
        overlapping.push(points[i]);

      }
    }

    if (overlapping.length > 0) {
      let best = 0
      let bestIndex = 0
      for (let i = 0; i < overlapping.length; i ++) {
        if (overlapping[i].strength > best){
          best = overlapping[i].strength
          bestIndex = i
        }
      }
      this.target = createVector(overlapping[bestIndex].x, overlapping[bestIndex].y);
      this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
    }
  }
  handlePheramoneFoodSteering() {
    let X = this.pos.x + visionSize;
    let Y = this.pos.y;

    let New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    let New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    if (showVision) {
      this.showVision();
    }

    const points = foodPheramoneTree.query(new QT.Circle(New_X, New_Y, visionSize));
    let overlapping = [];
    for (let i = 0; i < points.length; i++) {
      if (dist(points[i].x, points[i].y, New_X, New_Y) < visionSize + points[i].strength*5) {
        overlapping.push(points[i]);

      }
    }

    if (overlapping.length > 0) {
      let best = 0
      let bestIndex = 0
      for (let i = 0; i < overlapping.length; i ++) {
        if (overlapping[i].strength > best){
          best = overlapping[i].strength
          bestIndex = i
        }
      }
      this.target = createVector(overlapping[bestIndex].x, overlapping[bestIndex].y);
      this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
    }
  }

  update() {
    //this.followMouse()
    this.moveRandom();
    if (showVision) {
      this.showVision();
    }
    if (this.hasFood) {
      if (this.getCoolDown <= 0) {
        this.handlePheramoneHomeSteering()
      }

      this.handleNest();
      //--Lay Pheramone
      if (frameCount % 20 == 0) {
        let customPoint = {
            x: this.pos.x,
            y: this.pos.y,
            strength: 1
        };
        foodPheramoneTree.insert(customPoint);
      }

      //--
    } else {

      if (this.stopWanderingTime <= 0){
        this.desiredDirection = this.desiredDirection = new p5.Vector.sub(nestPos, this.pos);
      }

      if (this.getCoolDown <= 0) {
        this.handlePheramoneFoodSteering()
      }

      this.handleFood();
      //--Lay Pheramone
      if (frameCount % 20 == 0) {
        let customPoint = {
            x: this.pos.x,
            y: this.pos.y,
            strength: 1
        };
        homePheramoneTree.insert(customPoint)
      }

      //--
    }

    let desiredVelocity = createVector();
    let desiredSteeringForce = createVector();
    let acceleration = createVector();
    desiredVelocity = new p5.Vector.mult(this.desiredDirection, this.maxSpeed);
    desiredSteeringForce = new p5.Vector.sub(desiredVelocity, this.vel);
    //console.log(desiredSteeringForce)
    desiredSteeringForce.mult(this.steerStrength);
    acceleration = desiredSteeringForce.copy();
    acceleration.setMag(constrain(acceleration.mag(), 0, this.steerStrength));

    //console.log(desiredVelocity, desiredSteeringForce, acceleration, this.vel)
    let e = new p5.Vector.add(this.vel, acceleration);

    this.vel = e.copy();
    this.vel.setMag(constrain(this.vel.mag(), 0, this.maxSpeed));

    if (this.pos.x > width) {
      this.vel.mult(-1);
      this.desiredDirection.mult(-1);
    }
    if (this.pos.x < 0){
      this.vel.mult(-1);
      this.desiredDirection.mult(-1);
    }
    if (this.pos.y > height){
      this.vel.mult(-1);
      this.desiredDirection.mult(-1);
    }
    if (this.pos.y < 0){
      this.vel.mult(-1);
      this.desiredDirection.mult(-1);
    }

    this.pos.add(this.vel);
    this.angle = Math.atan2(this.vel.y, this.vel.x);

    if (this.getCoolDown >= 0){
      this.getCoolDown--;
    }
    if (this.stopWanderingTime >= 0){
      this.stopWanderingTime--;
    }
  }
}
