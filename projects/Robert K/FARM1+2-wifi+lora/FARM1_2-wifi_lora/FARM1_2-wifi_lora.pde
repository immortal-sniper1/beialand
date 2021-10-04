#include <WaspFrame.h>
#include <WaspWIFI_PRO.h>
#include <WaspLoRaWAN.h>
#include <WaspSensorGas_Pro.h>
#include <WaspPM.h>


/////////// NU UMBLA AICI!!!!!
// define variable SD
// define file name: MUST be 8.3 SHORT FILE NAME
char filename[] = "FILE1.TXT";
char *time_date; // stores curent date + time
int x, b, cycle_time;
uint8_t error;
uint8_t status = false;
char y[3];
uint8_t sd_answer;
bool sentence = false; // true for deletion on reboot  , false for data appended to end of file
bool IRL_time = false; //  true for no external date source
char rtc_str[] = "00:00:00:05";    // 11 char ps incepe de la 0
unsigned long prev, previous, previousSendFrame;
bool RTC_SUCCES;
int loop_count = 0;

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET1;
uint8_t socketLoRa = SOCKET0;
///////////////////////////////////////
// choose URL settings
///////////////////////////////////////
char type[] = "http";
char host[] = "82.78.81.178";
char port[] = "80";
///////////////////////////////////////
// FTP SERVER settings
///////////////////////////////////////
char ftp_server[] = "ftp.agile.ro";
char ftp_port[] = "21";
char ftp_user[] = "robi@agile.ro";
char ftp_pass[] = "U$d(SEFA8+UC";
///////////////////////////////////////

char programID[10];




////////////

uint8_t errorSetTimeServer, errorEnableTimeSync, errorSetGMT, errorsetTimefromWiFi, errorsetSSID, errorsetpass, errorsoftreset, errorresetdef, errorSendFrame, errorrequestOTA;
uint8_t statusWiFiconn, statusSetTimeServer, statusTimeSync, statusSetGMT, statussetTimefromWiFi;

uint8_t errorLoRa, errorLoRa_config;



// choose NTP server settings
///////////////////////////////////////
char SERVERS[][25] =
{
  "time.nist.gov",
  "wwv.nist.gov"
};
char server[25], serbuf[64];
///////////////////////////////////////

// Define Time Zone from -12 to 12 (i.e. GMT+2)
///////////////////////////////////////
uint8_t time_zone = 4;///for ROMANIA
///////////////////////////////////////




//variabile LORA
// Device parameters for Back-End registration
////////////////////////////////////////////////////////////
char DEVICE_EUI[]  = "0102030405060909";   // eui farm 1      0102030405060809                                      eui farm 2    0102030405060909
char APP_EUI[] = "70B3D57ED003FB39";
char APP_KEY[] = "7E0FC98B59786166B3A6866BC727F48E";      //appkey pt farm1    BA6F80723C2198135675AC0267DDA704            pt farm2  7E0FC98B59786166B3A6866BC727F48E


////////////////////////////////////////////////////////////

// Define port to use in Back-End: from 1 to 223
uint8_t PORTLORA = 3;
uint8_t datarate = 5;
//end-variabile LORA
// Define data payload to send (maximum is up to data rate)



///// EDITEAZA AICI DOAR
char node_ID[] = "FARM2";
int count_trials = 0;
int N_trials = 2;
char ESSID[] = "LANCOMBEIA";
char PASSW[] = "beialancom";
uint8_t max_atemptss = 10; // nr de max de trame de retrimit deodata
uint8_t resend_f = 2; // frame resend atempts
int cycle_time2 = 1120; // in seconds






Gas CO(SOCKET_B);
Gas NH3(SOCKET_C);
Gas CH4(SOCKET_F);









// subprograme



////////////////////FUNCTII///////////////////////////
/////////////////////////////FUNCTII WIFI///////////////////////////
void switchon_WiFi()
{
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
}

