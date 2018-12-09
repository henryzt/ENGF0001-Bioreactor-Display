import processing.serial.*;
import java.nio.ByteOrder;
import java.nio.ByteBuffer;

Serial arduinoPort;  // Create object from Serial class

display stirDisplay, heatingDisplay, phDisplay;
circularDisplay stirCirle, heatingCirle, phCirle;
display currentPointer;   //the current display mouse cursor is on

int widthDivide, heightDivide;  //divide h & w into parts, for putting the components
int lastMouseX = mouseX;
int lastMouseY = mouseY;

int graphWidth;
float[] stirGraph;  //store history values to plot the graph
float[] heatingGraph;
float[] phGraph;

float stirRealValue = 0; //0 for not connected
float stirSetValue = 700;
float phRealValue = 0;
float phSetValue = 5;
float heatingRealValue = 0;
float heatingSetValue = 25.0;

void setup() {
  size(900, 900);
  widthDivide = width / 10;
  heightDivide = 460 / 7;
  noStroke();
 
  connectToSerial();
  
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
  stirGraph= new float[width];
  phGraph= new float[width];
  heatingGraph= new float[width];
  
  ellipseMode(CENTER);
  setTimer(); //for test, delete later
  
  
  
}

void draw() {
  background(0);
  serialCall();
  
  //----------------------draw graphs----------------------
  if(showGraph){
    for(int i = 1; i < graphWidth; i++) { 
      stirGraph[i-1] = stirGraph[i]; 
      phGraph[i-1] = phGraph[i]; 
      heatingGraph[i-1] = heatingGraph[i]; 
    } 
    // Add the new values to the end of the array 
    stirGraph[graphWidth-1] = stirRealValue; 
    phGraph[graphWidth-1] =  phRealValue; 
    heatingGraph[graphWidth-1] =  heatingRealValue; 
    
    stirDisplay.updateGraph(stirGraph, stirSetValue, 1500, accentGreen);
    phDisplay.updateGraph(phGraph, phSetValue, 7, accentOrange);
    heatingDisplay.updateGraph(heatingGraph, heatingSetValue, 35, accentBlue);  
  }
  
  
  //----------------------setting stir display status (with in the acceptable range or not) ---------------------- 

  checkRangeAndUpdate(stirDisplay);
  checkRangeAndUpdate(phDisplay);
  checkRangeAndUpdate(heatingDisplay);

  
 
  //----------------------update displays---------------------- 
  stirDisplay.update(stirRealValue, stirSetValue);
  heatingDisplay.update(heatingRealValue, heatingSetValue);
  phDisplay.update(phRealValue, phSetValue);
  

  
  
  //----------------------update circular displays---------------------- 
  stirCirle.update(stirRealValue,stirSetValue, 1500, false);
  heatingCirle.update(heatingRealValue,heatingSetValue,35,false);
  phCirle.update(phRealValue,phSetValue,7,false);

}

//===============check range and update display status===============
void checkRangeAndUpdate(display display){
  float realValue = -1, setValue = -1, diff = 0;
   if(display == stirDisplay){
     realValue = stirRealValue;
     setValue = stirSetValue;
     diff = 20;
   }
   if(display == heatingDisplay){
     realValue = heatingRealValue;
     setValue = heatingSetValue;
     diff = 0.5;
   }  
   if(display == phDisplay){
     realValue = phRealValue;
     setValue = phSetValue;
     diff = 0;
   }
   
  if(realValue == 0){
      display.setStatus("Not Connected", secondary,darkGrey);
      return;
  }
   
  if(abs(realValue - setValue)> diff){
      if(realValue > setValue){
        display.setStatus("Decreasing...", accentRed,accentRed);
      }else{
        display.setStatus("Increasing...", accentRed,accentRed);
      }
    }else{
      display.setStatus("Updating...", accentGreen,accent);
    }


}

