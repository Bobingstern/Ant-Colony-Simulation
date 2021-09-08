PVector vecAdd(PVector a, PVector b){
  PVector as = a.copy();
  PVector bs = b.copy();
  as.add(bs);
  return as;
}


PVector vecSub(PVector a, PVector b){
  PVector as = a.copy();
  PVector bs = b.copy();
  as.sub(bs);
  return as;
}


PVector vecMultF(PVector a, float b){
  PVector as = a.copy();
  as.mult(b);
  return as;
}


class Ant {
  PVector pos;
  PVector vel;
  PVector desiredDirection;
  PVector target;
  QuadTree homePheramoneTree;
  QuadTree foodPheramoneTree;
  PVector nestPos;
  boolean claimed;
  ArrayList<Integer> COLOR;
  boolean hasFood = false;
  float wanderStrength = 0.2;
  float angle = 0;
  float maxSpeed = 0.06;
  float steerStrength = 0.03;
  int getCoolDown = 0;
  float stopWanderingTime = 10000;
  boolean canEnterNest = true;
  float evoTime = 200;  
  
  Ant(float ix, float iy, QuadTree h, QuadTree f, PVector nest, ArrayList<Integer> c) {
    this.pos = new PVector(ix, iy);
    this.vel = new PVector();
    this.desiredDirection = new PVector();
    this.moveRandom();
    this.target = new PVector();
    this.homePheramoneTree = h;
    this.foodPheramoneTree = f;
    this.nestPos = nest;
    this.COLOR = c;

    //0 = up, 1 = right, 2 = down, 3 = left
  }

  void show() {
    push();
    fill(this.COLOR.get(0), this.COLOR.get(1), this.COLOR.get(2));
    translate(this.pos.x, this.pos.y);
    rectMode(CENTER);
    rotate(this.angle);
    rect(0, 0, size, size / 2);

    fill(255, 0, 0);
    //circle(size / 2, -size / 5, size / 6);
    //circle(size / 2, size / 5, size / 6);
    if (this.hasFood){
      fill(0, 255, 0);
      circle(size, 0, foodSize);
    }
    pop();
  }

  void moveRandom() {
    float r = 1;
    float x = random(-r, r);
    float y = random(-1, 1) * sqrt((r * r) - x * x);
    this.target = new PVector(x, y);
    this.target.mult(this.wanderStrength);
    this.desiredDirection = vecAdd(this.desiredDirection, this.target);
    this.desiredDirection.normalize();
  }

  void followMouse() {
    this.target = new PVector(mouseX, mouseY);
    this.desiredDirection = vecSub(this.target, this.pos);
  }

  void showVision() {
    float X = this.pos.x + size * 3;
    float Y = this.pos.y;

    float New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    float New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    push();
    noStroke();
    fill(255, 255, 255, 30);
    circle(New_X, New_Y, visionSize);
    pop();
  }

  void handleFood() {
    float X = this.pos.x + visionSize;
    float Y = this.pos.y;

    float New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    float New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    if (showVision) {
      this.showVision();
    }
    ArrayList<Particle> points = new ArrayList<Particle>();
    points = foodTree.query(new Rectangle(New_X, New_Y, visionSize, visionSize), points);
    ArrayList<Particle> overlapping = new ArrayList<Particle>();
    ArrayList<Integer> overlappingIndexes = new ArrayList<Integer>();
    Particle food;
    int i = 0;
    for (Particle p : points) {
      if (dist(p.x, p.y, New_X, New_Y) < visionSize + foodSize) {
        overlapping.add(p);
        overlappingIndexes.add(i);
        food = p;
        i++;
      }
    }

    if (overlapping.size() > 0) {
      float best = 1000;
      int bestIndex = 0;
      i = 0;
      for (Particle p : overlapping) {
        if (dist(this.pos.x, this.pos.y, p.x, p.y) < best) {
          best = dist(this.pos.x, this.pos.y, p.x, p.y);
          bestIndex = i;
        }
        i++;
      }

      food = points.get(overlappingIndexes.get(bestIndex));

      this.target = new PVector(food.x, food.y);
      if (dist(this.pos.x, this.pos.y, this.target.x, this.target.y) < 5) {
        this.hasFood = true;
        this.stopWanderingTime = 10000;
        this.desiredDirection.mult(-1);
        this.vel.mult(-1);
        this.getCoolDown = 30;
        foodTree.remove(food);
      } else {
        this.desiredDirection = vecSub(this.target, this.pos);
      }
    }
  }

