#include <WaspSensorGas_Pro.h>
#include <WaspPM.h>
#include <WaspXBee868LP.h>
#include <WaspFrame.h>

/*
   Define objects for sensors
   Imagine we have a P&S! with the next sensors:
    - SOCKET_A: sensor (CO2)
    - SOCKET_B: sensor (NO2)
    - SOCKET_C: sensor (O3)
    - SOCKET_D: Particle matter sensor (dust)
    - SOCKET_E: BME280 sensor (temperature, humidity & pressure)
    - SOCKET_F: sensor (SO2)
*/
/////////// NU UMBLA AICI!!!!!
// define variable SD
// define file name: MUST be 8.3 SHORT FILE NAME
char filename[] = "FILE1.TXT";
char *time_date; // stores curent date + time
int x, b, cycle_time;
uint8_t status = false;
char y[3];
uint8_t sd_answer, ssent;
bool sentence = false; // true for deletion on reboot  , false for data appended to end of file
bool IRL_time = true; //  true for no external date source
char rtc_str[] = "00:00:00:05";    // 11 char ps incepe de la 0
unsigned long prev, previous, previousSendFrame;
bool RTC_SUCCES;
int cycle_time2 = 900; // in seconds




// Destination MAC address
// MAC LOW = 41C3ADE5
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20041C3ADE5";
//////////////////////////////////////////



// define variable
uint8_t error;

Gas CO2(SOCKET_A);
Gas NO2(SOCKET_B);
Gas O3(SOCKET_C);
Gas SO2(SOCKET_F);

float temperature;
float humidity;
float pressure;

float concCO2;
float concNO2;
float concSO2;
float concO3;

int OPC_status;
int OPC_measure;

char node_ID[] = "KRA868L";

// PAN (Personal Area Network) Identifier
uint8_t  panID[2] = {0x7F, 0xFF};

// Define Freq Channel to be set:
uint8_t  mask[4] = {0x3F, 0xFF, 0xFF, 0xFF};

// Define preamble ID
uint8_t preambleID = 0x00;

// Define the Encryption mode: 1 (enabled) or 0 (disabled)
uint8_t encryptionMode = 0;

// Define the AES 16-byte Encryption Key
char  encryptionKey[] = "WaspmoteLinkKey!";








void XXBEE()
{
  // init XBee
  xbee868LP.ON( SOCKET1 );
  /////////////////////////////////////
  // 1. set channel
  /////////////////////////////////////
  xbee868LP.setChannelMask( mask );

  // check at commmand execution flag
  if ( xbee868LP.error_AT == 0 )
  {
    USB.print(F("1. Channel set OK to: 0x"));
    USB.printHex( xbee868LP._channelMask[0] );
    USB.printHex( xbee868LP._channelMask[1] );
    USB.printHex( xbee868LP._channelMask[2] );
    USB.printHex( xbee868LP._channelMask[3] );
    USB.println();
  }
  else
  {
    USB.println(F("1. Error calling 'setChannel()'"));
  }


  /////////////////////////////////////
  // 2. set PANID
  /////////////////////////////////////
  xbee868LP.setPAN( panID );

  // check the AT commmand execution flag
  if ( xbee868LP.error_AT == 0 )
  {
    USB.print(F("2. PAN ID set OK to: 0x"));
    USB.printHex( xbee868LP.PAN_ID[0] );
    USB.printHex( xbee868LP.PAN_ID[1] );
    USB.println();
  }
  else
  {
    USB.println(F("2. Error calling 'setPAN()'"));
  }

  /////////////////////////////////////
  // 3. set preamble ID
  /////////////////////////////////////
  xbee868LP.setPreambleID( preambleID );

  // check the AT commmand execution flag
  if ( xbee868LP.error_AT == 0 )
  {
    USB.print(F("2. Preamble ID set OK to: 0x"));
    USB.printHex( xbee868LP._preambleID );
    USB.println();
  }
  else
  {
    USB.println(F("2. Error calling 'setPreambleID()'"));
  }

  /////////////////////////////////////
  // 4. set encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee868LP.setEncryptionMode( encryptionMode );

  // check the AT commmand execution flag
  if ( xbee868LP.error_AT == 0 )
  {
    USB.print(F("3. AES encryption configured (1:enabled; 0:disabled):"));
    USB.println( xbee868LP.encryptMode, DEC );
  }
  else
  {
    USB.println(F("3. Error calling 'setEncryptionMode()'"));
  }

  /////////////////////////////////////
  // 5. set encryption key
  /////////////////////////////////////
  xbee868LP.setLinkKey( encryptionKey );

  // check the AT commmand execution flag
  if ( xbee868LP.error_AT == 0 )
  {
    USB.println(F("4. AES encryption key set OK"));
  }
  else
  {
    USB.println(F("4. Error calling 'setLinkKey()'"));
  }

  /////////////////////////////////////
  // 6. write values to XBee module memory
  /////////////////////////////////////
  xbee868LP.writeValues();

  // check the AT commmand execution flag
  if ( xbee868LP.error_AT == 0 )
  {
    USB.println(F("5. Changes stored OK"));
  }
  else
  {
    USB.println(F("5. Error calling 'writeValues()'"));
  }

  USB.println(F("-------------------------------"));

  // store Waspmote identifier in EEPROM memory
  frame.setID( node_ID );
}