//===============mouse press function for buttons in the display===============
void mousePressed() {
  updateCurrentDisplayPointer();
  if(currentPointer != null){
    if (currentPointer.bPlus.over) {
      stepChangeSetValue(currentPointer,true,true);
   
    }
    if (currentPointer.bMinus.over) {
      stepChangeSetValue(currentPointer,false,true);
    }
  }
}


//===============mouse drag function on the circular display===============
void mouseDragged() {
  
    updateCircularDisplay(stirDisplay, stirCirle, stirRealValue, stirSetValue, 1500);
    updateCircularDisplay(heatingDisplay, heatingCirle, heatingRealValue, heatingSetValue, 35);
    updateCircularDisplay(phDisplay, phCirle, phRealValue, phSetValue, 7);
  
}

void updateCircularDisplay(display mainDisplay, circularDisplay circular, float realValue, float setValue, float max){
  if (circular.over){
    if(mouseY > lastMouseY){
        stepChangeSetValue(mainDisplay,false,true);
      }
      if(mouseY < lastMouseY){
        stepChangeSetValue(mainDisplay,true,true);
      }
  
      lastMouseY = mouseY;
      circular.setDelay = 50;
      circular.update(realValue,setValue, max, true);
  }
}

//=============== setting the current display mouse is over ===============
void updateCurrentDisplayPointer(){

  if(stirDisplay.over){
    currentPointer = stirDisplay;
  }else if(phDisplay.over){
    currentPointer = phDisplay;
  }else if(heatingDisplay.over){
    currentPointer = heatingDisplay;
  }
}



void keyPressed(){
  
  updateCurrentDisplayPointer();
  
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
       stepChangeSetValue(currentPointer,true,false);
    }
    if(keyCode == DOWN){
       stepChangeSetValue(currentPointer,false,false);
    }
    if(keyCode == RIGHT){
       stepChangeSetValue(currentPointer,true,true);
    }
    if(keyCode == LEFT){
       stepChangeSetValue(currentPointer,false,true);
    }
    
    if(keyCode == ENTER){
      String newText = currentPointer.confirmText();
      if(!newText.equals("")){
        float newValue = parseFloat(newText);
        changeSetValue(currentPointer, newValue);

      }
    }  //ENTER for confirming editing
      
  }
  

}


//=============== step change set value (add or sub a certain value) ==================
void stepChangeSetValue(display display, boolean addition, boolean big){
  float stirStepBig = 10, phStepBig = 0.5, heatingStepBig = 1;
  float stirStepSmall = 1, phStepSmall = 0.1, heatingStepSmall = 0.5;
  float finalChange = 0;
  float valueBeforeChange = 0;
  if(display == stirDisplay){
    valueBeforeChange = stirSetValue;
    if(big){
      finalChange = stirStepBig;
    }else{
      finalChange = stirStepSmall;
    }
  } 
  if(display == phDisplay){
    valueBeforeChange = phSetValue;
    if(big){
      finalChange = phStepBig;
    }else{
      finalChange = phStepSmall;
    }
  }
  if(display == heatingDisplay){
    valueBeforeChange = heatingSetValue;
    if(big){
      finalChange = heatingStepBig;
    }else{
      finalChange = heatingStepSmall;
    }
  }
  
  if(!addition){
    finalChange = - finalChange;
  }
  
  changeSetValue(display, valueBeforeChange + finalChange);
  
}



//===============funtion to check the set value and set it if it is within the correct range===============
void changeSetValue(display display, float value){
  
  if(display == stirDisplay){
    if(value <= 1500 && value >= 500){
      stirSetValue = value;
    }
  }
  
  if(display == phDisplay){
    if(value <= 7 && value >= 3){
      phSetValue = value;
    }
  }
  
  if(display == heatingDisplay){
    if(value <= 35 && value >= 25){
      heatingSetValue = value;
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
                heatingRealValue = random(heatingSetValue - 1,heatingSetValue + 1);
                phRealValue = random(phSetValue - 1,phSetValue + 1);
            }
      }, 100, 1000);
        
}