  void handleNest() {
    float X = this.pos.x + visionSize;
    float Y = this.pos.y;

    float New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    float New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    if (dist(this.nestPos.x, this.nestPos.y, New_X, New_Y) < visionSize + nestSize) {
      this.target = new PVector(this.nestPos.x, this.nestPos.y);
      if (dist(this.pos.x, this.pos.y, this.nestPos.x, this.nestPos.y) < nestSize/2){
        this.hasFood = false;
        this.desiredDirection.mult(-1);
        this.vel.mult(-1);
        this.getCoolDown = 30;
      } else {
        this.desiredDirection = vecSub(this.target, this.pos);
      }
    }
  }


  void queryThreeLocation(){
    ArrayList<Particle> frontPoints = new ArrayList<Particle>();
    ArrayList<Particle> leftPoints = new ArrayList<Particle>();
    ArrayList<Particle> rightPoints = new ArrayList<Particle>();

    float X = this.pos.x + visionSize/1.5;
    float Y = this.pos.y;

    float New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    float New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    if (this.hasFood){
      frontPoints = this.homePheramoneTree.queryCircle(new Circle(New_X, New_Y, visionSize/1.5), frontPoints);
    }
    else{
      frontPoints = this.foodPheramoneTree.queryCircle(new Circle(New_X, New_Y, visionSize/1.5), frontPoints);
    }

    if (showQureyPos){
      push();
      noStroke();
      fill(255, 255, 255, 30);
      //circle(New_X, New_Y, visionSize/1.5);
      pop();
    }
    //--------
    float X2 = this.pos.x + (visionSize/1.5) - (size);
    float Y2 = this.pos.y + size*3;

    float New_X2 = this.pos.x + (X2 - this.pos.x) * cos(this.angle) - (Y2 - this.pos.y) * sin(this.angle);
    float New_Y2 = this.pos.y + (X2 - this.pos.x) * sin(this.angle) + (Y2 - this.pos.y) * cos(this.angle);

    if (this.hasFood){
      rightPoints = this.homePheramoneTree.queryCircle(new Circle(New_X2, New_Y2, visionSize/1.5), rightPoints);
    }
    else{
      rightPoints = this.foodPheramoneTree.queryCircle(new Circle(New_X2, New_Y2, visionSize/1.5), rightPoints);
    }
    
    if (showQureyPos){
      push();
      noStroke();
      fill(255, 255, 255, 30);
      circle(New_X2, New_Y2, visionSize/1.5);
      pop();
    }

    //--------
    float X3 = this.pos.x + (visionSize/1.5) - (size);
    float Y3 = this.pos.y - size*3;

    float New_X3 = this.pos.x + (X3 - this.pos.x) * cos(this.angle) - (Y3 - this.pos.y) * sin(this.angle);
    float New_Y3 = this.pos.y + (X3 - this.pos.x) * sin(this.angle) + (Y3 - this.pos.y) * cos(this.angle);

    if (this.hasFood){
      leftPoints = this.homePheramoneTree.queryCircle(new Circle(New_X3, New_Y3, visionSize/1.5), leftPoints);
    }
    else{
      leftPoints = this.foodPheramoneTree.queryCircle(new Circle(New_X3, New_Y3, visionSize/1.5), leftPoints);
    }
    if (showQureyPos){
      push();
      noStroke();
      fill(255, 255, 255, 30);
      circle(New_X3, New_Y3, visionSize/1.5);
      pop();
    }


    ArrayList<Particle> frontOverlap = new ArrayList<Particle>();
    ArrayList<Particle> leftOverlap = new ArrayList<Particle>();
    ArrayList<Particle> rightOverlap = new ArrayList<Particle>();

    float frontConc = 0;
    float leftConc = 0;
    float rightConc = 0;

    for (int i=0;i<frontPoints.size();i++){
      if (dist(New_X, New_Y, frontPoints.get(i).x, frontPoints.get(i).y) < (visionSize/1.5)){
        frontOverlap.add(frontPoints.get(i));
        boolean canSee = true;
        
        if (canSee){
          frontConc += 1-(frameCount-frontPoints.get(i).data[1])/pheroLife;
        }

      }

      
    }
    for (var i=0;i<rightPoints.size();i++){
      if (dist(New_X2, New_Y2, rightPoints.get(i).x, rightPoints.get(i).y) < (visionSize/1.5)){
        rightOverlap.add(rightPoints.get(i));
        ArrayList<Particle> obs = new ArrayList<Particle>();
        boolean canSee = true;
        
        if (canSee){
          rightConc += 1-(frameCount-rightPoints.get(i).data[1])/pheroLife;
        }

      }
    }

    for (var i=0;i<leftPoints.size();i++){
      if (dist(New_X3, New_Y3, leftPoints.get(i).x, leftPoints.get(i).y) < (visionSize/1.5)){
        leftOverlap.add(leftPoints.get(i));
         ArrayList<Particle> obs = new ArrayList<Particle>();
        boolean canSee = true;
        
        if (canSee){
          leftConc += 1-(frameCount-leftPoints.get(i).data[1])/pheroLife;
        }

      }
    }

    if (frontConc > leftConc && frontConc > rightConc && frontOverlap.size() > 0){
      float best = 0;
      int bestIndex = 0;
      for (var i=0;i<frontOverlap.size();i++){
        if (frontOverlap.get(i).data[0] > best){
          best = frontOverlap.get(i).data[0];
          bestIndex = i;
        }
      }
      this.target = new PVector(frontOverlap.get(bestIndex).x, frontOverlap.get(bestIndex).y);
      //this.target = new PVector(New_X, New_Y);
      this.desiredDirection = vecSub(this.target, this.pos);
      if (showQureyPos){
        push();
        noStroke();
        fill(255, 255, 255, 80);
        circle(New_X, New_Y, visionSize/1.5);
        pop();
      }

    }
    else if (leftConc > frontConc && leftConc > rightConc && leftOverlap.size() > 0){
      float best = 0;
      int bestIndex = 0;
      for (var i=0;i<leftOverlap.size();i++){
        if (leftOverlap.get(i).data[0] > best){
          best = leftOverlap.get(i).data[0];
          bestIndex = i;
        }
      }
      this.target = new PVector(leftOverlap.get(bestIndex).x, leftOverlap.get(bestIndex).y);
      //this.target = new PVector(New_X3, New_Y3);
      this.desiredDirection = vecSub(this.target, this.pos);
      if (showQureyPos){
        push();
        noStroke();
        fill(255, 255, 255, 80);
        circle(New_X3, New_Y3, visionSize/1.5);
        pop();
      }
    }
    else if (rightConc > frontConc && rightConc > leftConc && rightOverlap.size() > 0){
      float best = 0;
      int bestIndex = 0;
      for (var i=0;i<rightOverlap.size();i++){
        if (rightOverlap.get(i).data[0] > best){
          best = rightOverlap.get(i).data[0];
          bestIndex = i;
        }
      }
      this.target = new PVector(rightOverlap.get(bestIndex).x, rightOverlap.get(bestIndex).y);
      //this.target = new PVector(New_X2, New_Y2);
      this.desiredDirection = vecSub(this.target, this.pos);
      if (showQureyPos){
        push();
        noStroke();
        fill(255, 255, 255, 80);
        circle(New_X2, New_Y2, visionSize/1.5);
        pop();
      }
    }

  }

