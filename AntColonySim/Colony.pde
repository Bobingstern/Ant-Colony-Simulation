class Colony{
  ArrayList<Ant> colony = new ArrayList<Ant>();
  int colonySize;
  PVector nestPos;
  QuadTree foodPheramoneTree;
  QuadTree homePheramoneTree;
  int Multi = 1;
  ArrayList<Integer> COLOR;
  int[] foodGot = {0};
  int coolDown = 0;
  Colony(float x, float y, int colonySize, ArrayList<Integer> col){
    this.colonySize = colonySize;
    this.nestPos = new PVector(x, y);
    this.COLOR = col;
    

    this.createColony(this.colonySize);
  }
  void createColony(int size) {
    nestSize = width/10;
    //this.nestPos = new PVector(round(width / 2), round(height / 2));
    this.createHomePheramone();

    for (int i = 0; i < size; i++) {
      this.colony.add(new Ant(this.nestPos.x, this.nestPos.y, this.homePheramoneTree, this.foodPheramoneTree, this.nestPos, this.COLOR, foodGot));
    }
  }



  void createHomePheramone() {
    this.homePheramoneTree = new QuadTree(new Rectangle(0, 0, width, height), 1000000000);
    this.foodPheramoneTree = new QuadTree(new Rectangle(0, 0, width, height), 1000000000);
  }


  void updateAll() {
    float t = millis();
    if (frameCount % s == 0 && !pause){on++;}
          
    for (int i = this.colony.size()-1; i >= 0 ; i--) {
      if (!pause){
        
        this.colony.get(i).update();
        if (frameCount % s == 0){
          this.colony.get(i).show(); 
        }
       
      
      }
    }
    println(millis()-t);
  }
  
    
  

  void showNest() {
    fill(197, 147, 45);
    circle(this.nestPos.x, this.nestPos.y, nestSize);
    fill(0, 0, 0);
    textSize(round(nestSize / 5));
    text("Food:"+foodGot[0], this.nestPos.x, this.nestPos.y-nestSize/5);
    text("Colony Size:"+this.colony.size(), this.nestPos.x, this.nestPos.y);
    textAlign(CENTER, CENTER);


  }

  void showFood() {
    if (frameCount % s == 0){
    
    ArrayList<Particle> points = foodTree.getAllPoints();
    for (int i = 0; i < points.size(); i++){
      fill(0, 255, 0);
      circle(points.get(i).x, points.get(i).y, foodSize);
    }
    
    ArrayList<Particle> home = this.homePheramoneTree.getAllPoints();
    for (int i = home.size() - 1; i >= 0; i --) {
      if (showHomePheramone) {
        fill(0, 0, 255);
        //circle(home.get(i).x, home.get(i).y, (home.get(i).data[0] * 2));
        push();
        //stroke(0, 0, 255);
        //point(home.get(i).x, home.get(i).y);
        pop();
      }
      
    }
    
    ArrayList<Particle> food = this.foodPheramoneTree.getAllPoints();
    for (int i = food.size() - 1; i >= 0; i --) {
      if (showFoodPheramone) {
        fill(255, 0, 0);
        //circle(food.get(i).x, food.get(i).y, (food.get(i).data[0] * 2));
        push();
        //stroke(255, 0, 0);
        //point(food.get(i).x, food.get(i).y);
        pop();
      }
      
    }
    }
  }

  void updatePheramone() {
    ArrayList<Particle> home = this.homePheramoneTree.getAllPoints();
    for (int i = home.size() - 1; i >= 0; i --) {
      if (showHomePheramone) {
        fill(0, 0, 255);
        //circle(home.get(i).x, home.get(i).y, (home.get(i).data[0] * 5));
        
      }
      if (frameCount - home.get(i).data[1] >= pheroLife) {
        this.homePheramoneTree.remove(home.get(i));
      }

    }

    ArrayList<Particle> food = this.foodPheramoneTree.getAllPoints();
    for (int i = food.size() - 1; i >= 0; i --) {
      if (showFoodPheramone) {
        fill(255, 0, 0);
        //circle(food.get(i).x, food.get(i).y, (food.get(i).data[0] * 5));
        
      }
      if (frameCount - food.get(i).data[1] >= pheroLife) {
        this.foodPheramoneTree.remove(food.get(i));
      }

    }
  }

  void update() {

    
    
    if (!pause){
      if (frameCount % pheroLife == 0){
       this.updatePheramone();
      }
      if (foodGot[0] - this.coolDown >= 10){
        this.coolDown = foodGot[0];
        for (int i=0;i<10;i++){
          this.colony.add(new Ant(this.nestPos.x, this.nestPos.y, this.homePheramoneTree, this.foodPheramoneTree, this.nestPos, this.COLOR, foodGot));

        }
      }
       
    }

    
    this.showNest();
    this.showFood();
    this.updateAll();
    
  }
}
