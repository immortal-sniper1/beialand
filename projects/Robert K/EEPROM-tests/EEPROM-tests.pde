/*
    ------ [Ut_1] Waspmote Using EEPROM Example --------

    Explanation: This example shows how to use the EEPROM memory of Waspmote

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
    Design:            David Gascón
    Implementation:    Marcos Yarza
*/

// Variables

// address in EEPROM
int address = 1024;
// value to write
int value = 10;
int aux = 0;
int i;
char xx[]="qwerrrr";


void setup()
{
  // Init USB
  USB.ON();
}

void loop()
{
  // WARNING: Reserved EEMPROM addresses below @1024
  // Utils.writeEEPROM do not let the user to write
  // below this address.
  // Do not try to write below this address as
  // you could over-write important configuration
  // --> Available addresses: from 1024 to 4095
  // in o celula se paote scrie maxim pana la 255 ca nr

  Utils.writeEEPROM(address, 'V');
  Utils.writeEEPROM(address+1, 'L');
  Utils.writeEEPROM(address+2, 'n');
  
  for ( i = address + 13; i < 2095; i++)
  {
    // Writing in the EEPROM
    Utils.writeEEPROM(i, i);
  }

  for ( i = address ; i < 4095; i++)
  {
    // Reading the EEPROM
    aux = Utils.readEEPROM(i);
    USB.print(F("Address EEPROM:  "));
    USB.print(i, DEC);
    USB.print(F(" -- Value: "));
    USB.println(aux, DEC);
  }

  USB.println("END");
  delay(1000000);


  if (address == 4096) // there are 4 kB available
  {
    address = 1024;
    USB.println("END");
    delay(10000);
  }
  delay(1);
}

