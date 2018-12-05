
display stirDisplay, heatingDisplay, phDisplay;
circularDisplay stirCirle, heatingCirle, phCirle;
display currentPointer;   //the current display mouse cursor is on

int widthDivide, heightDivide;  //divide h & w into parts, for putting the componets
int lastMouseX = mouseX;
int lastMouseY = mouseY;

int graphWidth;
int[] stirGraph;  //store history values to plot the graph

void setup() {
  size(730, 900);
  widthDivide = width / 10;
  heightDivide = 460 / 7;
  noStroke();
  
  //declare displays (control for each module, 3 in total)
  stirDisplay = new display(widthDivide, heightDivide * 5.2, "Stirring Speed Control", "RPM");
  phDisplay = new display(widthDivide, heightDivide *8, "PH Control", "pH");
  heatingDisplay = new display(widthDivide, heightDivide * 10.8, "Heating Control", "Degree");
 
  //declare circular displays (visulazation, 3 in total)
  stirCirle = new circularDisplay(widthDivide *2.4, heightDivide * 2.4, "RPM", accentGreen, darkGrey);
  phCirle = new circularDisplay(widthDivide *5.25, heightDivide * 2.4, "pH", accentOrange, darkGrey);
  heatingCirle = new circularDisplay(widthDivide *8.1, heightDivide * 2.4, "Degree", accentBlue, darkGrey);

  //for graphs below the display
  graphWidth = width;
  stirGraph= new int[width];
  
  ellipseMode(CENTER);
  setTimer(); //for test, delete later
  
}

void draw() {
  background(0);
  
  //----------------------draw graphs----------------------
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
  
  
  //----------------------setting stir display status (with in the acceptabl range or not) ---------------------- 

  if(abs(stirRealValue - stirSetValue)> 20){
    if(stirRealValue > stirSetValue){
      stirDisplay.setStatus("Decreasing...", accentRed,accentRed);
    }else{
      stirDisplay.setStatus("Increasing...", accentRed,accentRed);
    }
  }else{
    stirDisplay.setStatus("Updating...", accentGreen,accent);
  }
  //TODO: CHANGE THIS TO GENERAL FUNCTION LATER
  
  heatingDisplay.setStatus("Not Connected", secondary,darkGrey);
  phDisplay.setStatus("Not Connected", secondary,darkGrey);
  
 
  //----------------------update displays---------------------- (TODO: USE REAL VALUES)
  stirDisplay.update(stirRealValue, stirSetValue);
  heatingDisplay.update(24,27);
  phDisplay.update(4,5);
  

  
  
  //----------------------update circular displays---------------------- (TODO: USE REAL VALUES)
  stirCirle.update(stirRealValue,stirSetValue, 1500, false);
  heatingCirle.update(27,30,35,false);
  phCirle.update(4,5,7,false);

}

//===============mouse press function for buttons in the display===============
void mousePressed() {
  if (stirDisplay.bPlus.over) {
    changeSetValue(stirDisplay, stirSetValue +10);
 
  }
  if (stirDisplay.bMinus.over) {
    changeSetValue(stirDisplay, stirSetValue -10);
  }
}


//===============mouse drag function on the circular display===============
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
  //---------setting the current display mouse is over------
  if(stirDisplay.over){
    currentPointer = stirDisplay;
  }else if(phDisplay.over){
    currentPointer = phDisplay;
  }else if(heatingDisplay.over){
    currentPointer = heatingDisplay;
  }
  
  //---------global key functions------
  if(key == 'a'){
    animation = !animation;
  }
  if(key == 'g'){
    showGraph = !showGraph;
  }
  
  //---------mouse over display functions------
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
    }  //ENTER for confirming editing
      
  }
  

}
  


//===============funtion to check the set value and set it if it is within the correct range===============
void changeSetValue(display display, float value){
  
  if(display == stirDisplay){
    if(value <= 1500 && value >= 500){
      stirSetValue = (int) value;
    }
  }
  
}
  




//===============for testing, delete later===============
void setTimer(){ 
  
  //ref:https://stackoverflow.com/questions/17397259/how-to-do-an-action-in-periodic-intervals-in-java
   
   java.util.Timer scoreTimer = new java.util.Timer();
        scoreTimer.schedule(new TimerTask() {

            @Override
            public void run() {
                stirRealValue = (int) random(stirSetValue - 30,stirSetValue +30);
            }
      }, 100, 1000);
        
}
