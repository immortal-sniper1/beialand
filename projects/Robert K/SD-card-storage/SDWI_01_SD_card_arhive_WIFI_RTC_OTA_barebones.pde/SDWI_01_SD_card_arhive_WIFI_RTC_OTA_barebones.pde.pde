#include <WaspFrame.h>
#include <WaspWIFI_PRO.h>

/////////// NU UMBLA AICI!!!!!
// define variable SD
// define file name: MUST be 8.3 SHORT FILE NAME
char filename[] = "FILE1.TXT";
char *time_date; // stores curent date + time
int x, b, cycle_time;
uint8_t error;
uint8_t status = false;
char y[3];
uint8_t sd_answer, ssent;
bool sentence = false; // true for deletion on reboot  , false for data appended to end of file
bool IRL_time = true; //  true for no external date source
char rtc_str[] = "00:00:00:05";    // 11 char ps incepe de la 0
unsigned long prev, previous, previousSendFrame;
bool RTC_SUCCES;


uint8_t errorSetTimeServer, errorEnableTimeSync, errorSetGMT, errorsetTimefromWiFi, errorsetSSID, errorsetpass, errorsoftreset, errorresetdef, errorSendFrame, errorrequestOTA;
uint8_t statusWiFiconn, statusSetTimeServer, statusTimeSync, statusSetGMT, statussetTimefromWiFi;



// choose NTP server settings
///////////////////////////////////////
char SERVERS[][25] =
{
	"time.nist.gov",
	"wwv.nist.gov"
};
char server[25], serbuf[64];
///////////////////////////////////////

// Define Time Zone from -12 to 12 (i.e. GMT+2)
///////////////////////////////////////
uint8_t time_zone = 3;///for ROMANIA
///////////////////////////////////////





// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET0;
///////////////////////////////////////
// choose URL settings
///////////////////////////////////////
char type[] = "http";
char host[] = "82.78.81.178";
char port[] = "80";
///////////////////////////////////////
// FTP SERVER settings
///////////////////////////////////////
char ftp_server[] = "ftp.agile.ro";
char ftp_port[] = "21";
char ftp_user[] = "robi@agile.ro";
char ftp_pass[] = "U$d(SEFA8+UC";
///////////////////////////////////////
char programID[10];
int8_t answer, verr = 13;




///// EDITEAZA AICI DOAR
char node_ID[] = "ceva13x";
int count_trials = 0;
int N_trials = 10;
char ESSID[] = "LANCOMBEIA";
char PASSW[] = "beialancom";
uint8_t max_atemptss = 10; // nr de max de trame de retrimit deodata
uint8_t resend_f = 2; // frame resend atempts
int cycle_time2 = 30; // in seconds









// subprograme


//NU MODIFICA NIMIC IN SUBPROGRAME!
int trimitator_WIFI()
{
	int ssent;
// get actual time before wifi
	previous = millis();
	switchon_WiFi();
	b = 0;
qwerty:
	switchon_WiFi();
	statusWiFiconn = check_WiFi_conn();

	// check if module is connected
	if (statusWiFiconn == true)
	{

		ssent = WiFi_sendFrame();

	}
	if (ssent == 0 && b <= resend_f)
	{
		delay(5000);
    b++;
		goto qwerty;
	}

	switchoff_WiFi();
	b = (millis() - prev) / 1000;
	USB.print("loop execution time[s]: ");
	USB.println(b);
	return ssent;
}






void SD_TEST_FILE_CHECK( char filename_st[] =  filename )   // eventual de adaugat suport pt delete all files on SD?
{

	SD.ON();

	if (sentence == 1)
	{
		// Delete file
		sd_answer = SD.del(filename_st);

		if (sd_answer == 1)
		{
			USB.println(F("file deleted"));
		} else
		{
			USB.println(F("file NOT deleted"));
		}
	}
	// Create file IF id doent exist
	sd_answer = SD.create(filename_st);

	if (sd_answer == 1)
	{
		USB.println(F("file created"));
	} else
	{
		USB.println(F("file NOT created"));
	}

	USB.print("loop cycle time[s]:= ");
	USB.println(cycle_time2);
	sd_answer = SD.appendln(filename_st, "----------------------------------------------------------------------------");
	if (sd_answer == 1)
	{
		USB.println(F("writeing is OK"));
	} else
	{
		USB.println(F("writeing is haveing errors"));
	}

	SD.OFF(); /////////////////////////////modified by Ana
}











void scriitor_SD(char filename_a2[], uint8_t ssent_a = 0)
{
	SD.ON();
	USB.ON();
	USB.print(F("scriitor SD  "));

	long int size, m;
	m = 104857600 ; //100MB file size
	//m= 1048576;    //10MB file size
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


			/*
			USB.print(F("xxxxx"));
			USB.print(  filename_a  );
			USB.println(F("xxxxx"));
			USB.print(F("xxxxx"));
			USB.print(  strlen(  filename_a  ));
			USB.println(F("xxxxx"));

			*/
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




	int coruption = 0;
	//sd_answer = SD.appendln(filename_a, "am scris aici!!!!!!!!");
	//coruption = coruption + sd_answer;
	// now storeing it locally
	time_date = RTC.getTime();
	USB.print(F("time: "));
	USB.println(time_date);

	x = RTC.year;
	itoa(x, y, 10);
	if (x < 10) {
		y[1] = y[0];
		y[0] = '0';
	}

	sd_answer = SD.append(filename_a, y);
	coruption = coruption + sd_answer;
	sd_answer = SD.append(filename_a, ".");
	coruption = coruption + sd_answer;
	x = RTC.month;
	itoa(x, y, 10);
	if (x < 10)
	{
		y[1] = y[0];
		y[0] = '0';
	}
	sd_answer = SD.append(filename_a, y);
	coruption = coruption + sd_answer;
	sd_answer = SD.append(filename_a, ".");
	coruption = coruption + sd_answer;
	x = RTC.date;
	itoa(x, y, 10);
	if (x < 10) {
		y[1] = y[0];
		y[0] = '0';
	}
	sd_answer = SD.append(filename_a, y);
	coruption = coruption + sd_answer;
	sd_answer = SD.append(filename_a, ".");
	coruption = coruption + sd_answer;
	x = RTC.hour;
	itoa(x, y, 10);
	if (x < 10) {
		y[1] = y[0];
		y[0] = '0';
	}
	sd_answer = SD.append(filename_a, y);
	coruption = coruption + sd_answer;
	sd_answer = SD.append(filename_a, ".");
	coruption = coruption + sd_answer;
	x = RTC.minute;
	itoa(x, y, 10);
	if (x < 10)
	{
		y[1] = y[0];
		y[0] = '0';
	}
	sd_answer = SD.append(filename_a, y);
	coruption = coruption + sd_answer;
	sd_answer = SD.append(filename_a, ".");
	coruption = coruption + sd_answer;
	x = RTC.second;
	itoa(x, y, 10);
	if (x < 10)
	{
		y[1] = y[0];
		y[0] = '0';
	}
	sd_answer = SD.append(filename_a, y);
	coruption = coruption + sd_answer;
	sd_answer = SD.append(filename_a, "  ");
	coruption = coruption + sd_answer;



	sd_answer = SD.append(filename_a, frame.buffer, frame.length);  // scriere propriuzisa frame
	coruption = coruption + sd_answer;
	sd_answer = SD.append(filename_a, "  ");
	coruption = coruption + sd_answer;
	itoa(ssent_a, y, 10);
	sd_answer = SD.appendln(filename_a, y);
	coruption = coruption + sd_answer;
	// frame is stored

	SD.OFF();

	if (coruption == 15)
	{
		USB.println("SD storage done with no errors");
	} else {
		USB.print("SD sorage done with:");
		USB.print(15 - coruption);
		USB.println(" errors");
	}
}











