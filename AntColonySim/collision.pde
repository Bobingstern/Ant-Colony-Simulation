

boolean collideLineLineBool(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4){
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1){
    
    return true;
  }
  return false;
}

PVector collideLineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4){
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  PVector result = new PVector(x1 + (uA * (x2-x1)), y1 + (uA * (y2-y1)));
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1){
    
    return result;
  }
  else{
    return result;
  }

}



boolean collideLineRectBool(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh){
  
   boolean right, left, top, bottom;
   left =   collideLineLineBool(x1,y1,x2,y2, rx,ry,rx, ry+rh);
   right =  collideLineLineBool(x1,y1,x2,y2, rx+rw,ry, rx+rw,ry+rh);
   top =    collideLineLineBool(x1,y1,x2,y2, rx,ry, rx+rw,ry);
   bottom = collideLineLineBool(x1,y1,x2,y2, rx,ry+rh, rx+rw,ry+rh);
   if (left || right || top || bottom){
      return true; 
   }
   return false;
}
