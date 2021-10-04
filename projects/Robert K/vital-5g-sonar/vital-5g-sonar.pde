
#include <Wasp485.h>




void setup()
{
  // Power on the USB for viewing data in the serial monitor
  USB.ON();
  // Print hello message
  USB.println(F("This is RS-485 communication receive data example"));
  delay(100);

  // Powers on the module and assigns the SPI in socket0
  if ( W485.ON() == 0) {
    USB.println(F("RS-485 module started successfully"));
  } else {
    USB.println(F("RS-485 did not initialize correctly"));
  }
  delay(100);

  // Configure the baud rate of the module
  W485.baudRateConfig(9600);
  // Configure the parity bit as disabled
  W485.parityBit(DISABLE);
  // Use one stop bit configuration
  W485.stopBitConfig(1);

}




char masurare_adancime()
{
  char data;

  // power supply
 // W485.setPowerSocket(SWITCH_ON);
  // If data in response buffer
  if (W485.available())
  {
    while (W485.available()) {
      // Read one byte from the buffer
      data = W485.read();
      // Print data received in the serial monitor
      USB.print(data);
    }
  }
  return data;
  // Comment this line if the sensor has an external
  // power supply
 // W485.setPowerSocket(SWITCH_OFF);
}



void loop() {

  USB.print(F("adancime primita: "));
  USB.println( masurare_adancime() );


  delay(1000);
}
