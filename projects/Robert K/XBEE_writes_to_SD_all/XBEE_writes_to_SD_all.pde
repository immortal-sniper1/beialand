#include <WaspXBeeZB.h>



// known coordinator's operating 64-bit PAN ID to set
////////////////////////////////////////////////////////////////////////
uint8_t  PANID[] = {"BE1A"};
uint8_t error;
////////////////////////////////////////////////////////////////////////

char y[3];
int f;
char filename[] = "FILE1.TXT";



void scriitor_SD(char filename_a2[], uint8_t ssent_a = 0)
{
  SD.ON();
  USB.ON();
  USB.print(F("scriitor SD  "));

  long int size, m;
  //m = 104857600 ; //100MB file size
  m= 1048576;    //10MB file size
  bool q = true;
  int i;
  char filename_a[13];





  for (i = 0; i < 12; i++)
  {
    filename_a[i] = filename_a2[i];
  }
  //USB.println(F("scriitor SD2"));


  i = 1;
fazuzu:
  size = SD.getFileSize( filename_a );
  if (  (size >= m)  )
  {
    i++;
    itoa(i, y , 10);

    if (i < 10)
    {
      filename_a[4] = y[0];
    }
    else if ( i >= 10 && i <= 99)
    {
      for (int t = 0; t < 4; t++)
      {
        filename_a[9 - t] = filename_a[8 - t];
      }
      filename_a[4] = y[0];
      filename_a[5] = y[1];
      filename_a[10] = '\0';

    }
    else
    {

      if (i > 330)
      {
        i = 330; // pt ca exista o limita de fisiere in root si 330 a destul de sub limita sa nu faca probleme
      }
      for (int t = 0; t < 4; t++)
      {
        filename_a[10 - t] = filename_a[9 - t];
      }
      filename_a[4] = y[0];
      filename_a[5] = y[1];
      filename_a[6] = y[2];
      filename_a[11] = '\0';
    }

    goto  fazuzu;
  }
  //USB.println(F("scriitor SD4"));





  USB.print(F("se va scrie in: "));
  USB.println(filename_a);
  i = SD.create(filename_a);
  if (i == 1)
  {
    USB.println(F("file created since it was not present "));
  }

 f=ceil ( log(xbeeZB._length) );
    itoa(i, y , 10);
 SD.append(filename_a, xbeeZB._payload, xbeeZB._length ); 
 SD.append(filename_a, "  ", 2 );  
// SD.appendln(filename_a, y ,f );  
SD.appendln(filename_a," ");
}













void setup()
{
  // open USB
  USB.ON();
  SD.ON();
  SD.appendln(filename, "wfewfwefwe" ); 
  SD.appendln(filename, "----------" ); 
  ///////////////////////////////////////////////
  // Init XBee
  ///////////////////////////////////////////////
  xbeeZB.ON();


  ///////////////////////////////////////////////
  // 1. Disable Coordinator mode
  ///////////////////////////////////////////////

  /*************************************
    WARNING: Only XBee ZigBee S2C and
    XBee ZigBee S2D are able to use
    this function properly
  ************************************/

  /*
  xbeeZB.setCoordinator(DISABLED);

  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("1. Coordinator mode disabled"));
  }
  else
  {
    USB.println(F("1. Error while disabling Coordinator mode"));
  }
  /*
/*
  ///////////////////////////////////////////////
  // 2. Set PANID
  ///////////////////////////////////////////////
  xbeeZB.setPAN(PANID);

  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("2. PANID set OK"));
  }
  else
  {
    USB.println(F("2. Error while setting PANID"));
  }


  ///////////////////////////////////////////////
  // 3. Set channels to be scanned before creating network
  ///////////////////////////////////////////////
  // channels from 0x0B to 0x18 (0x19 and 0x1A are excluded)
  /* Range:[0x0 to 0x3FFF]
    Channels are scpedified as a bitmap where depending on
    the bit a channel is selected --> Bit (Channel):
     0 (0x0B)  4 (0x0F)  8 (0x13)   12 (0x17)
     1 (0x0C)  5 (0x10)  9 (0x14)   13 (0x18)
     2 (0x0D)  6 (0x11)  10 (0x15)
     3 (0x0E)  7 (0x12)   11 (0x16)    */


     
  xbeeZB.setScanningChannels(0x12, 0x12);

  // check at command flag
  if (xbeeZB.error_AT == 0)
  {
    USB.println(F("3. Scanning channels set OK"));
  }
  else
  {
    USB.println(F("3. Error while setting 'Scanning channels'"));
  }


  ///////////////////////////////////////////////
  // Save values
  ///////////////////////////////////////////////
  xbeeZB.writeValues();

  // wait for the module to set the parameters
  delay(10000);
  USB.println();

  ///////////////////////////////
  // get network parameters
  ///////////////////////////////

  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operatingPAN: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("extendedPAN: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

}









void loop()
{ 
  // receive XBee packet (wait for 10 seconds)
  error = xbeeZB.receivePacketTimeout( 500 );

  // check answer  
  if( error == 0 ) 
  {
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Data: "));  
    USB.println( xbeeZB._payload, xbeeZB._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Length: "));  
    USB.println( xbeeZB._length,DEC);
    scriitor_SD(filename );
  }
  else
  {
    // Print error message:
    /*
     * '7' : Buffer full. Not enough memory space
     * '6' : Error escaping character within payload bytes
     * '5' : Error escaping character in checksum byte
     * '4' : Checksum is not correct    
     * '3' : Checksum byte is not available 
     * '2' : Frame Type is not valid
     * '1' : Timeout when receiving answer   
    */
    USB.print(F("Error receiving a packet:"));
    USB.println(error,DEC);     
  }
} 





