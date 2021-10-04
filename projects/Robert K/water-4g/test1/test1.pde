#include <WaspSensorEvent_v30.h>
#include <smartWaterIons.h>

// Create an instance of the class
pt1000Class TemperatureSensor;
int value, value2;
hallSensorClass hall(SOCKET_A);
liquidPresenceClass liquidPresence(SOCKET_E);
float temp;
float humd;
float pres;

void setup()
{
  // Turn on the Smart Water Sensor Board and start the USB
  SWIonsBoard.ON();
  USB.ON();
}

void loop()
{
  // Reading of the Temperature sensor
  float temperature = TemperatureSensor.read();
  Events.ON();
  delay(10);
  value = hall.readHallSensor();
  value2 = liquidPresence.readliquidPresence();
  //Temperature
  temp = Events.getTemperature();
  //Humidity
  humd = Events.getHumidity();
  //Pressure
  pres = Events.getPressure();

  Events.OFF();

  // Print of the results
  USB.print(F("Temperature (Celsius degrees): "));
  USB.println(temperature);
  USB.print(F("events: "));
  USB.println(value);
  USB.print(F("events2: "));
  USB.println(value2);
  USB.println("-----------------------------");
  USB.print("Temperature: ");
  USB.printFloat(temp, 2);
  USB.println(F(" Celsius"));
  USB.print("Humidity: ");
  USB.printFloat(humd, 1);
  USB.println(F(" %"));
  USB.print("Pressure: ");
  USB.printFloat(pres, 2);
  USB.println(F(" Pa"));
  USB.println("-----------------------------");
  USB.println(F("-----------------------------------------------------------------"));
  // Delay
  delay(10000);
}





/*



A code for reading the sensor is shown below:
int value;
{
SensorEventv20.ON();
delay(10);
value = SensorEventv20.readValue(SOCKET);
}


value is an integer variable where the sensor state (a high value (3.3V) indicating liquid presence or a low value (0V) indicating
its absence) will be stored.
SOCKET indicates on which connector the sensor is placed (for this sensor it may be SENS_SOCKET1, SENS_SOCKET2, SENS_
SOCKET3 and SENS_SOCKET8).







A code for reading the sensor is shown below:
int value;
{
SensorEventv20.ON();
delay(10);
value = SensorEventv20.readValue(SOCKET);
}
value is an integer variable where the sensor state (a high value (3.3V) indicating that the sensor is closed or a low value (0V)
indicating that it is open) will be stored.
SOCKET indicates on which connector the sensor is placed (for this sensor it may be SENS_SOCKET1, SENS_SOCKET2, SENS_
SOCKET3 and SENS_SOCKET8).


 */
