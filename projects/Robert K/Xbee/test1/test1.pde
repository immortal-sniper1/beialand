#include <WaspXBee802.h>
#include <WaspFrame.h>
#include <WaspSensorGas_v30.h>

// PAN (Personal Area Network) Identifier
uint8_t  panID[2] = {0x20,0x07};  

// Define Freq Channel to be set: 
// Center Frequency = 2.405 + (CH - 11d) * 5 MHz
//   Range: 0x0B - 0x1A (XBee)
//   Range: 0x0C - 0x17 (XBee-PRO)
uint8_t  channel = 0x0C;

// Define the Encryption mode: 1 (enabled) or 0 (disabled)
uint8_t encryptionMode = 1;

// Define the AES 16-byte Encryption Key
char  encryptionKey[] = "libelium2015MVXB"; 

// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20040D878D1";
//////////////////////////////////////////

// Define the Waspmote ID
char NODE_ID[] = "sacrifice3";


// define variable
uint8_t error;







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
  // open USB port
  USB.ON();
  USB.println(F("LoRaWAN example - Send Confirmed packets (ACK)\n"));
  USB.println(F("------------------------------------"));
  USB.println(F("Module configuration"));
  USB.println(F("------------------------------------\n"));
  RTC.setTime("23:06:29:02:10:00:00");



  

  USB.println(F("-------------------------------"));
  USB.println(F("Configure XBee 802.15.4"));
  USB.println(F("-------------------------------"));

  // init XBee 
  xbee802.ON();

  delay(1000);


  /////////////////////////////////////
  // 1. set channel 
  /////////////////////////////////////
  xbee802.setChannel( channel );

  // check at commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.print(F("1. Channel set OK to: 0x"));
    USB.printHex( xbee802.channel );
    USB.println();
  }
  else 
  {
    USB.println(F("1. Error calling 'setChannel()'"));
  }


  /////////////////////////////////////
  // 2. set PANID
  /////////////////////////////////////
  xbee802.setPAN( panID );

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.print(F("2. PAN ID set OK to: 0x"));
    USB.printHex( xbee802.PAN_ID[0] ); 
    USB.printHex( xbee802.PAN_ID[1] ); 
    USB.println();
  }
  else 
  {
    USB.println(F("2. Error calling 'setPAN()'"));  
  }

  /////////////////////////////////////
  // 3. set encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee802.setEncryptionMode( encryptionMode );

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.print(F("3. AES encryption configured (1:enabled; 0:disabled):"));
    USB.println( xbee802.encryptMode, DEC );
  }
  else 
  {
    USB.println(F("3. Error calling 'setEncryptionMode()'"));
  }

  /////////////////////////////////////
  // 4. set encryption key
  /////////////////////////////////////
  xbee802.setLinkKey( encryptionKey );

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("4. AES encryption key set OK"));
  }
  else 
  {
    USB.println(F("4. Error calling 'setLinkKey()'")); 
  }

  /////////////////////////////////////
  // 5. write values to XBee module memory
  /////////////////////////////////////
  xbee802.writeValues();

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("5. Changes stored OK"));
  }
  else 
  {
    USB.println(F("5. Error calling 'writeValues()'"));   
  }
  
  
  USB.println(F("-------------------------------")); 


//pm
USB.ON();
 

    // Set the Waspmote ID
    frame.setID(NODE_ID);




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
  xbee802.ON();

  
  // Sensors need time to warm up and get a response from gas
  // To reduce the battery consumption, use deepSleep instead delay
  // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm  
 // PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);



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








  

  ///////////////////////////////////////////
  // 1. Create ASCII frame
  ///////////////////////////////////////////  

  // create new frame
  USB.println(F("Creating an ASCII frame"));
  frame.createFrame(BINARY, NODE_ID);  
  

  // add frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
  frame.addSensor(SENSOR_GASES_O2, O2Val);
  frame.addSensor(SENSOR_GASES_NO2, NO2PPM);
  frame.addSensor(SENSOR_GASES_VOC, VOCPPM);
  frame.addSensor(SENSOR_GASES_LPG, LPGPPM);
  frame.addSensor(SENSOR_GASES_CO, COPPM);
  frame.addSensor(SENSOR_GASES_SV, SVPPM);


  USB.println(F(" FRAME IS DONE:"));
  // Prints frame
  frame.showFrame();


    USB.println(F("a"));    

 
    // Show the frame
  frame.showFrame();



  ///////////////////////////////////////////
  // 2. Send packet
  ///////////////////////////////////////////  

  USB.println(F("sending..."));
  // send XBee packet
  error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
  
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



  USB.print("error= ");
  USB.println(error);
  USB.print("time: ");
  USB.print(   millis() /1000 );
  USB.println(" s");
  USB.print("time of cycle: ");
  USB.print(   (millis()-previous)/1000 );
  USB.println(" s");
  previous = millis();





  USB.println(F("-------------------------------"));
  USB.print(F("Going to sleep for "));
  //USB.print(delay_interval / 1000);
  USB.print(60);
  USB.println(F(" secounds."));
  USB.println(F("-------------------------------"));
  USB.println(F(" "));
  USB.println(F(" "));
  USB.println(F(" "));
  USB.println(F(" "));

  USB.OFF();
  
  // sleep
  delay(150000);
    //PWR.deepSleep("00:00:02:30", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
}



