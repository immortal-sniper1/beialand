/*
    ------ [RTC_10] Setting RTC watchdog reset --------

    Explanation: This example shows how to setup the RTC watchdog reset
    through the Alarm2 of the RTC. The RTC.setWatchdog() function permits
    to configure device resets in order to avoid

    Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Version:           3.0
    Design:            David Gascon
    Implementation:    Marcos Yarza, Yuri Carmona
*/
int x;

void setup()
{
  // init USB
  USB.ON();
  USB.println(F("*************************************"));
  USB.println(F("RTC_10 example"));
  USB.println(F("*************************************\n"));

  // init RTC
  RTC.ON();
  USB.println(F("RTC time:"));
  USB.println(F("------------------------------------"));
  USB.println(RTC.getTime());
  USB.println(F("------------------------------------\n"));

}


void loop()
{
  /**************************************************************
     -- Set RTC Watchdog reset --
     The input refers to the number of times the 'minute hand'
     changes. Everytime this function is called, the timer starts
     again from the beginning.
     Input: from 1 to 1000 minutes

     Example:
       If RTC is configured with 12h:30m:35s and we call
       RTC.setWatchdog(1); when the RTC reaches 12h:31m:00s
       a Waspmote reset will be triggered
   **************************************************************/
  RTC.setWatchdog(3);

  USB.println(F("Watchdog settings:"));
  USB.println(F("----------------------------------------------------"));
  USB.println(RTC.getWatchdog());
  USB.println(F("----------------------------------------------------\n"));
  x = 8;
  // enter an infinite while
  while (x > 0)
  {
    USB.print(F("Inside infinite loop. Time: "));
    USB.println(RTC.getTime());
    delay(1000);
    x--;
  }
}






/*
// asta e folosita in void loop la inceput de tott
void Watchdog_setup_and_reset(int x, bool y = false) // x e timpul in secunde  iar y e enable
{
  int tt;

  if ( y)
  {
    tt = 3 * x % 60;
    if (tt > 59)  // 59 minutes max timer time
    {
      tt = 59;
    }
    if (tt < 1)
    {
      tt = 1;   // 1 minute is min timer time
    }
    RTC.setWatchdog(tt);
    USB.print(F("RTC timer reset succesful"));
    USB.print(F("        next forced restart: "));
    USB.println(  RTC.getWatchdog()  );
  }

}




// asta vine in void setup
USB.println(F("Watchdog settings: 3 cycle time"));


*/


