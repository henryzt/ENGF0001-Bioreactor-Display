import java.util.TimerTask;

boolean showGraph = true;
boolean animation = true;

display stirDisplay, heatingDisplay, phDisplay;
circularDisplay stirCirle, heatingCirle, phCirle;
color accent = color(255, 229, 0);
color buttonOver = color(255);
color secondary = color(186, 186, 186);
color background = color(0);
color accentGreen = color(66, 244, 83);
color accentRed = color(244, 66, 66);
color accentBlue = color(0, 225, 255);
color accentOrange = color(255, 148, 0);
color darkGrey = color(50);
int widthDivide, heightDivide;
int stirRealValue = 700;
int stirSetValue = 700;
int lastMouseX = mouseX;
int lastMouseY = mouseY;
display currentPointer;

int graphWidth;
int[] stirGraph;

void setup() {
  size(730, 900);
  widthDivide = width / 10;
  heightDivide = 460 / 7;
  noStroke();
  stirDisplay = new display(widthDivide, heightDivide * 5.2, "Stirring Speed Control","RPM");
  phDisplay = new display(widthDivide, heightDivide *8, "PH Control","pH");
  heatingDisplay = new display(widthDivide, heightDivide * 10.8, "Heating Control","Degree");
 
  stirCirle = new circularDisplay(widthDivide *2.4,heightDivide * 2.4,"RPM",accentGreen, darkGrey);
  phCirle = new circularDisplay(widthDivide *5.25,heightDivide * 2.4,"pH",accentOrange, darkGrey);
  heatingCirle = new circularDisplay(widthDivide *8.1,heightDivide * 2.4,"Degree",accentBlue, darkGrey);


  ellipseMode(CENTER);
  setTimer();
  
  graphWidth = width;
  stirGraph= new int[width];
  
}

void draw() {
  background(0);
  
  if(showGraph){
    for(int i = 1; i < graphWidth; i++) { 
      stirGraph[i-1] = stirGraph[i]; 
    } 
    // Add the new values to the end of the array 
    stirGraph[graphWidth-1] = stirRealValue; 
    
    stirDisplay.updateGraph(stirGraph,1500, accentGreen);
    phDisplay.updateGraph(stirGraph,1500, accentOrange);
    heatingDisplay.updateGraph(stirGraph,1500, accentBlue);  
  }
  
  
  if(abs(stirRealValue - stirSetValue)> 20){
    if(stirRealValue > stirSetValue){
      stirDisplay.setStatus("Decreasing...", accentRed,accentRed);
    }else{
      stirDisplay.setStatus("Increasing...", accentRed,accentRed);
    }
  }else{
    stirDisplay.setStatus("Updating...", accentGreen,accent);
  }
  
 
  stirDisplay.update(stirRealValue, stirSetValue);
  heatingDisplay.update(24,27);
  phDisplay.update(4,5);
  
  heatingDisplay.setStatus("Not Connected", secondary,darkGrey);
  phDisplay.setStatus("Not Connected", secondary,darkGrey);
  
  stirCirle.update(stirRealValue,stirSetValue, 1500, false);
  heatingCirle.update(27,30,35,false);
  phCirle.update(4,5,7,false);

}

void mousePressed() {
  if (stirDisplay.bPlus.over) {
    changeSetValue(stirDisplay, stirSetValue +10);
 
  }
  if (stirDisplay.bMinus.over) {
    changeSetValue(stirDisplay, stirSetValue -10);
  }
}

void mouseDragged() {
  if (stirCirle.over){
      if(mouseY > lastMouseY){
        changeSetValue(stirDisplay, stirSetValue - 10);
      }
      if(mouseY < lastMouseY){
        changeSetValue(stirDisplay, stirSetValue + 10);
      }
      
    
    lastMouseY = mouseY;
    stirCirle.setDelay = 50;
    stirCirle.update(stirRealValue,stirSetValue, 1500, true);
  }
  
}


void keyPressed(){
  if(stirDisplay.over){
    currentPointer = stirDisplay;
  }else if(phDisplay.over){
    currentPointer = phDisplay;
  }else if(heatingDisplay.over){
    currentPointer = heatingDisplay;
  }
  
  if(key == 'a'){
    animation = !animation;
  }
  
  if(key == 'g'){
    showGraph = !showGraph;
  }
  
  if(currentPointer != null){
    if ((key >= '0' && key <= '9') || key == '.') {
      currentPointer.updateText(key);
      
    }
    

    
    if(keyCode == BACKSPACE){
      currentPointer.deleteText();
    }
    
    if(keyCode == UP){
       changeSetValue(currentPointer, stirSetValue + 1);
    }
    if(keyCode == DOWN){
       changeSetValue(currentPointer, stirSetValue - 1);
    }
    if(keyCode == LEFT){
       changeSetValue(currentPointer, stirSetValue - 10);
    }
    if(keyCode == RIGHT){
       changeSetValue(currentPointer, stirSetValue + 10);
    }
    
    if(keyCode == ENTER){
      String newText = currentPointer.confirmText();
      if(!newText.equals("")){
        float newValue = parseFloat(newText);
        
        if( currentPointer == stirDisplay){
             changeSetValue(stirDisplay, newValue);
        }
          
          
      }
    }
      
  }
  
  

    
    
  }
  
  
  void changeSetValue(display display, float value){
    
    if(display == stirDisplay){
      if(value <= 1500 && value >= 500){
        stirSetValue = (int) value;
      }
    }
    
  }
  



