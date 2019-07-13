//Import library for using the serial port
import processing.serial.*;

//Declare shapes used for drawing the range finders
PShape FLRange;
PShape FRRange;

//Declare shapes used for drawing the boxes for controling the car
PShape Forward;
PShape Backward;
PShape Left;
PShape Right;
PShape Stop;

//Declare shape for the switch task button
PShape buttons;

//Declare font for the text on the switch task button
PFont switchTask;

//Declare the variable for switching tasks
int task=0;

//Declare array of values sent from the car
int sentValues[];

//Declare the serial port we use to communicate with the arduino
Serial myPort;    

//Setup function, runs once at the start of the program
void setup()
{
  //Setup the size of the screen
  size(640,480);
  
  //Give our serial port a connection to the serial port the arduino is connected to
  myPort = new Serial(this, Serial.list()[1], 9600);
  
  //Declare the dimensions of the shape used to draw what the left range finder sees
  FLRange = createShape();
  FLRange.beginShape();
  FLRange.vertex(0, 0);
  FLRange.vertex(320,200);
  FLRange.vertex(320, 200);
  FLRange.vertex(320, 0);
  FLRange.endShape(CLOSE);
  
  //Declare the dimensions of the shape used to draw what the right range finder sees
  FRRange = createShape();
  FRRange.beginShape();
  FRRange.vertex(640, 0);
  FRRange.vertex(320, 200);
  FRRange.vertex(320, 200);
  FRRange.vertex(320, 0);
  FRRange.endShape(CLOSE);
  
  //Declare the dimensions for the box to indicate forward movement in the control function
  Forward = createShape(RECT,280,10,80,80);
  
  //Declare the dimensions for the box to indicate backwards movement in the control function
  Backward = createShape(RECT,280,390,80,80);
  
  //Declare the dimensions for the box to indicate left movement in the control function
  Left = createShape(RECT,10,200,80,80);
  
  //Declare the dimensions for the box to indicate right movement in the control function
  Right = createShape(RECT,550,200,80,80);
  
  //Declare the dimensions for the box to indicate forward movement in the control function
  Stop = createShape(RECT,280,200,80,80);
  
  //Declare the dimensions for the button for switching tasks
  buttons = createShape(RECT,480,430,160,50);
  //Fill the button with a color so it can be 
  buttons.setFill(100);
  
  //Create a font group with the font style in the folder and a font size of 20
  switchTask = createFont("vga850.fon", 20);
  //Give our text the font group we just created
  textFont(switchTask);
  
  
  
  
}

//Draw the rectangle at the bottom seen in the view task
void bottomRect()
{
  line(0,430,640,430);
  
}

//Draw the robot seen in the view task
void robot()
{
  rect(300,200,40,40);
}

//Draw the line representing the field of view for the range finders seen in the view task
void rangeFinders()
{
  line(0,0,320,200);
  line(320,0,320,200);
  line(640,0,320,200);
}

//Function to reset the boxes seen in control to the unpressed state 
void controlBlank()
{
  //Fill them to the default color
  Forward.setFill(255);
  Left.setFill(255);
  Right.setFill(255);
  Backward.setFill(255);
  Stop.setFill(255);
}

//Function to read values sent from arduino
void readFromArduino()
{
  //Create a string and read the value sent by the arduino until it comes to '>', the endline character
  String read = myPort.readStringUntil('>');
  //While nothing was read from the arduino
  while(read==null)
  {
    //Read the value sent by the arduino until it comes to '>', the endline character
    read = myPort.readStringUntil('>');
  }
  //Split the values in the read string into an array for easy access
  sentValues=(int(split(read,',')));
  //Since the range finders have some uncertainty, use only the 1st digit, as those seem to be consistant
  sentValues[0]/=100;
  sentValues[1]/=100;
}