boolean check_WiFi_conn()
{ // 2. Check if connected
  //////////////////////////////////////////////////

  // get actual time
  previous = millis();

  // check connectivity
  statusWiFiconn =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (statusWiFiconn == true)
  {
    USB.print(F("2. WiFi is connected OK"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
  }
  else
  {
    USB.print(F("2. WiFi is connected ERROR"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
    Utils.blinkRedLED(200, 10);
  }
  return statusWiFiconn;
}

void switchoff_WiFi()
{
  USB.println(F("4. WiFi switched OFF\n"));
  WIFI_PRO.OFF(socket);


  USB.println(F("-----------------------------------------------------------"));
  USB.println(F("Once the module has the correct Time Server Settings"));
  USB.println(F("it is always possible to request for the Time and"));
  USB.println(F("synchronize it to the Waspmote's RTC"));
  USB.println(F("-----------------------------------------------------------\n"));
}

void WiFi_resetdefault()
{
  errorresetdef = WIFI_PRO.resetValues();

  if (errorresetdef == 0)
  {
    USB.println(F("2. WiFi reset to default"));
  }
  else
  {
    USB.println(F("2. WiFi reset to default ERROR"));
  }
}

void setSSID_pass_reset()
{ // 3. Set ESSID
  //////////////////////////////////////////////////
  errorsetSSID = WIFI_PRO.setESSID(ESSID);

  if (errorsetSSID == 0)
  {
    USB.println(F("3. WiFi set ESSID OK"));
  }
  else
  {
    USB.println(F("3. WiFi set ESSID ERROR"));
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
  errorsetpass = WIFI_PRO.setPassword(WPA2, PASSW);

  if (errorsetpass == 0)
  {
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }
  else
  {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }


  //////////////////////////////////////////////////
  // 5. Software Reset
  // Parameters take effect following either a
  // hardware or software reset
  //////////////////////////////////////////////////
  errorsoftreset = WIFI_PRO.softReset();

  if (errorsoftreset == 0)
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
int  WiFi_sendFrame()
{
  uint8_t ssent = 0;
  // 3.2. Send Frame
  ///////////////////////////////
  // http frame
  previousSendFrame = millis();
  errorSendFrame = WIFI_PRO.sendFrameToMeshlium(type, host, port, frame.buffer, frame.length); // frame
  // check response
  if (errorSendFrame == 0)
  {
    USB.println(F("HTTP OK"));
    ssent = 1;
    USB.print(F("HTTP Time from OFF state (ms):"));
    USB.println(millis() - previousSendFrame);
    USB.println(F("ASCII FRAME SEND OK"));
  } else
  {
    USB.println(F("Error calling 'getURL' function"));
    ssent = 0;
    WIFI_PRO.printErrorCode();
  }
  return ssent;
}
void WiFi_print_status()
{
  USB.println(F("2.1. Connection Status:"));
  USB.println(F("-------------------------------"));
  USB.print(F("Rate (Mbps):"));
  USB.println(WIFI_PRO._rate);
  USB.print(F("Signal Level (%):"));
  USB.println(WIFI_PRO._level);
  USB.print(F("Link Quality(%):"));
  USB.println(WIFI_PRO._quality);
  USB.println(F("-------------------------------"));
}

void WiFi_setup()
{ switchon_WiFi();
  WiFi_resetdefault();
  setSSID_pass_reset();
}
/////////////////////////////ALTE FUNCTII DE START///////////////////////////
void start_prog()
{
  USB.ON();
  USB.println(F("Start program"));
  USB.println(F("***************************************"));
  USB.println(F("Once the module is set with one or more"));
  USB.println(F("AP settings, it attempts to join the AP"));
  USB.println(F("automatically once it is powered on"));
  USB.println(F("Refer to example 'WIFI_PRO_01' to configure"));
  USB.println(F("the WiFi module with proper settings"));
  USB.println(F("***************************************"));
}
/////////////////////////////FUNCTII RTC///////////////////////////
boolean RTC_setTimeServer(char *server)
{
  // 3.1. Set NTP Server (option1)
  errorSetTimeServer = WIFI_PRO.setTimeServer(1, server);

  // check response
  if (errorSetTimeServer == 0)
  {
    // sprintf (serbuf, "3.1. Time Server %s set OK \r\n", server);
    USB.print(F("3.1. Time Server %s set OK \r\n"));
    USB.println(server);
    statusSetTimeServer = true;
  }
  else
  {
    USB.println(F("3.1. Error calling 'setTimeServer' function"));
    WIFI_PRO.printErrorCode();
    statusSetTimeServer = false;
  }
  return statusSetTimeServer;
}

boolean RTC_EnableTimeSync()
{
  errorEnableTimeSync = WIFI_PRO.timeActivationFlag(true);

  // check response
  if ( errorEnableTimeSync == 0 )
  {
    USB.println(F("3.3. Network Time-of-Day Activation Flag set OK"));
    statusTimeSync = true;
  }
  else
  {
    USB.println(F("3.3. Error calling 'timeActivationFlag' function"));
    WIFI_PRO.printErrorCode();
    statusTimeSync = false;
  }
  return statusTimeSync;
}

void RTC_setGMT()
{
  errorSetGMT = WIFI_PRO.setGMT(time_zone);

  // check response
  if (errorSetGMT == 0)
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

void RTC_init()
{
  // Init RTC
  RTC.ON();
  USB.print(F("Current RTC settings:"));
  USB.println(RTC.getTime());
}


void RTC_setTimefromWiFi()
{
  // 3.1. Open FTP session
  errorsetTimefromWiFi = WIFI_PRO.setTimeFromWIFI();

  // check response
  if (errorsetTimefromWiFi == 0)
  {
    USB.print(F("3. Set RTC time OK. Time:"));
    USB.println(RTC.getTime());
    statussetTimefromWiFi = true;
  }
  else
  {
    USB.println(F("3. Error calling 'setTimeFromWIFI' function"));
    WIFI_PRO.printErrorCode();
    statussetTimefromWiFi = false;
  }
}



//NU MODIFICA NIMIC IN SUBPROGRAME!
int trimitator_WIFI()
{
  int ssent;
  // get actual time before wifi
  previous = millis();
  //////////////////////////////////////////////////
  // 4. Switch ON
  error = WIFI_PRO.ON(socket);
  b = 0;
qwerty:
  if (error == 0)
  {
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }
  status = WIFI_PRO.isConnected();
  // check if module is connected
  if (status == true)
  {
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
    USB.print(F(" (time it took for the WIFI status check)"));

    // 3.2. Send Frame
    ///////////////////////////////
    // http frame
    previous = millis();
    error = WIFI_PRO.sendFrameToMeshlium(type, host, port, frame.buffer, frame.length); // frame
    // check response
    if (error == 0)
    {
      USB.println(F("HTTP OK"));
      ssent = 1;
      USB.print(F("HTTP Time from OFF state (ms):"));
      USB.println(millis() - previous);
      USB.println(F("ASCII FRAME SEND OK"));
    } else
    {
      USB.println(F("Error calling 'getURL' function"));
      ssent = 0;
      WIFI_PRO.printErrorCode();
    }
  } else
  {
    USB.print(F("WiFi is connected ERROR"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
  }
  if (ssent == 0 && b <= resend_f)
  {
    delay(5000);
    b++;
    goto qwerty;
  }

  WIFI_PRO.OFF(socket);
  USB.println(F("WiFi switched OFF\n\n"));
  b = (millis() - prev) / 1000;
  USB.print(F("loop execution time[s]: "));
  USB.println(b);
  return ssent;
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

  USB.print(F("loop cycle time[s]:= "));
  USB.println(cycle_time2);
  sd_answer = SD.appendln(filename_st, "----------------------------------------------------------------------------");
  if (sd_answer == 1)
  {
    USB.println(F("writeing is OK"));
  } else
  {
    USB.println(F("writeing is haveing errors"));
  }


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
  } else {
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



void try_RTC_set()
{

  //////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////
  USB.println(F("STARTING RTC SET WITH WIFI:"));
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {
    USB.println(F("1. WiFi switched ON"));
  } else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }

  //////////////////////////////////////////////////
  // 2. Check if connected
  //////////////////////////////////////////////////

  // get actual time
  previous = millis();

  // check connectivity
  status = WIFI_PRO.isConnected();

  // Check if module is connected
  if (status == true)
  {
    USB.print(F("2. WiFi is connected OK"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
  } else
  {
    USB.print(F("2. WiFi is connected ERROR"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
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
      RTC_SUCCES = true;
    } else
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






void IN_LOOP_RTC_CHECK( bool RTC_SUCCES)
{
  if (  (RTC_SUCCES = false) || (intFlag & RTC_INT)  )
  {
    try_RTC_set();
  }
}





void WiFi_init()
{
  // 1. Switch ON the WiFi module
  //////////////////////////////////////////////////
  error = 1;
  while (error == 1)
  {
    error = WIFI_PRO.ON(socket);


    if (error == 0)
    {
      USB.println(F("1. WiFi switched ON"));
    } else
    {
      USB.println(F("1. WiFi did not initialize correctly"));
    }
  }

  // 2. Reset to default values
  //////////////////////////////////////////////////
  error = 1;
  while (error == 1)
  {
    error = WIFI_PRO.resetValues();

    if (error == 0)
    {
      USB.println(F("2. WiFi reset to default"));
    } else {
      USB.println(F("2. WiFi reset to default ERROR"));
    }
  }
  // 3. Set ESSID
  //////////////////////////////////////////////////
  error = 1;
  while (error == 1)
  {
    error = WIFI_PRO.setESSID(ESSID);

    if (error == 0)
    {
      USB.println(F("3. WiFi set ESSID OK"));
    } else {
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
  error = 1;
  while (error == 1)
  {
    error = WIFI_PRO.setPassword(WPA2, PASSW);

    if (error == 0)
    {
      USB.println(F("4. WiFi set AUTHKEY OK"));
    } else
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
  } else {
    USB.println(F("5. WiFi softReset ERROR"));
  }

  USB.println(F("*******************************************"));
  USB.println(F("Once the module is configured with ESSID"));
  USB.println(F("and PASSWORD, the module will attempt to "));
  USB.println(F("join the specified Access Point on power up"));
  USB.println(F("*******************************************\n"));
}






void all_in_1_frame_process()
{
  uint8_t ssent = 0;
  ssent = WiFi_sendFrame();
  trimitator_WIFI();


  scriitor_SD(filename, ssent);
}





void OTA_setup_check( int att = 1)   // asta reprogrameaza in practica , variabila att numara de cate ori va incerca re se reprogrameza fara succes pana se va renunta
{
  int q = 1;
  bool w = false;
  while ( q <= att && w == false)
  {
    USB.println(" ");
    USB.print(F("atempt: "));
    USB.print(q);
    USB.print(F("/"));
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
        w = true;
        break;

      default:
        USB.println(F("RESTARTING"));
        Utils.blinkGreenLED(500, 1);
        q++;
    }
  }

}








void OTA_check_loop(char server[] = ftp_server,     char port[] = ftp_port,    char user[] = ftp_user,    char password[] = ftp_pass  )
{
  USB.print(F("Program version: "));
  USB.println(Utils.getProgramVersion(), DEC);
  //////////////////////////////////////////////////
  // 4. OTA request
  //////////////////////////////////////////////////

  //////////////////////////////
  // 4.1. Switch ON
  //////////////////////////////

  SD.ON();
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }


  //////////////////////////////
  // 4.2. Check if connected
  //////////////////////////////
  // get actual time
  previous = millis();

  // check connectivity
  status =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (status == true)
  {
    USB.print(F("2. WiFi is connected OK"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);


    USB.println(F("2.1. Connection Status:"));
    USB.println(F("-------------------------------"));
    USB.print(F("Rate (Mbps):"));
    USB.println(WIFI_PRO._rate);
    USB.print(F("Signal Level (%):"));
    USB.println(WIFI_PRO._level);
    USB.print(F("Link Quality(%):"));
    USB.println(WIFI_PRO._quality);
    USB.println(F("-------------------------------"));

    //////////////////////////////
    // 4.3. Request OTA
    //////////////////////////////
    USB.println(F("2.2. Request OTA..."));
    error = WIFI_PRO.requestOTA( server, port, user, password);

    USB.print(F("=================="));
    USB.println(error , DEC);
    // If OTA fails, show the error code
    WIFI_PRO.printErrorCode();
    Utils.blinkRedLED(1300, 3);

  }
  else
  {
    USB.print(F("2. WiFi is connected ERROR"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
    Utils.blinkRedLED(200, 10);
  }


  //////////////////////////////////////////////////
  // 5. Switch OFF
  //////////////////////////////////////////////////
  WIFI_PRO.OFF(socket);
  USB.println(F("3. WiFi switched OFF"));
  USB.println(F("OTA_check_loop is done"));
  // show program version number
  USB.print(F("Program version: "));
  USB.println(Utils.getProgramVersion(), DEC);
  SD.OFF();
  delay(1000);


}















void RTC_setup()   // asa era in void setup si am pus tot in functia asta
{
  int NServers = sizeof(SERVERS) / sizeof(SERVERS[0]);
  //sprintf (serbuf, "The number of available servers in the list is %d \r\n", NServers);
  USB.print(F("The number of available servers in the list is %d \r\n"));
  USB.println(NServers);
  int plk = 0;
  start_prog();
  do
  { plk++;
    //sprintf (serbuf, "We reached trial %d \r\n", plk);
    USB.println(F("We reached trial %d \r\n"));
    USB.println(plk);
    WiFi_setup();
    statusWiFiconn = check_WiFi_conn();
    // Check if module is connected
    if (statusWiFiconn == true)
    {
      for (int cnt = 0; cnt < NServers; cnt++)
        statusSetTimeServer = RTC_setTimeServer(SERVERS[cnt]);
      if (statusSetTimeServer == true)
      {
        statusTimeSync = RTC_EnableTimeSync();
        if (statusTimeSync == true)
        { RTC_setGMT();
          goto SWITCHOFF;
        }
      }
    }
SWITCHOFF:
    switchoff_WiFi();
  }
  while ((statusSetTimeServer == false) && (plk < N_trials));
  delay(5000);
  RTC_init();
}




/////////////////MESUREMENT////////////////////////////////

void measurerr()
{


  float temperature;
  float humidity;
  float pressure;

  float concCO;
  float concNH3;
  float concCH4;

  int OPC_status;
  int OPC_measure;
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
  delay(1000);
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

  all_in_1_frame_process();



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

  all_in_1_frame_process();


}






















// initializare

void setup()
{
  USB.ON();
  RTC.ON(); // Executes the init process
  USB.println(F("START"));
  USB.println(F("FARM1/2+wifi+lora"));
  //data_maker( 10000 ,  filename  );


  // Utils.setProgramVersion( verr );

  //OTA_setup_check(10);
  RTC_setup();///////////////include WiFi_setup();

  USB.print(F("Current RTC settings:"));
  USB.println(RTC.getTime());


  // Set SD ON
  SD_TEST_FILE_CHECK();
  // pm




}





// main program
void loop()
{
  // get actual time before loop
  prev = millis();
  loop_count++;
  if (loop_count > 2000000000)
    // 2147483647
  {
    loop_count = 0;
  }
  USB.print(F("loop_count: "));
  USB.println( loop_count);


  measurerr();



  //OTA_check_loop();

  ///////////////  NU UMBLA AICI !!!
  RTC.setAlarm2("01:10:00", RTC_ABSOLUTE, RTC_ALM2_MODE1); // activare in fiecare duminica la 10:00 dimineata
  IN_LOOP_RTC_CHECK(  RTC_SUCCES);
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