void data_maker( int x , char filename_a[]  )
{
	SD.ON();

	for (int ii = 1 ; ii <= x ; ii++) //10MB per x=1
	{
		USB.println(" cycles: ");
		USB.println(ii);
		USB.println("/");
		USB.println(x);
		for (int g = 0; g < 324 ; g++)
		{
			SD.appendln(filename_a, " ");
			USB.println(" subcycles: ");
			USB.println(g);
			USB.println("/324");
			for (int k = 0 ; k < 324 ; k++)
				SD.append(filename_a, "eokfumpwqroifv4478fcmwpocfumwqgif17nwqrpn5fcmwifcwuifw7unpcwogr2rqfcnqwogfqprwfmqwfhwdjfbplpkp13pl ");   //100 byte per line
		}
	}
	SD.OFF();

}


















void RTC_setup()   // asa era in void setup si am pus tot in functia asta
{
	int NServers = sizeof(SERVERS) / sizeof(SERVERS[0]);
	sprintf (serbuf, "The number of available servers in the list is %d \r\n", NServers);
	USB.println(serbuf);
	start_prog();
	do
	{
		WiFi_setup();
		statusWiFiconn = check_WiFi_conn();
		// Check if module is connected
		if (statusWiFiconn == true)
		{
			for (int cnt = 0; cnt < NServers; cnt++)
				statusSetTimeServer = RTC_setTimeServer(SERVERS[cnt]);
			if (statusSetTimeServer == true)
			{
				statusTimeSync = RTC_EnableTimeSync();
				if (statusTimeSync == true)
				{	RTC_setGMT();
					goto SWITCHOFF;
				}
			}
		}
SWITCHOFF:
		switchoff_WiFi();
	}
	while (statusSetTimeServer == false);
	delay(5000);
	RTC_init();
}









////////////////////FUNCTII///////////////////////////
/////////////////////////////FUNCTII WIFI///////////////////////////
void switchon_WiFi()
{
// 1. Switch ON
	//////////////////////////////////////////////////
	error = WIFI_PRO.ON(socket);

	if (error == 0)
	{
		USB.println(F("1. WiFi switched ON"));
	}
	else
	{
		USB.println(F("1. WiFi did not initialize correctly"));
	}
}






boolean check_WiFi_conn()
{	// 2. Check if connected
	//////////////////////////////////////////////////

	// get actual time
	previous = millis();

	// check connectivity
	statusWiFiconn =  WIFI_PRO.isConnected();

	// Check if module is connected
	if (statusWiFiconn == true)
	{
		USB.print(F("2. WiFi is connected OK"));
		USB.print(F(" Time(ms):"));
		USB.println(millis() - previous);
	}
	else
	{
		USB.print(F("2. WiFi is connected ERROR"));
		USB.print(F(" Time(ms):"));
		USB.println(millis() - previous);
		Utils.blinkRedLED(200, 10);
	}
	return statusWiFiconn;
}






void switchoff_WiFi()
{
	USB.println(F("4. WiFi switched OFF\n"));
	WIFI_PRO.OFF(socket);


	USB.println(F("-----------------------------------------------------------"));
	USB.println(F("Once the module has the correct Time Server Settings"));
	USB.println(F("it is always possible to request for the Time and"));
	USB.println(F("synchronize it to the Waspmote's RTC"));
	USB.println(F("-----------------------------------------------------------\n"));
}







void WiFi_resetdefault()
{
	errorresetdef = WIFI_PRO.resetValues();

	if (errorresetdef == 0)
	{
		USB.println(F("2. WiFi reset to default"));
	}
	else
	{
		USB.println(F("2. WiFi reset to default ERROR"));
	}
}





