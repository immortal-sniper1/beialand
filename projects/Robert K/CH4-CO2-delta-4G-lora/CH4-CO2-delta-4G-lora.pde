#include <WaspFrame.h>
#include <Wasp4G.h>
#include <WaspLoRaWAN.h>
#include <WaspSensorGas_Pro.h>


//NU UNBLA AICI!!
// define variable SD
// define file name: MUST be 8.3 SHORT FILE NAME
char filename[] = "FILE1.TXT";
int loop_count;
char *time_date; // stores curent date + time
int cycle_time, x, b;
uint8_t error, status = false;
char y[3];
uint8_t sd_answer, ssent = 0, resend_f = 2; // frame resend atempts
bool sentence = false; // true for deletion on reboot  , false for data appended to end of file
bool IRL_time = true; //  true for no external date source  ( RTC)
char rtc_str[] = "00:00:00:05";    // 11 char ps incepe de la 0
unsigned long prev, previous;
bool RTC_SUCCES = false;

char programID[10];
// SERVER settings
///////////////////////////////////////
char host[] = "82.78.81.178";
uint16_t port = 80;
///////////////////////////////////////

///////////////////////////////////////
//FTP send
char SD_FILE[]     = "FILE1.TXT";
char SERVER_FILE[] = "HHKFILE2.TXT";
uint8_t connection_status, net_in_attempt;
char operator_name[20];
uint8_t program_verrr;


//EDITEAZA AICI!
int  cycle_time2 = 1150; // in seconds
char node_ID[] = "delta1";
uint8_t RTC_ATEMPTS = 10; // number of RTC sync atempts
// APN settings
///////////////////////////////////////    pt orange RO
char apn[] = "net";
char login[] = "";
char password[] = "";
///////////////////////////////////////
// FTP SERVER settings
///////////////////////////////////////
char ftp_server[] = "ftp.agile.ro";
uint16_t ftp_port = 21;
char ftp_user[] = "folderone@agile.ro";
char ftp_pass[] = "1fENXK~0qMgw";

///senzori
Gas CO2(SOCKET_C);
Gas CH4(SOCKET_A);

////////////

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



uint8_t errorSetTimeServer, errorEnableTimeSync, errorSetGMT, errorsetTimefromWiFi, errorsetSSID, errorsetpass, errorsoftreset, errorresetdef, errorSendFrame, errorrequestOTA;
uint8_t statusWiFiconn, statusSetTimeServer, statusTimeSync, statusSetGMT, statussetTimefromWiFi;
uint8_t socketLoRa = SOCKET1;
uint8_t errorLoRa, errorLoRa_config;
int VV1, ppp, ppp2, nnr;


// subprograme


void scriitor_SD(char filename_a2[], uint8_t ssent_a = 0)
{
  SD.ON();
  USB.println(F("scriitor SD  "));

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
    USB.println(F("/"));
    USB.println(x);
    for (int g = 0; g < 324 ; g++)
    {
      SD.appendln(filename_a, " ");
      USB.println(F(" subcycles: "));
      USB.println(g);
      USB.println(F("/324"));
      for (int k = 0 ; k < 324 ; k++)
        SD.append(filename_a, "eokfumpwqroifv4478fcmwpocfumwqgif17nwqrpn5fcmwifcwuifw7unpcwogr2rqfcnqwogfqprwfmqwfhwdjfbplpkp13plo");   //100 byte per line
    }
  }
  SD.OFF();

}







