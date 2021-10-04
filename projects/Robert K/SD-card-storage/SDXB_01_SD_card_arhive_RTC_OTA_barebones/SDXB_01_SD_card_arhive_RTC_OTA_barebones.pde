#include <WaspFrame.h>
#include <WaspXBeeZB.h>


//NU UNBLA AICI!!
// define variable SD
// define file name: MUST be 8.3 SHORT FILE NAME
char filename[] = "FILE1.TXT";

char *time_date; // stores curent date + time
int cycle_time, x, b;
uint8_t error, status = false;
char y[3];
uint8_t sd_answer, ssent = 0, resend_f = 2; // frame resend atempts
bool sentence = false; // true for deletion on reboot  , false for data appended to end of file
bool IRL_time = false; //  true for no external data source
bool RTC_IS_IN_SYNCC = false;
char rtc_str[] = "00:00:00:05";    // 11 char ps incepe de la 0
unsigned long prev, previous;


char programID[10];
/*
// SERVER settings
///////////////////////////////////////
char host[] = "82.78.81.178";
uint16_t port = 80;
uint8_t powerValue = 1; // Define the power level value
///////////////////////////////////////
*/
/*
//FTP send
char SD_FILE[]     = "FILE1.TXT";
char SERVER_FILE[] = "HHKFILE2.TXT";
uint8_t connection_status, net_in_attempt;
char operator_name[20];
*/


//EDITEAZA AICI!
int  cycle_time2 = 30; // in seconds
char node_ID[] = "qwerty13";
uint8_t RTC_ATEMPTS = 10; // number of RTC sync atempts
///////////////////////////////////////
/*
// FTP SERVER settings
///////////////////////////////////////
char ftp_server[] = "ftp.agile.ro";
uint16_t ftp_port = 21;
char ftp_user[] = "robi@agile.ro";
char ftp_pass[] = "U$d(SEFA8+UC";
*/
// coordinator's 64-bit PAN ID to set
////////////////////////////////////////////////////////////////////////
uint8_t  PANID[8] = { "BE1A"};
////////////////////////////////////////////////////////////////////////
// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20041678B8C";                                                  //"0013A200403A2A49";
//////////////////////////////////////////
char MESHLIUM_ADDRESS[] = "0013A20041678B8C";  // Destination MAC address




// subprograme


void scriitor_SD(char filename_a[], uint8_t ssent_a = 0)
{
  int coruption = 0;
  delay(1000);
  // now storeing it locally
  SD.ON();
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
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.date;
  itoa(x, y, 10);
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.hour;
  itoa(x, y, 10);
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.minute;
  itoa(x, y, 10);
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, ".");
  coruption = coruption + sd_answer;
  x = RTC.second;
  itoa(x, y, 10);
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }
  sd_answer = SD.append(filename_a, y);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, "  ");
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, frame.buffer, frame.length);
  coruption = coruption + sd_answer;
  sd_answer = SD.append(filename_a, "  ");
  coruption = coruption + sd_answer;
  itoa(ssent_a, y, 10);
  sd_answer = SD.appendln(filename_a, y);
  coruption = coruption + sd_answer;
  // frame is stored

  SD.OFF();

  if (coruption == 15) {
    USB.println("SD storage done with no errors");
  } else {
    USB.print("SD storage done with:");
    USB.print(15 - coruption);
    USB.println(" errors");
  }
}



