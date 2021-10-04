#include <WaspFrame.h>
#include <WaspSD.h>

// define variable
uint8_t error;


// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE1.TXT";
char* time_date; // stores curent date + time
// define an example string
int data;


// define variable
uint8_t sd_answer;
int sentence=0;   // 1 for deletion on reboot  , anything else for data appended to fiel only
bool IRL_time= true;  //  true for no external data source



void setup()
{
  // open USB port
  USB.ON();
  RTC.ON(); // Executes the init process
  if( IRL_time)
  {
    // Setting date and time [yy:mm:dd:dow:hh:mm:ss]
    RTC.setTime("21:02:01:02:00:00:00");
  }
  else
  {
    //ceva primire de data aici
  }

  USB.println(F("SD_arhive_V1"));
  
  // Set SD ON
  SD.ON();

    if ( sentence==1) 
    {
        // Delete file
        sd_answer = SD.del(filename);
  
       if( sd_answer == 1 )
       {
        USB.println(F("file deleted"));
       }
       else 
       {
        USB.println(F("file NOT deleted"));  
       }
         // Create file
         sd_answer = SD.create(filename);
  
         if( sd_answer == 1 )
         {
           USB.println(F("file created"));
         }
         else 
         {
           USB.println(F("file NOT created"));  
         } 
  
    }
      sd_answer = SD.appendln(filename,  "----------------------------------------------------------------------------" );

//pm
USB.ON();
}


void loop()
{
  USB.ON();
  SD.ON();


  // create new frame
  frame.createFrame(BINARY, "ceva id");  // farame de trimis 
  

  // add frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
 // data is sent here
    frame.showFrame();



 //frame for local storage
   frame.createFrame(ASCII, "ceva id");
  // add frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 


  time_date = RTC.getTime(); 
  USB.print(F("time: "));
  USB.println(time_date);  
  sd_answer = SD.append(filename, time_date);
  //USB.println("random1");
  sd_answer = SD.append(filename,  "  " );
  //USB.println("random2");
  sd_answer = SD.append(filename,  frame.buffer , frame.length );
  sd_answer = SD.append(filename,  "  " );
  sd_answer = SD.appendln(filename,  "ceva data de scris vin aici " );
  //USB.println(RTC.year);
  USB.println("random4");
  SD.OFF();
  USB.OFF();
  

delay(66600);
  

  //PWR.deepSleep("00:00:00:20", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
}
