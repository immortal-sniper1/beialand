#include <WaspSensorGas_Pro.h>
#include <WaspFrame.h>
#include <WaspPM.h>
#include <WaspWIFI_PRO.h> 
#include <WaspSD.h>


/*
   Define objects for sensors
   Imagine we have a P&S! with the next sensors:
    - SOCKET_A: BME280 sensor (temperature, humidity & pressure) 
    - SOCKET_B: sensor (CO)
    - SOCKET_C: sensor (NH3)
    - SOCKET_D: Particle matter sensor (dust)
    - SOCKET_E: None
    - SOCKET_F: sensor (CH4)
*/
// define variable SD
// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE1.TXT";


char* time_date; // stores curent date + time
int first_lost,x,b;
char y[3],ssent[7],ssent2[7];
uint8_t sd_answer;
bool sentence=false;   // true for deletion on reboot  , false for data appended to end of file 
bool IRL_time= false;  //  true for no external data source
int  cycle_time,cycle_time2=10;  // in seconds
char rtc_str[]="00:00:00:05";  //11 char ps incepe de la 0
unsigned long prev,previous;





// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET1;
///////////////////////////////////////


// choose URL settings
///////////////////////////////////////
char type[] = "http";
char host[] = "82.78.81.178";
char port[] = "80";
///////////////////////////////////////

uint8_t error;
uint8_t status;

Gas CO(SOCKET_B);
Gas NH3(SOCKET_C);
Gas CH4(SOCKET_F);

float temperature;
float humidity;
float pressure;

float concCO;
float concNH3;
float concCH4;

int OPC_status;
int OPC_measure;

char node_ID[] = "FARM1";









void setup()
{
  // open USB port
  USB.ON();
  RTC.ON(); // Executes the init process
  first_lost=-7;
  if( IRL_time)
  {
    // Setting date and time [yy:mm:dd:dow:hh:mm:ss]
    RTC.setTime("21:02:01:02:00:00:00");
  }
  else
  {
    //ceva primire de data aici
  }

  USB.println(F("SD_arhive_V2"));
  
  // Set SD ON
  SD.ON();

    if ( sentence) 
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

    }
         // Create file IF id doent exist 
         sd_answer = SD.create(filename);
  
         if( sd_answer == 1 )
         {
           USB.println(F("file created"));
         }
         else 
         {
           USB.println(F("file NOT created"));
           USB.println(SD.getFileSize(filename) );
         } 
  
       USB.print("loop cycle time[s]:= ");
       USB.println(cycle_time2 );
      sd_answer = SD.appendln(filename,  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" );

    USB.println(F("Frame Utility Example for Gases Pro Sensor Board"));
    USB.println(F("Sensors used:"));
    USB.println(F("- SOCKET_A: BME280 sensor (temperature, humidity & pressure)"));
    USB.println(F("- SOCKET_B: Electrochemical gas sensor (CO)"));
    USB.println(F("- SOCKET_C: Electrochemical gas sensor (NH3)"));
    USB.println(F("- SOCKET_F: Electrochemical gas sensor (CH4)"));
    USB.println(F("- SOCKET_D: Particle matter sensor (dust)"));
    
    // Set the Waspmote ID
    frame.setID(node_ID);
    //USB.OFF();

//pm
USB.ON();
}










void loop()
{
  prev=millis();
  USB.ON();

      ///////////////////////////////////////////
    // 0. Turn on sensors and wait
    ///////////////////////////////////////////

    //Power on gas sensors
    CO.ON();
    NH3.ON();
    CH4.ON();


    // Sensors need time to warm up and get a response from gas
    // To reduce the battery consumption, use deepSleep instead delay
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    USB.println(RTC.getTime());
    USB.println(F("Enter deep sleep mode to wait for sensors heating time..."));   // maybe add sleep time in here too
    PWR.deepSleep("00:00:00:30", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);    // trebuie sa fie 2 min
    USB.println(RTC.getTime());
    USB.println(F("wake up!!\r\n"));

    ///////////////////////////////////////////
    // 1. Read sensors
    ///////////////////////////////////////////

    // Read the sensors and compensate with the temperature internally
    concCO = CO.getConc();
    concNH3 = NH3.getConc();
    concCH4 = CH4.getConc();

    // Read enviromental variables
    temperature = CO.getTemp();
    //temperature=25;
    humidity = CO.getHumidity();
    pressure = CO.getPressure();

    ///////////////////////////////////////////
    // 2. Turn off the sensors
    ///////////////////////////////////////////

    //Power off sensors
    CO.OFF();
    NH3.OFF();
    CH4.OFF();

    ///////////////////////////////////////////
    // 3. Read particle matter sensor
    ///////////////////////////////////////////

    // Turn on the particle matter sensor
    OPC_status = PM.ON();
    if (OPC_status == 1)
    {
        USB.println(F("Particle sensor started"));
    }
    else
    {
        USB.println(F("Error starting the particle sensor"));
    }

    // Get measurement from the particle matter sensor
    if (OPC_status == 1)
    {
        // Power the fan and the laser and perform a measure of 5 seconds
        OPC_measure = PM.getPM(5000, 5000);
    }

    PM.OFF();





    //now storeing it locally 
  SD.ON();

  frame.createFrame(ASCII, node_ID);  // frame1 de  stocat
    // Add temperature
    frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
    // Add humidity
    frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
    // Add pressure value
    frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
    // Add CO value
    frame.addSensor(SENSOR_GASES_PRO_CO, concCO, 2);
    // Add NH3 value
    frame.addSensor(SENSOR_GASES_PRO_NH3, concNH3, 2);

  //  USB.println(F("cadru de stocet:")); 
  //  frame.showFrame();
    

  time_date = RTC.getTime(); 
  USB.print(F("time: "));
  USB.println(time_date);  
  
  x=RTC.year;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.month;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.day;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.hour;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.minute;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.second;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename,  "  " );
  sd_answer = SD.append(filename,  frame.buffer , frame.length );
  sd_answer = SD.append(filename,  "  " );
  sd_answer = SD.appendln(filename,  ssent );
