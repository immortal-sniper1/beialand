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
char y[3];
uint8_t sd_answer,ssent,ssent2,retries_f1=2; // resending for frame 1 , frame 2 has 2 extra
bool sentence=false;   // true for deletion on reboot  , false for data appended to end of file 
bool IRL_time= false;  //  true for no external data source
int  cycle_time,cycle_time2=1000;  // in seconds
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












uint8_t status2=false;

int count_trials=0;
int N_trials=10;
char ESSID[] = "FARM";
char PASSW[] = "beiafarm";


// choose NTP server settings
///////////////////////////////////////
char SERVER1[] = "time.nist.gov";
char SERVER2[] = "wwv.nist.gov";

//"pool.ntp.org";

///////////////////////////////////////

// Define Time Zone from -12 to 12 (i.e. GMT+2)
///////////////////////////////////////
uint8_t time_zone = 2;
///////////////////////////////////////









// functions

void try_RTC_set()
{//////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////  
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }


  //////////////////////////////////////////////////
  // 2. Check if connected
  //////////////////////////////////////////////////  

  // get actual time
  previous = millis();

  // check connectivity
  status =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (status == true)
  {    
    USB.print(F("2. WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
  }
  else
  {
    USB.print(F("2. WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);   
  }


  //////////////////////////////////////////////////
  // 3. Set RTC Time from WiFi module settings
  //////////////////////////////////////////////////  

  // Check if module is connected
  if (status == true)
  {   
    // 3.1. Open FTP session
    error = WIFI_PRO.setTimeFromWIFI();

    // check response
    if (error == 0)
    {
      USB.print(F("3. Set RTC time OK. Time:"));
      USB.println(RTC.getTime());
    }
    else
    {
      USB.println(F("3. Error calling 'setTimeFromWIFI' function"));
      WIFI_PRO.printErrorCode();
      status = false;   
    }
  }


  //////////////////////////////////////////////////
  // 4. Switch OFF
  //////////////////////////////////////////////////  
  WIFI_PRO.OFF(socket);
  USB.println(F("4. WiFi switched OFF\n\n")); 
  USB.println(F("Wait 10 seconds...\n")); 
  delay(10000);
  }


void WiFi_init()
{ // 1. Switch ON the WiFi module
  //////////////////////////////////////////////////
  error=1;
  while (error==1)
  {
   error = WIFI_PRO.ON(socket);
  
   if (error == 0)
   {    
     USB.println(F("1. WiFi switched ON"));
   }
   else
   {
     USB.println(F("1. WiFi did not initialize correctly"));
   }
  }

  // 2. Reset to default values
  //////////////////////////////////////////////////
  error=1;
  while (error==1)
  {error = WIFI_PRO.resetValues();

  if (error == 0)
    {    
    USB.println(F("2. WiFi reset to default"));
    }
  else
    {
    USB.println(F("2. WiFi reset to default ERROR"));
    }
  }
// 3. Set ESSID
  //////////////////////////////////////////////////
  error=1;
  while (error==1)
{
  error = WIFI_PRO.setESSID(ESSID);

  if (error == 0)
  {    
    USB.println(F("3. WiFi set ESSID OK"));
  }
  else
  {
    USB.println(F("3. WiFi set ESSID ERROR"));
  }

}
  //////////////////////////////////////////////////
  // 4. Set password key (It takes a while to generate the key)
  // Authentication modes:
  //    OPEN: no security
  //    WEP64: WEP 64
  //    WEP128: WEP 128
  //    WPA: WPA-PSK with TKIP encryption
  //    WPA2: WPA2-PSK with TKIP or AES encryption
  //////////////////////////////////////////////////
  error=1;
  while (error==1)
  {
  error = WIFI_PRO.setPassword(WPA2, PASSW);

  if (error == 0)
  {    
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }
  else
  {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }

  }
  //////////////////////////////////////////////////
  // 5. Software Reset 
  // Parameters take effect following either a 
  // hardware or software reset
  //////////////////////////////////////////////////
  error = WIFI_PRO.softReset();

  if (error == 0)
  {    
    USB.println(F("5. WiFi softReset OK"));
  }
  else
  {
    USB.println(F("5. WiFi softReset ERROR"));
  }


  USB.println(F("*******************************************"));
  USB.println(F("Once the module is configured with ESSID"));
  USB.println(F("and PASSWORD, the module will attempt to "));
  USB.println(F("join the specified Access Point on power up"));
  USB.println(F("*******************************************\n"));
  }



















// initialization

void setup()
{
 
  //////////////////////////////////////////////////
  // 2. Check if connected
  //////////////////////////////////////////////////  
  while (status==false)
  {
   WiFi_init();//initialize Wi-Fi communication
  // get actual time
  previous = millis();

  // check connectivity
  status =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (status == true)
  {    
    USB.print(F("2. WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
  }
  else
  {
    USB.print(F("2. WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous); 
  }

  }

  //////////////////////////////////////////////////
  // 3. NTP server
  //////////////////////////////////////////////////  

  // Check if module is connected
  if (status == true)
  {   

//    // 3.1. Set NTP Server (option1)
    error = WIFI_PRO.setTimeServer(1, SERVER1);

    // check response
    if (error == 0)
    {
      USB.println(F("3.1. Time Server1 set OK"));   
    }
    else
    {
      USB.println(F("3.1. Error calling 'setTimeServer' function"));
      WIFI_PRO.printErrorCode();
      status = false;   
    }
    
    
    // 3.2. Set NTP Server (option2)
    error = WIFI_PRO.setTimeServer(2, SERVER2);

    // check response
    if (error == 0)
    {
      USB.println(F("3.2. Time Server2 set OK"));   
    }
    else
    {
      USB.println(F("3.2. Error calling 'setTimeServer' function"));
      WIFI_PRO.printErrorCode();
      status = false;   
    }

    // 3.3. Enabled/Disable Time Sync
    if (status == true)
    { 
      error = WIFI_PRO.timeActivationFlag(true);

      // check response
      if( error == 0 )
      {
        USB.println(F("3.3. Network Time-of-Day Activation Flag set OK"));   
      }
      else
      {
        USB.println(F("3.3. Error calling 'timeActivationFlag' function"));
        WIFI_PRO.printErrorCode();  
        status = false;        
      } 
    }

    

    // 3.4. set GMT
    if (status == true)
    {     
      error = WIFI_PRO.setGMT(time_zone);

      // check response
      if (error == 0)
      {
        USB.print(F("3.4. GMT set OK to "));   
        USB.println(time_zone, DEC);
      }
      else
      {
        USB.println(F("3.4. Error calling 'setGMT' function"));
        WIFI_PRO.printErrorCode();       
      } 
    }
  }

//
//  //////////////////////////////////////////////////
//  // 4. Switch OFF
//  //////////////////////////////////////////////////  
//  USB.println(F("4. WiFi switched OFF\n")); 
//  WIFI_PRO.OFF(socket);


  USB.println(F("-----------------------------------------------------------")); 
  USB.println(F("Once the module has the correct Time Server Settings"));
  USB.println(F("it is always possible to request for the Time and"));
  USB.println(F("synchronize it to the Waspmote's RTC")); 
  USB.println(F("-----------------------------------------------------------\n")); 
  delay(5000);
  
  // Init RTC
//  RTC.ON();
//  USB.print(F("Current RTC settings:"));
//  USB.println(RTC.getTime());
//  


  // open USB port
  USB.ON();
  RTC.ON(); // Executes the init process
//  USB.print(F("Current RTC settings:"));
//  USB.println(RTC.getTime());
 // IRL_time=false;

  
  if( IRL_time)
  {
    // Setting date and time [yy:mm:dd:dow:hh:mm:ss]
    RTC.setTime("19:01:01:03:00:00:00");
  }
  else
  {
    // Check if module is connected
  if (status == true)
  {   
    // 3.1. Open FTP session
    error = WIFI_PRO.setTimeFromWIFI();

    // check response
    if (error == 0)
    {
      USB.print(F("3. Set RTC time OK. Time:"));
      USB.println(RTC.getTime());
    }
    else
    {
      USB.println(F("3. Error calling 'setTimeFromWIFI' function"));
      WIFI_PRO.printErrorCode();
      status = false;   
    }
  }

  while ((count_trials<N_trials)&& (status==false))
    {
      try_RTC_set();
      USB.print(F("Trial: "));
      count_trials=count_trials+1;
      USB.print(count_trials);
      USB.println();
      }

  }

  

   USB.print(F("Current RTC settings:"));
   USB.println(RTC.getTime());
   USB.println(F("farm1_V9_SD_arhive_RTC_ON"));
  
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

    }
         // Create file IF id doent exist 
         sd_answer = SD.create(filename);
  
         if( sd_answer == 1 )
         {
           USB.println(F("file created"));
         }
         else 
         {
           USB.print(F("file NOT created   file size[BYTES]:"));  
           USB.println( SD.getFileSize(filename) );
         } 
  
       USB.print("loop cycle time[s]:= ");
       USB.println(cycle_time2 );
      sd_answer = SD.appendln(filename,  "----------------------------------------------------------------------------" );


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
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);    // trebuie sa fie 2 min
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
    USB.println(F("Particle sensor is done mesuring, and was turned OFF."));




  // get actual time
  previous = millis();
  //////////////////////////////////////////////////
  // 4. Switch ON
  //////////////////////////////////////////////////  
b=0;
qwerty:


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
  


    RTC.getTime();
    
  // create new frame 1
  frame.createFrame(ASCII, node_ID);  // frame1 de trimis & stocat
 
  // add frame fields
////////////////////////////////////////////////////////////

      // Add CH4 value
      frame.addSensor(SENSOR_GASES_PRO_CH4, concCH4, 2);
      // Add CO value
      frame.addSensor(SENSOR_GASES_PRO_CO, concCO, 2);
      // Add NH3 value
      frame.addSensor(SENSOR_GASES_PRO_NH3, concNH3, 2);
      // Add PM1
      frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1, 2);
      // Add PM2.5
      frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5, 2);
      // Add PM10
      frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10, 2);
      // Add BAT level
      frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());

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
        ssent=1;
      
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous); 
      USB.println(F("ASCII FRAME 1 SEND OK")); 


    }
    else
    {
      USB.println(F("Error calling 'getURL' function"));
        ssent=0;
      WIFI_PRO.printErrorCode();
    }
  }
  else
  {
    USB.print(F("WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }

b++;
if (ssent==0 && b<=retries_f1)
{
  delay(5000);
  USB.print(F("atempting resend no: "));
  USB.println(b);
  goto qwerty;
}
if (ssent==0 && b>=retries_f1)
{
    USB.print(F("WIFI failed HARD for some reason "));
}
















delay(5000);
b=0;
qwerty_too:
  status =  WIFI_PRO.isConnected();


  // check if module is connected
  if (status == true)
  {    
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
  





//frame2

      frame.createFrame(ASCII);
      // Add temperature
      frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
      // Add humidity
      frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
      // Add pressure value
      frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
// frame 2 is made
       frame.showFrame();
   


////////////////////////////////////////////////////////////

 // 3.2. Send Frame to Meshlium
    ///////////////////////////////
    // http frame
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);   // frame 2

    // check response
    if (error == 0)
    {
      USB.println(F("HTTP OK")); 
        ssent=1;
      
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous); 
      USB.println(F("ASCII FRAME 2 SEND OK")); 
    }
    else
    {
      USB.println(F("Error calling 'getURL' function"));
        ssent2=0;
      WIFI_PRO.printErrorCode();
    }
  }
  else
  {
    USB.print(F("WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }

b++;
if (ssent2==0 && (b+2)<=retries_f1)
{
  delay(5000);
  USB.print(F("atempting resend no: "));
  USB.println(b);
  goto qwerty_too;
}




  //////////////////////////////////////////////////
  // 3. Switch OFF
  //////////////////////////////////////////////////  

  WIFI_PRO.OFF(socket);
  USB.println(F("WiFi switched OFF\n\n")); 

b=(millis()-prev)/1000;
  USB.print("loop execution time[s]: ");
  USB.println(b);

  
cycle_time=cycle_time2-b-2;
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

















  PWR.deepSleep("00:00:00:05", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
    //now storeing it locally 
  SD.ON();

  frame.createFrame(ASCII, node_ID);  // frame1 de  stocat
      // Add CH4 value
      frame.addSensor(SENSOR_GASES_PRO_CH4, concCH4, 2);
      // Add CO value
      frame.addSensor(SENSOR_GASES_PRO_CO, concCO, 2);
      // Add NH3 value
      frame.addSensor(SENSOR_GASES_PRO_NH3, concNH3, 2);
      // Add PM1
      frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1, 2);
      // Add PM2.5
      frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5, 2);
      // Add PM10
      frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10, 2);
      // Add BAT level
      frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());

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

  
  x=RTC.date;
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
  itoa(ssent,y ,10);
  sd_answer = SD.appendln(filename,  y );
// frame 1 is stored 




// frame2


      frame.createFrame(ASCII);
      // Add temperature
      frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
      // Add humidity
      frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
      // Add pressure value
      frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
 


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
  x=RTC.date;
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
    itoa(ssent2, y, 10);
  sd_answer = SD.appendln(filename, y  );


  SD.OFF();









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














