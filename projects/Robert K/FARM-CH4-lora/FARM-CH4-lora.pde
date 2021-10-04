#include <WaspFrame.h>
#include <WaspWIFI_PRO.h>
#include <WaspSensorPrototyping_v20.h>
#include <WaspLoRaWAN.h>

/////////// NU UMBLA AICI!!!!!
// define variable SD
// define file name: MUST be 8.3 SHORT FILE NAME
char filename[] = "FILE1.TXT";
char *time_date; // stores curent date + time
int x, b, cycle_time;
uint8_t error;
uint8_t status = false;
char y[3];
uint8_t sd_answer, ssent;
bool sentence = false; // true for deletion on reboot  , false for data appended to end of file
bool IRL_time = false; //  true for no external date source
char rtc_str[] = "00:00:00:05";    // 11 char ps incepe de la 0
unsigned long prev, previous, previousSendFrame;
bool RTC_SUCCES;

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET0;
uint8_t socketLoRa = SOCKET1;
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
int8_t answer, verr = 13;
int VV1;
int uart_data_ch[100];

// UART
// Create WaspUART object
WaspUART uart = WaspUART();

// Variable to store function returns
uint8_t answer13;

// Variable to store connection to UART
// AUX1(1) or AUX2(2)
uint8_t auxiliar = 1;

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
char DEVICE_EUI[]  = "0102030405060709";
char APP_EUI[] = "70B3D57ED003FB39";
char APP_KEY[] = "47F42DD94AC40EA2ED7D16DB71172080";
////////////////////////////////////////////////////////////

// Define port to use in Back-End: from 1 to 223
uint8_t PORTLORA = 3;
uint8_t datarate = 5;
//end-variabile LORA
// Define data payload to send (maximum is up to data rate)



/*
  #define SGX_V    ?
  char const str_NEW[] PROGMEM = "SGX_V2"; // ?
  #define SGX_CH4    ?
  char const str_NEW2[] PROGMEM = "SGX_CH42"; // ?
*/






///// EDITEAZA AICI DOAR
char node_ID[] = "FARM4";
int count_trials = 0;
int N_trials = 2;
char ESSID[] = "LANCOMBEIA";
char PASSW[] = "beialancom";
uint8_t max_atemptss = 10; // nr de max de trame de retrimit deodata
uint8_t resend_f = 2; // frame resend atempts
int cycle_time2 = 1150; // in seconds




// subprograme



/////////////////////LORA/////////////////////////

void LoRa_switchon()
{ // 1. Switch on
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.ON(socketLoRa);

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("1. Switch ON OK"));
  }
  else
  {
    USB.print(F("1. Switch ON error = "));
    USB.println(errorLoRa, DEC);
    errorLoRa_config = 1;
  }
}

void LoRa_adaptiveDR()
{ // 2. Enable Adaptive Data Rate (ADR)
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.setADR("on");

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.print(F("2. Adaptive Data Rate enabled OK. "));
    USB.print(F("ADR:"));
    USB.println(LoRaWAN._adr, DEC);
  }
  else
  {
    USB.print(F("2. Enable data rate error = "));
    USB.println(errorLoRa, DEC);
  }

}
void LoRa_changeDR()
{ // 2. Change data rate
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.setDataRate(datarate);

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("3. Data rate set OK"));
  }
  else
  {
    USB.print(F("3. Data rate set error= "));
    USB.println(errorLoRa, DEC);
    errorLoRa_config = 2;
  }

}

void LoRa_getDR()

{ errorLoRa = LoRaWAN.getDataRate();

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.print(F("4. Data rate get OK. "));
    USB.print(F("Data rate index:"));
    USB.println(LoRaWAN._dataRate, DEC);
  }
  else
  {
    USB.print(F("4. Data rate get error = "));
    USB.println(errorLoRa, DEC);
  }

}
void LoRa_setDeviceEUI()
{ // 3. Set Device EUI
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("5. Device EUI set OK"));
  }
  else
  {
    USB.print(F("5. Device EUI set error = "));
    USB.println(errorLoRa, DEC);
    errorLoRa_config = 3;
  }

}