//Function for manual control
void control()
{
  //Draw the shapes indicating the direction the robot is moving
  shape(Forward);
  shape(Backward);
  shape(Left);
  shape(Right);
  shape(Stop);
  //Draw the button
  shape(buttons);
  buttons.setFill(200);
  //Write the text on the button so the user knows to press it to switch functions
  text("Switch Task", 510, 462);
  //While processing and arduino and connected over serial
  if(myPort.read()>0)
  {
    //If a coded keyboard button is pressd
    if (key == CODED) 
    {
      //If the up button is pressed
      if (keyCode == UP) 
      {
        //Write to the program to tell the car to move in the selected direction
        myPort.write('1');
        //Reset all of the direction indicators
        controlBlank();
        //Fill the indicator box so the user sees which direction the car is going
        Forward.setFill(200);
      } 
      //If the left button is pressed
      else if (keyCode == LEFT) 
      {
        //Write to the program to tell the car to move in the selected direction
        myPort.write('3');
        //Reset all of the direction indicators
        controlBlank();
        //Fill the indicator box so the user sees which direction the car is going
        Left.setFill(200);
      }
      //If the right button is pressed
      else if (keyCode == RIGHT) 
      {
        //Write to the program to tell the car to move in the selected direction
        myPort.write('4');
        //Reset all of the direction indicators
        controlBlank();
        //Fill the indicator box so the user sees which direction the car is going
        Right.setFill(200);
      }
      //If the down button is pressed
      else if (keyCode == DOWN) 
      {
        //Write to the program to tell the car to move in the selected direction
        myPort.write('2');
        //Reset all of the direction indicators
        controlBlank();
        //Fill the indicator box so the user sees which direction the car is going
        Backward.setFill(200);
      }
    } 
    //If any other button is pressed
    else 
    {
      //Write to the program to tell the car to stop
      myPort.write('5');
      //Reset all of the direction indicators
      controlBlank();
      //Fill the indicator box so the user sees the car is not moving
      Stop.setFill(200);
    }
  }
  //If the arduino is not sending anything, it is disconnected
  else
  {
    //Tell the user they are disconnected
    text("Disconnected", 10, 462);
  }
  //If the user moves the mouse into the box and clicks
  if(mouseX>480 && mouseY>430 && mousePressed==true)
  {
    //Blank the box to indicate to the user the box was clicked
    buttons.setFill(0);
    //Tell the program it has switched tasks
    task=0;
    //Tell the car to switch tasks
    myPort.write('6');
    //Wait so the user has time to let go of the button before the task switches. Otherwise, it will switch tasks back and forth while the button is pressed
    delay(100);
  }
}

//Function for viewing what the range finders see
void view()
{
  //Declare variables used to adjust the height according to the range finder's values
  int FLHeight=0;
  int FRHeight=0;
  //Variable to hold a constant needed to calculate the positon of a vertex so the range finder's view can be drawn
  float rangeAngle = atan2(320,200);
  //Draw the objects needed for the program to work
  bottomRect();
  robot();
  rangeFinders();
  //Draw the button used for switching tasks
  shape(buttons);
  buttons.setFill(200);
  //Indicate that the button is used to switch tasks
  text("Switch Task", 510, 462);
  //If the user moves the mouse into the box and clicks
  if(mouseX>480 && mouseY>430 && mousePressed==true)
  {
    //Blank the box to indicate to the user the box was clicked
    buttons.setFill(0);
    //Tell the program it has switched tasks
    task=1;
    //Tell the car to switch tasks
    myPort.write('6');
    //Wait so the user has time to let go of the button before the task switches. Otherwise, it will switch tasks back and forth while the button is pressed
    delay(100);
  }
  //If the arduino is connected
  if(myPort.available()>0)
  {
    //Read values from the arduino
    readFromArduino();
    //Modifying the shape that indicates what the left range finder sees
    //Change the values so that it can be used for the heights of the range finder view
    FLHeight=(200/6)*sentValues[0];
    //Because the left side is tilted on the outermost line, we must use trigonometry to calculate it cooridinates
    FLRange.setVertex(1,(tan(rangeAngle)*FLHeight),FLHeight);
    //Set the coordinates of the right vertex to be at the same height of the left vertex
    FLRange.setVertex(2,320,FLHeight); 
    //Draw in the shape we made so the user sees where the object is
    FLRange.setStroke(255);
    //Modifying the shape that indicates what the right range finder sees
    //Change the values so that it can be used for the heights of the range finder view
    FRHeight=(200/6)*sentValues[1];
    //Because the right side is tilted on the outermost line, we must use trigonometry to calculate it cooridinates
    FRRange.setVertex(1,640-(tan(rangeAngle)*FRHeight),FRHeight);
    //Set the coordinates of the left vertex to be at the same height of the right vertex
    FRRange.setVertex(2,320,FRHeight);
    //Draw in the shape we made so the user sees where the object is
    FRRange.setStroke(255);
    //Draw the shapes with the changes made
    shape(FLRange);
    shape(FRRange);
  }
  //If processing isn't reading anything, the arduino is disconnected
  else
  {
    //Tell the user that arduino is disconnected
    text("Disconnected", 10, 462);
  }
}


void draw()
{
  if(task==0)
  {
    //Clear the screen
    clear();
    //Redraw the background
    background(200);
    //Start the range finder view program
    view();
  }
  else if(task==1)
  {
    //Clear the screen
    clear();
    //Redraw the background
    background(200);
    //Start the manual control program
    control();
  }

}
