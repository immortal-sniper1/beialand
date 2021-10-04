#include <WaspXBee802.h>
#include <WaspFrame.h>


// PAN (Personal Area Network) Identifier
uint8_t  panID[] = "be1a";  

// Define Freq Channel to be set: 
// Center Frequency = 2.405 + (CH - 11d) * 5 MHz
//   Range: 0x0B - 0x1A (XBee)
//   Range: 0x0C - 0x17 (XBee-PRO)
uint8_t  channel = 0x14;

// Define the Encryption mode: 1 (enabled) or 0 (disabled)
uint8_t encryptionMode = 1;

// Define the AES 16-byte Encryption Key
char  encryptionKey[] = "libelium2015MVXB"; 

// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20040D878D1";
//////////////////////////////////////////

// Define the Waspmote ID
char NODE_ID[] = "meshliumfa30";


// define variable
uint8_t error;

// messure every 10 minutes
unsigned long delay_interval = 900000;



// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE3.TXT";

// define an example string
int data;
char data2[4];

// define variable
uint8_t sd_answer;








void setup()
{
  // open USB port
  USB.ON();



  USB.println(F("SD_3 example"));
  
  // Set SD ON
  SD.ON();
    
  // Delete file
  sd_answer = SD.del(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file deleted"));
  }
  else 
  {
    USB.println(F("file NOT deleted"));  
  }
    
  // Create file
  sd_answer = SD.create(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file created"));
  }
  else 
  {
    USB.println(F("file NOT created"));  
  } 


  



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
}


void loop()
{
  SD.ON();










/*


  // 1 - It appends “he” in file indicating 2-byte length
  sd_answer = SD.append(filename, data, 2);
  
  if( sd_answer =! 1 )
  {
    USB.println(F("\n1 - append error"));
  }
  
  // show file
  SD.showFile(filename);
  delay(1000);
  
  
  // 2 - It appends “hello” at the end of the file
  sd_answer = SD.append(filename, data);
  
  if( sd_answer =! 1 )
  {
    USB.println(F("\n2 - append error"));
  }
  

  
  // 3 - It appends data to file adding an End Of Line at the end of the string
  sd_answer = SD.appendln(filename,"goodbye");
  
  if( sd_answer =! 1 )
  {
    USB.println(F("\n3 - append error"));
  }
  
*/










  
  sd_answer = SD.append(filename, "battery: ");
    if( sd_answer =! 1 )
  {
    USB.println(F("\n2 - append error"));
  }

  
  data=PWR.getBatteryLevel();
  itoa(data , data2 , 10);
  /*
  USB.print("data: "); 
  USB.println(data); 
  USB.print("data2: "); 
  USB.println(data2); 
  */
  
  sd_answer = SD.appendln(filename,  data2 );
  if( sd_answer =! 1 )
  {
    USB.println(F("\n2 - append error"));
  }

  
      USB.print("battery: "); 
      USB.println(PWR.getBatteryLevel(), DEC);


  ///////////////////////////////////////////
  // 1. Turn on sensors and wait
  ///////////////////////////////////////////
 // Power on the OPC_N2 sensor. 
    // If the gases PRO board is off, turn it on automatically.
  
  // create new frame
  frame.createFrame(BINARY, NODE_ID);  
  

  // add frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
 
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
    sd_answer = SD.appendln(filename, "send ok");
    if( sd_answer =! 1 )
    {
    USB.println(F("\n2 - append error"));
    }
    // blink green LED
    Utils.blinkGreenLED();
    
  }
  else 
  {
    USB.println(F("send error"));
    sd_answer = SD.appendln(filename, "send error");
    if( sd_answer =! 1 )
    {
    USB.println(F("\n2 - append error"));
    }
    // blink red LED
    Utils.blinkRedLED();
  }

    USB.print("time: ");
    USB.print(   millis() /1000 );
    USB.println(" s");
    sd_answer = SD.append(filename, "time: ");
    itoa(millis() /1000 , data2 , 10);
    sd_answer = SD.append(filename, data2);
    sd_answer = SD.appendln(filename, " s");
    sd_answer = SD.appendln(filename, "-----------------------------------");    
    SD.OFF();

  USB.println(F("-------------------------------"));
  USB.print(F("Going to sleep for "));
  USB.print(delay_interval / 50000);
  USB.println(F(" secounds."));
  USB.println(F("-------------------------------"));
  USB.println(" ");
  USB.println(" ");
  USB.println(" ");
  USB.println(" ");
  USB.println(" ");
        

  // sleep
  delay(delay_interval/50);
}