void LoRa_setAppEUI()
{ // 4. Set Application EUI
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.setAppEUI(APP_EUI);

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("6. Application EUI set OK"));
  }
  else
  {
    USB.print(F("6. Application EUI set error = "));
    USB.println(errorLoRa, DEC);
    errorLoRa_config = 4;
  }
}

void LoRa_AppSessionKey()
{ // 5. Set Application Session Key
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.setAppKey(APP_KEY);

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("7. Application Key set OK"));
  }
  else
  {
    USB.print(F("7. Application Key set error = "));
    USB.println(errorLoRa, DEC);
    errorLoRa_config = 5;
  }
}

void LoRa_joinOTAA()
{ errorLoRa = LoRaWAN.joinOTAA();

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("8. Join network OK"));
  }
  else
  {
    USB.print(F("8. Join network error = "));
    USB.println(error, DEC);
    errorLoRa_config = 6;
  }
}

void LoRa_saveconfig()
{ // 7. Save configuration
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.saveConfig();

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("9. Save configuration OK"));
  }
  else
  {
    USB.print(F("9. Save configuration error = "));
    USB.println(errorLoRa, DEC);
    errorLoRa_config = 7;
  }
}

void LoRa_switchoff()
{
  // 8. Switch off
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.OFF(socketLoRa);

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("10. Switch OFF OK"));
  }
  else
  {
    USB.print(F("10. Switch OFF error = "));
    USB.println(error, DEC);
    errorLoRa_config = 8;
  }
}

void LoRa_joinABP_send()

{ // 2. Join network
  //////////////////////////////////////////////

  errorLoRa = LoRaWAN.joinABP();

  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("2. Join network OK"));
    LoRa_changeDR();
    LoRa_getDR();
    LoRa_sendconfirmed();

  }
  else
  {
    USB.print(F("2. Join network error = "));
    USB.println(errorLoRa, DEC);
  }

}

void LoRa_sendconfirmed()

{ errorLoRa = LoRaWAN.sendConfirmed(PORTLORA, frame.buffer, frame.length);
  ssent = 0;

  //////////////////////////////////////////////
  // 3. Send Confirmed packet
  //////////////////////////////////////////////



  // Error messages:
  //    /*
  //     * '6' : Module hasn't joined a network
  //     * '5' : Sending error
  //     * '4' : Error with data length
  //     * '2' : Module didn't response
  //     * '1' : Module communication error
  //     */
  // Check status
  if ( errorLoRa == 0 )
  {
    USB.println(F("3. Send Confirmed packet OK"));
    ssent = 1;
    if (LoRaWAN._dataReceived == true)
    {
      USB.print(F("   There's data on port number "));
      USB.print(LoRaWAN._port, DEC);
      USB.print(F(".\r\n   Data: "));
      USB.println(LoRaWAN._data);
    }
  }

  else
  {
    USB.print(F("3. Send Confirmed packet error = "));
    USB.println(errorLoRa, DEC);
    ssent = 0;
  }



}

/////////////////////LORA/////////////////////////