void setSSID_pass_reset()
{	// 3. Set ESSID
	//////////////////////////////////////////////////
	errorsetSSID = WIFI_PRO.setESSID(ESSID);

	if (errorsetSSID == 0)
	{
		USB.println(F("3. WiFi set ESSID OK"));
	}
	else
	{
		USB.println(F("3. WiFi set ESSID ERROR"));
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
	errorsetpass = WIFI_PRO.setPassword(WPA2, PASSW);

	if (errorsetpass == 0)
	{
		USB.println(F("4. WiFi set AUTHKEY OK"));
	}
	else
	{
		USB.println(F("4. WiFi set AUTHKEY ERROR"));
	}

	//////////////////////////////////////////////////
	// 5. Software Reset
	// Parameters take effect following either a
	// hardware or software reset
	//////////////////////////////////////////////////
	errorsoftreset = WIFI_PRO.softReset();

	if (errorsoftreset == 0)
	{
		USB.println(F("5. WiFi softReset OK"));
	}
	else
	{
		USB.println(F("5. WiFi softReset ERROR"));
	}


	USB.println(F("*******************************************"));
	USB.println(F("Once the module is configured with ESSID"));
	USB.println(F("and PASSWORD, the module will attempt to "));
	USB.println(F("join the specified Access Point on power up"));
	USB.println(F("*******************************************\n"));

}








boolean WiFi_sendFrame()
{
// 3.2. Send Frame
	///////////////////////////////
	// http frame
	previousSendFrame = millis();
	errorSendFrame = WIFI_PRO.sendFrameToMeshlium(type, host, port, frame.buffer, frame.length); // frame
	// check response
	if (errorSendFrame == 0)
	{
		USB.println(F("HTTP OK"));
		ssent = 1;
		USB.print(F("HTTP Time from OFF state (ms):"));
		USB.println(millis() - previousSendFrame);
		USB.println(F("ASCII FRAME SEND OK"));
	}
	else
	{
		USB.println(F("Error calling 'getURL' function"));
		ssent = 0;
		WIFI_PRO.printErrorCode();
	}
	return ssent;
}







void WiFi_print_status()
{
	USB.println(F("2.1. Connection Status:"));
	USB.println(F("-------------------------------"));
	USB.print(F("Rate (Mbps):"));
	USB.println(WIFI_PRO._rate);
	USB.print(F("Signal Level (%):"));
	USB.println(WIFI_PRO._level);
	USB.print(F("Link Quality(%):"));
	USB.println(WIFI_PRO._quality);
	USB.println(F("-------------------------------"));
}






void WiFi_setup()
{
	switchon_WiFi();
	WiFi_resetdefault();
	setSSID_pass_reset();
}





/////////////////////////////ALTE FUNCTII DE START///////////////////////////
void start_prog()
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
}




/////////////////////////////FUNCTII RTC///////////////////////////
boolean RTC_setTimeServer(char *server)
{
// 3.1. Set NTP Server (option1)
	errorSetTimeServer = WIFI_PRO.setTimeServer(1, server);

	// check response
	if (errorSetTimeServer == 0)
	{	sprintf (serbuf, "3.1. Time Server %s set OK \r\n", server);
		USB.println(serbuf);
		statusSetTimeServer = true;
	}
	else
	{
		USB.println(F("3.1. Error calling 'setTimeServer' function"));
		WIFI_PRO.printErrorCode();
		statusSetTimeServer = false;
	}
	return statusSetTimeServer;
}




boolean RTC_EnableTimeSync()
{
	errorEnableTimeSync = WIFI_PRO.timeActivationFlag(true);

	// check response
	if ( errorEnableTimeSync == 0 )
	{
		USB.println(F("3.3. Network Time-of-Day Activation Flag set OK"));
		statusTimeSync = true;
	}
	else
	{
		USB.println(F("3.3. Error calling 'timeActivationFlag' function"));
		WIFI_PRO.printErrorCode();
		statusTimeSync = false;
	}
	return statusTimeSync;
}

void RTC_setGMT()
{
	errorSetGMT = WIFI_PRO.setGMT(time_zone);

	// check response
	if (errorSetGMT == 0)
	{
		USB.print(F("3.4. GMT set OK to "));
		USB.println(time_zone, DEC);
	}
	else
	{
		USB.println(F("3.4. Error calling 'setGMT' function"));
		WIFI_PRO.printErrorCode();
	}
}

void RTC_init()
{
// Init RTC
	RTC.ON();
	USB.print(F("Current RTC settings:"));
	USB.println(RTC.getTime());
}


void RTC_setTimefromWiFi()
{
// 3.1. Open FTP session
	errorsetTimefromWiFi = WIFI_PRO.setTimeFromWIFI();

	// check response
	if (errorsetTimefromWiFi == 0)
	{
		USB.print(F("3. Set RTC time OK. Time:"));
		USB.println(RTC.getTime());
		statussetTimefromWiFi = true;
	}
	else
	{
		USB.println(F("3. Error calling 'setTimeFromWIFI' function"));
		WIFI_PRO.printErrorCode();
		statussetTimefromWiFi = false;
	}
}


void IN_LOOP_RTC_CHECK( bool RTC_SUCCES)
{
	if (  (RTC_SUCCES = false) || (intFlag & RTC_INT)  )
	{
		USB.println(F("Atempt RTC on weekly basis to make sure it is correct"));
		RTC_setTimefromWiFi();
	}
}






































































void all_in_1_frame_process()
{
	if ( PWR.getBatteryLevel() >= 50 )
	{
		ssent = trimitator_WIFI();
	}
	else
	{
		if ( PWR.getBatteryLevel() < 20 )
		{
			ssent = 0;
		}
		else
		{
			ssent = trimitator_WIFI();  // eventual de adaugat un counter care reduce rata de trimitere la 1/2 sau 1/3
		}
	}



	scriitor_SD(filename, ssent);
}





void OTA_setup_check( int att = 1)   // asta reprogrameaza in practica , variabila att numara de cate ori va incerca re se reprogrameza fara succes pana se va renunta
{
	int q = 1;
	bool w = false;
	while ( q <= att && w == false)
	{
		USB.println(" ");
		USB.print(F("atempt: "));
		USB.print(q);
		USB.print(F("/"));
		USB.println(att);
		// show program ID
		Utils.getProgramID(programID);
		USB.println(F("-----------------------------"));
		USB.print(F("Program id: "));
		USB.println(programID);

		// show program version number
		USB.print(F("Program version: "));
		USB.println(Utils.getProgramVersion(), DEC);
		USB.println(F("-----------------------------"));

		status = Utils.checkNewProgram();

		switch (status)
		{
		case 0:
			USB.println(F("REPROGRAMMING ERROR"));
			Utils.blinkRedLED(300, 3);
			q++;
			break;

		case 1:
			USB.println(F("REPROGRAMMING OK"));
			Utils.blinkGreenLED(300, 3);
			w = true;
			break;

		default:
			USB.println(F("RESTARTING"));
			Utils.blinkGreenLED(500, 1);
			q++;
		}
	}

}








