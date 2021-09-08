class Colony{
  ArrayList<Ant> colony = new ArrayList<Ant>();
  int colonySize;
  PVector nestPos;
  QuadTree foodPheramoneTree;
  QuadTree homePheramoneTree;
  int Multi = 1;
  ArrayList<Integer> COLOR = new ArrayList<Integer>();
  Colony(float x, float y, int colonySize){
    this.colonySize = colonySize;
    this.nestPos = new PVector(x, y);
    this.COLOR.add(255);
    this.COLOR.add(255);
    this.COLOR.add(0);
    

    this.createColony(this.colonySize);
  }
  void createColony(int size) {
    nestSize = width/10;
    //this.nestPos = new PVector(round(width / 2), round(height / 2));
    this.createHomePheramone();

    for (int i = 0; i < size; i++) {
      this.colony.add(new Ant(this.nestPos.x, this.nestPos.y, this.homePheramoneTree, this.foodPheramoneTree, this.nestPos, this.COLOR));
    }
  }



  void createHomePheramone() {
    this.homePheramoneTree = new QuadTree(new Rectangle(0, 0, width, height), 1000000000);
    this.foodPheramoneTree = new QuadTree(new Rectangle(0, 0, width, height), 1000000000);
  }


  void updateAll() {
    for (int i = 0; i < this.colonySize; i++) {
      if (!pause){
        for (int x=0;x<this.Multi;x++){
          this.colony.get(i).update();
        }
        
      }

      this.colony.get(i).show();
    }
  }

  void showNest() {
    fill(197, 147, 45);
    circle(this.nestPos.x, this.nestPos.y, nestSize);
    fill(0, 0, 0);
    textSize(round(nestSize / 5));
    textAlign(CENTER, CENTER);


  }

  void showFood() {
    ArrayList<Particle> points = foodTree.getAllPoints();
    for (int i = 0; i < points.size(); i++){
      fill(0, 255, 0);
      circle(points.get(i).x, points.get(i).y, foodSize);
    }
    
    ArrayList<Particle> home = this.homePheramoneTree.getAllPoints();
    for (int i = home.size() - 1; i >= 0; i --) {
      if (showHomePheramone) {
        fill(0, 0, 255);
        circle(home.get(i).x, home.get(i).y, (home.get(i).data[0] * 5));
      }
      
    }
    
    ArrayList<Particle> food = this.foodPheramoneTree.getAllPoints();
    for (int i = food.size() - 1; i >= 0; i --) {
      if (showFoodPheramone) {
        fill(255, 0, 0);
        circle(food.get(i).x, food.get(i).y, (food.get(i).data[0] * 5));
      }
      
    }
  }

  void updatePheramone() {
    ArrayList<Particle> home = this.homePheramoneTree.getAllPoints();
    for (int i = home.size() - 1; i >= 0; i --) {
      if (showHomePheramone) {
        fill(0, 0, 255);
        circle(home.get(i).x, home.get(i).y, (home.get(i).data[0] * 5));
      }
      if (frameCount - home.get(i).data[1] >= pheroLife) {
        this.homePheramoneTree.remove(home.get(i));
      }

    }

    ArrayList<Particle> food = this.foodPheramoneTree.getAllPoints();
    for (int i = food.size() - 1; i >= 0; i --) {
      if (showFoodPheramone) {
        fill(255, 0, 0);
        circle(food.get(i).x, food.get(i).y, (food.get(i).data[0] * 5));
      }
      if (frameCount - food.get(i).data[1] >= pheroLife) {
        this.foodPheramoneTree.remove(food.get(i));
      }

    }
  }

  void update() {

    this.showNest();
    this.showFood();
    if (!pause){
      if (frameCount % pheroLife == 0){
       this.updatePheramone();
      }
       
    }

    this.updateAll();
  }
}
