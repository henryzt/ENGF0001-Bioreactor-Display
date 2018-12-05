class circularDisplay{
  float x, y;
  String unit;
  color main, secondary, trinary = color(100);
  
  int size = 180;
  int rippleSize = 0;
  boolean over = false;
  int setDelay = 0;
  
  
  circularDisplay(float xi,float yi, String uniti, color maini, color secondaryi){
      x=xi;
      y=yi;
      unit = uniti;
      main = maini;
      secondary = secondaryi;
  }
  
  void update(float realValue, float setValue, float max, boolean setting){
    float percentageReal = realValue/max;
    float percentageSet = setValue/max;
    //arc: x,y,w,h,start-rad,stop-rad
    float setSize = size;
    if(setValue < realValue){
      setSize = size * 1.07;
    }
      
    if(setting || setDelay > 0){
      updateRipple(secondary);
    }else{
      updateRipple(main);
    }
    fill(secondary);
    arc(x,y,size,size,0,TWO_PI);
    
   
    fill(trinary, 100);
    arc(x,y,setSize,setSize,-radians(90),radians(360 * percentageSet - 90));
    
    fill(main);
    arc(x,y,size,size,-radians(90),radians(360 * percentageReal - 90));
    
    
    float disX = x - mouseX;
    float disY = y - mouseY;
    if (sqrt(sq(disX) + sq(disY)) < size/2 ) {
      fill(30);
      over = true;
    } else {
      fill(0);
      over =  false;
    }
    
    arc(x,y,size*0.9,size*0.9,0,2 * PI);
    
    textAlign(CENTER,CENTER);
    textSize(40);
    
    if(setting || setDelay > 0){
      setDelay --;
      fill(secondary);
      text((int)setValue, x, y - 7);
    }else{
      fill(main);
      text((int)realValue, x, y - 7);
    }
    fill(trinary);
    textSize(25);
    text(unit, x, y + 29);
    textAlign(LEFT);
    
  }
  
  
  void updateRipple(color colour){
    if(!animation){
      return;
    }

    fill(colour, 100 - rippleSize);
    arc(x,y,size + rippleSize,size + rippleSize,-radians(90),radians(360 - 90));
    rippleSize++;
    if(rippleSize > 100){
      rippleSize = 0;
    }
    
  }
  
}
