byte value;

void connectToSerial() {

  String portName = "";
  String[] ports =  Serial.list();
  for (int i = 0; i < ports.length; i++) {
    //in macOS, the port for ardunio will be named usbmodemXXX
    if (ports[i].contains("usbmodem")) {
      portName = ports[i];
      break;
    }
  } 
  if (portName != "") {
    arduinoPort = new Serial(this, portName, 9600);
  } else {
    println("No port Found, please exit the program then enter the portnumber manunally."); 
    arduinoPort = new Serial(this, ports[0], 9600);   //If cannot find port, please change it here.
  }

  print(portName);
}


final int REQUEST_INTERVAL_MS = 500;
final int RESPONSE_MAX_TIME_MS = 50;

int currentTimeMs = 0;
int previousTimeMs = 0;

int requestSentTimeMs = 0;

byte[] getTemperatureRequest = {0x01, 0x00, 0x00, 0x00, 0x00};
byte[] getRpmRequest = {0x02, 0x00, 0x00, 0x00, 0x00};
byte[] getPhRequest = {0x03, 0x00, 0x00, 0x00, 0x00};
//byte[] setTemperatureRequest = {0x04, 0x00, 0x00, 0x12, 0x34};
//byte[] setRpmRequest = {0x05, 0x00, 0x00, 0x12, 0x34};
//byte[] setPhRequest = {0x06, 0x00, 0x00, 0x12, 0x34};
//byte[] invalidRequest1 = {0x00, 0x02, 0x03, 0x04, 0x05};
//byte[] invalidRequest2 = {0x07, 0x02, 0x03, 0x04, 0x05};

byte responseHeader = 0x00;
byte responseBuffer[] = new byte[5];
byte responsePayload[] = new byte[4];

void serialCall() {

  currentTimeMs = millis();
  if (currentTimeMs - previousTimeMs > REQUEST_INTERVAL_MS) {
    arduinoPort.write(getPhRequest);
    arduinoPort.write(getRpmRequest);
    arduinoPort.write(getTemperatureRequest);
    serialSend();
    requestSentTimeMs = millis();
    previousTimeMs = millis();
  }

  currentTimeMs = millis();

  responseBuffer[0] = 0x00;
  responseBuffer[1] = 0x00;
  responseBuffer[2] = 0x00;
  responseBuffer[3] = 0x00;
  responseBuffer[4] = 0x00;

  if (arduinoPort.available() >= 5) {
    if (currentTimeMs - requestSentTimeMs < RESPONSE_MAX_TIME_MS) {
      for (int i = 0; i < 5; i++) {
        value = (byte) arduinoPort.read();
        responseBuffer[i] = value;
      }


      responseHeader = responseBuffer [0];
      for (int i = 0; i < 4; i++) {
        responsePayload[i] = responseBuffer[i+1];
      }



      float f = ByteBuffer.wrap(responsePayload)
        .order(ByteOrder.LITTLE_ENDIAN)
        .getFloat();

      switch(responseHeader) {
      case 0x01:
        heatingRealValue = f;
        break;
      case 0x02:
        stirRealValue = f;
        break;
      case 0x03:
        phRealValue = f;
        break;
      default:
        break;
      }
      
      println(f);
    }
  }
}

void serialSend() {
  arduinoPort.write(getRequestBuffer((byte) 0x04, heatingSetValue));
  arduinoPort.write(getRequestBuffer((byte) 0x05, stirSetValue));
  arduinoPort.write(getRequestBuffer((byte) 0x06, phSetValue));
}

byte[] getRequestBuffer(byte header, float value) {
  byte[] payload = floatToByteArray(value);
  byte[] buffer = new byte[5];
  buffer[0] = header;
  for (int i = 0; i < 4; i++) {
    buffer[i + 1] = payload [i];
  }

  return buffer;
}

byte[] floatToByteArray(float value) {
  return ByteBuffer.allocate(4)
    .order(ByteOrder.LITTLE_ENDIAN)
    .putFloat(value).array();
}
