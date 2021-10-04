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
#include <WaspPM.h>
#include <WaspXBee868LP.h>
#include <WaspFrame.h> 

/*
   Define objects for sensors
   Imagine we have a P&S! with the next sensors:
    - SOCKET_A: sensor (CO2) 
    - SOCKET_B: sensor (NO2)
    - SOCKET_C: sensor (O3)
    - SOCKET_D: Particle matter sensor (dust)
    - SOCKET_E: BME280 sensor (temperature, humidity & pressure)
    - SOCKET_F: sensor (SO2)
*/

// Destination MAC address
// MAC LOW = 41C3ADE5 
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20041C3ADE5";
//////////////////////////////////////////



// define variable
uint8_t error;

Gas CO2(SOCKET_A);
Gas NO2(SOCKET_B);
Gas O3(SOCKET_C);
Gas SO2(SOCKET_F);

float temperature;
float humidity;
float pressure;

float concCO2;
float concNO2;
float concSO2;
float concO3;

int OPC_status;
int OPC_measure;

char node_ID[] = "SEP1";

// PAN (Personal Area Network) Identifier
uint8_t  panID[2] = {0x7F,0xFF}; 

// Define Freq Channel to be set: 
uint8_t  mask[4] = {0x3F,0xFF,0xFF,0xFF};

// Define preamble ID
uint8_t preambleID = 0x00;

// Define the Encryption mode: 1 (enabled) or 0 (disabled)
uint8_t encryptionMode = 0;

// Define the AES 16-byte Encryption Key
char  encryptionKey[] = "WaspmoteLinkKey!"; 

void setup()
{
//    USB.ON();
//    USB.println("Frame Utility Example for Gases Pro Sensor Board");
//    USB.println("Sensors used:"));
//    USB.println("- SOCKET_A: Electrochemical gas sensor (C2)"");
//    USB.println("- SOCKET_B: Electrochemical gas sensor (NO2)");
//    USB.println("- SOCKET_C: Electrochemical gas sensor (O3)");
//    USB.println("- SOCKET_D: Particle matter sensor (dust)");
//    USB.println("- SOCKET_E: BME280 sensor (temperature, humidity & pressure)");
//    USB.println("- SOCKET_F: Electrochemical gas sensor (SO2)");

    
   // open USB port
  USB.ON();

  USB.println(F("-------------------------------"));
  USB.println(F("Configure XBee 868LP"));
  USB.println(F("-------------------------------"));

  // init XBee 
  xbee868LP.ON( SOCKET1 );  
  /////////////////////////////////////
  // 1. set channel 
  /////////////////////////////////////
  xbee868LP.setChannelMask( mask );

  // check at commmand execution flag
  if( xbee868LP.error_AT == 0 ) 
  {
    USB.print(F("1. Channel set OK to: 0x"));
    USB.printHex( xbee868LP._channelMask[0] );
    USB.printHex( xbee868LP._channelMask[1] );
    USB.printHex( xbee868LP._channelMask[2] );
    USB.printHex( xbee868LP._channelMask[3] );
    USB.println();
  }
  else 
  {
    USB.println(F("1. Error calling 'setChannel()'"));
  }


  /////////////////////////////////////
  // 2. set PANID
  /////////////////////////////////////
  xbee868LP.setPAN( panID );

  // check the AT commmand execution flag
  if( xbee868LP.error_AT == 0 ) 
  {
    USB.print(F("2. PAN ID set OK to: 0x"));
    USB.printHex( xbee868LP.PAN_ID[0] ); 
    USB.printHex( xbee868LP.PAN_ID[1] ); 
    USB.println();
  }
  else 
  {
    USB.println(F("2. Error calling 'setPAN()'"));  
  }

  /////////////////////////////////////
  // 3. set preamble ID
  /////////////////////////////////////
  xbee868LP.setPreambleID( preambleID );

  // check the AT commmand execution flag
  if( xbee868LP.error_AT == 0 ) 
  {
    USB.print(F("2. Preamble ID set OK to: 0x"));
    USB.printHex( xbee868LP._preambleID );
    USB.println();
  }
  else 
  {
    USB.println(F("2. Error calling 'setPreambleID()'"));  
  }

  /////////////////////////////////////
  // 4. set encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee868LP.setEncryptionMode( encryptionMode );

  // check the AT commmand execution flag
  if( xbee868LP.error_AT == 0 ) 
  {
    USB.print(F("3. AES encryption configured (1:enabled; 0:disabled):"));
    USB.println( xbee868LP.encryptMode, DEC );
  }
  else 
  {
    USB.println(F("3. Error calling 'setEncryptionMode()'"));
  }

  /////////////////////////////////////
  // 5. set encryption key
  /////////////////////////////////////
  xbee868LP.setLinkKey( encryptionKey );

  // check the AT commmand execution flag
  if( xbee868LP.error_AT == 0 ) 
  {
    USB.println(F("4. AES encryption key set OK"));
  }
  else 
  {
    USB.println(F("4. Error calling 'setLinkKey()'")); 
  }

  /////////////////////////////////////
  // 6. write values to XBee module memory
  /////////////////////////////////////
  xbee868LP.writeValues();

  // check the AT commmand execution flag
  if( xbee868LP.error_AT == 0 ) 
  {
    USB.println(F("5. Changes stored OK"));
  }
  else 
  {
    USB.println(F("5. Error calling 'writeValues()'"));   
  }

  USB.println(F("-------------------------------")); 

  // store Waspmote identifier in EEPROM memory
  frame.setID( node_ID );
}