void pregatitor_XBEE()
{


  ///////////////////////////////////////////////
  // Init XBee
  ///////////////////////////////////////////////
  xbeeZB.ON();
  delay(1000);


  ///////////////////////////////////////////////
  // 1. Set Coordinator Enable
  ///////////////////////////////////////////////

  /*************************************
    WARNING: Only XBee ZigBee S2C and
    XBee ZigBee S2D are able to use
    this function properly
  ************************************/
  xbeeZB.setCoordinator(ENABLED);

  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("1. Coordinator Enabled OK"));
  }
  else
  {
    USB.println(F("1. Error while enabling Coordinator mode"));
  }


  ///////////////////////////////////////////////
  // 2. Set PANID
  ///////////////////////////////////////////////
  xbeeZB.setPAN(PANID);

  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("2. PANID set OK"));
  }
  else
  {
    USB.println(F("2. Error while setting PANID"));
  }

  ///////////////////////////////////////////////
  // 3. Set channels to be scanned before creating network
  ///////////////////////////////////////////////
  /* Range:[0x0 to 0x3FFF]
    Channels are scpedified as a bitmap where depending on
    the bit a channel is selected --> Bit (Channel):
     0 (0x0B)  4 (0x0F)  8 (0x13)   12 (0x17)
     1 (0x0C)  5 (0x10)  9 (0x14)   13 (0x18)
     2 (0x0D)  6 (0x11)  10 (0x15)
     3 (0x0E)  7 (0x12)  11 (0x16)    */
  xbeeZB.setScanningChannels(0x14, 0x15);

  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("3. Scanning channels set OK"));
  }
  else
  {
    USB.println(F("3. Error while setting 'Scanning channels'"));
  }

  ///////////////////////////////////////////////
  // Save values
  ///////////////////////////////////////////////
  xbeeZB.writeValues();

  // wait for the module to set the parameters
  delay(10000);
  USB.println();
}







int XBEE_frame_sender()
{

  // send XBee packet
  error = xbeeZB.send( RX_ADDRESS, frame.buffer, frame.length );

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

    // blink red LED
    Utils.blinkRedLED();
  }

  // wait for five seconds
  delay(5000);
}









/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
  xbeeZB.getAssociationIndication();

  while ( xbeeZB.associationIndication != 0 )
  {
    delay(2000);

    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();

    xbeeZB.getAssociationIndication();
  }

  USB.println(F("\nJoined a network!"));

  // 3. get network parameters
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

}







void ALL_IN_ONE_FRAME_HANDLER()
{
  ssent = XBEE_frame_sender();
  scriitor_SD(filename, ssent);
}








void POWER_LVL_INSPECTOR()
{
  USB.println(F("----------------------------------"));
  USB.println(F("\tPOWER LEVEL"));
  USB.println(F("----------------------------------\n"
                "XBee (S2) (boost mode enabled)\n"
                "0 = -8 dBm\n"
                "1 = -4 dBm\n"
                "2 = -2 dBm\n"
                "3 =  0 dBm\n"
                "4 = +2 dBm\n"
                "----------------------------------\n"
                "XBee-PRO (S2)\n"
                "4 = 17 dBm\n"
                "----------------------------------\n"
                "XBee-PRO (S2) - International variant -\n"
                "4 = 17 dBm\n"
                "----------------------------------\n"
                "XBee-PRO (S2B) (boost mode enabled)\n"
                "4 = 18 dBm\n"
                "3 = 16 dBm\n"
                "2 = 14 dBm\n"
                "1 = 12 dBm\n"
                "0 = 10 dBm\n"
                "----------------------------------\n"
                "XBee-PRO (S2B)- International variant - (boost mode enabled)\n"
                "4 = 10 dBm\n"
                "3 =  8 dBm\n"
                "2 =  6 dBm\n"
                "1 =  4 dBm\n"
                "0 =  2 dBm\n"
                "----------------------------------\n"
                "XBee-PRO (S2C)\n"
                "4 =  5 dBm\n"
                "3 =  3 dBm\n"
                "2 =  1 dBm\n"
                "1 = -1 dBm\n"
                "0 = -5 dBm\n"
                "----------------------------------\n"
                "XBee-PRO (S2D)\n"
                "4 = 18 dBm\n"
                "3 = 16 dBm\n"
                "2 = 14 dBm\n"
                "1 = 12 dBm\n"
                "0 =  0 dBm\n"
                "----------------------------------"));

  delay(1000);

  // init XBee
  xbeeZB.ON();

  // get the Power Level
  xbeeZB.getPowerLevel();

  USB.print(F("Current Power Level:"));
  USB.println(xbeeZB.powerLevel, DEC);
  USB.println();
  delay(1000);
}








