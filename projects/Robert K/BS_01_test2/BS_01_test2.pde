/*  
 *  ------ [BS_01] Getting the value of temperature sensor -------- 
 *  
 *  Explanation: This example shows how to get the vale of temperature
 *  sensor. Temperature Sensor MCP9700A plugged to ANALOG6 pin
 *  
 *  Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           3.0
 *  Design:            Marcos Yarza
 *  Implementation:    Marcos Yarza
 */

// Library include
#include <WaspSensorGas_v30.h>
#include <WaspFrame.h>
#include <WaspLoRaWAN.h>



uint8_t error;
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

// define radio settings
//////////////////////////////////////////////
uint8_t power = 15;
uint32_t frequency;
char spreading_factor[] = "sf12";
char coding_rate[] = "4/5";
uint16_t bandwidth = 125;
char crc_mode[] = "on";
//////////////////////////////////////////////




// define data to send
char data[] = "The council of Elrond salutes you.";


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

char node_ID[] = "O2_example";





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

char data2[200] ;
char payload_hex[200];

bool chargeState;
uint16_t chargeCurrent;



void setup()
{
  // Open the USB connection
 // data2[]="uyguyg";
  USB.ON();
  USB.println(F("USB port started..."));
    RTC.ON();
  USB.println(F("RTC time:"));
  USB.println(F("------------------------------------"));
  USB.println(RTC.getTime());
  USB.println(F("------------------------------------\n"));
    // Switch ON and configure the Gases Board

        O2Sensor.setCalibrationPoints(voltages, concentrations_o2);
        LPGSensor.setCalibrationPoints(voltages_lps, concentrations_lps, 3);
        CO2Sensor.setCalibrationPoints(voltages_co2, concentrations_co2, 3);

        // variable
uint8_t error;

  USB.println(F("Radio "));

  // module setup
  error = radioModuleSetup();
  
  // Check status
  if (error == 0)
  {
    USB.println(F("Module configured OK"));     
  }
  else 
  {
    USB.println(F("Module configured ERROR"));     
  }  

}
  



void loop()
{  


  Gases.ON();  
  O2Sensor.ON();
  LPGSensor.ON();
  CO2Sensor.ON();

  // read temperature sensor connected to ANALOG6 pin
  temperature = Utils.readTemperature();
  USB.print(F("Value of temperature: "));
  USB.print(temperature*0.088);
  USB.println(F(" Celsius degrees"));
  
  USB.println(RTC.getTime());
  USB.print("battery (Volts): ");
USB.println(PWR.getBatteryVolts());
USB.print("battery percent: ");
USB.println((int)(PWR.getBatteryLevel()));

// snprint(data2, sizeof(data2), "%s%d", "Value of temperature: ", temperature);

  float O2Vol = O2Sensor.readVoltage();
  USB.print(F("O2 concentration Estimated: "));
  USB.print(O2Vol);
  USB.print(F(" mV | "));
  delay(100);

  // Read the concentration value in %
  float O2Val = O2Sensor.readConcentration();
  
  USB.print(F(" O2 concentration Estimated: "));
  USB.print(O2Val*0.6);
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



  Utils.hex2str((uint8_t*)data, payload_hex, strlen(data));
      USB.print("in hexa: "); 
      USB.println(payload_hex); 
      USB.print("lungime: "); 
      USB.println( strlen( payload_hex)   );     





        
error = LoRaWAN.sendRadio(payload_hex);

  if (error == 0)
  {
    USB.println(F("--> Packet sent OK"));
  }
  else 
  {
    USB.print(F("Error waiting for packets. error = "));  
    USB.println(error, DEC);   
  }


/*
error = LoRaWAN.sendRadio("test2");

  if (error == 0)
  {
    USB.println(F("--> Packet sent OK"));
  }
  else 
  {
    USB.print(F("Error waiting for packets. error = "));  
    USB.println(error, DEC);   
  }

*/


/*
  error = LoRaWAN.sendRadio(data);

  if (error == 0)
  {
    USB.println(F("--> Packet sent OK"));
  }
  else 
  {
    USB.print(F("Error waiting for packets. error = "));  
    USB.println(error, DEC);   
  }
  */

  USB.println(F("------------------------------------------------------"));


  Gases.OFF();  
  O2Sensor.OFF();
  LPGSensor.OFF();
  CO2Sensor.OFF();




  // get charging state and current
  chargeState = PWR.getChargingState();
  chargeCurrent = PWR.getBatteryCurrent(); 
  
  
  // Show the battery charging state. This is valid for both USB and Solar panel
  // If any of those ports are used --> the charging state will be true
  USB.print(F("Battery charging state: "));
  if (chargeState == true)
  {
    USB.println(F("Battery is charging"));
  }
  else
  {
    USB.println(F("Battery is not charging"));
  }

  // Show the battery charging current (only from solar panel)
  USB.print(F("Battery charging current (only from solar panel): "));
  USB.print(chargeCurrent, DEC);
  USB.println(F(" mA"));

  USB.println();





  
  delay(25000); 
}










