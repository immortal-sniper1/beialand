/*
    ------ [BS_01] Getting the value of temperature sensor --------

    Explanation: This example shows how to get the vale of temperature
    sensor. Temperature Sensor MCP9700A plugged to ANALOG6 pin

    Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Version:           3.0
    Design:            Marcos Yarza
    Implementation:    Marcos Yarza
*/

// Library include
#include <WaspSensorGas_v30.h>
#include <WaspFrame.h>
#include <WaspWIFI_PRO.h>




///// EDITEAZA AICI DOAR
char node_ID[] = "ceva13xx";
int count_trials = 0;
int N_trials = 5;
char ESSID[] = "LANCOMBEIA";
char PASSW[] = "beialancom";
uint8_t max_atemptss = 10; // nr de max de trame de retrimit deodata
uint8_t resend_f = 2; // frame resend atempts
int cycle_time2 = 120; // in seconds
uint8_t error;
unsigned long prev, previous;
int x, b, cycle_time;
uint8_t status = false;







// choose NTP server settings
///////////////////////////////////////
char SERVER1[] = "time.nist.gov";
char SERVER2[] = "wwv.nist.gov";
//"pool.ntp.org";
///////////////////////////////////////

// Define Time Zone from -12 to 12 (i.e. GMT+2)
///////////////////////////////////////
uint8_t time_zone = 3;
///////////////////////////////////////

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET0;
///////////////////////////////////////
// choose URL settings
///////////////////////////////////////
char type[] = "http";
char host[] = "82.78.81.178";
char port[] = "80";


// O2 Sensor must be connected in SOCKET_1
O2SensorClass O2Sensor(SOCKET_1);

// Percentage values of Oxygen
#define POINT1_PERCENTAGE 0.0
#define POINT2_PERCENTAGE 5.0

// Calibration Voltage Obtained during calibration process (in mV)
#define POINT1_VOLTAGE 0.35
#define POINT2_VOLTAGE 2.0

float concentrations_o2[] = {POINT1_PERCENTAGE, POINT2_PERCENTAGE};
float voltages[] =       {POINT1_VOLTAGE, POINT2_VOLTAGE};





// LPG Sensor can be connected in SOCKET6 or SOCKET7
LPGSensorClass LPGSensor(SOCKET_7);

// Concentratios used in calibration process (PPM VALUE)
#define POINT1_PPM_LPG 10.0   //  <-- Normal concentration in air
#define POINT2_PPM_LPG 50.0
#define POINT3_PPM_LPG 100.0

// Calibration voltages obtained during calibration process (in KOHMs)
#define POINT1_RES_LPG 45.25  // <-- Rs at normal concentration in air
#define POINT2_RES_LPG 25.50
#define POINT3_RES_LPG 3.55

// Define the number of calibration points
#define numPoints 3


float concentrations_lps[] = {POINT1_PPM_LPG, POINT2_PPM_LPG, POINT3_PPM_LPG};
float voltages_lps[] =       {POINT1_RES_LPG, POINT2_RES_LPG, POINT3_RES_LPG};

//char node_ID[] = "LPG_example";

CO2SensorClass CO2Sensor(SOCKET_2);

// Concentratios used in calibration process
#define POINT1_PPM_CO2 350.0    // PPM VALUE <-- Normal concentration in air
#define POINT2_PPM_CO2 1000.0   // PPM VALUE
#define POINT3_PPM_CO2 3000.0   // PPM VALUE

// Calibration vVoltages obtained during calibration process
#define POINT1_VOLT_CO2 0.300
#define POINT2_VOLT_CO2 0.350
#define POINT3_VOLT_CO2 0.380

float concentrations_co2[] = {POINT1_PPM_CO2, POINT2_PPM_CO2, POINT3_PPM_CO2};
float voltages_co2[] =       {POINT1_VOLT_CO2, POINT2_VOLT_CO2, POINT3_VOLT_CO2};


float temperature = 0.0;























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























void setup()
{
  // Open the USB connection
  USB.ON();
  USB.println(F("USB port started..."));
  RTC.ON();
  WiFi_init();
  USB.println(F("RTC time:"));
  USB.println(F("------------------------------------"));
  USB.println(RTC.getTime());
  USB.println(F("------------------------------------\n"));
  // Switch ON and configure the Gases Board

  O2Sensor.setCalibrationPoints(voltages, concentrations_o2);
  LPGSensor.setCalibrationPoints(voltages_lps, concentrations_lps, 3);
  CO2Sensor.setCalibrationPoints(voltages_co2, concentrations_co2, 3);





}

void loop()
{
  Gases.ON();
  // Switch ON the SOCKET_1
  O2Sensor.ON();
  // Switch ON the sensor socket

  LPGSensor.ON();
  CO2Sensor.ON();
  delay(200000);
  // read temperature sensor connected to ANALOG6 pin
  temperature = Utils.readTemperature();
  USB.print(F("Value of temperature: "));
  USB.print(temperature * 0.088);
  USB.println(F(" Celsius degrees"));

  USB.println(RTC.getTime());
  USB.print("battery (Volts): ");
  USB.println(PWR.getBatteryVolts());
  USB.print("battery percent: ");
  USB.println((int)(PWR.getBatteryLevel()));



  float O2Vol = O2Sensor.readVoltage();
  USB.print(F("O2 concentration Estimated: "));
  USB.print(O2Vol);
  USB.print(F(" mV | "));
  delay(100);

  // Read the concentration value in %
  float O2Val = O2Sensor.readConcentration();

  USB.print(F(" O2 concentration Estimated: "));
  USB.print(O2Val * 0.6);
  USB.println(F(" %"));



  float LPGVol = LPGSensor.readVoltage();         // Voltage value of the sensor
  float LPGRes = LPGSensor.readResistance();      // Resistance of the sensor
  float LPGPPM = LPGSensor.readConcentration();   // PPM value of LPG
  float CO2PPM = CO2Sensor.readConcentration();
  float CO2Vol = CO2Sensor.readVoltage();

  // Print of the results
  USB.print(F("LPG Sensor Voltage: "));
  USB.print(LPGVol);
  USB.println(F(" V |"));

  // Print of the results
  USB.print(F(" LPG Sensor Resistance: "));
  USB.print(LPGRes);
  USB.println(F(" Ohms |"));

  USB.print(F(" LPG concentration Estimated: "));
  USB.print(LPGPPM);
  USB.println(F(" ppm"));



  USB.print(F("CO2 Sensor Voltage: "));
  USB.print(CO2Vol);
  USB.println(F("volts |"));


  Gases.OFF();
  // Switch ON the SOCKET_1
  O2Sensor.OFF();
  // Switch ON the sensor socket

  LPGSensor.OFF();
  CO2Sensor.OFF();
  delay(10000);



  frame.createFrame(ASCII, node_ID); // frame1 de  stocat
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  frame.addSensor(SENSOR_GASES_LPG, LPGPPM  );     // CH4 analogic
  frame.addSensor(SENSOR_GASES_CO2, CO2Vol  );     // CH4 analogic
  frame.addTimestamp();

  frame.showFrame();
  trimitator_WIFI();

  USB.println(F("------------------------------------------------------"));

  delay(600000);
}