void INFO_4G_MDD()
{
  int temperature;
  USB.ON();
  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.println(F("Start INFO_4G_MDD"));
  delay(5000);
  /////////////////////////////////////////////////
  // 1. Switch on the 4G module
  //////////////////////////////////////////////////
  error = _4G.ON();

  // check answer
  if (error == 0)
  {
    USB.println(F("4G module ready\n"));

    ////////////////////////////////////////////////
    // 1.1. Hardware revision
    ////////////////////////////////////////////////
    error = _4G.getInfo(Wasp4G::INFO_HW);
    if (error == 0)
    {
      USB.print(F("1.1. Hardware revision: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.println(F("1.1. Hardware revision ERROR"));
    }

    ////////////////////////////////////////////////
    // 1.2. Manufacturer identification
    ////////////////////////////////////////////////
    error = _4G.getInfo(Wasp4G::INFO_MANUFACTURER_ID);
    if (error == 0)
    {
      USB.print(F("1.2. Manufacturer identification: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.println(F("1.2. Manufacturer identification ERROR"));
    }

    ////////////////////////////////////////////////
    // 1.3. Model identification
    ////////////////////////////////////////////////
    error = _4G.getInfo(Wasp4G::INFO_MODEL_ID);
    if (error == 0)
    {
      USB.print(F("1.3. Model identification: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.println(F("1.3. Model identification ERROR"));
    }

    ////////////////////////////////////////////////
    // 1.4. Revision identification
    ////////////////////////////////////////////////
    error = _4G.getInfo(Wasp4G::INFO_REV_ID);
    if (error == 0)
    {
      USB.print(F("1.4. Revision identification: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.println(F("1.4. Revision identification ERROR"));
    }

    ////////////////////////////////////////////////
    // 1.5. Revision identification
    ////////////////////////////////////////////////
    error = _4G.getInfo(Wasp4G::INFO_IMEI);
    if (error == 0)
    {
      USB.print(F("1.5. IMEI: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.println(F("1.5. IMEI ERROR"));
    }

    ////////////////////////////////////////////////
    // 1.6. IMSI
    ////////////////////////////////////////////////
    error = _4G.getInfo(Wasp4G::INFO_IMSI);
    if (error == 0)
    {
      USB.print(F("1.6. IMSI: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.println(F("1.6. IMSI ERROR"));
    }

    ////////////////////////////////////////////////
    // 1.7. ICCID
    ////////////////////////////////////////////////
    error = _4G.getInfo(Wasp4G::INFO_ICCID);
    if (error == 0)
    {
      USB.print(F("1.7. ICCID: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.println(F("1.7. ICCID ERROR"));
    }

    ////////////////////////////////////////////////
    // 1.8. Show APN settings
    ////////////////////////////////////////////////
    USB.println(F("1.8. Show APN:"));
    _4G.show_APN();

    ////////////////////////////////////////////////
    // 1.9. Get temperature
    ////////////////////////////////////////////////
    error = _4G.getTemp();
    if (error == 0)
    {
      USB.print(F("1.9a. Temperature interval: "));
      USB.println(_4G._tempInterval, DEC);
      USB.print(F("1.9b. Temperature: "));
      USB.print(_4G._temp, DEC);
      USB.println(F(" Celsius degrees"));
    }
    else
    {
      USB.println(F("1.9. Temperature ERROR"));
    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("4G module not started"));
  }
  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.OFF();

}





void INFO_4G_NET()
{
  USB.ON();
  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.println(F("Starting INFO_4G_NET"));

  //////////////////////////////////////////////////
  // 1. sets operator parameters
  //////////////////////////////////////////////////
  _4G.set_APN(apn, login, password);

  //////////////////////////////////////////////////
  // 2. Show APN settings via USB port
  //////////////////////////////////////////////////
  _4G.show_APN();

  //////////////////////////////////////////////////
  // 1. Switch ON the 4G module
  //////////////////////////////////////////////////
  error = _4G.ON();

  if (error == 0)
  {
    USB.println(F("1. 4G module ready"));

    ////////////////////////////////////////////////
    // 1.1. Check connection to network and continue
    ////////////////////////////////////////////////
    connection_status = _4G.checkDataConnection(30);

    if (connection_status == 0)
    {
      USB.println(F("1.1. Module connected to network"));

      // delay for network parameters stabilization
      delay(5000);

      //////////////////////////////////////////////
      // 1.2. Get RSSI
      //////////////////////////////////////////////
      error = _4G.getRSSI();
      if (error == 0)
      {
        USB.print(F("1.2. RSSI: "));
        USB.print(_4G._rssi, DEC);
        USB.println(F(" dBm"));
      }
      else
      {
        USB.println(F("1.2. Error calling 'getRSSI' function"));
      }

      //////////////////////////////////////////////
      // 1.3. Get Network Type
      //////////////////////////////////////////////
      error = _4G.getNetworkType();

      if (error == 0)
      {
        USB.print(F("1.3. Network type: "));
        switch (_4G._networkType)
        {
          case Wasp4G::NETWORK_GPRS:
            USB.println(F("GPRS"));
            break;
          case Wasp4G::NETWORK_EGPRS:
            USB.println(F("EGPRS"));
            break;
          case Wasp4G::NETWORK_WCDMA:
            USB.println(F("WCDMA"));
            break;
          case Wasp4G::NETWORK_HSDPA:
            USB.println(F("HSDPA"));
            break;
          case Wasp4G::NETWORK_LTE:
            USB.println(F("LTE"));
            break;
          case Wasp4G::NETWORK_UNKNOWN:
            USB.println(F("Unknown or not registered"));
            break;
        }
      }
      else
      {
        USB.println(F("1.3. Error calling 'getNetworkType' function"));
      }

      //////////////////////////////////////////////
      // 1.4. Get Operator name
      //////////////////////////////////////////////
      memset(operator_name, '\0', sizeof(operator_name));
      error = _4G.getOperator(operator_name);

      if (error == 0)
      {
        USB.print(F("1.4. Operator: "));
        USB.println(operator_name);
      }
      else
      {
        USB.println(F("1.4. Error calling 'getOperator' function"));
      }
    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("4G module not started"));
    USB.print(F("Error code: "));
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////////
  // 2. Switch OFF the 4G module
  //////////////////////////////////////////////////
  _4G.OFF();
  USB.println(F("2. Switch OFF 4G module"));
  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.OFF();

}




void HTTP_GET_4G()
{
  // SERVER settings
  ///////////////////////////////////////
  char host[] = "test.libelium.com";
  uint16_t port = 80;
  char resource[] = "/test-get-post.php?varA=1&varB=2&varC=3&varD=4&varE=5&varF=6&varG=7&varH=8&varI=9&varJ=10&varK=11&varL=12&varM=13&varN=14&varO=15";
  ///////////////////////////////////////

  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.println(F("STARTING HTTP_GET_4G"));
  //////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////
  error = _4G.ON();

  if (error == 0)
  {
    USB.println(F("1. 4G module ready..."));


    ////////////////////////////////////////////////
    // 2. HTTP GET
    ////////////////////////////////////////////////

    USB.print(F("2. Getting URL with GET method..."));

    // send the request
    error = _4G.http( Wasp4G::HTTP_GET, host, port, resource);

    // Check the answer
    if (error == 0)
    {
      USB.print(F("Done. HTTP code: "));
      USB.println(_4G._httpCode);
      USB.print(F("Server response: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.print(F("Failed. Error code: "));
      USB.println(error, DEC);
    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("1. 4G module not started"));
    USB.print(F("Error code: "));
    USB.println(error, DEC);
  }


  ////////////////////////////////////////////////
  // 3. Powers off the 4G module
  ////////////////////////////////////////////////
  USB.println(F("3. Switch OFF 4G module"));
  _4G.OFF();
  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
}


void HTTP_POST_4G()
{
  // SERVER settings
  ///////////////////////////////////////
  char host[] = "test.libelium.com";
  uint16_t port = 80;
  char resource[] = "/test-get-post.php";
  char data[] = "varA=1&varB=2&varC=3&varD=4&varE=5";
  ///////////////////////////////////////

  USB.ON();
  USB.println(F("Starting program HTTP_POST_4G"));

  //////////////////////////////////////////////////
  // 1. sets operator parameters
  //////////////////////////////////////////////////
  _4G.set_APN(apn, login, password);


  //////////////////////////////////////////////////
  // 2. Show APN settings via USB port
  //////////////////////////////////////////////////
  _4G.show_APN();


  //////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////
  error = _4G.ON();

  if (error == 0)
  {
    USB.println(F("1. 4G module ready..."));


    ////////////////////////////////////////////////
    // 2. HTTP POST
    ////////////////////////////////////////////////

    USB.print(F("2. HTTP POST request..."));

    // send the request
    error = _4G.http( Wasp4G::HTTP_POST, host, port, resource, data);

    // check the answer
    if (error == 0)
    {
      USB.print(F("Done. HTTP code: "));
      USB.println(_4G._httpCode);
      USB.print(F("Server response: "));
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.print(F("Failed. Error code: "));
      USB.println(error, DEC);
    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("4G module not started"));
    USB.print(F("Error code: "));
    USB.println(error, DEC);
  }

  ////////////////////////////////////////////////
  // 3. Powers off the 4G module
  ////////////////////////////////////////////////
  USB.println(F("3. Switch OFF 4G module"));
  //_4G.enterPIN("0000");    // pt oranege

  _4G.OFF();


}








int HTTP_4G_TRIMITATOR_FRAME()
{

  int ssent = 0;
  int  joyy = 0;
  int ssent2;

  if ( PWR.getBatteryLevel() < 20)
  {
    USB.print(F("LOW BATTERY ABANDONING TRANSMISION ATEMPT IN ORDER TO KEEP THE STATION ALIVE AND RECORDING DATA ON THE SD"));
    goto RIUK;
  }

  // nu se trimite daca bateria e prea descarcata
  if ( PWR.getBatteryLevel() >= 50 )
  {
    goto gato;
  }
  else
  {
    if ( PWR.getBatteryLevel() >= 30 )
    {
      if ( loop_count % 2 == 0)
      {
        goto gato;
      }
    }
    else
    {
      if ( (PWR.getBatteryLevel() >= 20 ) && ( loop_count % 4 == 0)   )
      {
        goto gato;
      }
    }
  }

  USB.println(F("Not sending data due to low battery levels BUT DATA IS STORED ON THE SD CARD"));
  goto RIUK;
gato:




  //////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////
  error = _4G.ON();

  if (error == 0)
  {
    USB.println(F("1. 4G module ready..."));

    ////////////////////////////////////////////////
    // 3. Send to Meshlium
    ////////////////////////////////////////////////

gato2:

    USB.print(F("Sending the frame..."));
    error = _4G.sendFrameToMeshlium( host, port, frame.buffer, frame.length);

    // check the answer
    if ( error == 0)
    {
      USB.print(F("Done. HTTP code: "));
      USB.println(_4G._httpCode);
      USB.print(F("Server response: "));
      USB.println(_4G._buffer, _4G._length);
      ssent2 = _4G._httpCode;
      if ( ssent2 == 200)
      {
        ssent = 1;
      }
      else
      {
        ssent = 0;

      }
    }
    else
    {
      USB.print(F("Failed. Error code: "));
      USB.println(error, DEC);

    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("4G module not started"));
    USB.print(F("Error code: "));
    USB.println(error, DEC);
  }



  if ( ssent != 1 && joyy <= resend_f)
  {
    joyy++;
    goto gato2;
  }





  ////////////////////////////////////////////////
  // 4. Powers off the 4G module
  ////////////////////////////////////////////////
  USB.println(F("4. Switch OFF 4G module"));
  _4G.OFF();
RIUK:
  return ssent;
}






void SET_RTC_4G( int g = 2) // 2 pt GMT+2 adica ora Romaniei
{
  USB.println(F(" "));
  USB.println(F(" "));
  USB.println(F(" "));
  USB.println(F(" "));
  USB.println(F("START OF THE RTC SEGMENT"));
  //////////////////////////////////////////////////
  // 1. Switch ON the 4G module
  //////////////////////////////////////////////////
kyuubi:
  error = _4G.ON();

  if (error == 0)
  {
    USB.println(F("1. 4G module ready"));

    ////////////////////////////////////////////////
    // 1.1. Check connection to network and continue
    ////////////////////////////////////////////////
    connection_status = _4G.checkDataConnection(60);

    if (connection_status == 0)
    {
      _4G.setTimeFrom4G();
      USB.println(F("CURENT TIME:"));
      USB.println(RTC.getTime());
      USB.println(RTC.getTimestamp());
      RTC_SUCCES = true;
    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("4G module not started"));
    USB.print(F("Error code: "));
    USB.println(error, DEC);
    x++;
    if (x <= g)
    {
      goto kyuubi;
    }

  }

  //////////////////////////////////////////////////
  // 2. Switch OFF the 4G module
  //////////////////////////////////////////////////
  _4G.OFF();
  USB.println(F("2. Switch OFF 4G module"));
}



void IN_LOOP_RTC_CHECK( bool S)
{
  if (  (S = false) || (intFlag & RTC_INT)   )
  {
    SET_RTC_4G();
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





void OTAP_4G()
{
  USB.println(F("STARTING OTAP VERSION CHECK"));
  //////////////////////////////
  // 4.1. Switch ON
  //////////////////////////////
  error = _4G.ON();

  if (error == 0)
  {
    USB.println(F("1. 4G module ready..."));

    //////////////////////////////
    // 4.3. Request OTA
    //////////////////////////////
    USB.println(F("==> Request OTA..."));
    error = _4G.requestOTA(ftp_server, ftp_port, ftp_user, ftp_pass);

    if (error != 0)
    {
      USB.print(F("OTA request failed. Error code: "));
      printErrorxx(error);
    }

    // blink RED led
    Utils.blinkRedLED(300, 3);

  }
  else
  {
    USB.println(F("4G module not started"));
  }

  USB.println(F("5. Switch OFF 4G module"));
  _4G.OFF();

}



void FTP_4G_SEND(char SD_FILE[] , char SERVER_FILE[])
{
  int previous;
  //////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////
  error = _4G.ON();

  if (error == 0)
  {
    USB.println(F("1. 4G module ready..."));

    ////////////////////////////////////////////////
    // 2.1. FTP open session
    ////////////////////////////////////////////////

    error = _4G.ftpOpenSession(ftp_server, ftp_port, ftp_user, ftp_pass);

    // check answer
    if (error == 0)
    {
      USB.println(F("2.1. FTP open session OK"));

      previous = millis();

      //////////////////////////////////////////////
      // 2.2. FTP upload
      //////////////////////////////////////////////

      error = _4G.ftpUpload(SERVER_FILE, SD_FILE);

      if (error == 0)
      {

        USB.print(F("2.2. Uploading SD file to FTP server done! "));
        USB.print(F("Upload time: "));
        USB.print((millis() - previous) / 1000, DEC);
        USB.println(F(" s"));
      }
      else
      {
        USB.print(F("2.2. Error calling 'ftpUpload' function. Error: "));
        USB.println(error, DEC);
      }

      //////////////////////////////////////////////
      // 2.3. FTP close session
      //////////////////////////////////////////////

      error = _4G.ftpCloseSession();

      if (error == 0)
      {
        USB.println(F("2.3. FTP close session OK"));
      }
      else
      {
        USB.print(F("2.3. Error calling 'ftpCloseSession' function. error: "));
        USB.println(error, DEC);
        USB.print(F("CMEE error: "));
        USB.println(_4G._errorCode, DEC);
      }
    }
    else
    {
      USB.print(F( "2.1. FTP connection error: "));
      USB.println(error, DEC);
    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("1. 4G module not started"));
  }


  ////////////////////////////////////////////////
  // 3. Powers off the 4G module
  ////////////////////////////////////////////////
  USB.println(F("3. Switch OFF 4G module"));
  _4G.OFF();
}




void OTA_setup_check( int att = 1)   // asta reprogrameaza in practica , variabila att numara de cate ori va incerca re se reprogrameza fara succes pana se va renunta
{
  int q = 1;
  bool w = false;
  while ( q <= att && w == false)
  {
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


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









void measurerr_CH4()
{

  USB.println(" Inceputuul citirii CH4 ETA 60+ SEC ");
  //PWR.setSensorPower(SENS_3V3, SENS_ON);   // power sensor on
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
    VV1 = analogRead(ANALOG2);     // 2 pt socket C                5 pt socket F
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



  //citirea digitala
  /*
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
  */
  if (ppp2 < 0)
  {
    ppp2 = -ppp2;
  }

  /*
    frame.createFrame(ASCII, node_ID); // frame1 de  stocat
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    frame.addSensor(SENSOR_GASES_CH4, ppp  );     // CH4 analogic
    frame.addSensor(SENSOR_GASES_US, VV1);       // tensiune RAW de la output analogic
    frame.addTimestamp();
    frame.addSensor(SENSOR_GASES_O2, ppp2  );     // CH4 digital
    frame.addSensor(SENSOR_GASES_PRES, nnr  );    // date din frame uart  RAW (binar)
    frame.showFrame();
    //PWR.setSensorPower(SENS_3V3, SENS_OFF);

  */
}









///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void masurator_aer()
{

  float temperature;
  float humidity;
  float pressure;

  float concCO2;
  float concCH4;


  //Power on gas sensors
  CO2.ON();


  // Sensors need time to warm up and get a response from gas
  // To reduce the battery consumption, use deepSleep instead delay
  // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
  USB.println(RTC.getTime());
  USB.println(F("Enter deep sleep mode to wait for sensors heating time..."));   // maybe add sleep time in here too
  // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
  //PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
  delay(120000);
  USB.println(RTC.getTime());
  USB.println(F("wake up!!\r\n"));

  ///////////////////////////////////////////
  // 1. Read sensors
  ///////////////////////////////////////////

  // Read the sensors and compensate with the temperature internally
  concCO2 = CO2.getConc();


  // Read enviromental variables
  temperature = CO2.getTemp();
  humidity = CO2.getHumidity();
  pressure = CO2.getPressure();

  ///////////////////////////////////////////
  // 2. Turn off the sensors
  ///////////////////////////////////////////

  //Power off sensors
  CO2.OFF();
  delay(500);
  measurerr_CH4();





  // frame de trimis

  frame.createFrame(BINARY, node_ID); // frame

  frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
  // Add humidity
  frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
  // Add pressure value
  frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  // Add CO2 value
  frame.addSensor(SENSOR_GASES_PRO_CO2, concCO2);
  frame.addSensor(SENSOR_GASES_CH4, ppp  );     // CH4 analogic
  frame.addSensor(SENSOR_GASES_US, VV1);       // tensiune RAW de la output analogic
  frame.addTimestamp();
  frame.addSensor(SENSOR_GASES_O2, ppp2  );     // CH4 digital
  frame.addSensor(SENSOR_GASES_PRES, nnr  );    // date din frame uart  RAW (binar)

  // frame.showFrame();




  ssent = HTTP_4G_TRIMITATOR_FRAME();
  LoRa_switchon();
  LoRa_joinABP_send();
  LoRa_switchoff();

  frame.createFrame(ASCII, node_ID); // frame

  frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
  // Add humidity
  frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
  // Add pressure value
  frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  // Add CO2 value
  frame.addSensor(SENSOR_GASES_PRO_CO2, concCO2);
  frame.addSensor(SENSOR_GASES_CH4, ppp  );     // CH4 analogic
  frame.addSensor(SENSOR_GASES_US, VV1);       // tensiune RAW de la output analogic
  frame.addTimestamp();
  frame.addSensor(SENSOR_GASES_O2, ppp2  );     // CH4 digital
  frame.addSensor(SENSOR_GASES_PRES, nnr  );    // date din frame uart  RAW (binar)

  frame.showFrame();

  scriitor_SD(filename, ssent);





}
















// initializare

void setup()
{
  USB.ON();
  RTC.ON();
  //  x=setProgramVersion(1);


  INFO_4G_MDD();
  INFO_4G_NET();
  //HTTP_GET_4G();
  //HTTP_POST_4G();
  //FTP_4G_SEND( SD_FILE , SERVER_FILE  );
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  OTA_setup_check(5);


  ////////////////////////////////////////////////////////////////////////////////////////////////////
  // 1. sets operator parameters

  _4G.set_APN(apn, login, password);
  _4G.show_APN();

  SET_RTC_4G(RTC_ATEMPTS);
  USB.println(RTC.getTime());
  USB.println(F("Water Xtreme 4G"));


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

  USB.print(F("loop cycle time[s]:= "));
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
  loop_count = 0;


/*
  //error = LoRaWAN.getDeviceEUI();
  USB.print(F("EUI : "));
  USB.println(LoRaWAN.getDeviceEUI());

  //error = LoRaWAN.getDeviceAddr();
  USB.print(F("Adress : "));
  USB.println( LoRaWAN.getDeviceAddr());

  */
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

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  program_verrr = Utils.getProgramVersion();    //versiune program
  masurator_aer();

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  OTAP_4G();

  USB.println(F("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT "));
  /// NU UMBLA AICI!
  RTC.setAlarm2("01:10:00", RTC_ABSOLUTE, RTC_ALM2_MODE1); // activare in fiecare duminica la 1000 dimineata
  IN_LOOP_RTC_CHECK( RTC_SUCCES);

  USB.println(F("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT "));


  cycle_time = cycle_time2 - b - 5;
  if (cycle_time < 10) {
    cycle_time = 15;
  }
  USB.print(F("cycle time= "));
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
  USB.print(F("X"));
  USB.print(rtc_str);
  USB.println(F("X"));

  //USB.println(F("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"));
  USB.println(RTC.getTimestamp());
  USB.OFF();
  //delay(30000);
  PWR.deepSleep(rtc_str, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.println(F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
  USB.println(F("6. Wake up!!\n\n"));


}





