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
    this.wanderStrength = 0.2;
    this.angle = 0;
    this.maxSpeed = 0.6;
    this.steerStrength = 0.05;
    this.getCoolDown = 0;
    this.stopWanderingTime = 10000;
    this.canEnterNest = true
    this.evoTime = 200
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
        this.desiredDirection.mult(-1)
        this.getCoolDown = 30
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
      if (dist(this.pos.x, this.pos.y, nestPos.x, nestPos.y) < nestSize-visionSize){
        this.hasFood = false;
        this.food = undefined;
        foodClaimed ++;
        this.desiredDirection.mult(-1);
        this.getCoolDown = 30
      } else {
        this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
      }
    }
  }


  queryThreeLocation(){
    let frontPoints = []
    let leftPoints = []
    let rightPoints = []

    let X = this.pos.x + visionSize/1.5;
    let Y = this.pos.y;

    let New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    let New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    if (this.hasFood){
      frontPoints = homePheramoneTree.query(new QT.Circle(New_X, New_Y, visionSize/1.5))
    }
    else{
      frontPoints = foodPheramoneTree.query(new QT.Circle(New_X, New_Y, visionSize/1.5))
    }

    if (showQureyPos){
      push();
      noStroke();
      fill(255, 255, 255, 30);
      circle(New_X, New_Y, visionSize/1.5);
      pop();
    }
    //--------
    let X2 = this.pos.x + (visionSize/1.5) - (size);
    let Y2 = this.pos.y + size*3;

    let New_X2 = this.pos.x + (X2 - this.pos.x) * cos(this.angle) - (Y2 - this.pos.y) * sin(this.angle);
    let New_Y2 = this.pos.y + (X2 - this.pos.x) * sin(this.angle) + (Y2 - this.pos.y) * cos(this.angle);

    if (this.hasFood){
      rightPoints = homePheramoneTree.query(new QT.Circle(New_X2, New_Y2, visionSize/1.5))
    }
    else{
      rightPoints = foodPheramoneTree.query(new QT.Circle(New_X2, New_Y2, visionSize/1.5))
    }
    if (showQureyPos){
      push();
      noStroke();
      fill(255, 255, 255, 30);
      circle(New_X2, New_Y2, visionSize/1.5);
      pop();
    }

    //--------
    let X3 = this.pos.x + (visionSize/1.5) - (size);
    let Y3 = this.pos.y - size*3;

    let New_X3 = this.pos.x + (X3 - this.pos.x) * cos(this.angle) - (Y3 - this.pos.y) * sin(this.angle);
    let New_Y3 = this.pos.y + (X3 - this.pos.x) * sin(this.angle) + (Y3 - this.pos.y) * cos(this.angle);

    if (this.hasFood){
      leftPoints = homePheramoneTree.query(new QT.Circle(New_X3, New_Y3, visionSize/1.5))
    }
    else{
      leftPoints = foodPheramoneTree.query(new QT.Circle(New_X3, New_Y3, visionSize/1.5))
    }
    if (showQureyPos){
      push();
      noStroke();
      fill(255, 255, 255, 30);
      circle(New_X3, New_Y3, visionSize/1.5);
      pop();
    }


    let frontOverlap = []
    let leftOverlap = []
    let rightOverlap = []

    let frontConc = 0
    let leftConc = 0
    let rightConc = 0

    for (var i=0;i<frontPoints.length;i++){
      if (dist(New_X, New_Y, frontPoints[i].x, frontPoints[i].y) < (visionSize/1.5)){
        frontOverlap.push(frontPoints[i])
        let life = frameCount - frontPoints[i].frame
        let evo = Math.max(1, life-this.evoTime)
        frontConc += 1-frontPoints[i].strength
      }
    }
    for (var i=0;i<rightPoints.length;i++){
      if (dist(New_X2, New_Y2, rightPoints[i].x, rightPoints[i].y) < (visionSize/1.5)){
        rightOverlap.push(rightPoints[i])
        let life = frameCount - rightPoints[i].frame
        let evo = Math.max(1, life-this.evoTime)
        rightConc += 1-rightOverlap[i].strength
      }
    }

    for (var i=0;i<leftPoints.length;i++){
      if (dist(New_X3, New_Y3, leftPoints[i].x, leftPoints[i].y) < (visionSize/1.5)){
        leftOverlap.push(leftPoints[i])
        let life = frameCount - leftPoints[i].frame
        let evo = Math.max(1, life-this.evoTime)
        leftConc += 1-leftOverlap[i].strength
      }
    }

    if (frontConc > leftConc && frontConc > rightConc && frontOverlap.length > 0){
      let best = 0;
      let bestIndex = 0;
      for (var i=0;i<frontOverlap.length;i++){
        if (frontOverlap[i].strength > best){
          best = frontOverlap[i].strength
          bestIndex = i
        }
      }
      this.target = createVector(frontOverlap[bestIndex].x, frontOverlap[bestIndex].y)
      this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
      if (showQureyPos){
        push();
        noStroke();
        fill(255, 255, 255, 80);
        circle(New_X, New_Y, visionSize/1.5);
        pop();
      }

    }
    else if (leftConc > frontConc && leftConc > rightConc && leftOverlap.length > 0){
      let best = 0;
      let bestIndex = 0;
      for (var i=0;i<leftOverlap.length;i++){
        if (leftOverlap[i].strength > best){
          best = leftOverlap[i].strength
          bestIndex = i
        }
      }
      this.target = createVector(leftOverlap[bestIndex].x, leftOverlap[bestIndex].y)
      this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
      if (showQureyPos){
        push();
        noStroke();
        fill(255, 255, 255, 80);
        circle(New_X3, New_Y3, visionSize/1.5);
        pop();
      }
    }
    else if (rightConc > frontConc && rightConc > leftConc && rightOverlap.length > 0){
      let best = 0;
      let bestIndex = 0;
      for (var i=0;i<rightOverlap.length;i++){
        if (rightOverlap[i].strength > best){
          best = rightOverlap[i].strength
          bestIndex = i
        }
      }
      this.target = createVector(rightOverlap[bestIndex].x, rightOverlap[bestIndex].y)
      this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
      if (showQureyPos){
        push();
        noStroke();
        fill(255, 255, 255, 80);
        circle(New_X2, New_Y2, visionSize/1.5);
        pop();
      }
    }

  }

  handlePheramoneHomeSteering() {
    this.queryThreeLocationHome()
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
      let best = 1;
      let bestIndex = 0
      for (let i = 0; i < overlapping.length; i ++) {
        if (overlapping[i].strength < best){
          best = overlapping[i].strength
          bestIndex = i
        }
      }
      this.target = createVector(overlapping[bestIndex].x, overlapping[bestIndex].y);
      this.desiredDirection = new p5.Vector.sub(this.target, this.pos);
    }
  }
  handlePheramoneFoodSteering() {
    this.queryThreeLocationHome()
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
      let best = 1;
      let bestIndex = 0
      for (let i = 0; i < overlapping.length; i ++) {
        if (overlapping[i].strength < best){
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
      if (this.getCoolDown <= 0 && random(0, 1) < 0.85) {
        this.queryThreeLocation()
      }

      this.handleNest();
      //--Lay Pheramone
      if (frameCount % framesUntilPheramone == 0) {
        let customPoint = {
            x: this.pos.x,
            y: this.pos.y,
            strength: 1,
            frame: frameCount
        };
        foodPheramoneTree.insert(customPoint);
      }

      //--
    } else {



      if (this.getCoolDown <= 0 && random(0, 1) < 0.85) {
        this.queryThreeLocation()
      }

      this.handleFood();
      //--Lay Pheramone
      if (frameCount % framesUntilPheramone == 0) {
        let customPoint = {
            x: this.pos.x,
            y: this.pos.y,
            strength: 1,
            frame: frameCount
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