void OTA_check_loop(char server[] = ftp_server,     char port[] = ftp_port,    char user[] = ftp_user,    char password[] = ftp_pass  )
{
	USB.print(F("Program version: "));
	USB.println(Utils.getProgramVersion(), DEC);
	SD.ON();
	switchon_WiFi();
	statusWiFiconn = check_WiFi_conn();

	// Check if module is connected
	if (statusWiFiconn == true)
	{
		WiFi_print_status();
		//////////////////////////////
		// 4.3. Request OTA
		//////////////////////////////
		USB.println(F("2.2. Request OTA..."));
		errorrequestOTA = WIFI_PRO.requestOTA( server, port, user, password);
		USB.print(F("=================="));
		USB.println(errorrequestOTA , DEC);
		// If OTA fails, show the error code
		WIFI_PRO.printErrorCode();
		Utils.blinkRedLED(1300, 3);
	}

	switchoff_WiFi();
	USB.println(F("OTA_check_loop is done"));
	// show program version number
	USB.print(F("Program version: "));
	USB.println(Utils.getProgramVersion(), DEC);
	SD.OFF();
	delay(1000);


}

/*



  switch (error)
  {
    case ERROR_CODE_0000: USB.println(F("Timeout")); break;
    case ERROR_CODE_0010: USB.println(F("SD not present")); break;
    case ERROR_CODE_0011: USB.println(F("file not created")); break;
    case ERROR_CODE_0012: USB.println(F("SD error open file")); break;
    case ERROR_CODE_0013: USB.println(F("SD error set file offset")); break;
    case ERROR_CODE_0014: USB.println(F("SD error writing")); break;
    case ERROR_CODE_0020: USB.println(F("rx buffer full")); break;
    case ERROR_CODE_0021: USB.println(F("error downloading UPGRADE.TXT")); break;
    case ERROR_CODE_0022: USB.println(F("filename in UPGRADE.TXT is not a 7-byte name")); break;
    case ERROR_CODE_0023: USB.println(F("no FILE label is found in UPGRADE.TXT")); break;
    case ERROR_CODE_0024: USB.println(F("NO_FILE is defined as FILE in UPGRADE.TXT")); break;
    case ERROR_CODE_0025: USB.println(F("no PATH label is found in UPGRADE.TXT")); break;
    case ERROR_CODE_0026: USB.println(F("no SIZE label is found in UPGRADE.TXT")); break;
    case ERROR_CODE_0027: USB.println(F("no VERSION label is found in UPGRADE.TXT")); break;
    case ERROR_CODE_0028: USB.println(F("version indicated in UPGRADE.TXT is lower/equal to Waspmote's version")); break;
    case ERROR_CODE_0029: USB.println(F("file size does not match the indicated in UPGRADE.TXT")); break;
    case ERROR_CODE_0030: USB.println(F("error downloading binary file")); break;
    case ERROR_CODE_0031: USB.println(F("invalid data length")); break;
    case ERROR_CODE_0041: USB.println(F("Illegal delimiter")); break;
    case ERROR_CODE_0042: USB.println(F("Illegal value")); break;
    case ERROR_CODE_0043: USB.println(F("CR expected ")); break;
    case ERROR_CODE_0044: USB.println(F("Number expected")); break;
    case ERROR_CODE_0045: USB.println(F("CR or ‘,’ expected")); break;
    case ERROR_CODE_0046: USB.println(F("DNS expected")); break;
    case ERROR_CODE_0047: USB.println(F("‘:’ or ‘~’ expected")); break;
    case ERROR_CODE_0048: USB.println(F("String expected")); break;
    case ERROR_CODE_0049: USB.println(F("‘:’ or ‘=’ expected")); break;
    case ERROR_CODE_0050: USB.println(F("Text expected")); break;
    case ERROR_CODE_0051: USB.println(F("Syntax error")); break;
    case ERROR_CODE_0052: USB.println(F("‘,’ expected")); break;
    case ERROR_CODE_0053: USB.println(F("Illegal cmd code")); break;
    case ERROR_CODE_0054: USB.println(F("Error when setting parameter")); break;
    case ERROR_CODE_0055: USB.println(F("Error when getting parameter value")); break;
    case ERROR_CODE_0056: USB.println(F("User abort")); break;
    case ERROR_CODE_0057: USB.println(F("Error when trying to establish PPP")); break;
    case ERROR_CODE_0058: USB.println(F("Error when trying to establish SMTP")); break;
    case ERROR_CODE_0059: USB.println(F("Error when trying to establish POP3")); break;
    case ERROR_CODE_0060: USB.println(F("Single session body for MIME exceeds the maximum allowed")); break;
    case ERROR_CODE_0061: USB.println(F("Internal memory failure")); break;
    case ERROR_CODE_0062: USB.println(F("User aborted the system")); break;
    case ERROR_CODE_0063: USB.println(F("~CTSH needs to be LOW to change to hardware flow control")); break;
    case ERROR_CODE_0064: USB.println(F("User aborted last cmd using ‘---’")); break;
    case ERROR_CODE_0065: USB.println(F("iChip unique ID already exists")); break;
    case ERROR_CODE_0066: USB.println(F("Error when setting the MIF parameter")); break;
    case ERROR_CODE_0067: USB.println(F("Cmd ignored as irrelevant")); break;
    case ERROR_CODE_0068: USB.println(F("iChip serial number already exists")); break;
    case ERROR_CODE_0069: USB.println(F("Timeout on host communication")); break;
    case ERROR_CODE_0070: USB.println(F("Modem failed to respond")); break;
    case ERROR_CODE_0071: USB.println(F("No dial tone response")); break;
    case ERROR_CODE_0072: USB.println(F("No carrier modem response")); break;
    case ERROR_CODE_0073: USB.println(F("Dial failed")); break;
    case ERROR_CODE_0074: USB.println(F("WLAN connection lost")); break;
    case ERROR_CODE_0075: USB.println(F("Access denied to ISP server")); break;
    case ERROR_CODE_0076: USB.println(F("Unable to locate POP3 server")); break;
    case ERROR_CODE_0077: USB.println(F("POP3 server timed out")); break;
    case ERROR_CODE_0078: USB.println(F("Access denied to POP3 server")); break;
    case ERROR_CODE_0079: USB.println(F("POP3 failed ")); break;
    case ERROR_CODE_0080: USB.println(F("No suitable message in mailbox")); break;
    case ERROR_CODE_0081: USB.println(F("Unable to locate SMTP server")); break;
    case ERROR_CODE_0082: USB.println(F("SMTP server timed out")); break;
    case ERROR_CODE_0083: USB.println(F("SMTP failed")); break;
    case ERROR_CODE_0086: USB.println(F("Writing to internal non-volatile parameters database failed")); break;
    case ERROR_CODE_0087: USB.println(F("Web server IP registration failed")); break;
    case ERROR_CODE_0088: USB.println(F("Socket IP registration failed")); break;
    case ERROR_CODE_0089: USB.println(F("E-mail IP registration failed")); break;
    case ERROR_CODE_0090: USB.println(F("IP registration failed for all methods specified")); break;
    case ERROR_CODE_0094: USB.println(F("In Always Online mode, connection was lost and re-established")); break;
    case ERROR_CODE_0096: USB.println(F("A remote host, which had taken over iChip through the LATI port, was disconnected")); break;
    case ERROR_CODE_0100: USB.println(F("Error restoring default parameters")); break;
    case ERROR_CODE_0101: USB.println(F("No ISP access numbers defined")); break;
    case ERROR_CODE_0102: USB.println(F("No USRN defined")); break;
    case ERROR_CODE_0103: USB.println(F("No PWD entered")); break;
    case ERROR_CODE_0104: USB.println(F("No DNS defined")); break;
    case ERROR_CODE_0105: USB.println(F("POP3 server not defined")); break;
    case ERROR_CODE_0106: USB.println(F("MBX (mailbox) not defined")); break;
    case ERROR_CODE_0107: USB.println(F("MPWD (mailbox password) not defined")); break;
    case ERROR_CODE_0108: USB.println(F("TOA (addressee) not defined")); break;
    case ERROR_CODE_0109: USB.println(F("REA (return e-mail address) not defined")); break;
    case ERROR_CODE_0110: USB.println(F("SMTP server not defined")); break;
    case ERROR_CODE_0111: USB.println(F("Serial data overflow")); break;
    case ERROR_CODE_0112: USB.println(F("Illegal cmd when modem online")); break;
    case ERROR_CODE_0113: USB.println(F("Remote firmware update attempted but not completed. The original firmware remained intact.")); break;
    case ERROR_CODE_0114: USB.println(F("E-mail parameters update rejected")); break;
    case ERROR_CODE_0115: USB.println(F("SerialNET could not be started due to missing parameters")); break;
    case ERROR_CODE_0116: USB.println(F("Error parsing a new trusted CA certificate")); break;
    case ERROR_CODE_0117: USB.println(F("Error parsing a new Private Key")); break;
    case ERROR_CODE_0118: USB.println(F("Protocol specified in the USRV parameter does not exist or is unknown")); break;
    case ERROR_CODE_0119: USB.println(F("WPA passphrase too short has to be 8-63 chars")); break;
    case ERROR_CODE_0122: USB.println(F("SerialNET error: Host Interface undefined (HIF=0)")); break;
    case ERROR_CODE_0123: USB.println(F("SerialNET mode error: Host baud rate cannot be determined")); break;
    case ERROR_CODE_0124: USB.println(F("SerialNET over TELNET error: HIF parameter must be set to 1 or 2")); break;
    case ERROR_CODE_0125: USB.println(F("Invalid WEP key")); break;
    case ERROR_CODE_0126: USB.println(F("Invalid parameters’ profile number")); break;
    case ERROR_CODE_0128: USB.println(F("Product ID already exists")); break;
    case ERROR_CODE_0129: USB.println(F("HW pin can not be changed after Product-ID was set ")); break;
    case ERROR_CODE_0200: USB.println(F("Socket does not exist")); break;
    case ERROR_CODE_0201: USB.println(F("Socket empty on receive")); break;
    case ERROR_CODE_0202: USB.println(F("Socket not in use")); break;
    case ERROR_CODE_0203: USB.println(F("Socket down")); break;
    case ERROR_CODE_0204: USB.println(F("No available sockets")); break;
    case ERROR_CODE_0206: USB.println(F("PPP open failed for socket")); break;
    case ERROR_CODE_0207: USB.println(F("Error creating socket")); break;
    case ERROR_CODE_0208: USB.println(F("Socket send error")); break;
    case ERROR_CODE_0209: USB.println(F("Socket receive error")); break;
    case ERROR_CODE_0210: USB.println(F("PPP down for socket")); break;
    case ERROR_CODE_0212: USB.println(F("Socket flush error ")); break;
    case ERROR_CODE_0215: USB.println(F("No carrier error on socket operation")); break;
    case ERROR_CODE_0216: USB.println(F("General exception")); break;
    case ERROR_CODE_0217: USB.println(F("Out of memory")); break;
    case ERROR_CODE_0218: USB.println(F("An STCP (Open Socket) cmd specified a local port number that is already in use")); break;
    case ERROR_CODE_0219: USB.println(F("SSL initialization/internal CA certificate loading error")); break;
    case ERROR_CODE_0220: USB.println(F("SSL3 negotiation error")); break;
    case ERROR_CODE_0221: USB.println(F("Illegal SSL socket handle. Must be an open and active TCP socket.")); break;
    case ERROR_CODE_0222: USB.println(F("Trusted CA certificate does not exist")); break;
    case ERROR_CODE_0224: USB.println(F("Decoding error on incoming SSL data")); break;
    case ERROR_CODE_0225: USB.println(F("No additional SSL sockets available")); break;
    case ERROR_CODE_0226: USB.println(F("Maximum SSL packet size (2KB) exceeded")); break;
    case ERROR_CODE_0227: USB.println(F("AT+iSSND cmd failed because size of stream sent exceeded 2048 bytes")); break;
    case ERROR_CODE_0228: USB.println(F("AT+iSSND cmd failed because checksum calculated does not match checksum sent by host")); break;
    case ERROR_CODE_0229: USB.println(F("SSL parameters are missing ")); break;
    case ERROR_CODE_0230: USB.println(F("Maximum packet size (4GB) exceeded")); break;
    case ERROR_CODE_0300: USB.println(F("HTTP server unknown")); break;
    case ERROR_CODE_0301: USB.println(F("HTTP server timeout ")); break;
    case ERROR_CODE_0303: USB.println(F("No URL specified ")); break;
    case ERROR_CODE_0304: USB.println(F("Illegal HTTP host name")); break;
    case ERROR_CODE_0305: USB.println(F("Illegal HTTP port number")); break;
    case ERROR_CODE_0306: USB.println(F("Illegal URL address")); break;
    case ERROR_CODE_0307: USB.println(F("URL address too long ")); break;
    case ERROR_CODE_0308: USB.println(F("The AT+iWWW cmd failed because iChip does not contain a home page")); break;
    case ERROR_CODE_0309: USB.println(F("WEB server is already active with a different backlog.")); break;
    case ERROR_CODE_0400: USB.println(F("MAC address exists")); break;
    case ERROR_CODE_0401: USB.println(F("No IP address")); break;
    case ERROR_CODE_0402: USB.println(F("Wireless LAN power set failed")); break;
    case ERROR_CODE_0403: USB.println(F("Wireless LAN radio control failed")); break;
    case ERROR_CODE_0404: USB.println(F("Wireless LAN reset failed")); break;
    case ERROR_CODE_0405: USB.println(F("Wireless LAN hardware setup failed")); break;
    case ERROR_CODE_0406: USB.println(F("Cmd failed because WiFi module is currently busy")); break;
    case ERROR_CODE_0407: USB.println(F("Illegal WiFi channel")); break;
    case ERROR_CODE_0408: USB.println(F("Illegal SNR threshold")); break;
    case ERROR_CODE_0409: USB.println(F("WPA connection process has not yet completed")); break;
    case ERROR_CODE_0410: USB.println(F("The network connection is offline (modem)")); break;
    case ERROR_CODE_0411: USB.println(F("Cmd is illegal when Bridge mode is active")); break;
    case ERROR_CODE_0501: USB.println(F("Communications platform already active")); break;
    case ERROR_CODE_0505: USB.println(F("Cannot open additional FTP session – all FTP handles in use")); break;
    case ERROR_CODE_0506: USB.println(F("Not an FTP session handle")); break;
    case ERROR_CODE_0507: USB.println(F("FTP server not found")); break;
    case ERROR_CODE_0508: USB.println(F("Timeout when connecting to FTP server")); break;
    case ERROR_CODE_0509: USB.println(F("Failed to login to FTP server (bad username or password or account)")); break;
    case ERROR_CODE_0510: USB.println(F("FTP cmd could not be completed")); break;
    case ERROR_CODE_0511: USB.println(F("FTP data socket could not be opened")); break;
    case ERROR_CODE_0512: USB.println(F("Failed to send data on FTP data socket")); break;
    case ERROR_CODE_0513: USB.println(F("FTP shutdown by remote server")); break;
    case ERROR_CODE_0550: USB.println(F("Telnet server not found")); break;
    case ERROR_CODE_0551: USB.println(F("Timeout when connecting to Telnet server")); break;
    case ERROR_CODE_0552: USB.println(F("Telnet cmd could not be completed")); break;
    case ERROR_CODE_0553: USB.println(F("Telnet session shutdown by remote server")); break;
    case ERROR_CODE_0554: USB.println(F("A Telnet session is not currently active")); break;
    case ERROR_CODE_0555: USB.println(F("A Telnet session is already open")); break;
    case ERROR_CODE_0556: USB.println(F("Telnet server refused to switch to BINARY mode")); break;
    case ERROR_CODE_0557: USB.println(F("Telnet server refused to switch to ASCII mode")); break;
    case ERROR_CODE_0560: USB.println(F("Client could not retrieve a ring response e-mail")); break;
    case ERROR_CODE_0561: USB.println(F("Remote peer closed the SerialNET socket")); break;
    case ERROR_CODE_0570: USB.println(F("PING destination not found")); break;
    case ERROR_CODE_0571: USB.println(F("No reply to PING request")); break;
    case ERROR_CODE_0600: USB.println(F("Port Forwarding Rule will create ambiguous NAT entry")); break;
    case ERROR_CODE_0084:
    case ERROR_CODE_0085:
    case ERROR_CODE_0091:
    case ERROR_CODE_0092:
    case ERROR_CODE_0093:
    case ERROR_CODE_0098:
    case ERROR_CODE_0099:
    case ERROR_CODE_0120:
    case ERROR_CODE_0121:
    case ERROR_CODE_0223:
    case ERROR_CODE_0302:
    case ERROR_CODE_0500:
    case ERROR_CODE_0502:
    case ERROR_CODE_0503:
    case ERROR_CODE_0504:
    case ERROR_CODE_0514:
    case ERROR_CODE_0558:
    case ERROR_CODE_0559: USB.println(F("RESERVED")); break;
    default: USB.println(F("UNKNOWN ***"));
  }


 */



























