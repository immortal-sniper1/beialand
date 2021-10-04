/*
 *  ------------  [GP_v30_08] - Frame Class Utility  --------------
 *
 *  Explanation: This is the basic code to create a frame with some
 *   Gases Pro Sensor Board sensors
 *
 *  Copyright (C) 2019 Libelium Comunicaciones Distribuidas S.L.
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
 *  Version:        3.2
 *  Design:             David Gascón
 *  Implementation:     Alejandro Gállego
 */

#include <WaspSensorGas_Pro.h>
#include <WaspFrame.h>
#include <WaspPM.h>
#include <WaspWIFI_PRO.h> 

/*
   Define objects for sensors
   Imagine we have a P&S! with the next sensors:
    - SOCKET_A: BME280 sensor (temperature, humidity & pressure) 
    - SOCKET_B: sensor (CO)
    - SOCKET_C: sensor (NH3)
    - SOCKET_D: Particle matter sensor (dust)
    - SOCKET_E: None
    - SOCKET_F: sensor (CH4)
*/

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET1;
///////////////////////////////////////


// choose URL settings
///////////////////////////////////////
char type[] = "http";
char host[] = "82.78.81.178";
char port[] = "80";
///////////////////////////////////////

uint8_t error;
uint8_t status;
unsigned long previous;

Gas CO(SOCKET_B);
Gas NH3(SOCKET_C);
Gas CH4(SOCKET_F);

float temperature;
float humidity;
float pressure;

float concCO;
float concNH3;
float concCH4;

int OPC_status;
int OPC_measure;

char node_ID[] = "FARM1";

void setup()
{
    USB.ON();
    USB.println(F("Frame Utility Example for Gases Pro Sensor Board"));
    USB.println(F("Sensors used:"));
    USB.println(F("- SOCKET_A: BME280 sensor (temperature, humidity & pressure)"));
    USB.println(F("- SOCKET_B: Electrochemical gas sensor (CO)"));
    USB.println(F("- SOCKET_C: Electrochemical gas sensor (NH3)"));
    USB.println(F("- SOCKET_F: Electrochemical gas sensor (CH4)"));
    USB.println(F("- SOCKET_D: Particle matter sensor (dust)"));
    
    // Set the Waspmote ID
    frame.setID(node_ID);
    //USB.OFF();
}












void loop()
{


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
    USB.OFF();
   // PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
    USB.ON();
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








  // get actual time
  previous = millis();
  //////////////////////////////////////////////////
  // 4. Switch ON
  //////////////////////////////////////////////////  
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }
  //////////////////////////////////////////////////
  // 5. Join AP
  //////////////////////////////////////////////////  
  // check connectivity
  status =  WIFI_PRO.isConnected();

  // check if module is connected
  if (status == true)
  {    
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
  

    RTC.ON();
    RTC.getTime();








    ///////////////////////////////////////////
    // 6. Create ASCII frame
    ///////////////////////////////////////////

    // Create new frame (ASCII)
    frame.createFrame(ASCII);

    // Add temperature
    frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
    // Add humidity
    frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
    // Add pressure value
    frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
    // Add CO value
    frame.addSensor(SENSOR_GASES_PRO_CO, concCO, 2);
    // Add NH3 value
    frame.addSensor(SENSOR_GASES_PRO_NH3, concNH3, 2);
    // Add CH4 value
    frame.addSensor(SENSOR_GASES_PRO_CH4, concCH4, 2);
    
     
    // Show the frame
    frame.showFrame();
    
   
// 3.2. Send Frame to Meshlium
    ///////////////////////////////
    // http frame
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);   // frame 1

    // check response
    if (error == 0)
    {
      USB.println(F("HTTP OK"));          
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous); 
      WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
      USB.println(F("ASCII FRAME 1 SEND OK")); 


    }
    else
    {
      USB.println(F("Error calling 'getURL' function"));
      WIFI_PRO.printErrorCode();
    }


      frame.createFrame(ASCII);
        // Add PM1
      frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1, 2);
      // Add PM2.5
      frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5, 2);
      // Add PM10
      frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10, 2);
      // Add BAT level
      frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
      frame.showFrame();
      error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);   // frame 2
      
    // check response
    if (error == 0)
    {
      USB.println(F("HTTP OK"));          
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous); 
      WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
      USB.println(F("ASCII FRAME 2 SEND OK")); 


    }
    else
    {
      USB.println(F("Error calling 'getURL' function"));
      WIFI_PRO.printErrorCode();
    }









    
  }
  else
  {
    USB.print(F("WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }

  
  //////////////////////////////////////////////////
  // 3. Switch OFF
  //////////////////////////////////////////////////  
  WIFI_PRO.OFF(socket);
  USB.println(F("WiFi switched OFF\n\n")); 
  // Go to deepsleep  

  ////////////////////////////////////////////////
  // 5. Sleep
  ////////////////////////////////////////////////
  USB.println(F("5. Enter deep sleep..."));
  PWR.deepSleep("00:00:18:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  USB.ON();
  USB.println(F("----------------------------------------------------------------------------------------------"));
  USB.println(F("6. Wake up!!\n\n"));

    
}
