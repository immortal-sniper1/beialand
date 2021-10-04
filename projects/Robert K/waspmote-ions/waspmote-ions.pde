#include <smartWaterIons.h>
#include <WaspFrame.h>
#include <WaspWIFI_PRO.h>



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
uint8_t socket = SOCKET0;
//uint8_t socketLoRa = SOCKET1;
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


///// EDITEAZA AICI DOAR
char node_ID[] = "IONS1";
int count_trials = 0;
int N_trials = 2;
char ESSID[] = "LANCOMBEIA";
char PASSW[] = "beialancom";
uint8_t max_atemptss = 10; // nr de max de trame de retrimit deodata
uint8_t resend_f = 2; // frame resend atempts
int cycle_time2 = 1200; // in seconds

// Create an instance of the class
pt1000Class     tempSensor;
ionSensorClass  calciumSensor(SOCKET_A);
ionSensorClass  NO3Sensor(SOCKET_B);
ionSensorClass  AmmoniumSensor (SOCKET_C);
ionSensorClass  MagnesiumSensor(SOCKET_D);





//======================================================================
// Calibration concentrations solutions used in the process
//======================================================================
//#define point1 10.0
//#define point2 100.0
//#define point3 1000.0
//======================================================================
// Calibration voltage values for Calcium sensor
//======================================================================
#define point1_volt_Ca 2.950
#define point2_volt_Ca 3.024
#define point3_volt_Ca 3.150
//======================================================================
// Calibration voltage values for NO3 sensor
//======================================================================
#define point1_volt_NO3 3.567
#define point2_volt_NO3 3.426
#define point3_volt_NO3 3.409
//======================================================================
// Calibration voltage values for Magnesium sensor
//======================================================================
#define point1_volt_MG 2.615
#define point2_volt_MG 2.727
#define point3_volt_MG 2.853
//======================================================================
// Calibration voltage values for NH4 sensor
//======================================================================
#define point1_volt_NH4 2.901
#define point2_volt_NH4 3.027
#define point3_volt_NH4 3.170
//======================================================================
// Define the number of calibration points
//======================================================================
#define NUM_POINTS 3

//======================================================================
//const float concentrations[] = { point1, point2, point3 };
const float voltages_Ca[]    = { point1_volt_Ca,  point2_volt_Ca,  point3_volt_Ca};
const float voltages_NO3[]   = { point1_volt_NO3, point2_volt_NO3, point3_volt_NO3 };
const float voltages_MG[]    = { point1_volt_MG,  point2_volt_MG,  point3_volt_MG };
const float voltages_NH4[]   = { point1_volt_NH4, point2_volt_NH4, point3_volt_NH4 };
//======================================================================


const float concentrationsCa[]  = { 36.0,   180.0, 360.0 };
const float concentrationsMg[]  = { 11.0,   55.0,  110.0 };
const float concentrationsNO3[] = { 132.0,  660.0, 1320.0 };
const float concentrationsNH4[] = { 4.0,    20.0,  40.0 };



// calibrare
//float x1 , x2, x3, x4, difff;




// subprograme
//NU MODIFICA NIMIC IN SUBPROGRAME!

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








//// WIFI//////////////////////////////////////////////

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
  bool rr = true;
  uint8_t lvl;

  if ( PWR.getBatteryLevel() >= 50)
  {
    goto SS;
  }
  else
  {
    if ( (PWR.getBatteryLevel() >= 30)  && (loop_count % 2 == 0) )
    {
      goto SS;
    }
    else
    {
      lvl = 1;
      goto NSS;
    }
    if ( (PWR.getBatteryLevel() >= 20) && (PWR.getBatteryLevel() < 30) && (loop_count % 4 == 0) )
    {
      goto SS;
    }
    else
    {
      lvl = 2;
      goto NSS;
    }

  }


SS:
  ssent = trimitator_WIFI();
  rr = false;
NSS:
  scriitor_SD(filename, ssent);
  if ( rr)
  {
    USB.println(F("DATA WAS NOT SENT DUE TO LOW BATTERY BUT IT WAS RECORDED ON THE SD CARD"));
    USB.print(F("AT THE CURENT BATTERY LEVEL DATA IS  SENT OANCE EVERY "));
    USB.print(  pow(2, lvl)   );
    USB.println(F(" CYCLES AND NOW IT IS ONE OF THE NON TRANSMISSION CYCLES"));
  }

}