void SD_TEST_FILE_CHECK( char filename_st[] =  filename )   // eventual de adaugat suport pt delete all files on SD?
{

  SD.ON();

  if (sentence == 1)
  {
    // Delete file
    sd_answer = SD.del(filename_st);

    if (sd_answer == 1)
    {
      USB.println(F("file deleted"));
    } else
    {
      USB.println(F("file NOT deleted"));
    }
  }
  // Create file IF id doent exist
  sd_answer = SD.create(filename_st);

  if (sd_answer == 1)
  {
    USB.println(F("file created"));
  } else
  {
    USB.println(F("file NOT created"));
  }

  USB.print("loop cycle time[s]:= ");
  USB.println(cycle_time2);
  sd_answer = SD.appendln(filename_st, "----------------------------------------------------------------------------");
  if (sd_answer == 1)
  {
    USB.println(F("writeing is OK"));
  } else
  {
    USB.println(F("writeing is haveing errors"));
  }

  SD.OFF(); /////////////////////////////modified by Ana
}











void scriitor_SD(char filename_a2[], uint8_t ssent_a = 0)
{
  SD.ON();
  USB.ON();
  USB.print(F("scriitor SD  "));

  long int size, m;
  m = 104857600 ; //100MB file size
  //m= 1048576;    //10MB file size
  bool q = true;
  int i;
  char filename_a[13];


  for (i = 0; i < 12; i++)
  {
    filename_a[i] = filename_a2[i];
  }
  //USB.println(F("scriitor SD2"));


  i = 1;
fazuzu:
  size = SD.getFileSize( filename_a );
  if (  (size >= m)  )
  {
    i++;
    itoa(i, y , 10);

    if (i < 10)
    {
      filename_a[4] = y[0];
    }
    else if ( i >= 10 && i <= 99)
    {
      for (int t = 0; t < 4; t++)
      {
        filename_a[9 - t] = filename_a[8 - t];
      }
      filename_a[4] = y[0];
      filename_a[5] = y[1];
      filename_a[10] = '\0';


      /*
        USB.print(F("xxxxx"));
        USB.print(  filename_a  );
        USB.println(F("xxxxx"));
        USB.print(F("xxxxx"));
        USB.print(  strlen(  filename_a  ));
        USB.println(F("xxxxx"));

      */
    }
    else
    {

      if (i > 330)
      {
        i = 330; // pt ca exista o limita de fisiere in root si 330 a destul de sub limita sa nu faca probleme
      }
      for (int t = 0; t < 4; t++)
      {
        filename_a[10 - t] = filename_a[9 - t];
      }
      filename_a[4] = y[0];
      filename_a[5] = y[1];
      filename_a[6] = y[2];
      filename_a[11] = '\0';
    }

    goto  fazuzu;
  }
  //USB.println(F("scriitor SD4"));





  USB.print(F("se va scrie in: "));
  USB.println(filename_a);
  i = SD.create(filename_a);
  if (i == 1)
  {
    USB.println(F("file created since it was not present "));
  }




  int coruption = 0;
  //sd_answer = SD.appendln(filename_a, "am scris aici!!!!!!!!");
  //coruption = coruption + sd_answer;
  // now storeing it locally
  time_date = RTC.getTime();
  USB.print(F("time: "));
  USB.println(time_date);

  x = RTC.year;
  itoa(x, y, 10);
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }

  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.month;
  itoa(x, y, 10);
  if (x < 10)
  {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.date;
  itoa(x, y, 10);
  if (x < 10) 
  {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.hour;
  itoa(x, y, 10);
  if (x < 10)
  {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.minute;
  itoa(x, y, 10);
  if (x < 10)
  {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.second;
  itoa(x, y, 10);
  if (x < 10)
  {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, "  ");
  coruption = coruption + sd_answer;



  sd_answer = SD.append(filename_a, frame.buffer, frame.length);  // scriere propriuzisa frame
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, "  ");
  coruption = coruption + sd_answer;
  itoa(ssent_a, y, 10);
  sd_answer = SD.appendln(filename_a, y);
  coruption = coruption + sd_answer;
  // frame is stored

  SD.OFF();

  if (coruption == 15)
  {
    USB.println(F("SD storage done with no errors"));
  }
  else
  {
    USB.print(F("SD sorage done with:"));
    USB.print(15 - coruption);
    USB.println(F(" errors"));
  }
}











void data_maker( int x , char filename_a[]  )
{
  SD.ON();

  for (int ii = 1 ; ii <= x ; ii++) //10MB per x=1
  {
    USB.println(F(" cycles: "));
    USB.println(ii);
    USB.println("/");
    USB.println(x);
    for (int g = 0; g < 324 ; g++)
    {
      SD.appendln(filename_a, " ");
      USB.println(F(" subcycles: "));
      USB.println(g);
      USB.println(F("/324"));
      for (int k = 0 ; k < 324 ; k++)
        SD.append(filename_a, "eokfumpwqroifv4478fcmwpocfumwqgif17nwqrpn5fcmwifcwuifw7unpcwogr2rqfcnqwogfqprwfmqwfhwdjfbplpkp13pl ");   //100 byte per line
    }
  }
  SD.OFF();

}









void gaze_Szelanya()
{
  // 1. Turn on sensors and wait
  ///////////////////////////////////////////

  //Power on gas sensors
  CO2.ON();
  NO2.ON();
  SO2.ON();
  O3.ON();


  // Sensors need time to warm up and get a response from gas
  // To reduce the battery consumption, use deepSleep instead delay
  // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
  USB.println(RTC.getTime());
  USB.println(F("Enter deep sleep mode to wait for sensors heating time..."));
  //PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
  delay(3000);
  USB.ON();
  USB.println(RTC.getTime());
  USB.println(F("wake up!!\r\n"));

  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////

  // Read the sensors and compensate with the temperature internally
  concCO2 = CO2.getConc();
  concNO2 = NO2.getConc();
  concSO2 = SO2.getConc();
  concO3  = O3.getConc();

  // Read enviromental variables
  temperature = CO2.getTemp();
  humidity    = CO2.getHumidity();
  pressure    = CO2.getPressure();

  ///////////////////////////////////////////
  // 3. Turn off the sensors
  ///////////////////////////////////////////

  //Power off sensors
  CO2.OFF();
  NO2.OFF();
  O3.OFF();
  SO2.OFF();
  delay(500);
  ///////////////////////////////////////////
  // 4. Read particle matter sensor
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
  delay(500);
  // Create new frame (ASCII)
  frame.createFrame(ASCII);
  //    // Add PM1
  //    frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1, 2);
  //      // Add PM2.5
  //    frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5, 2);
  //      // Add PM10
  //    frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10, 2);
  // Add BAT level
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  // Add temperature
  frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
  //    // Add humidity
  frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
  //    // Add pressure value
  frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
  //    // Add CO2 value
  //    frame.addSensor(SENSOR_GASES_PRO_CO2, concCO2, 2);
  //    // Add NO2 value
  //    frame.addSensor(SENSOR_GASES_PRO_NO2, concNO2, 2);
  //    // Add SO2 value
  //    frame.addSensor(SENSOR_GASES_PRO_SO2, concSO2, 2);
  //    // Add O3 value
  //    frame.addSensor(SENSOR_GASES_PRO_O3, concO3, 2);
  // Show the frame
  frame.showFrame();

}


void trimitaro_data_XXBEE()
{
  // 6. Send Frame to Meshlium
  ///////////////////////////////////////////
  // 2. Send packet
  ///////////////////////////////////////////
  xbee868LP.ON();
  delay(2000);
  // send XBee packet
  error = xbee868LP.send( RX_ADDRESS, frame.buffer, frame.length );

  // check TX flag
  if ( error == 0 )
  {
    USB.println(F("send ok"));

    // blink green LED
    Utils.blinkGreenLED();

  }
  else
  {
    USB.println(F("send error"));
    USB.print(F("Failed. Error code: "));
    USB.println(error, DEC);
    // blink red LED
    Utils.blinkRedLED();
  }

  // wait for five seconds
  delay(5000);
  xbee868LP.OFF();
}


// asta e folosita in void loop la inceput de tott
void Watchdog_setup_and_reset(int x, bool y = false) // x e timpul in secunde  iar y e enable
{
  int tt;

  if ( y)
  {
    tt =  x * 3 % 60;
    if (tt > 59)  // 59 minutes max timer time
    {
      tt = 59;
    }
    if (tt < 1)
    {
      tt = 1;   // 1 minute is min timer time
    }
    RTC.setWatchdog(tt);
    USB.print(F("RTC timer reset succesful"));
    USB.print(F("        next forced restart: "));
    USB.println(  RTC.getWatchdog()  );
  }
}


void setup()
{
  //    USB.ON();
  //    USB.println("Frame Utility Example for Gases Pro Sensor Board");
  //    USB.println("Sensors used:"));
  //    USB.println("- SOCKET_A: Electrochemical gas sensor (C2)"");
  //    USB.println("- SOCKET_B: Electrochemical gas sensor (NO2)");
  //    USB.println("- SOCKET_C: Electrochemical gas sensor (O3)");
  //    USB.println("- SOCKET_D: Particle matter sensor (dust)");
  //    USB.println("- SOCKET_E: BME280 sensor (temperature, humidity & pressure)");
  //    USB.println("- SOCKET_F: Electrochemical gas sensor (SO2)");


  // open USB port
  USB.ON();

  USB.println(F("-------------------------------"));
  USB.println(F("Configure XBee 868LP"));
  USB.println(F("-------------------------------"));
  USB.println(F("Watchdog settings: 3 cycle time"));


  XXBEE();
  SD_TEST_FILE_CHECK();

}







void loop()
{
  // get actual time before loop
  prev = millis();
  Watchdog_setup_and_reset( cycle_time2 , false );
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  gaze_Szelanya();
  trimitaro_data_XXBEE();
  scriitor_SD( filename);





  //OTA_check_loop();

  ///////////////  NU UMBLA AICI !!!
  // RTC.setAlarm2("01:10:00", RTC_ABSOLUTE, RTC_ALM2_MODE1); // activare in fiecare duminica la 10:00 dimineata
  // IN_LOOP_RTC_CHECK(  RTC_SUCCES);
  cycle_time = cycle_time2 - b - 5;
  if (cycle_time < 10)
  {
    cycle_time = 15;
  }
  USB.print(F("cycle time: "));
  USB.println(cycle_time);

  x = cycle_time % 60; // sec
  itoa(x, y, 10);
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }
  rtc_str[9] = y[0];
  rtc_str[10] = y[1];

  x = cycle_time / 60 % 60; // min
  itoa(x, y, 10);
  if (x < 10)
  {
    y[1] = y[0];
    y[0] = '0';
  }
  rtc_str[6] = y[0];
  rtc_str[7] = y[1];

  x = cycle_time / 3600 % 3600; // h
  itoa(x, y, 10);
  if (x < 10)
  {
    y[1] = y[0];
    y[0] = '0';
  }
  rtc_str[3] = y[0];
  rtc_str[4] = y[1];

  ////////////////////////////////////////////////
  // 5. deepsleep
  ////////////////////////////////////////////////
  USB.println(F("5. Enter deep sleep..."));
  USB.print(F("X"));
  USB.print(rtc_str);
  USB.println(F("X"));

  USB.println(F("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"));
  USB.OFF();
  PWR.deepSleep(rtc_str, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.println(F("6. Wake up!!\n\n"));

}