// initializare

void setup()
{
	USB.ON();
	RTC.ON(); // Executes the init process
	USB.println(F("START"));

	//data_maker( 10000 ,  filename  );


// Utils.setProgramVersion( verr );



	OTA_setup_check(10);
	RTC_setup();///////////////include WiFi_setup();

	USB.print(F("Current RTC settings:"));
	USB.println(RTC.getTime());

	USB.println(F("SD_CARD_ARHIVE_V5_RTC_ON_BAREBONES"));
	// Set SD ON
	SD_TEST_FILE_CHECK();
	// pm
	USB.ON();
}







// main program
void loop()
{
	// get actual time before loop
	prev = millis();

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	frame.createFrame(ASCII, node_ID); // frame1 de  stocat

	// set frame fields (Battery sensor - uint8_t)
	frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
	frame.addTimestamp();
	//frame.addSensor(SENSOR_STR, "Prior to No0 you can now store node flo");
	frame.showFrame();
	//USB.println("11111 ");
	//scriitor_SD(filename, 7);
	//USB.println("1333333 ");
	all_in_1_frame_process();

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	OTA_check_loop();


///////////////  NU UMBLA AICI !!!
	RTC.setAlarm2("01:10:00", RTC_ABSOLUTE, RTC_ALM2_MODE1); // activare in fiecare duminica la 10:00 dimineata
	//IN_LOOP_RTC_CHECK(  RTC_SUCCES);


	cycle_time = cycle_time2 - b - 5;
	if (cycle_time < 10)
	{
		cycle_time = 15;
	}
	USB.print("cycle time: ");
	USB.println(cycle_time);

	x = cycle_time % 60; // sec
	itoa(x, y, 10);
	if (x < 10) {
		y[1] = y[0];
		y[0] = '0';
	}
	rtc_str[9] = y[0];
	rtc_str[10] = y[1];

	x = cycle_time / 60 % 60; // min
	itoa(x, y, 10);
	if (x < 10)
	{
		y[1] = y[0];
		y[0] = '0';
	}
	rtc_str[6] = y[0];
	rtc_str[7] = y[1];

	x = cycle_time / 3600 % 3600; // h
	itoa(x, y, 10);
	if (x < 10)
	{
		y[1] = y[0];
		y[0] = '0';
	}
	rtc_str[3] = y[0];
	rtc_str[4] = y[1];

	////////////////////////////////////////////////
	// 5. deepsleep
	////////////////////////////////////////////////
	USB.println(F("5. Enter deep sleep..."));
	USB.print("X");
	USB.print(rtc_str);
	USB.println("X");

	USB.println("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
	USB.OFF();
	PWR.deepSleep(rtc_str, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
	USB.ON();
	USB.println(
	    F("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	      "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"));
	USB.println(F("6. Wake up!!\n\n"));
}










/*

uint8_t requestOTAAA(char server[],   char port[], char user[], char pass[], char verr_file[] )
{
  uint8_t error;
  char* str_pointer;
  char aux_name[8];
  char path[100];
  char aux_str[10];
  long int aux_size;
  uint8_t aux_version;
  int length;
  char format_file[10];
  char format_path[10];
  char format_size[10];
  char format_version[10];
  uint16_t handle;

  // set to zero the buffer 'path'
  memset(path, 0x00, sizeof(path));

  // switch SD card ON
  SD.ON();

  // go to Root directory
  SD.goRoot();

  // check if the card is there or not
  if (!SD.isSD())
  {
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(F("Error: SD not present\n"));
#endif
    SD.OFF();
    WIFI_PRO._errorCode = ERROR_CODE_0010;
    return 1;
  }

  // Delete file in the case it exists
  if (SD.isFile(verr_file) == 1)
  {
#if DEBUG_WIFI_PRO > 1
    PRINT_WIFI_PRO(F("delete file\n"));
#endif
    SD.del(verr_file);
  }

  // switch off the SD card
  SD.OFF();

  ////////////////////////////////////////////////////////////////////////////
  // 1. Download config file
  ////////////////////////////////////////////////////////////////////////////

#if DEBUG_WIFI_PRO > 1
  PRINT_WIFI_PRO(F("Downloading OTA config file...\n"));
#endif

  // Open FTP session
  error = WIFI_PRO.ftpOpenSession( server, port, user, pass );

  // check response
  if (error == 0)
  {
    handle = WIFI_PRO._ftp_handle;
#if DEBUG_WIFI_PRO > 1
    PRINT_WIFI_PRO(F("Open FTP session OK\n"));
#endif
  }
  else
  {
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(F("Error opening FTP session\n"));
#endif
    return 1;
  }

  // get verr_file
  error = WIFI_PRO.ftpDownload(handle, verr_file, verr_file);

  // check if file was downloaded correctly
  if (error == 0)
  {
#if DEBUG_WIFI_PRO > 1
    PRINT_WIFI_PRO(F("verr_file downloaded OK\n"));
#endif
  }
  else
  {
    WIFI_PRO._errorCode = ERROR_CODE_0021;
    WIFI_PRO.ftpCloseSession(handle);
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(F("ERROR downloading verr_file\n"));
#endif
    return 1;
  }


  ////////////////////////////////////////////////////////////////////////////
  // 2. Analyze verr_file
  ////////////////////////////////////////////////////////////////////////////

  // "FILE:"
  strcpy_P( format_file, (char*)pgm_read_word(&(table_WIFI_FORMAT[19])));
  // "PATH:"
  strcpy_P( format_path, (char*)pgm_read_word(&(table_WIFI_FORMAT[20])));
  // "SIZE:"
  strcpy_P( format_size, (char*)pgm_read_word(&(table_WIFI_FORMAT[21])));
  // "VERSION:"
  strcpy_P( format_version, (char*)pgm_read_word(&(table_WIFI_FORMAT[22])));


  SD.ON();
  SD.goRoot();

  // clear buffer
  memset(WIFI_PRO._buffer, 0x00, WIFI_PRO._bufferSize);

  // Reads the file and copy to '_buffer'
  SD.cat(verr_file, 0, WIFI_PRO._bufferSize);
  strcpy((char*)WIFI_PRO._buffer, SD.buffer );

  /// 1. Search the file name
  str_pointer = strstr((char*) WIFI_PRO._buffer, format_file);
  if (str_pointer != NULL)
  {
    // Copy the FILE contents:
    // get string length and check it is equal to 7
    length = strchr(str_pointer, '\n') - 1 - strchr(str_pointer, ':');
    if (length != 7)
    {
      WIFI_PRO._errorCode = ERROR_CODE_0022;
      WIFI_PRO.ftpCloseSession(handle);
#if DEBUG_WIFI_PRO > 0
      PRINT_WIFI_PRO(F("length:"));
      USB.println(length);
#endif
      return 1;
    }
    // copy string
    strncpy(aux_name, strchr(str_pointer, ':') + 1, 7);
    aux_name[7] = '\0';
  }
  else
  {
    SD.OFF();
    WIFI_PRO.ftpCloseSession(handle);
    WIFI_PRO._errorCode = ERROR_CODE_0023;
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(F("No FILE label\n"));
#endif
    return 1;
  }

  /// 2. Check if NO_FILE is the filename
  if (strcmp(aux_name, NO_OTA) == 0)
  {
    WIFI_PRO.ftpCloseSession(handle);
    WIFI_PRO._errorCode = ERROR_CODE_0024;
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(NO_OTA);
    USB.println(NO_OTA);
#endif
    return 1;
  }

  /// 3. Search the path
  str_pointer = strstr((char*) WIFI_PRO._buffer, format_path);
  if (str_pointer != NULL)
  {
    // copy the PATH contents
    length = strchr(str_pointer, '\n') - 1 - strchr(str_pointer, ':');
    strncpy(path, strchr(str_pointer, ':') + 1, length );
    path[length] = '\0';

    // delete actual program
    SD.del(aux_name);
  }
  else
  {
    SD.OFF();
    WIFI_PRO.ftpCloseSession(handle);
    WIFI_PRO._errorCode = ERROR_CODE_0025;
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(F("No PATH label\n"));
#endif
    return 1;
  }

  /// 4. Search file size
  str_pointer = strstr((char*) WIFI_PRO._buffer, format_size);
  if (str_pointer != NULL)
  {
    // copy the SIZE contents
    length = strchr(str_pointer, '\n') - 1 - strchr(str_pointer, ':');
    // check length does not overflow
    if (length >= (int)sizeof(aux_str))
    {
      length = sizeof(aux_str) - 1;
    }
    strncpy(aux_str, strchr(str_pointer, ':') + 1, length);
    aux_str[length] = '\0';

    // converto from string to int
    aux_size = atol(aux_str);
  }
  else
  {
    SD.OFF();
    WIFI_PRO.ftpCloseSession(handle);
    WIFI_PRO._errorCode = ERROR_CODE_0026;
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(F("No SIZE label\n"));
#endif
    return 1;
  }

  /// 5. Search Version
  str_pointer = strstr((char*) WIFI_PRO._buffer, format_version);
  if (str_pointer != NULL)
  {
    // copy the SIZE contents
    length = strchr(str_pointer, '\n') - 1 - strchr(str_pointer, ':');
    // check length does not overflow
    if (length >= (int)sizeof(aux_str))
    {
      length = sizeof(aux_str) - 1;
    }
    strncpy(aux_str, strchr(str_pointer, ':') + 1, length);
    aux_str[length] = '\0';

    // convert from string to uint8_t
    aux_version = (uint8_t)atoi(aux_str);
  }
  else
  {
    SD.OFF();
    WIFI_PRO.ftpCloseSession(handle);
    WIFI_PRO._errorCode = ERROR_CODE_0027;
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(F("No VERSION label\n"));
#endif
    return 1;
  }

  // print configuration file contents
  USB.println(F("--------------------------------"));
  PRINT_WIFI_PRO(F("FILE:"));
  USB.println(aux_name);
  PRINT_WIFI_PRO(F("PATH:"));
  USB.println(path);
  PRINT_WIFI_PRO(F("SIZE:"));
  USB.println(aux_size);
  PRINT_WIFI_PRO(F("VERSION:"));
  USB.println(aux_version, DEC);
  USB.println(F("--------------------------------"));

  // get actual program version
  uint8_t prog_version = Utils.getProgramVersion();
  // get actual program name (PID)
  char prog_name[8];
  Utils.getProgramID(prog_name);

  // check if version number
#ifdef CHECK_VERSION
  if (strcmp(prog_name, aux_name) == 0)
  {
    if (prog_version >= aux_version)
    {
      WIFI_PRO.ftpCloseSession(handle);
      WIFI_PRO._errorCode = ERROR_CODE_0028;

      // if we have specified the same program id and lower/same version
      // number, then do not proceed with OTA
      PRINT_WIFI_PRO(F("Invalid version: current="));
      USB.print(prog_version, DEC);
      USB.print(F("; new="));
      USB.println(aux_version, DEC);
      return 1;
    }
  }
#endif


  ////////////////////////////////////////////////////////////////////////////
  // 3. Download binary file
  ////////////////////////////////////////////////////////////////////////////

  // create server file complete path: path + filename
  char server_file[100];
  if (path[strlen(path) - 1] == '/')
  {
    snprintf(server_file, sizeof(server_file), "%s%s", path, aux_name);
  }
  else
  {
    snprintf(server_file, sizeof(server_file), "%s/%s", path, aux_name);
  }

#if DEBUG_WIFI_PRO > 0
  PRINT_WIFI_PRO(F("Downloading OTA FILE\n"));
  PRINT_WIFI_PRO(F("Server file:"));
  USB.println(server_file);
  PRINT_WIFI_PRO(F("SD file:"));
  USB.println(aux_name);
#endif


  // get binary file
  error = WIFI_PRO.ftpDownload(handle, server_file, aux_name);

  if (error == 0)
  {
    // check if size matches
    SD.ON();
    // get file size
    int32_t sd_file_size = SD.getFileSize(aux_name);
    if (sd_file_size != aux_size)
    {
      SD.OFF();
      WIFI_PRO.ftpCloseSession(handle);
      WIFI_PRO._errorCode = ERROR_CODE_0029;
#if DEBUG_WIFI_PRO > 0
      PRINT_WIFI_PRO(F("Size does not match\n"));
      PRINT_WIFI_PRO(F("sd_file_size:"));
      USB.println(sd_file_size);
      PRINT_WIFI_PRO(F("UPGRADE.TXT size field:"));
      USB.println(aux_size);
#endif
      return 1;
    }
#if DEBUG_WIFI_PRO > 1
    SD.ls();
#endif
    WIFI_PRO.ftpCloseSession(handle);
    Utils.loadOTA(aux_name, aux_version);
    return 0;
  }
  else
  {
    SD.OFF();
    WIFI_PRO.ftpCloseSession(handle);
    WIFI_PRO._errorCode = ERROR_CODE_0030;
#if DEBUG_WIFI_PRO > 0
    PRINT_WIFI_PRO(F("Error getting binary\n"));
#endif
    return 1;
  }

  return 1;
}

*/