void RTC_SET(int incercari = RTC_ATEMPTS , char MESHLIUM_ADDRESS[] = MESHLIUM_ADDRESS )
{
  uint8_t t = 0 ; 
  int v = 0;
  USB.ON();
  RTC.ON();
  xbeeZB.ON();
  /*
    USB.print(F("RTC_IS_IN_SYNCC= "));
    USB.println(RTC_IS_IN_SYNCC);
    USB.print(F(" irl time"));
    USB.println(IRL_time);
  */
  //USB.println(F("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"));
  if ((RTC_IS_IN_SYNCC == false) && (IRL_time == false))
  {
    USB.println(F("STARTING RTC SYNC"));
    while ( t == 0 && v <= incercari)
    {
      // set RTC time
      error = xbeeZB.setRTCfromMeshlium(MESHLIUM_ADDRESS);
      // check flag
      if ( error == 0 )
      {
        USB.println(F("SET RTC ok. "));
        t = 1;
        RTC_IS_IN_SYNCC = true;
      }
      else
      {
        USB.print(v);
        USB.print("/");
        USB.print(incercari);
        USB.println(F(" SET RTC error. "));
        delay(1000);
        v++;
      }
    }
    if (t == 0)
    {
      USB.println(F("RTC sync FAILED many times , aborting process for now"));
      USB.print(F("RTC Time:"));
      USB.println(RTC.getTime());
    }
    else
    {
      USB.print(F("RTC Time:"));
      USB.println(RTC.getTime());
    }

    delay(1000);
  }
  else
  {
    delay(1);
  }
}








//printError - prints the error related to OTA

void printErrorxx(uint8_t err)
{
  switch (err)
  {
  case 1:  USB.println(F("SD not present"));
    break;
  case 2:  USB.println(F("error downloading UPGRADE.TXT"));
    break;
  case 3:  USB.println(F("error opening FTP session"));
    break;
  case 4:  USB.println(F("filename is different to 7 bytes"));
    break;
  case 5:  USB.println(F("no 'FILE' pattern found"));
    break;
  case 6:  USB.println(F("'NO_FILE' is the filename"));
    break;
  case 7:  USB.println(F("no 'PATH' pattern found"));
    break;
  case 8:  USB.println(F("no 'SIZE' pattern found"));
    break;
  case 9:  USB.println(F("no 'VERSION' pattern found"));
    break;
  case 10: USB.println(F("invalid program version number"));
    break;
  case 11: USB.println(F("file size does not match in UPGRADE.TXT and server"));
    break;
  case 12: USB.println(F("error downloading binary file: server file size is zero"));
    break;
  case 13: USB.println(F("error downloading binary file: reading the file size"));
    break;
  case 14: USB.println(F("error downloading binary file: SD not present"));
    break;
  case 15: USB.println(F("error downloading binary file: error creating the file in SD"));
    break;
  case 16: USB.println(F("error downloading binary file: error opening the file"));
    break;
  case 17: USB.println(F("error downloading binary file: error setting the pointer of the file"));
    break;
  case 18: USB.println(F("error downloading binary file: error opening the GET connection"));
    break;
  case 19: USB.println(F("error downloading binary file: error module returns error code after requesting data"));
    break;
  case 20: USB.println(F("error downloading binary file: error  getting packet size"));
    break;
  case 21: USB.println(F("error downloading binary file: packet size mismatch"));
    break;
  case 22: USB.println(F("error downloading binary file: error writing SD"));
    break;
  case 23: USB.println(F("error downloading binary file: no more retries getting data"));
    break;
  case 24: USB.println(F("error downloading binary file: size mismatch"));
    break;
  default : USB.println(F("unknown"));

  }
}








void OTA_setup_check( int att=1)     // asta reprogrameaza in practica , variabila att numara de cate ori va incerca re se reprogrameza fara succes pana se va renunta 
{

  int q=1;
  bool w=false;
  while( q<=att && w==false) 
  {

    USB.println(  PWR.getBatteryLevel()   );
          break;
    USB.print(F("iteration: "));
    USB.print(q);
    USB.print(F(" / "));
    USB.println(att);
  // show program ID
  Utils.getProgramID(programID);
  USB.println(F("-----------------------------"));
  USB.print(F("Program id: "));
  USB.println(programID);

  // show program version number
  USB.print(F("Program version: "));
  USB.println(Utils.getProgramVersion(), DEC);
  USB.println(F("-----------------------------"));

  status = Utils.checkNewProgram();

  switch (status)
  {
  case 0:
    USB.println(F("REPROGRAMMING ERROR"));
    Utils.blinkRedLED(300, 3);
    q++;
    break;

  case 1:
    USB.println(F("REPROGRAMMING OK"));
    Utils.blinkGreenLED(300, 3);
    w=true;
    break;

  default:
    USB.println(F("RESTARTING"));
    Utils.blinkGreenLED(500, 1);
    q++;
  }
  }
  
}



