  void checkCollision(){
    ArrayList<Particle> cols = new ArrayList<Particle>();
    cols = obstacles.query(new Rectangle(this.pos.x, this.pos.y, size*2, size*2), cols);
    float lines[][] = new float[4][4];

    float X = this.pos.x + size/2;
    float Y = this.pos.y-size/4;

    float New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    float New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    float X2 = this.pos.x + size/2;
    float Y2 = this.pos.y+size/4;

    float New_X2 = this.pos.x + (X2 - this.pos.x) * cos(this.angle) - (Y2 - this.pos.y) * sin(this.angle);
    float New_Y2 = this.pos.y + (X2 - this.pos.x) * sin(this.angle) + (Y2 - this.pos.y) * cos(this.angle);

    
    lines[0][0] = New_X;
    lines[0][1] = New_Y;
    lines[0][2] = New_X2;
    lines[0][3] = New_Y2;

    X = this.pos.x - size/2;
    Y = this.pos.y-size/4;

    New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    X2 = this.pos.x - size/2;
    Y2 = this.pos.y+size/4;

    New_X2 = this.pos.x + (X2 - this.pos.x) * cos(this.angle) - (Y2 - this.pos.y) * sin(this.angle);
    New_Y2 = this.pos.y + (X2 - this.pos.x) * sin(this.angle) + (Y2 - this.pos.y) * cos(this.angle);

    lines[1][0] = New_X;
    lines[1][1] = New_Y;
    lines[1][2] = New_X2;
    lines[1][3] = New_Y2;

    X = this.pos.x - size/2;
    Y = this.pos.y-size/4;

    New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    X2 = this.pos.x + size/2;
    Y2 = this.pos.y-size/4;

    New_X2 = this.pos.x + (X2 - this.pos.x) * cos(this.angle) - (Y2 - this.pos.y) * sin(this.angle);
    New_Y2 = this.pos.y + (X2 - this.pos.x) * sin(this.angle) + (Y2 - this.pos.y) * cos(this.angle);

    lines[2][0] = New_X;
    lines[2][1] = New_Y;
    lines[2][2] = New_X2;
    lines[2][3] = New_Y2;

    X = this.pos.x - size/2;
    Y = this.pos.y+size/4;

    New_X = this.pos.x + (X - this.pos.x) * cos(this.angle) - (Y - this.pos.y) * sin(this.angle);
    New_Y = this.pos.y + (X - this.pos.x) * sin(this.angle) + (Y - this.pos.y) * cos(this.angle);

    X2 = this.pos.x + size/2;
    Y2 = this.pos.y+size/4;

    New_X2 = this.pos.x + (X2 - this.pos.x) * cos(this.angle) - (Y2 - this.pos.y) * sin(this.angle);
    New_Y2 = this.pos.y + (X2 - this.pos.x) * sin(this.angle) + (Y2 - this.pos.y) * cos(this.angle);

    lines[3][0] = New_X;
    lines[3][1] = New_Y;
    lines[3][2] = New_X2;
    lines[3][3] = New_Y2;
    
    boolean gotHit = false;
    ArrayList<PVector> hits = new ArrayList<PVector>();
    ArrayList<Integer> e = new ArrayList<Integer>();
    for (var i=0;i<cols.size();i++){
      float colLines[][] = new float[4][4];
      colLines[0][0] = cols.get(i).x;
      colLines[0][1] = cols.get(i).y;
      colLines[0][2] = cols.get(i).x;
      colLines[0][3] = cols.get(i).y+obsSize;
      
      colLines[1][0] = cols.get(i).x+obsSize;
      colLines[1][1] = cols.get(i).y;
      colLines[1][2] = cols.get(i).x+obsSize;
      colLines[1][3] = cols.get(i).y+obsSize;
      
      colLines[2][0] = cols.get(i).x;
      colLines[2][1] = cols.get(i).y;
      colLines[2][2] = cols.get(i).x+obsSize;
      colLines[2][3] = cols.get(i).y;
      
      colLines[3][0] = cols.get(i).x;
      colLines[3][1] = cols.get(i).y+obsSize;
      colLines[3][2] = cols.get(i).x+obsSize;
      colLines[3][3] = cols.get(i).y+obsSize;
      

      for (var n=0;n<colLines.length;n++){
        for (var j=0;j<lines.length;j++){
          if (collideLineLineBool(colLines[n][0], colLines[n][1], colLines[n][2], colLines[n][3], lines[j][0], lines[j][1], lines[j][2], lines[j][3])){
            hits.add(collideLineLine(colLines[n][0], colLines[n][1], colLines[n][2], colLines[n][3], lines[j][0], lines[j][1], lines[j][2], lines[j][3]));
            gotHit = true;
            e.add(i);
          }
        }
      }
    }
    if (gotHit){

      PVector desiredVelocity = new PVector();
      PVector desiredSteeringForce = new PVector();
      PVector acceleration = new PVector();
      desiredVelocity = vecMultF(this.desiredDirection, this.maxSpeed);
      desiredSteeringForce = vecSub(desiredVelocity, this.vel);
      desiredSteeringForce.mult(this.steerStrength);
      acceleration = desiredSteeringForce.copy();
      acceleration.setMag(constrain(acceleration.mag(), 0, this.steerStrength));

      this.vel = vecAdd(this.vel, acceleration);

      this.vel.setMag(constrain(this.vel.mag(), 0, this.maxSpeed));


      this.pos.sub(this.vel.mult(10));
      this.angle = atan2(this.vel.y, this.vel.x);

      this.desiredDirection.mult(-1);

      for (int i=0;i<3;i++){
        desiredVelocity = new PVector();
        desiredSteeringForce = new PVector();
        acceleration = new PVector();
        desiredVelocity = vecMultF(this.desiredDirection, this.maxSpeed);
        desiredSteeringForce = vecSub(desiredVelocity, this.vel);
        //console.log(desiredSteeringForce)
        desiredSteeringForce.mult(1);
        acceleration = desiredSteeringForce.copy();
        acceleration.setMag(constrain(acceleration.mag(), 0, 1));

        this.vel = vecAdd(this.vel, acceleration);

        this.vel.setMag(constrain(this.vel.mag(), 0, this.maxSpeed));


        this.pos.add(this.vel);
        this.angle = atan2(this.vel.y, this.vel.x);
      }

    }




  }

