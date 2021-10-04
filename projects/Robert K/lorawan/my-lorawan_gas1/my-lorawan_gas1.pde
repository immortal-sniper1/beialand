/*  
 *  ------ LoRaWAN Code Example -------- 
 *  
 *  Explanation: This example shows how to configure the module and
 *  send frames to a LoRaWAN gateway with ACK after join a network
 *  using OTAA
 *  
 *  Copyright (C) 2017 Libelium Comunicaciones Distribuidas S.L. 
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
 *  along with this program.  If not, see .  
 *  
 *  Version:           3.1
 *  Design:            David Gascon 
 *  Implementation:    Luis Miguel Marti
 */

#include <WaspLoRaWAN.h>
#include <WaspFrame.h>
#include <WaspSensorGas_v30.h>

// socket to use
//////////////////////////////////////////////
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

// Device parameters for Back-End registration
////////////////////////////////////////////////////////////
char DEVICE_EUI[]  = "00F1123C64E9C937";
char APP_EUI[] = "70B3D57ED003A4E5";
char APP_KEY[] = "3762B5DD8DAFC0C5C37FF9568EBF3516";
////////////////////////////////////////////////////////////

// Define port to use in Back-End: from 1 to 223
uint8_t PORT = 2;

// variable
uint8_t error;

// define the Waspmote ID 
char moteID[] = "sacrifice2";

//patea de gaze
float VOLT;
uint16_t CHRG;
#define NUM_OF_POINTS 3
int i;

O2SensorClass O2Sensor(SOCKET_1);
#define POINT1_PERCENTAGE 0.0
#define POINT2_PERCENTAGE 5.0
// Calibration Voltage Obtained during calibration process (in mV)
#define POINT1_VOLTAGE 0.35
#define POINT2_VOLTAGE 2.0
float concentrations_o2[] = {POINT1_PERCENTAGE, POINT2_PERCENTAGE};
float voltages_o2[] =       {POINT1_VOLTAGE, POINT2_VOLTAGE};





CO2SensorClass CO2Sensor(SOCKET_2);
#define POINT1_PPM_CO2 350.0    // PPM VALUE <-- Normal concentration in air
#define POINT2_PPM_CO2 1000.0   // PPM VALUE
#define POINT3_PPM_CO2 3000.0   // PPM VALUE
// Calibration vVoltages obtained during calibration process
#define POINT1_VOLT_CO2 0.300
#define POINT2_VOLT_CO2 0.350
#define POINT3_VOLT_CO2 0.380
float concentrations_co2[] = {POINT1_PPM_CO2, POINT2_PPM_CO2, POINT3_PPM_CO2};
float voltages_co2[] =       {POINT1_VOLT_CO2, POINT2_VOLT_CO2, POINT3_VOLT_CO2};





NO2SensorClass NO2Sensor(SOCKET_3);
#define POINT1_PPM_NO2 10.0   // PPM VALUE <-- Normal concentration in air
#define POINT2_PPM_NO2 50.0   // PPM VALUE
#define POINT3_PPM_NO2 100.0  // PPM VALUE
// Calibration voltages obtained during calibration process (in KOHMs)
#define POINT1_RES_NO2 45.25  // <-- Rs at normal concentration in air
#define POINT2_RES_NO2 25.50
#define POINT3_RES_NO2 3.55
float concentrations_no2[] = {POINT1_PPM_NO2, POINT2_PPM_NO2, POINT3_PPM_NO2};
float voltages_no2[] =       {POINT1_RES_NO2, POINT2_RES_NO2, POINT3_RES_NO2};





COSensorClass COSensor(SOCKET_4); 
#define POINT1_PPM_CO 100.0   // <--- Ro value at this concentration
#define POINT2_PPM_CO 300.0   // 
#define POINT3_PPM_CO 1000.0  // 
// Calibration resistances obtained during calibration process
#define POINT1_RES_CO 230.30 // <-- Ro Resistance at 100 ppm. Necessary value.
#define POINT2_RES_CO 40.665 //
#define POINT3_RES_CO 20.300 //
float concentrations_co[] = { POINT1_PPM_CO, POINT2_PPM_CO, POINT3_PPM_CO };
float resValues_co[] =      { POINT1_RES_CO, POINT2_RES_CO, POINT3_RES_CO };