uint8_t radioModuleSetup()
{ 

  uint8_t status = 0;
  uint8_t e = 0;
  
  //////////////////////////////////////////////
  // 1. switch on
  //////////////////////////////////////////////

  e = LoRaWAN.ON(socket);

  // Check status
  if (e == 0)
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));

    if (LoRaWAN._version == RN2483_MODULE || LoRaWAN._version == RN2903_IN_MODULE)
  {
    frequency = 868100000;
  }
  else if(LoRaWAN._version == RN2903_MODULE)
  {
    frequency = 902300000;
  }
  else if(LoRaWAN._version == RN2903_AS_MODULE)
  {
    frequency = 917300000;
  }

  //////////////////////////////////////////////
  // 2. Enable P2P mode
  //////////////////////////////////////////////

  e = LoRaWAN.macPause();

  // Check status
  if (e == 0)
  {
    USB.println(F("2. P2P mode enabled OK"));
  }
  else 
  {
    USB.print(F("2. Enable P2P mode error = "));
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 3. Set/Get Radio Power
  //////////////////////////////////////////////

  // Set power
  e = LoRaWAN.setRadioPower(power);

  // Check status
  if (e == 0)
  {
    USB.println(F("3.1. Set Radio Power OK"));
  }
  else 
  {
    USB.print(F("3.1. Set Radio Power error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get power
  e = LoRaWAN.getRadioPower();

  // Check status
  if (e == 0) 
  {
    USB.print(F("3.2. Get Radio Power OK. ")); 
    USB.print(F("Power: "));
    USB.println(LoRaWAN._radioPower);
  }
  else 
  {
    USB.print(F("3.2. Get Radio Power error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 4. Set/Get Radio Frequency
  //////////////////////////////////////////////

  // Set frequency
  e = LoRaWAN.setRadioFreq(frequency);

  // Check status
  if (e == 0)
  {
    USB.println(F("4.1. Set Radio Frequency OK"));
  }
  else 
  {
    USB.print(F("4.1. Set Radio Frequency error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get frequency
  e = LoRaWAN.getRadioFreq();

  // Check status
  if (e == 0) 
  {
    USB.print(F("4.2. Get Radio Frequency OK. ")); 
    USB.print(F("Frequency: "));
    USB.println(LoRaWAN._radioFreq);
  }
  else 
  {
    USB.print(F("4.2. Get Radio Frequency error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 5. Set/Get Radio Spreading Factor (SF)
  //////////////////////////////////////////////

  // Set SF
  e = LoRaWAN.setRadioSF(spreading_factor);

  // Check status
  if (e == 0)
  {
    USB.println(F("5.1. Set Radio SF OK"));
  }
  else 
  {
    USB.print(F("5.1. Set Radio SF error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get SF
  e = LoRaWAN.getRadioSF();

  // Check status
  if (e == 0) 
  {
    USB.print(F("5.2. Get Radio SF OK. ")); 
    USB.print(F("Spreading Factor: "));
    USB.println(LoRaWAN._radioSF);
  }
  else 
  {
    USB.print(F("5.2. Get Radio SF error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 6. Set/Get Radio Coding Rate (CR)
  //////////////////////////////////////////////

  // Set CR
  e = LoRaWAN.setRadioCR(coding_rate);

  // Check status
  if (e == 0)
  {
    USB.println(F("6.1. Set Radio CR OK"));
  }
  else 
  {
    USB.print(F("6.1. Set Radio CR error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get CR
  e = LoRaWAN.getRadioCR();

  // Check status
  if (e == 0) 
  {
    USB.print(F("6.2. Get Radio CR OK. ")); 
    USB.print(F("Coding Rate: "));
    USB.println(LoRaWAN._radioCR);
  }
  else 
  {
    USB.print(F("6.2. Get Radio CR error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 7. Set/Get Radio Bandwidth (BW)
  //////////////////////////////////////////////

  // Set BW
  e = LoRaWAN.setRadioBW(bandwidth);

  // Check status
  if (e == 0)
  {
    USB.println(F("7.1. Set Radio BW OK"));
  }
  else 
  {
    USB.print(F("7.1. Set Radio BW error = "));
    USB.println(e, DEC);
  }

  // Get BW
  e = LoRaWAN.getRadioBW();

  // Check status
  if (e == 0) 
  {
    USB.print(F("7.2. Get Radio BW OK. ")); 
    USB.print(F("Bandwidth: "));
    USB.println(LoRaWAN._radioBW);
  }
  else 
  {
    USB.print(F("7.2. Get Radio BW error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 8. Set/Get Radio CRC mode
  //////////////////////////////////////////////

  // Set CRC
  e = LoRaWAN.setRadioCRC(crc_mode);

  // Check status
  if (e == 0)
  {
    USB.println(F("8.1. Set Radio CRC mode OK"));
  }
  else 
  {
    USB.print(F("8.1. Set Radio CRC mode error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get CRC
  e = LoRaWAN.getRadioCRC();

  // Check status
  if (e == 0) 
  {
    USB.print(F("8.2. Get Radio CRC mode OK. ")); 
    USB.print(F("CRC status: "));
    USB.println(LoRaWAN._crcStatus);
  }
  else 
  {
    USB.print(F("8.2. Get Radio CRC mode error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));


  return status;
}

