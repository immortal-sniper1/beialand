
// include WiFi library
#include <WaspWIFI_PRO.h>


// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET0;
///////////////////////////////////////

// FTP server settings 
/////////////////////////////////
char server[] = "ftp.agile.ro";
char port[] = "21";
char user[] = "robi@agile.ro";
char password[] = "U$d(SEFA8+UC";
/////////////////////////////////
int N_trials = 10;
char ESSID[] = "LANCOMBEIA";
char PASSW[] = "beialancom";
uint8_t max_atemptss = 10; // nr de max de trame de retrimit deodata

// define variables
uint8_t error;
uint8_t status;
unsigned long previous;
int8_t answer;
char programID[10];



void WiFi_init() { // 1. Switch ON the WiFi module
  //////////////////////////////////////////////////
  error = 1;
  while (error == 1) {
    error = WIFI_PRO.ON(socket);

    if (error == 0) {
      USB.println(F("1. WiFi switched ON"));
    } else {
      USB.println(F("1. WiFi did not initialize correctly"));
    }
  }

  // 2. Reset to default values
  //////////////////////////////////////////////////
  error = 1;
  while (error == 1) {
    error = WIFI_PRO.resetValues();

    if (error == 0) {
      USB.println(F("2. WiFi reset to default"));
    } else {
      USB.println(F("2. WiFi reset to default ERROR"));
    }
  }
  // 3. Set ESSID
  //////////////////////////////////////////////////
  error = 1;
  while (error == 1) {
    error = WIFI_PRO.setESSID(ESSID);

    if (error == 0) {
      USB.println(F("3. WiFi set ESSID OK"));
    } else {
      USB.println(F("3. WiFi set ESSID ERROR"));
    }
  }
  //////////////////////////////////////////////////
  // 4. Set password key (It takes a while to generate the key)
  // Authentication modes:
  //    OPEN: no security
  //    WEP64: WEP 64
  //    WEP128: WEP 128
  //    WPA: WPA-PSK with TKIP encryption
  //    WPA2: WPA2-PSK with TKIP or AES encryption
  //////////////////////////////////////////////////
  error = 1;
  while (error == 1) {
    error = WIFI_PRO.setPassword(WPA2, PASSW);

    if (error == 0) {
      USB.println(F("4. WiFi set AUTHKEY OK"));
    } else {
      USB.println(F("4. WiFi set AUTHKEY ERROR"));
    }
  }
  //////////////////////////////////////////////////
  // 5. Software Reset
  // Parameters take effect following either a
  // hardware or software reset
  //////////////////////////////////////////////////
  error = WIFI_PRO.softReset();

  if (error == 0) {
    USB.println(F("5. WiFi softReset OK"));
  } else {
    USB.println(F("5. WiFi softReset ERROR"));
  }

  USB.println(F("*******************************************"));
  USB.println(F("Once the module is configured with ESSID"));
  USB.println(F("and PASSWORD, the module will attempt to "));
  USB.println(F("join the specified Access Point on power up"));
  USB.println(F("*******************************************\n"));
}




void setup()
{
  USB.ON();
  USB.println(F("Start program"));  
  USB.println(F("***************************************"));  
  USB.println(F("Once the module is set with one or more"));
  USB.println(F("AP settings, it attempts to join the AP"));
  USB.println(F("automatically once it is powered on"));    
  USB.println(F("Refer to example 'WIFI_PRO_01' to configure"));  
  USB.println(F("the WiFi module with proper settings"));
  USB.println(F("***************************************"));
  WiFi_init();
  //////////////////////////////////////////////////
  // 1. Check if the program has been programmed ok
  //////////////////////////////////////////////////
  answer = Utils.checkNewProgram();   
 
  switch (answer)
  {
  case 0:  
    USB.print(F("REPROGRAMMING ERROR"));
    Utils.blinkRedLED(300, 3);
    break;   

  case 1:  
    USB.println(F("REPROGRAMMING OK"));
    Utils.blinkGreenLED(300, 3);
    break; 

  default: 
    USB.println(F("RESTARTING"));
    Utils.blinkGreenLED(500, 1);
  }      


  // show program ID 
  Utils.getProgramID(programID);
  USB.println(F("-------------------------------"));
  USB.print(F("Program id: "));
  USB.println(programID);

  // show program version number
  USB.print(F("Program version: "));
  USB.println(Utils.getProgramVersion(),DEC);
  USB.println(F("-------------------------------"));
  

  //////////////////////////////////////////////////
  // 2. User setup
  //////////////////////////////////////////////////

  // Put your setup code here, to run once:

}