void RTC_setup()   // asa era in void setup si am pus tot in functia asta
{
  int NServers = sizeof(SERVERS) / sizeof(SERVERS[0]);
  sprintf (serbuf, "The number of available servers in the list is %d \r\n", NServers);
  USB.println(serbuf);
  int plk = 0;
  start_prog();
  do
  { plk++;
    sprintf (serbuf, "We reached trial %d \r\n", plk);
    USB.println(serbuf);
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
boolean WiFi_sendFrame()
{
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
  { sprintf (serbuf, "3.1. Time Server %s set OK \r\n", server);
    USB.println(serbuf);
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
  USB.print("loop execution time[s]: ");
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
    USB.println("SD storage done with no errors");
  } else {
    USB.print("SD sorage done with:");
    USB.print(15 - coruption);
    USB.println(" errors");
  }
}







void data_maker( int x , char filename_a[]  )
{
  SD.ON();

  for (int ii = 1 ; ii <= x ; ii++) //10MB per x=1
  {
    USB.println(" cycles: ");
    USB.println(ii);
    USB.println("/");
    USB.println(x);
    for (int g = 0; g < 324 ; g++)
    {
      SD.appendln(filename_a, " ");
      USB.println(" subcycles: ");
      USB.println(g);
      USB.println("/324");
      for (int k = 0 ; k < 324 ; k++)
        SD.append(filename_a, "eokfumpwqroifv4478fcmwpocfumwqgif17nwqrpn5fcmwifcwuifw7unpcwogr2rqfcnqwogfqprwfmqwfhwdjfbplpkp13pl ");   //100 byte per line
    }
  }
  SD.OFF();

}









/*
  void pregatitor_RTC_set()  // trebuie rulat 1 data in setup apot se poate rula  try_RTC_set() de n ori
  {
  int atempts = 0;
  //////////////////////////////////////////////////
  // 2. Check if connected
  //////////////////////////////////////////////////
  error = WIFI_PRO.ON(socket);
  if (error == 0)
  {
    USB.println(F("1. WiFi switched ON"));
  } else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }
  while (status == false)
  {
    WiFi_init(); // initialize Wi-Fi communication
    // get actual time
    previous = millis();
    atempts++;
    USB.print(F("atempt: "));
    USB.println(atempts);
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
    } else
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
    } else
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
      if (error == 0)
      {
        USB.println(F("3.3. Network Time-of-Day Activation Flag set OK"));
      } else
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
      } else
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
  USB.println(
    F("-----------------------------------------------------------\n"));
  }
*/




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
  ssent = trimitator_WIFI();


    USB.println(F("WIFI/4G failed to send atempting with LORAWAN "));
    LoRa_switchon();
    LoRa_joinABP_send();
    LoRa_switchoff();
    ssent = 3;
  

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





/*
  switch (error)
  {
    case ERROR_CODE_0000: USB.println(F("Timeout")); break;
    case ERROR_CODE_0010: USB.println(F("SD not present")); break;
    case ERROR_CODE_0011: USB.println(F("file not created")); break;
    case ERROR_CODE_0012: USB.println(F("SD error open file")); break;
    case ERROR_CODE_0013: USB.println(F("SD error set file offset")); break;
    case ERROR_CODE_0014: USB.println(F("SD error writing")); break;
    case ERROR_CODE_0020: USB.println(F("rx buffer full")); break;
    case ERROR_CODE_0021: USB.println(F("error downloading UPGRADE.TXT")); break;
    case ERROR_CODE_0022: USB.println(F("filename in UPGRADE.TXT is not a 7-byte name")); break;
    case ERROR_CODE_0023: USB.println(F("no FILE label is found in UPGRADE.TXT")); break;
    case ERROR_CODE_0024: USB.println(F("NO_FILE is defined as FILE in UPGRADE.TXT")); break;
    case ERROR_CODE_0025: USB.println(F("no PATH label is found in UPGRADE.TXT")); break;
    case ERROR_CODE_0026: USB.println(F("no SIZE label is found in UPGRADE.TXT")); break;
    case ERROR_CODE_0027: USB.println(F("no VERSION label is found in UPGRADE.TXT")); break;
    case ERROR_CODE_0028: USB.println(F("version indicated in UPGRADE.TXT is lower/equal to Waspmote's version")); break;
    case ERROR_CODE_0029: USB.println(F("file size does not match the indicated in UPGRADE.TXT")); break;
    case ERROR_CODE_0030: USB.println(F("error downloading binary file")); break;
    case ERROR_CODE_0031: USB.println(F("invalid data length")); break;
    case ERROR_CODE_0041: USB.println(F("Illegal delimiter")); break;
    case ERROR_CODE_0042: USB.println(F("Illegal value")); break;
    case ERROR_CODE_0043: USB.println(F("CR expected ")); break;
    case ERROR_CODE_0044: USB.println(F("Number expected")); break;
    case ERROR_CODE_0045: USB.println(F("CR or â€˜,â€™ expected")); break;
    case ERROR_CODE_0046: USB.println(F("DNS expected")); break;
    case ERROR_CODE_0047: USB.println(F("â€˜:â€™ or â€˜~â€™ expected")); break;
    case ERROR_CODE_0048: USB.println(F("String expected")); break;
    case ERROR_CODE_0049: USB.println(F("â€˜:â€™ or â€˜=â€™ expected")); break;
    case ERROR_CODE_0050: USB.println(F("Text expected")); break;
    case ERROR_CODE_0051: USB.println(F("Syntax error")); break;
    case ERROR_CODE_0052: USB.println(F("â€˜,â€™ expected")); break;
    case ERROR_CODE_0053: USB.println(F("Illegal cmd code")); break;
    case ERROR_CODE_0054: USB.println(F("Error when setting parameter")); break;
    case ERROR_CODE_0055: USB.println(F("Error when getting parameter value")); break;
    case ERROR_CODE_0056: USB.println(F("User abort")); break;
    case ERROR_CODE_0057: USB.println(F("Error when trying to establish PPP")); break;
    case ERROR_CODE_0058: USB.println(F("Error when trying to establish SMTP")); break;
    case ERROR_CODE_0059: USB.println(F("Error when trying to establish POP3")); break;
    case ERROR_CODE_0060: USB.println(F("Single session body for MIME exceeds the maximum allowed")); break;
    case ERROR_CODE_0061: USB.println(F("Internal memory failure")); break;
    case ERROR_CODE_0062: USB.println(F("User aborted the system")); break;
    case ERROR_CODE_0063: USB.println(F("~CTSH needs to be LOW to change to hardware flow control")); break;
    case ERROR_CODE_0064: USB.println(F("User aborted last cmd using â€˜---â€™")); break;
    case ERROR_CODE_0065: USB.println(F("iChip unique ID already exists")); break;
    case ERROR_CODE_0066: USB.println(F("Error when setting the MIF parameter")); break;
    case ERROR_CODE_0067: USB.println(F("Cmd ignored as irrelevant")); break;
    case ERROR_CODE_0068: USB.println(F("iChip serial number already exists")); break;
    case ERROR_CODE_0069: USB.println(F("Timeout on host communication")); break;
    case ERROR_CODE_0070: USB.println(F("Modem failed to respond")); break;
    case ERROR_CODE_0071: USB.println(F("No dial tone response")); break;
    case ERROR_CODE_0072: USB.println(F("No carrier modem response")); break;
    case ERROR_CODE_0073: USB.println(F("Dial failed")); break;
    case ERROR_CODE_0074: USB.println(F("WLAN connection lost")); break;
    case ERROR_CODE_0075: USB.println(F("Access denied to ISP server")); break;
    case ERROR_CODE_0076: USB.println(F("Unable to locate POP3 server")); break;
    case ERROR_CODE_0077: USB.println(F("POP3 server timed out")); break;
    case ERROR_CODE_0078: USB.println(F("Access denied to POP3 server")); break;
    case ERROR_CODE_0079: USB.println(F("POP3 failed ")); break;
    case ERROR_CODE_0080: USB.println(F("No suitable message in mailbox")); break;
    case ERROR_CODE_0081: USB.println(F("Unable to locate SMTP server")); break;
    case ERROR_CODE_0082: USB.println(F("SMTP server timed out")); break;
    case ERROR_CODE_0083: USB.println(F("SMTP failed")); break;
    case ERROR_CODE_0086: USB.println(F("Writing to internal non-volatile parameters database failed")); break;
    case ERROR_CODE_0087: USB.println(F("Web server IP registration failed")); break;
    case ERROR_CODE_0088: USB.println(F("Socket IP registration failed")); break;
    case ERROR_CODE_0089: USB.println(F("E-mail IP registration failed")); break;
    case ERROR_CODE_0090: USB.println(F("IP registration failed for all methods specified")); break;
    case ERROR_CODE_0094: USB.println(F("In Always Online mode, connection was lost and re-established")); break;
    case ERROR_CODE_0096: USB.println(F("A remote host, which had taken over iChip through the LATI port, was disconnected")); break;
    case ERROR_CODE_0100: USB.println(F("Error restoring default parameters")); break;
    case ERROR_CODE_0101: USB.println(F("No ISP access numbers defined")); break;
    case ERROR_CODE_0102: USB.println(F("No USRN defined")); break;
    case ERROR_CODE_0103: USB.println(F("No PWD entered")); break;
    case ERROR_CODE_0104: USB.println(F("No DNS defined")); break;
    case ERROR_CODE_0105: USB.println(F("POP3 server not defined")); break;
    case ERROR_CODE_0106: USB.println(F("MBX (mailbox) not defined")); break;
    case ERROR_CODE_0107: USB.println(F("MPWD (mailbox password) not defined")); break;
    case ERROR_CODE_0108: USB.println(F("TOA (addressee) not defined")); break;
    case ERROR_CODE_0109: USB.println(F("REA (return e-mail address) not defined")); break;
    case ERROR_CODE_0110: USB.println(F("SMTP server not defined")); break;
    case ERROR_CODE_0111: USB.println(F("Serial data overflow")); break;
    case ERROR_CODE_0112: USB.println(F("Illegal cmd when modem online")); break;
    case ERROR_CODE_0113: USB.println(F("Remote firmware update attempted but not completed. The original firmware remained intact.")); break;
    case ERROR_CODE_0114: USB.println(F("E-mail parameters update rejected")); break;
    case ERROR_CODE_0115: USB.println(F("SerialNET could not be started due to missing parameters")); break;
    case ERROR_CODE_0116: USB.println(F("Error parsing a new trusted CA certificate")); break;
    case ERROR_CODE_0117: USB.println(F("Error parsing a new Private Key")); break;
    case ERROR_CODE_0118: USB.println(F("Protocol specified in the USRV parameter does not exist or is unknown")); break;
    case ERROR_CODE_0119: USB.println(F("WPA passphrase too short has to be 8-63 chars")); break;
    case ERROR_CODE_0122: USB.println(F("SerialNET error: Host Interface undefined (HIF=0)")); break;
    case ERROR_CODE_0123: USB.println(F("SerialNET mode error: Host baud rate cannot be determined")); break;
    case ERROR_CODE_0124: USB.println(F("SerialNET over TELNET error: HIF parameter must be set to 1 or 2")); break;
    case ERROR_CODE_0125: USB.println(F("Invalid WEP key")); break;
    case ERROR_CODE_0126: USB.println(F("Invalid parametersâ€™ profile number")); break;
    case ERROR_CODE_0128: USB.println(F("Product ID already exists")); break;
    case ERROR_CODE_0129: USB.println(F("HW pin can not be changed after Product-ID was set ")); break;
    case ERROR_CODE_0200: USB.println(F("Socket does not exist")); break;
    case ERROR_CODE_0201: USB.println(F("Socket empty on receive")); break;
    case ERROR_CODE_0202: USB.println(F("Socket not in use")); break;
    case ERROR_CODE_0203: USB.println(F("Socket down")); break;
    case ERROR_CODE_0204: USB.println(F("No available sockets")); break;
    case ERROR_CODE_0206: USB.println(F("PPP open failed for socket")); break;
    case ERROR_CODE_0207: USB.println(F("Error creating socket")); break;
    case ERROR_CODE_0208: USB.println(F("Socket send error")); break;
    case ERROR_CODE_0209: USB.println(F("Socket receive error")); break;
    case ERROR_CODE_0210: USB.println(F("PPP down for socket")); break;
    case ERROR_CODE_0212: USB.println(F("Socket flush error ")); break;
    case ERROR_CODE_0215: USB.println(F("No carrier error on socket operation")); break;
    case ERROR_CODE_0216: USB.println(F("General exception")); break;
    case ERROR_CODE_0217: USB.println(F("Out of memory")); break;
    case ERROR_CODE_0218: USB.println(F("An STCP (Open Socket) cmd specified a local port number that is already in use")); break;
    case ERROR_CODE_0219: USB.println(F("SSL initialization/internal CA certificate loading error")); break;
    case ERROR_CODE_0220: USB.println(F("SSL3 negotiation error")); break;
    case ERROR_CODE_0221: USB.println(F("Illegal SSL socket handle. Must be an open and active TCP socket.")); break;
    case ERROR_CODE_0222: USB.println(F("Trusted CA certificate does not exist")); break;
    case ERROR_CODE_0224: USB.println(F("Decoding error on incoming SSL data")); break;
    case ERROR_CODE_0225: USB.println(F("No additional SSL sockets available")); break;
    case ERROR_CODE_0226: USB.println(F("Maximum SSL packet size (2KB) exceeded")); break;
    case ERROR_CODE_0227: USB.println(F("AT+iSSND cmd failed because size of stream sent exceeded 2048 bytes")); break;
    case ERROR_CODE_0228: USB.println(F("AT+iSSND cmd failed because checksum calculated does not match checksum sent by host")); break;
    case ERROR_CODE_0229: USB.println(F("SSL parameters are missing ")); break;
    case ERROR_CODE_0230: USB.println(F("Maximum packet size (4GB) exceeded")); break;
    case ERROR_CODE_0300: USB.println(F("HTTP server unknown")); break;
    case ERROR_CODE_0301: USB.println(F("HTTP server timeout ")); break;
    case ERROR_CODE_0303: USB.println(F("No URL specified ")); break;
    case ERROR_CODE_0304: USB.println(F("Illegal HTTP host name")); break;
    case ERROR_CODE_0305: USB.println(F("Illegal HTTP port number")); break;
    case ERROR_CODE_0306: USB.println(F("Illegal URL address")); break;
    case ERROR_CODE_0307: USB.println(F("URL address too long ")); break;
    case ERROR_CODE_0308: USB.println(F("The AT+iWWW cmd failed because iChip does not contain a home page")); break;
    case ERROR_CODE_0309: USB.println(F("WEB server is already active with a different backlog.")); break;
    case ERROR_CODE_0400: USB.println(F("MAC address exists")); break;
    case ERROR_CODE_0401: USB.println(F("No IP address")); break;
    case ERROR_CODE_0402: USB.println(F("Wireless LAN power set failed")); break;
    case ERROR_CODE_0403: USB.println(F("Wireless LAN radio control failed")); break;
    case ERROR_CODE_0404: USB.println(F("Wireless LAN reset failed")); break;
    case ERROR_CODE_0405: USB.println(F("Wireless LAN hardware setup failed")); break;
    case ERROR_CODE_0406: USB.println(F("Cmd failed because WiFi module is currently busy")); break;
    case ERROR_CODE_0407: USB.println(F("Illegal WiFi channel")); break;
    case ERROR_CODE_0408: USB.println(F("Illegal SNR threshold")); break;
    case ERROR_CODE_0409: USB.println(F("WPA connection process has not yet completed")); break;
    case ERROR_CODE_0410: USB.println(F("The network connection is offline (modem)")); break;
    case ERROR_CODE_0411: USB.println(F("Cmd is illegal when Bridge mode is active")); break;
    case ERROR_CODE_0501: USB.println(F("Communications platform already active")); break;
    case ERROR_CODE_0505: USB.println(F("Cannot open additional FTP session â€“ all FTP handles in use")); break;
    case ERROR_CODE_0506: USB.println(F("Not an FTP session handle")); break;
    case ERROR_CODE_0507: USB.println(F("FTP server not found")); break;
    case ERROR_CODE_0508: USB.println(F("Timeout when connecting to FTP server")); break;
    case ERROR_CODE_0509: USB.println(F("Failed to login to FTP server (bad username or password or account)")); break;
    case ERROR_CODE_0510: USB.println(F("FTP cmd could not be completed")); break;
    case ERROR_CODE_0511: USB.println(F("FTP data socket could not be opened")); break;
    case ERROR_CODE_0512: USB.println(F("Failed to send data on FTP data socket")); break;
    case ERROR_CODE_0513: USB.println(F("FTP shutdown by remote server")); break;
    case ERROR_CODE_0550: USB.println(F("Telnet server not found")); break;
    case ERROR_CODE_0551: USB.println(F("Timeout when connecting to Telnet server")); break;
    case ERROR_CODE_0552: USB.println(F("Telnet cmd could not be completed")); break;
    case ERROR_CODE_0553: USB.println(F("Telnet session shutdown by remote server")); break;
    case ERROR_CODE_0554: USB.println(F("A Telnet session is not currently active")); break;
    case ERROR_CODE_0555: USB.println(F("A Telnet session is already open")); break;
    case ERROR_CODE_0556: USB.println(F("Telnet server refused to switch to BINARY mode")); break;
    case ERROR_CODE_0557: USB.println(F("Telnet server refused to switch to ASCII mode")); break;
    case ERROR_CODE_0560: USB.println(F("Client could not retrieve a ring response e-mail")); break;
    case ERROR_CODE_0561: USB.println(F("Remote peer closed the SerialNET socket")); break;
    case ERROR_CODE_0570: USB.println(F("PING destination not found")); break;
    case ERROR_CODE_0571: USB.println(F("No reply to PING request")); break;
    case ERROR_CODE_0600: USB.println(F("Port Forwarding Rule will create ambiguous NAT entry")); break;
    case ERROR_CODE_0084:
    case ERROR_CODE_0085:
    case ERROR_CODE_0091:
    case ERROR_CODE_0092:
    case ERROR_CODE_0093:
    case ERROR_CODE_0098:
    case ERROR_CODE_0099:
    case ERROR_CODE_0120:
    case ERROR_CODE_0121:
    case ERROR_CODE_0223:
    case ERROR_CODE_0302:
    case ERROR_CODE_0500:
    case ERROR_CODE_0502:
    case ERROR_CODE_0503:
    case ERROR_CODE_0504:
    case ERROR_CODE_0514:
    case ERROR_CODE_0558:
    case ERROR_CODE_0559: USB.println(F("RESERVED")); break;
    default: USB.println(F("UNKNOWN ***"));
  }
*/





int binaryToDecimal(int n)
{
  int num = n;
  int dec_value = 0;
  int base = 1;

  int temp = num;
  while (temp)
  {
    int last_digit = temp % 10;
    temp = temp / 10;
    dec_value += last_digit * base;
    base = base * 2;
  }
  return dec_value;
}


void measurerr_CH4()
{
  Utils.setLED(LED0, LED_ON);
  Utils.setLED(LED1, LED_ON);
  USB.println(" Inceputuul citirii CH4 ETA 60+ SEC ");
  PWR.setSensorPower(SENS_3V3, SENS_ON);   // power sensor on
  //PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);    // trebuie sa fie 2 min
  delay(120000);
  USB.println(F("wake up!!\r\n"));
  int ppp, ppp2, dd, j, nnr, jj;
  long int sum = 0;
  char answer4[] = {"ERROR reading sensor\r\n"};
  uint32_t timeout = 5000;
  char sensor_reading[] = {"\r\n"};
  char kk[10];




  //USB.println(F("Analog output (0 - 3.3V): from 0 to 1023"));     // citirea pin analog
  for (  j = 1; j <= 5 ; j++)
  {
    VV1 = analogRead(ANALOG6);     // pin 6 pt pcb diy
    USB.print(F("  ||    ANALOG: "));
    USB.print(VV1);
    sum = sum + VV1;

    delay(1200);
  }

  USB.println(" ");
  VV1 = sum / 5;
  ppp = VV1  * 50000 / 1023;
  if (ppp < 0)
  {
    ppp = 0;
  }
  USB.println(" ");
  USB.print(F("  ||    ANALOG avg: "));
  USB.print(  VV1 );
  USB.print(F("  units and that is equivalent to: "));
  USB.print(  VV1 * 3.3333 / 1023 );
  USB.print(F("  V"));
  USB.println(" ");






  // citire pin digital
  /*
    0        0      low
    0.2      62
    1.8      558    high
    2        620
  */
  sum = 0;
  for (  j = 1; j <= 5 ; j++)
  {
    answer13 = uart.waitFor(sensor_reading, answer4, timeout);
    switch (answer13)
    {
      case 0:
        USB.println(F("TIMEOUTED 10S "));
        break;
      case 1:
        USB.print(F("Parse sensor info: "));
        USB.println((char*)uart._buffer);
        break;
      case 2:
        // Answer was ERROR reading sensor
        USB.println(F("Answer was ERROR reading sensor"));
        break;
      default:
        USB.println(F("HOW IS THIS EVEN POSSIBLE??!!"));
        USB.println(F("CODE IS MESSES UP HARD HERE!"));
    }
    USB.print(F("UART data: "));
    nnr = 0;
    for (  jj = 0; jj < uart._length ; jj++)
    {
      USB.print(   uart._buffer[jj]  );
      nnr = nnr * 10 + uart._buffer[jj];
      uart_data_ch[j * 5 + jj] = uart._buffer[jj];
    }
    USB.println(" " );
    ppp2 = binaryToDecimal( nnr);
    USB.println(F("DIgital data: "));
    USB.println( ppp2 );
    sum = sum + ppp2;
    delay(1200);

  }
  USB.println(" ");
  ppp2 = sum / 5;

  USB.print(F("SUM-digital: "));
  USB.println(sum);

if(ppp2<0)
{
ppp2=-ppp2;
}


  frame.createFrame(ASCII, node_ID); // frame1 de  stocat
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  frame.addSensor(SENSOR_GASES_CH4, ppp  );     // CH4 analogic
  frame.addSensor(SENSOR_GASES_US, VV1);       // tensiune RAW de la output analogic
  frame.addTimestamp();
  frame.addSensor(SENSOR_GASES_O2, ppp2  );     // CH4 digital
  frame.addSensor(SENSOR_GASES_PRES, nnr  );    // date din frame uart  RAW (binar)
  frame.showFrame();
  PWR.setSensorPower(SENS_3V3, SENS_OFF);
  Utils.setLED(LED1, LED_OFF);
  WiFi_sendFrame();

}























// initializare

void setup()
{
  USB.ON();
  Utils.setLED(LED0, LED_ON);
  RTC.ON(); // Executes the init process
  USB.println(F("START"));

  //data_maker( 10000 ,  filename  );


  // Utils.setProgramVersion( verr );



  WiFi_init();

  //OTA_setup_check(10);
  RTC_setup();///////////////include WiFi_setup();

  USB.print(F("Current RTC settings:"));
  USB.println(RTC.getTime());

  USB.println(F("SD_CARD_ARHIVE_V5_RTC_ON_BAREBONES"));
  // Set SD ON
  SD_TEST_FILE_CHECK();
  // pm
  USB.ON();

  //UART

  uart.setBaudrate(115200);
  uart.setUART(SOCKET0);
  uart.beginUART();
  Utils.setMuxAux1();
  serialFlush(1);



  LoRa_switchon();
  LoRa_changeDR();
  LoRa_getDR();
  //  LoRa_adaptiveDR();
  LoRa_setDeviceEUI();
  LoRa_setAppEUI();
  LoRa_AppSessionKey();
  LoRa_joinOTAA();
  LoRa_saveconfig();
  LoRa_switchoff();

}







// main program
void loop()
{
  // get actual time before loop
  prev = millis();
  Utils.setLED(LED0, LED_ON);




  measurerr_CH4();




  all_in_1_frame_process();

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //OTA_check_loop();






  ///////////////  NU UMBLA AICI !!!
  RTC.setAlarm2("01:10:00", RTC_ABSOLUTE, RTC_ALM2_MODE1); // activare in fiecare duminica la 10:00 dimineata
  IN_LOOP_RTC_CHECK(  RTC_SUCCES);
  cycle_time = cycle_time2 - b - 5;
  if (cycle_time < 10)
  {
    cycle_time = 15;
  }
  USB.print("cycle time: ");
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
  USB.print("X");
  USB.print(rtc_str);
  USB.println("X");

  USB.println("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
  USB.OFF();
  //PWR.deepSleep(rtc_str, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.println(
    F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.println(F("6. Wake up!!\n\n"));
}