void setTimer(){ //for simulation
  
  //ref:https://stackoverflow.com/questions/17397259/how-to-do-an-action-in-periodic-intervals-in-java
   
   java.util.Timer scoreTimer = new java.util.Timer();
        scoreTimer.schedule(new TimerTask() {

            @Override
            public void run() {
                stirRealValue = (int) random(stirSetValue - 30,stirSetValue +30);
            }
      }, 100, 500);
        
}



class button{
  int size = 50;
  float x,y;
  int sign;
  boolean over = false;
  //String usage;
  //sign: 0 for -,  1 for +
  
  button(float xi, float yi, int signi){
    x = xi;
    y = yi;
    sign = signi;
    
  }
  
  void update(){
    float disX = x - mouseX;
    float disY = y - mouseY;
    if (sqrt(sq(disX) + sq(disY)) < size/2 ) {
      fill(buttonOver);
      over = true;
    } else {
      fill(accent);
      over =  false;
    }
    
    ellipse(x, y, size, size);
    
    String signText;
    
    if(sign == 0){
      signText = "-";
    }else{
      signText = "+";
    }
    
    textSize(30);
    textAlign(CENTER,CENTER);
    fill(background);
    text(signText,x +1,y - 7);
    

    
  }
    
  
  
}




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






class display{
  float x, y;
  float h = heightDivide *2.7;
  String title, unit, status = "Updating...";
  int i = 30; 
  boolean plus = true;
  color statusColor = accentGreen, realValueColor = accent;
  button bMinus, bPlus;
  
  boolean over = false;
  boolean editing = true;
  String activeEdit = "";

  
    display(float xi,float yi, String titlei, String uniti){
      x=xi;
      y=yi;
      title = titlei;
      unit = uniti;
      
      bMinus = new button(widthDivide * 6.6, y+heightDivide *1.45, 0);
      bPlus = new button(widthDivide * 8.8, y+heightDivide *1.45, 1);
    }
    
    void update(int realValue, int setValue){
     
      if(mouseY > y - 30 && mouseY < y + heightDivide * 2.3){
        fill(50,140);
        rect(0,y - 35,width, h+6);
        //currentPointer = display.this;
        over = true;
      }else{
        editing = false;
        currentPointer = null;
        activeEdit = "";
        over = false;
      }
      
      
      
      textAlign(LEFT);
      textSize(25);
      fill(secondary);
      text(title,x,y + 13);
      
      textSize(100);
      fill(realValueColor);
      text(realValue,x,y + heightDivide * 1.8);
      float valueWidth = textWidth(Integer.toString(realValue));
      
      
      textSize(20);
      fill(secondary);
      text(unit,x + valueWidth + 10, y + heightDivide *1.8);
      
      textAlign(CENTER);
      textSize(35);
      
      
      if(editing){
        
          fill(accentGreen, 255-map(millis()%1000,200,0,0,300));
          println(millis()%1000);
          println(millis());
        
        text(activeEdit, widthDivide * 7.7, y+ heightDivide *1.6);
      }else{
        if(over){
          fill(accentGreen);
        }
        text(setValue, widthDivide * 7.7, y+ heightDivide *1.6);
      }
      
      
      
      
      updateSlider();
      
      bPlus.update();
      bMinus.update();
      
      
      
      
      
    }
    
    void updateSlider(){
      float xs = widthDivide * 6.2;
      float ys = y + heightDivide * 0.6;
      float ws = widthDivide *3;
      float hs = 4;
      
      fill(secondary);
      rect(xs, ys, ws, hs);
      
      
      
      //int j = 0;
      if(plus == true){
        i++;
      }else{
        i--;
      }
      
      if(i > ws /2){
        plus = false;
      }
      if(i <= 30 ){
        plus = true;
      }
      
        
      fill(statusColor);
      rect(xs + i -30, ys,  i +30, hs);
      
      textAlign(CENTER);
      textSize(18);
      fill(statusColor, 255-(i - 30)*2);
      text(status, xs + ws/2, y + 30);
      
      
    }
    
    void setStatus(String text, color statusColor, color valueColor){
      status = text;
      this.statusColor = statusColor;
      this.realValueColor = valueColor;
    }
    
    void updateText(char append){
        editing = true;
        if(activeEdit.length() < 5){
          if(activeEdit.equals("0")){
            activeEdit = "";
          }
          activeEdit = activeEdit + append;
        }
        //println(activeEdit);

    }
    
    void deleteText(){
      if(editing){
          if(activeEdit.length() == 1 ){
            activeEdit = "0";
          }else{
            activeEdit = activeEdit.substring(0, activeEdit.length()-1);
          }
        }
    }
    
    String confirmText(){
      if(editing){
        String temp = activeEdit;
        activeEdit = "";
        editing = false;
        return temp;
      }
      return "";
      
      
    }
    
    void updateGraph(int[] list, int max, color colour){
      float heightDiv = h/max;
          
        

        for(int i=1; i<graphWidth; i++) {
          //point(i,  y - 31 + h -(heightDiv * list[i]));
          float y1 = y - 31 + h -(heightDiv * list[i-1]);
          float y2 = y - 31 + h -(heightDiv * list[i]);
          
          fill(colour, 30);
          rect(i-1,y1,1,y+h-30-y1);
          strokeWeight(3);
          
          //if(statusColor == accentRed){
          //   stroke(accentRed,30);
          //}else{
            stroke(colour,30);
          //}
         
          line(i-1,y1, i, y2 );
          
          noStroke();
        }
    }
  
}