void IONII()
{
  uint8_t ssent = 0;

  ///////////////////////////////////////////
  // 1. Turn on the board
  ///////////////////////////////////////////

  SWIonsBoard.ON();
  delay(2000);

  ///////////////////////////////////////////
  // 2. Read sensors
  ///////////////////////////////////////////

  // Read the Calcium sensor
  float CaVolts = calciumSensor.read();
  //  USB.print(F("calciumSensor: "));
  //  USB.println( CaVolts );
  //  difff = x1 - CaVolts;
  //  x1 = CaVolts;
  //  USB.print(F("difff = "));
  //  USB.println( difff );
  float calciumValue = calciumSensor.calculateConcentration(CaVolts);
  delay(200);

  // Read the NO3 sensor
  float NO3Volts = NO3Sensor.read();
  //  USB.print(F("NO3Sensor: "));
  //  USB.println( NO3Volts );
  //  difff = x2 - NO3Volts;
  //  x2 = NO3Volts;
  //  USB.print(F("difff = "));
  //  USB.println( difff );
  float NO3Value = NO3Sensor.calculateConcentration(NO3Volts);
  delay(200);

  // Read the Temperature sensor
  float tempValue = tempSensor.read();
  delay(200);

  // Read the NH4 sensor
  float AmmoniumSensorV =   AmmoniumSensor.read();
  //  USB.print(F(" AmmoniumSensor: "));
  //  USB.println( AmmoniumSensorV );
  //  difff =x3 - AmmoniumSensorV;
  //  x3 = AmmoniumSensorV;
  //  USB.print(F("difff = "));
  //  USB.println( difff );
  float AmmoniumSensorD = AmmoniumSensor.calculateConcentration( AmmoniumSensorV  );
  delay(200);

  // Read the MG sensor
  float MagnesiumSensorV = MagnesiumSensor.read();
  //  USB.print(F(" MagnesiumSensor: "));
  //  USB.println( MagnesiumSensorV );
  //  difff = x4 - MagnesiumSensorV;
  //  x4 = MagnesiumSensorV;
  //  USB.print(F("difff = "));
  //  USB.println( difff );
  float MagnesiumSensorD = MagnesiumSensor.calculateConcentration( MagnesiumSensorV  );
  delay(200);

  // Delay
  SWIonsBoard.OFF();
  delay(200);

  // Print of the results
  USB.print(F("Temperature (Celsius degrees): "));
  USB.println(tempValue);
  USB.print(F("BAT= "));
  USB.println(  PWR.getBatteryLevel()  );


  ///////////////////////////////////////////
  // 4. Create BINARY frame
  ///////////////////////////////////////////

  // Create new frame (BINARY)
  frame.createFrame(BINARY);

  // Add temperature
  frame.addSensor(SENSOR_IONS_WT, tempValue);
  // Add PH
  frame.addSensor(SENSOR_IONS_CA, calciumValue);
  // Add ORP value
  frame.addSensor(SENSOR_IONS_NO3, NO3Value);
  // Add PH
  frame.addSensor(SENSOR_IONS_MG, MagnesiumSensorD);
  // Add ORP value
  frame.addSensor(SENSOR_IONS_NH4, AmmoniumSensorD);

  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());



   ssent = trimitator_WIFI();



  ///////////////////////////////////////////
  // 4. Create ASCII frame
  ///////////////////////////////////////////

  // Create new frame (ASCII)
  frame.createFrame(ASCII);

  // Add temperature
  frame.addSensor(SENSOR_IONS_WT, tempValue);
  // Add PH
  frame.addSensor(SENSOR_IONS_CA, calciumValue);
  // Add ORP value
  frame.addSensor(SENSOR_IONS_NO3, NO3Value);
  // Add PH
  frame.addSensor(SENSOR_IONS_MG, MagnesiumSensorD);
  // Add ORP value
  frame.addSensor(SENSOR_IONS_NH4, AmmoniumSensorD);

  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());

  // Show the frame
  frame.showFrame();

  scriitor_SD(filename, ssent);


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
  // Turn on the Smart Water Sensor Board and start the USB
  USB.ON();
  RTC.ON(); // Executes the init process
  USB.println(F("START"));
  USB.println(F("IONS "));
  //data_maker( 10000 ,  filename  );

  WiFi_init();
  // Utils.setProgramVersion( verr );

  //OTA_setup_check(10);
  // RTC_setup();///////////////include WiFi_setup();

  USB.print(F("Current RTC settings:"));
  USB.println(RTC.getTime());


  // Set SD ON
  SD_TEST_FILE_CHECK();

  // Calibrate the Calcium sensor
  calciumSensor.setCalibrationPoints(voltages_Ca, concentrationsCa, NUM_POINTS);
  // Calibrate the NO3 sensor
  NO3Sensor.setCalibrationPoints(voltages_NO3, concentrationsNO3, NUM_POINTS);
  // Calibrate the Magnesium sensor
  MagnesiumSensor.setCalibrationPoints(voltages_MG, concentrationsMg, NUM_POINTS);
  // Calibrate the NH4 sensor
  AmmoniumSensor.setCalibrationPoints(voltages_NH4, concentrationsNH4, NUM_POINTS);


//  x1 = 0;
//  x2 = 0;
//  x3 = 0;
//  x4 = 0;
}






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



  IONII();


 Watchdog_setup_and_reset( cycle_time2 , true );

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