// initializare

void setup()
{
  
  USB.ON();
  USB.println(  PWR.getBatteryLevel()   );
  RTC.ON();
  OTA_setup_check(10);
  // Setting date and time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("19:01:01:03:00:00:00");
  USB.println(RTC.getTime());

  pregatitor_XBEE();
  //USB.print(F("QAZ= "));
  //USB.println(RTC_IS_IN_SYNCC);
  RTC_SET(RTC_ATEMPTS );
  USB.println(RTC.getTime());


  ////////////////////////////////////////////////////////////////////////////////////////////////////
  // show program ID
  Utils.getProgramID(programID);
  USB.println(F("-----------------------------"));
  USB.print(F("Program id: "));
  USB.println(programID);

  // show program version number
  USB.print(F("Program version: "));
  USB.println(Utils.getProgramVersion(), DEC);
  USB.println(F("-----------------------------"));

  status = Utils.checkNewProgram();

  switch (status)
  {
  case 0:
    USB.println(F("REPROGRAMMING ERROR"));
    Utils.blinkRedLED(300, 3);
    break;

  case 1:
    USB.println(F("REPROGRAMMING OK"));
    Utils.blinkGreenLED(300, 3);
    break;

  default:
    USB.println(F("RESTARTING"));
    Utils.blinkGreenLED(500, 1);
  }

  POWER_LVL_INSPECTOR();




  USB.println(RTC.getTime());
  USB.println(F("SD_CARD_ARHIVE_V1_RTC_OTAP_4G_BAREBONES"));


  // Set SD ON
  SD.ON();

  if (sentence == 1)
  {
    // Delete file
    sd_answer = SD.del(filename);

    if (sd_answer == 1)
    {
      USB.println(F("file deleted"));
    } else
    {
      USB.println(F("file NOT deleted"));
    }
  }
  // Create file IF id doent exist
  sd_answer = SD.create(filename);

  if (sd_answer == 1)
  {
    USB.println(F("file created"));
  } else
  {
    USB.println(F("file NOT created"));
  }

  USB.print("loop cycle time[s]:= ");
  USB.println(cycle_time2);
  sd_answer = SD.appendln(filename, "--------------------------------------------------------------------------------------------------------------");
  if (sd_answer == 1)
  {
    USB.println(F("writeing is OK"));
  } else
  {
    USB.println(F("writeing is haveing errors"));
  }

  USB.println(F("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"));
  USB.println(F("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"));
  USB.println(F("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"));


  // pm
  USB.ON();

}




// main program
void loop()
{
  RTC_SET(RTC_ATEMPTS );// try to get TRC if it failed in the initial setup
  // get actual time before loop
  prev = millis();

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  frame.createFrame(ASCII, node_ID); // frame1 de  stocat
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  // set frame fields (Time from RTC)
  frame.showFrame();

  ALL_IN_ONE_FRAME_HANDLER();
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





/// NU UMBLA AICI!
  cycle_time = cycle_time2 - b - 5;
  if (cycle_time < 10) {
    cycle_time = 15;
  }
  USB.print("cycle time= ");
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
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }
  rtc_str[6] = y[0];
  rtc_str[7] = y[1];

  x = cycle_time / 3600 % 3600; // h
  itoa(x, y, 10);
  if (x < 10) {
    y[1] = y[0];
    y[0] = '0';
  }
  rtc_str[3] = y[0];
  rtc_str[4] = y[1];

  ///-------------

  // Go to deepsleep

  ////////////////////////////////////////////////
  // 5. Sleep
  ////////////////////////////////////////////////
  USB.println(F("5. Enter deep sleep..."));
  USB.print("X");
  USB.print(rtc_str);
  USB.println("X");

  //USB.println("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
  USB.OFF();
  delay(20000);
  //PWR.deepSleep(rtc_str, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.println(F("6. Wake up!!\n\n"));


}





