//Include Romeo Motor Control Library
#include <Romeo_m.h>

//Declare variables for range finders
int rangePinL=A2;
int rangePinR=A3;

//Declare variables for wheel speed sensors
int wheelSpeedPinL=A2;
int wheelSpeedPinR=A3;

//Variables for values read from range finders
int range1=0;
int range2=0;

//Variable to hold the mode the program is in
int mode=0;

//Variables for values read from the wheel speed sensors
int speedL=0;
int speedR=0;

//Array for values to be sent through the serial port
int values[]={0,0,0,0,0};

//Declare variables used for finding speeds that allowed both wheels to spin equally
int sentSpeedL=200;
int sentSpeedR=200;

int switchMode=0;

//Function run once by arduino, first function run and used for setup
void setup() 
{
  //Turn on motor control
  Romeo_m.Initialise();
  //Turn on serial communication
  Serial.begin(9600);
}

//Function for controlling the motors
void move(int direction=-1, float magnitude=0)
{ 
   //If the value sent in is 1
   if(direction == 1)
   {
      //Run both motors forwards
      Romeo_m.motorControl(Forward,200,Forward,200);

   }
   //If the value sent in is 2
   else if(direction == 2)
   {
      //Run both motors backwards   
      Romeo_m.motorControl(Reverse,200,Reverse,200);      
   }
   //If the value sent in is 3
   else if(direction == 3)
   {
      //Set the motor directions to turn the car right
      Romeo_m.motorControl(Reverse,200,Forward,200);   
   }
   //If the value sent in is 4
   else if(direction == 4)
   {
      //Set the motor directions to turn the car left
      Romeo_m.motorControl(Forward,200,Reverse,200);
   }
   //If the value sent in is -1
   else if(direction == -1)
   {
      //Turn the motors off
      Romeo_m.motorStop();
   }

}
//Function for serial communication
void serial()
{
  //While in serial mode,check if the user pressed switch task, which would send a 6
  if(Serial.available()>0)
  {
    if(Serial.read()=='6')
    {
      //If a 6 was sent, switch modes to the control function
      switchMode=1;
    }
  }
  //Create a string array
  String list[5];
  //Create a string that will be sent over the serial to processing
  String toSend;

  //Fill the integer array with the values that we want to send
  values[0]=analogRead(rangePinL);
  values[1]=analogRead(rangePinR);
  values[2]=speedL;
  values[3]=speedR;
  values[4]=0;

  //Take the values from the integer array and put it in the string array
  for(int counter=0;counter<=4;counter++)
  {
    list[counter] = String(values[counter]);
  }
  //Take the values from the string array and add them all up into one string
  for(int counter=0;counter<=4;counter++)
  {
    toSend = toSend + list[counter] + ",";
    //At the last number, add a '>' so processing knows where each group of data ends
    if(counter==4)
    {
      toSend = toSend + list[counter] + ">";
    }
  }
  //Print the string to the serial port
  Serial.print(toSend);
  //Wait for the whole string to be sent before continuing
  Serial.flush();
  //Put information in order to be sent to processing
  //Order: rangeFinder1,rangeFinder2,speedL,speedR,mode
 
}
//Function for finding the wheel speed
void wheelSpeed()
{
  int tickL=0;
  int tickR=0;
  int startTime=0;
  int endTime=0;
  int firstTickL=0;
  int firstTickR=0;
  //While the wheel has not moved 1/5 
  while(tickL==0)
  {
    //Find the time in milliseconds 
    startTime=millis();
    //Check if the wheel is blocked by a spoke
    while(analogRead(wheelSpeedPinL)<300)
    {
      //If this is the first time the arduino noticed the block
      if(firstTickL==1)
      {
        //Add 0.2 to the wheel rotation counter
        tickL=tickL+0.2;
        //Tell the arduino that it has counted the spoke and to stop reading until this spoke has passed
        firstTickL=0;
      }
    }
    //Tell the car that the spoke has passed 
    firstTickL=1;
  }
  //Find the time when the spoke passed
  endTime=millis();
  //Calculate the speed of the wheel
  //Wheel has radius of 19cm
  //One tick is 3.8cm
  //3.8/time = wheelSpeed
  speedL=3.8/((endTime-startTime)/1000);
  //Reset the variables so the speed can be calculated again
  tickL=0; 
  startTime=0;
  endTime=0;
  //While the wheel has not moved 1/5 
  while(tickR==0)
  {
    //Find the time in milliseconds 
    startTime=millis();
    //Check if the wheel is blocked by a spoke
    while(analogRead(wheelSpeedPinR)<300)
    {
      //If this is the first time the arduino noticed the block
      if(firstTickR==1)
      {
        //Add 0.2 to the wheel rotation counter
        tickR=tickR+0.2;
        //Tell the arduino that it has counted the spoke and to stop reading until this spoke has passed
        firstTickR=0;
      }
    }
    //Tell the car that the spoke has passed 
    firstTickR=1;
  }
  //Find the time when the spoke passed
  endTime=millis();
  //Calculate the speed of the wheel
  //Wheel has radius of 19cm
  //One tick is 3.8cm
  //3.8/time = wheelSpeed
  speedR=3.8/((endTime-startTime)/1000);
  //Reset the variables so the speed can be calculated again
  tickR=0; 
  startTime=0;
  endTime=0;
}
//Function for controlling the car over serial
void control()
{
  //If the wheels have inequal speed
  if(speedL<speedR || speedL>speedR)
  {
    //If the left wheel has a lower speed
    if(speedL<speedR)
    {
      //If the left wheel is not at max speed
      if(sentSpeedL<200)
      {
        //Speed it up
        sentSpeedL++;
      }
      //If the left wheel is at max speed
      else
      {
        //Slow the right wheel down
        sentSpeedR--;
      }
    }
    //If the right wheel has a lower speed
    if(speedL>speedR)
    {
      //If the right wheel is not a max speed
      if(sentSpeedR<200)
      {
        //Speed it up
        sentSpeedR++;
      }
      //If the right wheel is at max speed
      else
      {
        //Slow the left wheel down
        sentSpeedL--;
      }
    }
  }
  //Indicate to the program that the car is in manual control mode
  Serial.write('C');
  //Declare variable to hold the value sent to the arduino
  int val;
  //Check if any value was sent to the arduino by processing
  if(Serial.available()>0)
  {  
     //If so, save that value to the val variable
     val = Serial.read();
  }
  //Check the values of the val variable
  switch(val)
  {
    //If the user sent a 1
    case '1'://Go forward
    Romeo_m.motorControl(Forward,200,Forward,200);
    break;
    //If the user sent a 2
    case'2'://Go back
    Romeo_m.motorControl(Reverse,200,Reverse,200);
    break;
    //If the user sent a 4
    case'4'://Turn left
    Romeo_m.motorControl(Forward,100,Reverse,200);
    break;
    //If the user sent a 3
    case'3'://Turn right
    Romeo_m.motorControl(Reverse,200,Forward,100);
    break;
    //If the user sent a 5
    case'5'://Stop 
    Romeo_m.motorStop();
    break;
    //If the user sent a 6
    case'6':
    //Indicate to the program that the car is switching modes
    switchMode==0;
    break;
    //If anything else is sent, do nothing
    default: break;
  }
}

//Main looping function
void loop()
{
  //If the car is in serial mode
  if(mode==0)
  {
    //Run the function to check the wheel speed
    wheelSpeed();
    //Run the function for serial output
    serial();
  }
  //If the car is in manual control mode
  if(mode==1)
  {
    //Run the function for manual control
    control();
  }
}