void loop()
{   
  //////////////////////////////////////////////////
  // 3. User loop program
  //////////////////////////////////////////////////

  // put your main code here, to run repeatedly:

    USB.println(F("program1"));
        USB.println(F("program1"));   
        USB.println(F("program1"));   
        USB.println(F("program1"));
        USB.println(F("program1"));  
        USB.println(F("program1"));  
        USB.println(F("program1"));
    USB.println(F("program1"));
        USB.println(F("program1"));   
        USB.println(F("program1"));   
        USB.println(F("program1"));
        USB.println(F("program1"));  
        USB.println(F("program1"));  
        USB.println(F("program1"));
            USB.println(F("program1"));
        USB.println(F("program1"));   
        USB.println(F("program1"));   
        USB.println(F("program1"));
        USB.println(F("program1"));  
        USB.println(F("program1"));  
        USB.println(F("program1"));
            USB.println(F("program1"));
        USB.println(F("program1"));   
        USB.println(F("program1"));   
        USB.println(F("program1"));
        USB.println(F("program1"));  
        USB.println(F("program1"));  
        USB.println(F("program1"));
            USB.println(F("program1"));
        USB.println(F("program1"));   
        USB.println(F("program1"));   
        USB.println(F("program1"));
        USB.println(F("program1"));  
        USB.println(F("program1"));  
        USB.println(F("program1"));
            USB.println(F("program1"));
        USB.println(F("program1"));   
        USB.println(F("program1"));   
        USB.println(F("program1"));
        USB.println(F("program1"));  
        USB.println(F("program1"));  
        USB.println(F("---------------------------------------------------------------------------"));
  //////////////////////////////////////////////////
  // 4. OTA request
  //////////////////////////////////////////////////

  //////////////////////////////
  // 4.1. Switch ON
  //////////////////////////////
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }


  //////////////////////////////
  // 4.2. Check if connected
  //////////////////////////////
  // get actual time
  previous = millis();

  // check connectivity
  status =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (status == true)
  {    
    USB.print(F("2. WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
      

    USB.println(F("2.1. Connection Status:"));
    USB.println(F("-------------------------------"));
    USB.print(F("Rate (Mbps):"));
    USB.println(WIFI_PRO._rate);
    USB.print(F("Signal Level (%):"));
    USB.println(WIFI_PRO._level);
    USB.print(F("Link Quality(%):"));
    USB.println(WIFI_PRO._quality);
    USB.println(F("-------------------------------"));

    //////////////////////////////
    // 4.3. Request OTA
    //////////////////////////////    
    USB.println(F("2.2. Request OTA..."));
    error = WIFI_PRO.requestOTA(server, port, user, password);

    // If OTA fails, show the error code     
    WIFI_PRO.printErrorCode();
    Utils.blinkRedLED(300, 3);

  }
  else
  {
    USB.print(F("2. WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
    Utils.blinkRedLED(100, 10);
  }


  //////////////////////////////////////////////////
  // 5. Switch OFF
  //////////////////////////////////////////////////  
  WIFI_PRO.OFF(socket);
  USB.println(F("3. WiFi switched OFF"));
  USB.println(F("Wait...\n\n"));
  delay(10000);


}
