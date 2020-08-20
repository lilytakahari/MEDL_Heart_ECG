// PROGRAM OVERVIEW:
// Graphs the analog input as the Arduino receives it. A graph will show up on screen.
// After around 40 seconds, the program terminates and a csv file is created
// in the same folder as this file with the received data and the time at which
// the data was received.
// The csv file is created using Table objects.
//
// HOW TO RUN THE PROGRAM WITH ARDUINO:
// 1. Open the Arduino IDE.
// 2. In Files > Examples > Firmata, open StandardFirmata and upload it to the Arduino.
// 3. Open this file in Processing.
// 4. Press Run. 

// import necessary modules
import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;

// create necessary objects

// Arduino object
Arduino arduino;

// table object, and string object for file name
Table table;
String fileName;

long start; // keeps track of when program started

final int pinInput = 0; // establish which pin is the input

// vertical limits for graphing
final float maxHeight = 450;
final float minHeight = 50;

float[] serialArray = new float[1000]; // array to store input readings
float valInput = 0; // create global valInput variable
long numInputs = 0; // keep track of inputs
int startingX = 0;  // keep track of which x location to start graphing from

// this function runs once at the start of the program
void setup() {
  size(1000, 500);  // establish size of graph
  
  // figure out which port the Arduino is, and change the list index as necessary
  printArray(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[3], 57600);
  
  // set the pin mode to input
  arduino.pinMode(pinInput, Arduino.INPUT);
  
  // create the table and its labels
  table = new Table();
  table.addColumn("Time (s)");
  table.addColumn("Input Reading");
  
  // color the background and draw the background lines
  background(19, 28, 20);
  drawLines();
 
  // set graphing stroke color and weight
  stroke(0, 255, 0);
  strokeWeight(4);
  
  // record the start of the program
  start = millis();
}

// this function runs infinitely
void draw() {
  // if 40 seconds have passed since the start of the program,
  // save the table to a file and terminate
  if ((millis() - start) >= 40 * 1000) {
    fileName = "ECG_" + str(month()) + str(day()) + ".csv";
    saveTable(table, fileName);
    exit();
  }
  
  // lots of graphing code that doesn't need to be specifically understood
  // it's essentially just plotting the data stored in the array
  if (numInputs > width) {
    background(19, 28, 20);
    drawLines();
    stroke(0, 255, 0);
    strokeWeight(4);
    int x1 = 0;
    int x2 = 0;
    for (int i = startingX + 1; i < width; i++) {
      line(x1, height - serialArray[i-1], x2, height - serialArray[i]);
      x1++;
      x2++;
    }
    if (startingX != 0) {
      for (int i = 1; i < startingX; i++) {
        line(x1, height - serialArray[i-1], x2, height - serialArray[i]);
        x1++;
        x2++;
      }
    }
  }
  
  // this code corresponds to adding a new pair of data, time and input reading
  TableRow newRow = table.addRow(); // create a new row in the table
  valInput = (float)(arduino.analogRead(pinInput)); // receive the input value from Arduino
  // record the time and input
  newRow.setFloat("Time (s)", (millis() - start) * 0.001);
  newRow.setFloat("Input Reading", valInput);
  
  // println(valInput);  // print statement for debugging
  
  // map the input value to one suitable for graphing
  valInput = map(valInput, 0, 1023, minHeight, maxHeight);
  serialArray[startingX] = valInput; // store the input value in the array
  // more graphing code
  if (numInputs < width && startingX >= 1) {
     line(startingX - 1, height - serialArray[startingX-1], startingX, height - serialArray[startingX]);
  }
  startingX++;
  numInputs++;
  if (startingX >= width) {
    startingX = 0;
  }
}

// draws the background lines
void drawLines() {
  float[] lines = new float[6];
  int i = 0;
  for (int y = 0; y <= 1023; y += 200) {
    lines[i] = height - map(y, 0, 1023, minHeight, maxHeight);
    i++;
  }
  stroke(0, 100, 0);
  strokeWeight(1);
  for (int j = 0; j < 6; j++) {
    line(0, lines[j], width, lines[j]);
  } 
}
