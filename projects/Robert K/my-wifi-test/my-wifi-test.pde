#include <WaspLoRaWAN.h>
#include <WaspSensorGas_v30.h>
#include <WaspFrame.h>
#include <WaspWIFI_PRO.h> 
#include "WaspFrameConstantsv15.h"



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

float VOLT;
uint16_t CHRG;


float temperature = 0.0;
uint8_t error2;
char data[] = "The council of Elrond salutes you.";
char data2[200] ;
char payload_hex[200];
char message[100];









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




bool chargeState;
uint16_t chargeCurrent;







char node_ID[] = "qwerty"; //ex GAS_WiFi


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
/*
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
*/

 frame.setID(node_ID);
  Gases.ON(); 


}
  










void loop()
{  




  O2Sensor.ON();
  LPGSensor.ON();
  CO2Sensor.ON();
   previous = millis(); 
  // read temperature sensor connected to ANALOG6 pin
  temperature = Utils.readTemperature();
  USB.print(F("Value of temperature: "));
  USB.print(temperature);
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
  // 2. Join AP
  //////////////////////////////////////////////////  
  // check connectivity
  status =  WIFI_PRO.isConnected();

  // check if module is connected
  if (status == true)
  {    
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);

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






  frame.createFrame(BINARY, node_ID);


  
  // Add Oxygen voltage value
  frame.addSensor(SENSOR_GASES_O2, O2Val);
  // Add CO2 PPM value
  //frame.addSensor(SENSOR_GASES_CO2, CO2PPM);
  // Add NO2 PPM value
//  frame.addSensor(SENSOR_GASES_NO2, NO2PPM);
  // Add VOC PPM value
 // frame.addSensor(SENSOR_GASES_VOC, VOCPPM);
   // Add LPG PPM value
  frame.addSensor(SENSOR_GASES_LPG, LPGPPM);

  //frame.addSensor(SENSOR_GASES_AP1, APP_PPM);
   // Add BAT level  value
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()         );
 // frame.addSensor(SENSOR_TEMP, readTemperature()            );
 // frame.addSensor(batt_state , PWR.getChargingState()       );
  frame.addSensor(SENSOR_BAT , PWR.getBatteryCurrent()     );

 
  frame.addSensor(SENSOR_GASES_TC, Gases.getTemperature()   );
  frame.addSensor(SENSOR_GASES_HUM, Gases.getHumidity()     );
  frame.addSensor(SENSOR_GASES_PRES, Gases.getPressure()    );
  frame.showFrame();



    
// 3.2. Send Frame to Meshlium
    ///////////////////////////////

    // http frame
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);

    // check response
    if (error == 0)
    {
      USB.println(F("HTTP OK"));          
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous);
      frame.createFrame(ASCII, node_ID);
//      frame.addSensor(SENSOR_BAT_VOLT, VOLT);
 //     frame.addSensor(SENSOR_BAT_CURR, CHRG); 
      WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
      USB.println(F("ASCII FRAME SEND OK")); 
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
    // After 30 seconds, Waspmote wakes up thanks to the RTC Alarm
   USB.println(F("enter deep sleep"));
  // Go to sleep disconnecting all switches and modules
  // After 10 seconds, Waspmote wakes up thanks to the RTC Alarm
    USB.println(RTC.getTime());

  PWR.deepSleep("00:00:00:05",RTC_OFFSET,RTC_ALM1_MODE1,ALL_ON);
       USB.ON();
       USB.println(RTC.getTime());
  USB.println(F("\nwake up"));

  // After wake up check interruption source
  if( intFlag & RTC_INT )
  {
    // clear interruption flag
    intFlag &= ~(RTC_INT);
    
    USB.println(F("---------------------"));
    USB.println(F("RTC INT captured"));
    USB.println(F("---------------------"));
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
  }






  USB.println(F("------------------------------------------------------"));
 // Gases.OFF();  
  O2Sensor.OFF();
  LPGSensor.OFF();
  CO2Sensor.OFF();


  
  delay(25000); 
}