void loop()
{

//    RTC.ON();
//    RTC.getTime();
    ///////////////////////////////////////////
    // 1. Turn on sensors and wait
    ///////////////////////////////////////////

    //Power on gas sensors
    CO2.ON();
    NO2.ON();
    SO2.ON();
    O3.ON();
    

    // Sensors need time to warm up and get a response from gas
    // To reduce the battery consumption, use deepSleep instead delay
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    USB.println(RTC.getTime());
    USB.println(F("Enter deep sleep mode to wait for sensors heating time..."));
   // PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
    USB.ON();
    USB.println(RTC.getTime());
    USB.println(F("wake up!!\r\n"));

    ///////////////////////////////////////////
    // 2. Read sensors
    ///////////////////////////////////////////

    // Read the sensors and compensate with the temperature internally
    concCO2 = CO2.getConc();
    concNO2 = NO2.getConc();
    concSO2 = SO2.getConc();
    concO3 = O3.getConc();

    // Read enviromental variables
    temperature = CO2.getTemp();
    humidity = CO2.getHumidity();
    pressure = CO2.getPressure();

    ///////////////////////////////////////////
    // 3. Turn off the sensors
    ///////////////////////////////////////////

    //Power off sensors
    CO2.OFF();
    NO2.OFF();
    O3.OFF();
    SO2.OFF();

    ///////////////////////////////////////////
    // 4. Read particle matter sensor
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


 /////////////////////////////////////
  // 1. get channel 
  /////////////////////////////////////
  xbee868LP.getChannelMask();
  USB.print(F("Channel mask: 0x"));
    USB.printHex( xbee868LP._channelMask[0] );
    USB.printHex( xbee868LP._channelMask[1] );
    USB.printHex( xbee868LP._channelMask[2] );
    USB.printHex( xbee868LP._channelMask[3] );
    USB.println();
  
  /////////////////////////////////////
  // 2. get PANID
  /////////////////////////////////////
  xbee868LP.getPAN();
  USB.print(F("panid: "));
  USB.printHex(xbee868LP.PAN_ID[0]); 
  USB.printHex(xbee868LP.PAN_ID[1]); 
  USB.println(); 

  /////////////////////////////////////
  // 3. get encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee868LP.getEncryptionMode();
  USB.print(F("encryption mode: "));
  USB.printHex(xbee868LP.encryptMode);
  USB.println(); 

  USB.println(F("-------------------------------")); 





    ///////////////////////////////////////////
    // 5. Create ASCII frame
    ///////////////////////////////////////////

    // Create new frame (ASCII)
    frame.createFrame(ASCII);
//    // Add PM1
//    frame.addSensor(SENSOR_GASES_PRO_PM1, PM._PM1, 2);
//      // Add PM2.5
//    frame.addSensor(SENSOR_GASES_PRO_PM2_5, PM._PM2_5, 2);
//      // Add PM10
//    frame.addSensor(SENSOR_GASES_PRO_PM10, PM._PM10, 2);
      // Add BAT level
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    // Add temperature
//    frame.addSensor(SENSOR_GASES_PRO_TC, temperature, 2);
//    // Add humidity
//    frame.addSensor(SENSOR_GASES_PRO_HUM, humidity, 2);
//    // Add pressure value
//    frame.addSensor(SENSOR_GASES_PRO_PRES, pressure, 2);
//    // Add CO2 value
//    frame.addSensor(SENSOR_GASES_PRO_CO2, concCO2, 2);
//    // Add NO2 value
//    frame.addSensor(SENSOR_GASES_PRO_NO2, concNO2, 2);
//    // Add SO2 value
//    frame.addSensor(SENSOR_GASES_PRO_SO2, concSO2, 2);
//    // Add O3 value
//    frame.addSensor(SENSOR_GASES_PRO_O3, concO3, 2);
    // Show the frame
    frame.showFrame();
    
   
// 6. Send Frame to Meshlium
   ///////////////////////////////////////////
  // 2. Send packet
  ///////////////////////////////////////////  

  // send XBee packet
  error = xbee868LP.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
    // blink green LED
    Utils.blinkGreenLED();
    
  }
  else 
  {
    USB.println(F("send error"));
    
    // blink red LED
    Utils.blinkRedLED();
  }

  // wait for five seconds
  delay(5000);

//  ////////////////////////////////////////////////
//  // 5. Sleep
//  ////////////////////////////////////////////////
//  USB.println(F("5. Enter deep sleep..."));
//  PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
//
//  USB.ON();
//  USB.println(F("6. Wake up!!\n\n"));

    
}
