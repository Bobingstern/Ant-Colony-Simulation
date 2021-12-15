class Circle {
  float x, y, r, rSquared;
  Circle(float x, float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.rSquared = this.r * this.r;
  }

  boolean contains(Particle point) {
    // check if the point is in the circle by checking if the euclidean distance of
    // the point and the center of the circle if smaller or equal to the radius of
    // the circle
    float d = pow((point.x - this.x), 2) + pow((point.y - this.y), 2);
    return d <= this.rSquared;
  }

  boolean intersects(Rectangle range) {

    float xDist = abs(range.x - this.x);
    float yDist = abs(range.y - this.y);

    // radius of the circle
    float r = this.r;

    float w = range.w / 2;
    float h = range.h / 2;

    float edges = pow((xDist - w), 2) + pow((yDist - h), 2);

    // no intersection
    if (xDist > (r + w) || yDist > (r + h))
      return false;

    // intersection within the circle
    if (xDist <= w || yDist <= h)
      return true;

    // intersection on the edge of the circle
    return edges <= this.rSquared;
  }
}



class QuadTree {
  Rectangle boundary;
  ArrayList<Particle> particles;
  int capacity;
  Boolean isDivided;

  QuadTree northEast, northWest, southEast, southWest;

  QuadTree(Rectangle boundary, int n) {
    this.boundary = new Rectangle(boundary);
    this.capacity = n;
    this.particles = new ArrayList<Particle>();
    this.isDivided = false;
  }

  void subdivide() {
    float x = this.boundary.x;
    float y = this.boundary.y;
    float w = this.boundary.w * 0.5;
    float h = this.boundary.h * 0.5;

    Rectangle ne = new Rectangle(x + w, y - h, w, h);
    northEast = new QuadTree(ne, this.capacity);
    Rectangle nw = new Rectangle(x - w, y - h, w, h);
    northWest = new QuadTree(nw, this.capacity);
    Rectangle se = new Rectangle(x + w, y + h, w, h);
    southEast = new QuadTree(se, this.capacity);
    Rectangle sw = new Rectangle(x - w, y + h, w, h);
    southWest = new QuadTree(sw, this.capacity);
    isDivided = true;
  }

  Boolean insert(Particle point) {
    if (!this.boundary.contains(point)) {
      return false;
    }

    if (particles.size() < this.capacity) {
      ArrayList<Particle> close = new ArrayList<Particle>();
      close = queryCircle(new Circle(point.x, point.y, 2.6), close);
      if (close.size() == 0){
        particles.add(point);
      }
      else{
        
          close.get(0).data[1] = frameCount; 
        
       
      }
      
      return true;
    } else {
      if (!isDivided) {
        subdivide();
      }
      if (northEast.insert(point)) {
        return true;
      } else if (this.northWest.insert(point)) {
        return true;
      } else if (this.southEast.insert(point)) {
        return true;
      } else if (this.southWest.insert(point)) {
        return true;
      }
    }
    return false;
  }

  ArrayList<Particle> query(Rectangle range, ArrayList<Particle> found) {
    if (found == null) {
      found = new ArrayList<Particle>();
    }
    if (this.boundary.intersects(range)) {

      for (Particle p : particles) {
        if (range.contains(p)) {
          found.add(p);
        }
      }
      if (isDivided) {
        northWest.query(range, found);
        northEast.query(range, found);
        southWest.query(range, found);
        southEast.query(range, found);
      }
    }
    return found;
  }
  ArrayList<Particle> queryCircle(Circle range, ArrayList<Particle> found) {
    if (found == null) {
      found = new ArrayList<Particle>();
    }
    if (this.boundary.intersectsCircle(range)) {

      for (Particle p : particles) {
        if (range.contains(p)) {
          found.add(p);
        }
      }
      if (isDivided) {
        northWest.queryCircle(range, found);
        northEast.queryCircle(range, found);
        southWest.queryCircle(range, found);
        southEast.queryCircle(range, found);
      }
    }
    return found;
  }
  ArrayList<Particle> getAllPoints(){
    return particles;
  }
  
  void remove(Particle point){
    for (int i=particles.size()-1;i>=0;i--){
      if (point.x == particles.get(i).x && point.y == particles.get(i).y){
        particles.remove(i);
      }
    }
    
    
  }

  void show() {
    stroke(255);
    strokeWeight(0.5);
    noFill();
    rectMode(CENTER);
    rect(boundary.x, boundary.y, boundary.w * 2, boundary.h * 2);
    if (isDivided) {
      this.northEast.show();
      this.northWest.show();
      this.southEast.show();
      this.southWest.show();
    }
    stroke(255, 0, 100);
    strokeWeight(2);
    for (Particle p : particles) {
      point(p.x, p.y);
    }
  }
}