VOCSensorClass VOCSensor(SOCKET_5); 
#define POINT1_PPM_VOC 100.0   //  <--- Ro value at this concentration
#define POINT2_PPM_VOC 300.0   
#define POINT3_PPM_VOC 1000.0 
// Calibration resistances obtained during calibration process
#define POINT1_RES_VOC 230.30 // <-- Ro Resistance at 100 ppm. Necessary value.
#define POINT2_RES_VOC 40.665 // 
#define POINT3_RES_VOC 20.300 // 
float concentrations[] = { POINT1_PPM_VOC, POINT2_PPM_VOC, POINT3_PPM_VOC };
float resValues[] =      { POINT1_RES_VOC, POINT2_RES_VOC, POINT3_RES_VOC };





LPGSensorClass LPGSensor(SOCKET_6); ; // <---- SOCKET7 Class used
#define POINT1_PPM_LPG 10.0   // PPM VALUE <-- Normal concentration in air
#define POINT2_PPM_LPG 50.0   // PPM VALUE
#define POINT3_PPM_LPG 100.0  // PPM VALUE
// Calibration voltages obtained during calibration process (in KOHMs)
#define POINT1_RES_LPG 45.25  // <-- Rs at normal concentration in air
#define POINT2_RES_LPG 25.50
#define POINT3_RES_LPG 3.55
float concentrations_lps[] = {POINT1_PPM_LPG, POINT2_PPM_LPG, POINT3_PPM_LPG};
float voltages_lps[] =       {POINT1_RES_LPG, POINT2_RES_LPG, POINT3_RES_LPG};





SVSensorClass SVSensor(SOCKET_7); 
#define POINT1_PPM_SV 10.0  // <-- Normal concentration in air
#define POINT2_PPM_SV 50.0 
#define POINT3_PPM_SV 100.0  
// Calibration voltages obtained during calibration process (in KOHMs)
#define POINT1_RES_SV 45.25  // <-- Rs at normal concentration in air
#define POINT2_RES_SV 25.50
#define POINT3_RES_SV 3.55
float concentrations_sv[] = { POINT1_PPM_SV, POINT2_PPM_SV, POINT3_PPM_SV };
float voltages_sv[] =       { POINT1_RES_SV, POINT2_RES_SV, POINT3_RES_SV };


float temperature; // Stores the temperature in ºC
float humidity;    // Stores the realitve humidity in %RH
float pressure;    // Stores the pressure in Pa
unsigned long previous;






