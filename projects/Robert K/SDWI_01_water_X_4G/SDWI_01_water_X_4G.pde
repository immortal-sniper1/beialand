#include <WaspFrame.h>
#include <Wasp4G.h>
#include <WaspSensorXtr.h>
//#include <SensorXtr.h>


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
bool IRL_time = false; //  true for no external data source
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
char node_ID[] = "SWX1";
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

//[Sensor Class] [Sensor Name] [Selected socket]
VegaPuls_C21 mySensor_A(XTR_SOCKET_A);
Aqualabo_PHEHT myPHEHT_B(XTR_SOCKET_B);
Aqualabo_C4E myC4E_C(XTR_SOCKET_C);
Aqualabo_MES5 myMES5_D(XTR_SOCKET_D);
Aqualabo_OPTOD myOPTOD_E(XTR_SOCKET_E);




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
  int ssent2;
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
    goto not_sendeder;
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


    ////////////////////////////////////////////////
    // 4. Powers off the 4G module
    ////////////////////////////////////////////////
    USB.println(F("4. Switch OFF 4G module"));
    _4G.OFF();
not_sendeder:
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






  void masurator_apa()
  {
    int joyy;
    // Socket B sensor
    // Turn ON the sensor
    myPHEHT_B.ON();
    // Read the sensor
    myPHEHT_B.read();
    // Turn off the sensor
    myPHEHT_B.OFF();



    // Socket E sensor
    // Turn ON the sensor
    myOPTOD_E.ON();
    // Read the sensor
    myOPTOD_E.read();
    // Turn off the sensor
    myOPTOD_E.OFF();


    // Socket C sensor
    // Turn ON the sensor
    myC4E_C.ON();
    // Read the sensor
    myC4E_C.read();
    // Turn off the sensor
    myC4E_C.OFF();

    // Socket D sensor
    // Turn ON the sensor
    myMES5_D.ON();
    // Read the sensor
    myMES5_D.read();
    // Turn off the sensor
    myMES5_D.OFF();

    // Socket A sensor Radar VegaPuls
    // Turn ON the sensor
    mySensor_A.ON();
    // Read the sensor
    mySensor_A.read();
    // Turn off the sensor
    mySensor_A.OFF();

    USB.print(F("radar data mySensor.VegaPulsC21.distance: "));
    USB.println(mySensor_A.VegaPulsC21.distance);
    USB.print(F("radar data mySensor_A.VegaPulsC21.stage: "));
    USB.println(mySensor_A.VegaPulsC21.stage);
    USB.println(F("  "));
    // frame de trimis

    frame.createFrame(BINARY, node_ID); // frame2
    frame.setFrameType(INFORMATION_FRAME_WTR_XTR);

    // add Socket B sensor values
    frame.addSensor(WTRX_PHEHT_TC2_B, myPHEHT_B.sensorPHEHT.temperature);
    frame.addSensor(WTRX_PHEHT_PH_B, myPHEHT_B.sensorPHEHT.pH);
    frame.addSensor(WTRX_PHEHT_PM_B, myPHEHT_B.sensorPHEHT.pHMV);
    frame.addSensor(WTRX_PHEHT_RX_B, myPHEHT_B.sensorPHEHT.redox);
    // add Socket E sensor values
    frame.addSensor(WTRX_OPTOD_TC1_E, myOPTOD_E.sensorOPTOD.temperature);
    frame.addSensor(WTRX_OPTOD_OS_E, myOPTOD_E.sensorOPTOD.oxygenSAT);
    frame.addSensor(WTRX_OPTOD_OM_E, myOPTOD_E.sensorOPTOD.oxygenMGL);
    frame.addSensor(WTRX_OPTOD_OP_E, myOPTOD_E.sensorOPTOD.oxygenPPM);
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    frame.addSensor(SENSOR_VAPI, program_verrr );   //versiune program       eventual schimbat cu SENSOR_VAPI
    frame.addSensor(SENSOR_TIME, RTC.getTimestamp());
    // add Socket D sensor values
    frame.addSensor(WTRX_MES5_TC6_D, myMES5_D.sensorMES5.temperature);
    frame.addSensor(WTRX_MES5_SB_D, myMES5_D.sensorMES5.sludgeBlanket);
    frame.addSensor(WTRX_MES5_SS_D, myMES5_D.sensorMES5.suspendedSolids);
    frame.addSensor(WTRX_MES5_TF_D, myMES5_D.sensorMES5.turbidityFAU);

    // add Socket C sensor values
    frame.addSensor(WTRX_C4E_TC3_C, myC4E_C.sensorC4E.temperature);
    frame.addSensor(WTRX_C4E_CN_C, myC4E_C.sensorC4E.conductivity);
    frame.addSensor(WTRX_C4E_SA_C, myC4E_C.sensorC4E.salinity);
    frame.addSensor(WTRX_C4E_TD_C, myC4E_C.sensorC4E.totalDissolvedSolids);

    // add Socket A sensor values                           // astea sunt copi a celor din socket C
    //frame.addSensor(WTRX_C4E_TC3_C, myC4E_C.sensorC4E.temperature);
    //frame.addSensor(WTRX_C4E_CN_C, myC4E_C.sensorC4E.conductivity);
    //frame.addSensor(WTRX_C4E_SA_C, myC4E_C.sensorC4E.salinity);
    //frame.addSensor(WTRX_C4E_TD_C, myC4E_C.sensorC4E.totalDissolvedSolids);
    frame.addSensor(WTRX_C21_DIS_A, mySensor_A.VegaPulsC21.distance);  //distanta pana la  apa


    // frame.showFrame();

    if ( PWR.getBatteryLevel() < 20)
    {
      USB.print(F("LOW BATTERY ABANDONING TRANSMISION ATEMPT IN ORDER TO KEEP THE STATION ALIVE AND RECORDING DATA ON THE SD"));
      goto RIUK;
    }


    joyy = 0;
gooo:
    ssent = HTTP_4G_TRIMITATOR_FRAME();
    if ( ssent != 1 && joyy <= resend_f)
    {
      joyy++;
      delay(1000);
      goto gooo;
    }
RIUK:


    frame.createFrame(ASCII, node_ID); // frame1
    frame.setFrameType(INFORMATION_FRAME_WTR_XTR);


    // add Socket B sensor values
    frame.addSensor(WTRX_PHEHT_TC2_B, myPHEHT_B.sensorPHEHT.temperature);
    frame.addSensor(WTRX_PHEHT_PH_B, myPHEHT_B.sensorPHEHT.pH);
    frame.addSensor(WTRX_PHEHT_PM_B, myPHEHT_B.sensorPHEHT.pHMV);
    frame.addSensor(WTRX_PHEHT_RX_B, myPHEHT_B.sensorPHEHT.redox);
    // add Socket E sensor values
    frame.addSensor(WTRX_OPTOD_TC1_E, myOPTOD_E.sensorOPTOD.temperature);
    frame.addSensor(WTRX_OPTOD_OS_E, myOPTOD_E.sensorOPTOD.oxygenSAT);
    frame.addSensor(WTRX_OPTOD_OM_E, myOPTOD_E.sensorOPTOD.oxygenMGL);
    frame.addSensor(WTRX_OPTOD_OP_E, myOPTOD_E.sensorOPTOD.oxygenPPM);
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    frame.addSensor(SENSOR_VAPI, program_verrr );   //versiune program       eventual schimbat cu SENSOR_VAPI
    //Version of API N/A SENSOR_VAPI 125 VAPI 1 uint8_t 1 N/A N/A
    // set frame fields (Time from RTC)
    frame.addSensor(SENSOR_TIME, RTC.getTimestamp());
    frame.showFrame();

    // 4. Calculation of level percentage
    //  float levelPercentage = 100 - ((mySensor_A.VegaPulsC21.distance * 100.0) / (mySensor_A.VegaPulsC21.stage + mySensor_A.VegaPulsC21.distance));

    //use  https://development.libelium.com/data-frame-programming-guide/frame-structure#smart-water-xtreme
    //frame.addSensor(WTRX_C21_DIS_A, mySensor_A.VegaPulsC21.distance);
    //frame ul pentru level perrcentage, s-ar putea sa nu mearga
    //frame.addSensor(WTRX_C21_TC7_A, levelPercentage);


    /*
      joyy = 0;
      gooo:
      ssent = HTTP_4G_TRIMITATOR_FRAME();
      if ( ssent != 1 && joyy <= resend_f)
      {
        joyy++;
        delay(1000);
        goto gooo;
      }
      scriitor_SD(filename, ssent);
    */

    frame.createFrame(ASCII, node_ID); // frame2
    frame.setFrameType(INFORMATION_FRAME_WTR_XTR);



    // add Socket D sensor values
    frame.addSensor(WTRX_MES5_TC6_D, myMES5_D.sensorMES5.temperature);
    frame.addSensor(WTRX_MES5_SB_D, myMES5_D.sensorMES5.sludgeBlanket);
    frame.addSensor(WTRX_MES5_SS_D, myMES5_D.sensorMES5.suspendedSolids);
    frame.addSensor(WTRX_MES5_TF_D, myMES5_D.sensorMES5.turbidityFAU);

    // add Socket C sensor values
    frame.addSensor(WTRX_C4E_TC3_C, myC4E_C.sensorC4E.temperature);
    frame.addSensor(WTRX_C4E_CN_C, myC4E_C.sensorC4E.conductivity);
    frame.addSensor(WTRX_C4E_SA_C, myC4E_C.sensorC4E.salinity);
    frame.addSensor(WTRX_C4E_TD_C, myC4E_C.sensorC4E.totalDissolvedSolids);

    // add Socket A sensor values                           // astea sunt copi a celor din socket C
    //frame.addSensor(WTRX_C4E_TC3_C, myC4E_C.sensorC4E.temperature);
    //frame.addSensor(WTRX_C4E_CN_C, myC4E_C.sensorC4E.conductivity);
    //frame.addSensor(WTRX_C4E_SA_C, myC4E_C.sensorC4E.salinity);
    //frame.addSensor(WTRX_C4E_TD_C, myC4E_C.sensorC4E.totalDissolvedSolids);
    frame.addSensor(WTRX_C21_DIS_A, mySensor_A.VegaPulsC21.distance);  //distanta pana la  apa

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
    masurator_apa();

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





