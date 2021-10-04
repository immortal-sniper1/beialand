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

void setup()
{
  // Open the USB connection
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
  Gases.ON();  
  // Switch ON the SOCKET_1
  O2Sensor.ON();
    // Switch ON the sensor socket

      LPGSensor.ON();
        CO2Sensor.ON();


  

}

void loop()
{  
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





  USB.println(F("------------------------------------------------------"));

  delay(5000); 
}