void setup() 
{
  USB.ON();
  USB.println(F("LoRaWAN example - Send Confirmed packets (ACK)\n"));
  USB.println(F("------------------------------------"));
  USB.println(F("Module configuration"));
  USB.println(F("------------------------------------\n"));
  RTC.setTime("23:06:29:02:10:00:00");

  //////////////////////////////////////////////
  // 1. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 2. Set Device EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Device EUI set OK"));     
  }
  else 
  {
    USB.print(F("2. Device EUI set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 3. Set Application EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setAppEUI(APP_EUI);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("3. Application EUI set OK"));     
  }
  else 
  {
    USB.print(F("3. Application EUI set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 4. Set Application Session Key
  //////////////////////////////////////////////

  error = LoRaWAN.setAppKey(APP_KEY);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Application Key set OK"));     
  }
  else 
  {
    USB.print(F("4. Application Key set error = ")); 
    USB.println(error, DEC);
  }

  /////////////////////////////////////////////////
  // 5. Join OTAA to negotiate keys with the server
  /////////////////////////////////////////////////
  
  error = LoRaWAN.joinOTAA();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("5. Join network OK"));         
  }
  else 
  {
    USB.print(F("5. Join network error = ")); 
    USB.println(error, DEC);
  }

 // LoRaWAN.setRadioCR("4/7");
 // LoRaWAN.getRadioCR();
  //////////////////////////////////////////////
  // 6. Save configuration
  //////////////////////////////////////////////

  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("6. Save configuration OK"));     
  }
  else 
  {
    USB.print(F("6. Save configuration error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 7. Switch off
  //////////////////////////////////////////////

  error = LoRaWAN.OFF(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("7. Switch OFF OK"));     
  }
  else 
  {
    USB.print(F("7. Switch OFF error = ")); 
    USB.println(error, DEC);
  }

  
  USB.println(F("\n---------------------------------------------------------------"));
  USB.println(F("Module configured"));
  USB.println(F("After joining through OTAA, the module and the network exchanged "));
  USB.println(F("the Network Session Key and the Application Session Key which "));
  USB.println(F("are needed to perform communications. After that, 'ABP mode' is used"));
  USB.println(F("to join the network and send messages after powering on the module"));
  USB.println(F("---------------------------------------------------------------\n"));
  USB.println();  
  
  frame.setID(moteID);

    USB.println(F("the te sensor initiation part: "));

  // Configure the calibration values
  O2Sensor.setCalibrationPoints(voltages_o2, concentrations_o2);
  // Configure the calibration values
  CO2Sensor.setCalibrationPoints(voltages_co2, concentrations_co2, NUM_OF_POINTS);
  // Configure the calibration values
  NO2Sensor.setCalibrationPoints(voltages_no2, concentrations_no2, NUM_OF_POINTS);
  // Configure the calibration values
  VOCSensor.setCalibrationPoints(resValues, concentrations, NUM_OF_POINTS);
  // Configure the calibration values
  LPGSensor.setCalibrationPoints(voltages_lps, concentrations_lps, NUM_OF_POINTS);
  // Calculate the slope and the intersection of the logarithmic function
  COSensor.setCalibrationPoints(resValues_co, concentrations_co, NUM_OF_POINTS);
  // Calculate the slope and the intersection of the logarithmic function
  SVSensor.setCalibrationPoints(voltages_sv, concentrations_sv, NUM_OF_POINTS);
  USB.println(F("Frame Gases_Board"));
  USB.println(F("Sensors used:"));
  USB.println(F("- SOCKET_1: O2 sensor"));
  USB.println(F("- SOCKET_2: CO2 sensor)"));
  USB.println(F("- SOCKET_3: NO2 sensor"));
  USB.println(F("- SOCKET_4: CO sensor"));
  USB.println(F("- SOCKET_5: VOC sensor"));
  USB.println(F("- SOCKET_6: LPG sensor"));
  USB.println(F("- SOCKET_7: APP1 / SV [1] sensor"));
  USB.println(F("- SOCKET_8: BME280 sensor (temperature, humidity & pressure"));
  USB.OFF();






}






void loop() 
{

  USB.ON();
  Gases.ON();








  // Read enviromental variables
  temperature = Gases.getTemperature();
  humidity = Gases.getHumidity();
  pressure = Gases.getPressure();
  
  VOLT = PWR.getBatteryVolts();
 // CHRG = PWR.getBatteryCurrent();
  //////////////////////////////////////////////////////////////////////
  // 2.2 Read O2 Sensor - Connected in SOCKET1
  //////////////////////////////////////////////////////////////////////
  O2Sensor.ON();
  delay(1000);
  // O2 Sensor does not need power suplly
  float O2Vol = O2Sensor.readVoltage();
  delay(100);
   // Read the concentration value in %
  float O2Val = O2Sensor.readConcentration();
  O2Sensor.OFF();

  //////////////////////////////////////////////////////////////////////
  // 2.3 Read CO2 Sensor - Connected in SOCKET2
  //////////////////////////////////////////////////////////////////////
  CO2Sensor.ON();
  delay(1000);
  // PPM value of CO2
  // Voltage value of the sensor
  float CO2Vol = CO2Sensor.readVoltage();
  // PPM value of CO2
  float CO2PPM = CO2Sensor.readConcentration();
  CO2Sensor.OFF();

  //////////////////////////////////////////////////////////////////////
  // 2.4 Read NO2 Sensor - Connected in SOCKET3
  //////////////////////////////////////////////////////////////////////
  NO2Sensor.ON();
  delay(1000);
  // PPM value of NO2
  float NO2Vol = NO2Sensor.readVoltage();       // Voltage value of the sensor
  float NO2Res = NO2Sensor.readResistance();    // Resistance of the sensor
  float NO2PPM = NO2Sensor.readConcentration(); // PPM value of NO2
  NO2Sensor.OFF();

  //////////////////////////////////////////////////////////////////////
  // 2.4 Read VOC Sensor - Connected in SOCKET5
  //////////////////////////////////////////////////////////////////////
  VOCSensor.ON();
  delay(1000);
  // PPM value of VOC
  float VOCVol = VOCSensor.readVoltage();       // Voltage value of the sensor
  float VOCRes = VOCSensor.readResistance();    // Resistance of the sensor
  float VOCPPM = VOCSensor.readConcentration(); // PPM value of VOC
  VOCSensor.OFF();

  // 2.5 Read LPG Sensor - Connected in SOCKET7
  //////////////////////////////////////////////////////////////////////
  LPGSensor.ON();
  delay(1000);
  // PPM value of CH4
  float LPGVol = LPGSensor.readVoltage();         // Voltage value of the sensor
  float LPGRes = LPGSensor.readResistance();      // Resistance of the sensor
  float LPGPPM = LPGSensor.readConcentration();   // PPM value of LPGfloat LPGPPM = LPGSensor.readConcentration();
  LPGSensor.OFF();
  
  // 2.6 Read LPG Sensor - Connected in SOCKET6
  //////////////////////////////////////////////////////////////////////
  COSensor.ON();
  // PPM value of CO
  delay(1000);
  float COVol = COSensor.readVoltage();          // Voltage value of the sensor
  float CORes = COSensor.readResistance();       // Resistance of the sensor
  float COPPM = COSensor.readConcentration(); // PPM value of CO
  COSensor.OFF();

  // 2.7 Read SV Sensor - Connected in SOCKET7
  //////////////////////////////////////////////////////////////////////
  SVSensor.ON();
    delay(1000);
  // PPM value of SV
  float SVVol = SVSensor.readVoltage();       // Voltage value of the sensor
  float SVRes = SVSensor.readResistance();    // Resistance of the sensor
  float SVPPM = SVSensor.readConcentration(); // PPM value of Solvent Vapor sensor
  SVSensor.OFF();
  Gases.OFF();

  // Print of the results
  USB.print(F("Temperature: "));
  USB.print(temperature);
  USB.println(F(" Celsius Degrees"));
  
  USB.print(F("Humidity : "));
  USB.print(humidity);
  USB.println(F(" %RH"));

  USB.print(F("Pressure : "));
  USB.print(pressure);
  USB.println(F(" Pa"));
  /////////////////print of results//////////////////////////
  // O2 Sensor does not need power suplly
  USB.print(F("O2 concentration Estimated: "));
  USB.print(O2Vol);
  USB.println(F(" mV"));
  
  USB.print(F("O2 concentration Estimated: "));
  USB.print(O2Val);
  USB.println(F(" %"));  

  // Print of the results
  USB.print(F("NO2 Sensor Voltage: "));
  USB.print(NO2Vol);
  USB.println(F(" V"));
  
  // Print of the results
  USB.print(F("NO2 Sensor Resistance: "));
  USB.print(NO2Res);
  USB.println(F(" Ohms"));

  // Print of the results
  USB.print(F("NO2 concentration Estimated: "));
  USB.print(NO2PPM);
  USB.println(F(" PPM"));
 
  
  // Print of the results
  USB.print(F("CO Sensor Voltage: "));
  USB.print(COVol);
  USB.print(F(" mV"));

  // Print of the results
  USB.print(F("CO Sensor Resistance: "));
  USB.print(CORes);
  USB.print(F(" Ohms"));

  USB.print(F("CO concentration Estimated: "));
  USB.print(COPPM);
  USB.println(F(" ppm"));

  // Print of the results
  USB.print(F("CO2 Sensor Voltage: "));
  USB.print(CO2Vol);
  USB.println(F("volts"));
  
  USB.print(F("CO2 concentration estimated: "));
  USB.print(CO2PPM);
  USB.println(F(" ppm"));

  // Print of the results
  USB.print(F("VOC Sensor Voltage: "));
  USB.print(VOCVol);
  USB.println(F(" V"));

  // Print of the results
  USB.print(F("VOC Sensor Resistance: "));
  USB.print(VOCRes);
  USB.println(F(" Ohms"));

  USB.print(F("VOC concentration Estimated: "));
  USB.print(VOCPPM);
  USB.println(F(" ppm"));

  // Print of the results
  USB.print(F("Solvent Vapors Sensor Voltage: "));
  USB.print(SVVol);
  USB.println(F(" V"));
  
  // Print of the results
  USB.print(F("Solvent Vapors Sensor Resistance: "));
  USB.print(SVRes);
  USB.println(F(" Ohms"));

  // Print of the results
  USB.print(F("Solvent Vapors concentration Estimated: "));
  USB.print(SVPPM);
  USB.println(F(" PPM"));

  // Print of the results
  USB.print(F("LPG Sensor Voltage: "));
  USB.print(LPGVol);
  USB.println(F(" V"));

  // Print of the results
  USB.print(F("LPG Sensor Resistance: "));
  USB.print(LPGRes);
  USB.println(F(" Ohms"));

  USB.print(F("LPG concentration Estimated: "));
  USB.print(LPGPPM);
  USB.println(F(" ppm"));

  // Show the remaining battery level
  USB.print(F("Battery Level: "));
  USB.print(PWR.getBatteryLevel(),DEC);
  USB.println(F(" %"));
  
  // Show the battery Volts
  USB.print(F("Battery (Volts): "));
  USB.print(PWR.getBatteryVolts());
  USB.println(F(" V"));

  //////////////////////////////////////////////
  // 1. Creating a new frame
  //////////////////////////////////////////////
  USB.println(F("Creating an ASCII frame"));

  // Create new frame (ASCII)
  frame.createFrame(ASCII);


  frame.addSensor(SENSOR_GASES_O2, O2Val);
  frame.addSensor(SENSOR_GASES_NO2, NO2PPM);
  frame.addSensor(SENSOR_GASES_VOC, VOCPPM);
  frame.addSensor(SENSOR_GASES_LPG, LPGPPM);
  frame.addSensor(SENSOR_GASES_CO, COPPM);
  frame.addSensor(SENSOR_GASES_SV, SVPPM);
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  
  USB.println(F(" FRAME IS DONE:"));
  // Prints frame
  frame.showFrame();




    USB.println(F("a"));     


  //////////////////////////////////////////////
  // 2. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
  }
    USB.println(F("b"));   

  //////////////////////////////////////////////
  // 3. Join network
  //////////////////////////////////////////////

  error = LoRaWAN.joinABP();
    USB.println(F("c"));   
  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Join network OK")); 

    //////////////////////////////////////////////
    // 4. Send confirmed packet 
    //////////////////////////////////////////////

    error = LoRaWAN.sendConfirmed( PORT, frame.buffer, frame.length);

    // Error messages:
    /*
     * '6' : Module hasn't joined a network
     * '5' : Sending error
     * '4' : Error with data length    
     * '2' : Module didn't response
     * '1' : Module communication error   
     */
    // Check status
    if( error == 0 ) 
    {
      USB.println(F("3. Send confirmed packet OK"));     
      if (LoRaWAN._dataReceived == true)
      { 
        USB.print(F("   There's data on port number "));
        USB.print(LoRaWAN._port,DEC);
        USB.print(F(".\r\n   Data: "));
        USB.println(LoRaWAN._data);
      }
    }
    else 
    {
      USB.print(F("3. Send confirmed packet error = ")); 
      USB.println(error, DEC);
    }    
  }
  else 
  {
    USB.print(F("2. Join network error = ")); 
    USB.println(error, DEC);
  }
    USB.println(F("d"));   
  //////////////////////////////////////////////
  // 5. Switch off
  //////////////////////////////////////////////

  error = LoRaWAN.OFF(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Switch OFF OK"));     
  }
  else 
  {
    USB.print(F("4. Switch OFF error = ")); 
    USB.println(error, DEC);
  }









  USB.print("time: ");
  USB.print(   millis() /1000 );
  USB.println(" s");
  USB.print("time of cycle: ");
  USB.print(   (millis()-previous)/1000 );
  USB.println(" s");
  previous = millis();


  
  USB.println();
  USB.println();
  USB.println();
  USB.println();
  USB.println();
  
  USB.OFF();

  delay(60000);



}