// frame 1 is stored 




// frame2


      frame.createFrame(ASCII);
        // Add PM1
      frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1, 2);
      // Add PM2.5
      frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5, 2);
      // Add PM10
      frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10, 2);
      // Add BAT level
      frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
      // Add CH4 value
      frame.addSensor(SENSOR_GASES_PRO_CH4, concCH4, 2);
 


  x=RTC.year;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.month;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.day;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.hour;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.minute;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );
  sd_answer = SD.append(filename, ".");
  x=RTC.second;
  itoa(x, y, 10);
  if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
  sd_answer = SD.append(filename,  y  );


  sd_answer = SD.append(filename,  "  " );
  sd_answer = SD.append(filename,  frame.buffer , frame.length );
  sd_answer = SD.append(filename,  "  " );
  sd_answer = SD.appendln(filename,  ssent2 );




  SD.OFF();






  // get actual time
  previous = millis();
  //////////////////////////////////////////////////
  // 4. Switch ON
  //////////////////////////////////////////////////  

  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }
  //////////////////////////////////////////////////
  // 5. Join AP
  //////////////////////////////////////////////////  
  // check connectivity
  status =  WIFI_PRO.isConnected();


  // check if module is connected
  if (status == true)
  {    
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
  

    RTC.ON();
    RTC.getTime();
    
  // create new frame1
  frame.createFrame(ASCII, node_ID);  // frame1 de trimis & stocat
 
  // add frame fields
////////////////////////////////////////////////////////////

    // Add temperature
    frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
    // Add humidity
    frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
    // Add pressure value
    frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
    // Add CO value
    frame.addSensor(SENSOR_GASES_PRO_CO, concCO, 2);
    // Add NH3 value
    frame.addSensor(SENSOR_GASES_PRO_NH3, concNH3, 2);


////////////////////////////////////////////////////////////
    frame.showFrame();
 // data is sent here

 // 3.2. Send Frame to Meshlium
    ///////////////////////////////
    // http frame
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);   // frame 1

    // check response
    if (error == 0)
    {
      USB.println(F("HTTP OK")); 
      for (x=0;x<4;x++)
      {
        ssent[x]="true"[x];
      }
      
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous); 
      WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
      USB.println(F("ASCII FRAME 1 SEND OK")); 


    }
    else
    {
      USB.println(F("Error calling 'getURL' function"));
      for (x=0;x<5;x++)
      {
        ssent[x]="false"[x];
      }
      WIFI_PRO.printErrorCode();
    }
  }
  else
  {
    USB.print(F("WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }






//frame2

      frame.createFrame(ASCII);
        // Add PM1
      frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1, 2);
      // Add PM2.5
      frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5, 2);
      // Add PM10
      frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10, 2);
      // Add BAT level
      frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
      // Add CH4 value
      frame.addSensor(SENSOR_GASES_PRO_CH4, concCH4, 2);

    
      frame.showFrame();
      error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);   // frame 2 is made



////////////////////////////////////////////////////////////

 // 3.2. Send Frame to Meshlium
    ///////////////////////////////
    // http frame
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);   // frame 2

    // check response
    if (error == 0)
    {
      USB.println(F("HTTP OK")); 
      for (x=0;x<4;x++)
      {
        ssent2[x]="true"[x];
      }
      
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous); 
      WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
      USB.println(F("ASCII FRAME 2 SEND OK")); 


    }
    else
    {
      USB.println(F("Error calling 'getURL' function"));
      for (x=0;x<5;x++)
      {
        ssent2[x]="false"[x];
      }
      WIFI_PRO.printErrorCode();
    }


  //////////////////////////////////////////////////
  // 3. Switch OFF
  //////////////////////////////////////////////////  



b=(millis()-prev)/1000;
  USB.print("loop execution time[s]: ");
  USB.println(b);

  
cycle_time=cycle_time2-b-1;
if ( cycle_time <10)
{
  cycle_time=15;
}
  USB.println(cycle_time);

  
x=cycle_time%60;  // sec
itoa(x, y, 10);
if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
rtc_str[9]=y[0];
rtc_str[10]=y[1];


x=cycle_time/60%60;  // min
itoa(x, y, 10);
if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
rtc_str[6]=y[0];
rtc_str[7]=y[1];


x=cycle_time/3600%3600;  // h
itoa(x, y, 10);
if(x<10)
{
  y[1]=y[0];
  y[0]='0';
}
rtc_str[3]=y[0];
rtc_str[4]=y[1];

///-------------


  WIFI_PRO.OFF(socket);
  USB.println(F("WiFi switched OFF\n\n")); 

  // Go to deepsleep  

  ////////////////////////////////////////////////
  // 5. Sleep
  ////////////////////////////////////////////////
  USB.println(F("5. Enter deep sleep..."));
  USB.print("X");USB.print(rtc_str);USB.println("X");

  USB.println("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
  USB.OFF();

  PWR.deepSleep(rtc_str, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.println(F("6. Wake up!!\n\n"));

}





















/*

void lost_frames( int x)
{
  if(first_lost<x and first_lost != -7)
  first_lost=first_lost;
  else
  first_lost=x;
};

*/

//     first_lost++;
//     USB.println( SD.cat( filename, 13 , 53 ) );  citeste de le linia  13  53  de caractere

/* 
int data_resender ( char filename , int first_lost )
{
   USB.println( SD.cat( filename, first_lost , frame.length ) );



  return 1;
}

*/



