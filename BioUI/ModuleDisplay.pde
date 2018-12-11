class button {
  int size = 50;
  float x, y;
  int sign;
  boolean over = false;
  //String usage;
  //sign: 0 for -,  1 for +

  button(float xi, float yi, int signi) {
    x = xi;
    y = yi;
    sign = signi;
  }

  void update() {
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

    if (sign == 0) {
      signText = "-";
    } else {
      signText = "+";
    }

    textSize(30);
    textAlign(CENTER, CENTER);
    fill(background);
    text(signText, x +1, y - 7);
  }
}






class display {
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


  display(float xi, float yi, String titlei, String uniti) {
    x=xi;
    y=yi;
    title = titlei;
    unit = uniti;

    bMinus = new button(widthDivide * 6.6, y+heightDivide *1.45, 0);
    bPlus = new button(widthDivide * 8.8, y+heightDivide *1.45, 1);
  }

  void update(float realValue, float setValue) {

    if (mouseY > y - 30 && mouseY < y + heightDivide * 2.3) {
      fill(50, 140);
      rect(0, y - 35, width, h+6);
      //currentPointer = display.this;
      over = true;
    } else {
      editing = false;
      currentPointer = null;
      activeEdit = "";
      over = false;
    }



    textAlign(LEFT);
    textSize(25);
    fill(secondary);
    text(title, x, y + 13);

    textSize(100);
    fill(realValueColor);
    text(toTwoDP(realValue), x, y + heightDivide * 1.8);
    float valueWidth = textWidth(toTwoDP(realValue));


    textSize(20);
    fill(secondary);
    text(unit, x + valueWidth + 10, y + heightDivide *1.8);

    textAlign(CENTER);
    textSize(35);


    if (editing) {

      fill(accentGreen, 255-map(millis()%1000, 200, 0, 0, 300));
      println(millis()%1000);
      println(millis());

      text(activeEdit, widthDivide * 7.7, y+ heightDivide *1.6);
    } else {
      if (over) {
        fill(accentGreen);
      }
      text(toTwoDP(setValue), widthDivide * 7.7, y+ heightDivide *1.6);
    }




    updateSlider();

    bPlus.update();
    bMinus.update();
  }

  void updateSlider() {
    float xs = widthDivide * 6.2;
    float ys = y + heightDivide * 0.6;
    float ws = widthDivide *3;
    float hs = 4;

    fill(secondary);
    rect(xs, ys, ws, hs);



    //int j = 0;
    if (plus == true) {
      i++;
    } else {
      i--;
    }

    if (i > ws /2) {
      plus = false;
    }
    if (i <= 30 ) {
      plus = true;
    }


    fill(statusColor);
    rect(xs + i -30, ys, i +30, hs);

    textAlign(CENTER);
    textSize(18);
    fill(statusColor, 255-(i - 30)*2);
    text(status, xs + ws/2, y + 30);
  }

  void setStatus(String text, color statusColor, color valueColor) {
    status = text;
    this.statusColor = statusColor;
    this.realValueColor = valueColor;
  }

  void updateText(char append) {
    editing = true;
    if (activeEdit.length() < 5) {
      if (activeEdit.equals("0")) {
        activeEdit = "";
      }
      activeEdit = activeEdit + append;
    }
    //println(activeEdit);
  }

  void deleteText() {
    if (editing) {
      if (activeEdit.length() == 1 ) {
        activeEdit = "0";
      } else {
        activeEdit = activeEdit.substring(0, activeEdit.length()-1);
      }
    }
  }

  String confirmText() {
    if (editing) {
      String temp = activeEdit;
      activeEdit = "";
      editing = false;
      return temp;
    }
    return "";
  }

  void updateGraph(float[] list, float setValue, int max, color colour) {
    float heightDiv = h/max;
    float startY = y - 31 + h;

    for (int i=1; i<graphWidth; i++) {
      //point(i,  y - 31 + h -(heightDiv * list[i]));
      
      float y1 = startY -(heightDiv * list[i-1]);
      float y2 = startY -(heightDiv * list[i]);

      fill(colour, 30);
      rect(i-1, y1, 1, y+h-30-y1);
      strokeWeight(3);

      stroke(colour, 30);
      line(i-1, y1, i, y2 );
      
      
      if(i % 20 == 0 && baseline){
        strokeWeight(1);
        stroke(colour, 80);
        line(i, startY - heightDiv * setValue, i + 5, startY - heightDiv * setValue ); // set value baseline 
      }
      
      
      noStroke();
    }
    
  }
}



String toTwoDP(float value) {
  return String.format("%.2f", value);
}