  void update() {
    //this.followMouse();
    this.moveRandom();
    if (showVision) {
      this.showVision();
    }
    if (this.hasFood) {
      if (this.getCoolDown <= 0 && random(0, 1) < 0.85) {
        this.queryThreeLocation();
      }

      this.handleNest();
      //--Lay Pheramone
      if (frameCount % framesUntilPheramone == 0) {
        float data[] = {1, frameCount};
        this.foodPheramoneTree.insert(new Particle(this.pos.x, this.pos.y, data));
      }

      //--
    } else {

      if (this.getCoolDown <= 0 && random(0, 1) < 0.85) {
        this.queryThreeLocation();
      }

      this.handleFood();
      //--Lay Pheramone
      if (frameCount % framesUntilPheramone == 0) {
        float data[] = {1, frameCount};
        this.homePheramoneTree.insert(new Particle(this.pos.x, this.pos.y, data));
      }

      //--
    }

    this.checkCollision();
    PVector desiredVelocity = new PVector();
    PVector desiredSteeringForce = new PVector();
    PVector acceleration = new PVector();
    desiredVelocity = vecMultF(this.desiredDirection, this.maxSpeed);
    desiredSteeringForce = vecSub(desiredVelocity, this.vel);
    desiredSteeringForce.mult(this.steerStrength);
    acceleration = desiredSteeringForce.copy();
    acceleration.setMag(constrain(acceleration.mag(), 0, this.steerStrength));

    this.vel = vecAdd(this.vel, acceleration);
    this.vel.setMag(constrain(this.vel.mag(), 0, this.maxSpeed));


    this.pos.add(this.vel.mult(10));
    this.angle = atan2(this.vel.y, this.vel.x);

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
    this.angle = atan2(this.vel.y, this.vel.x);


    if (this.getCoolDown >= 0){
      this.getCoolDown--;
    }

    
    if (this.stopWanderingTime >= 0){
      this.stopWanderingTime--;
    }
  }
}
