# ring-bell
Rings the school bell at scheduled times

ORIGEN

When I was a student in the school of computer science, back in 1997, there was a person in charge of ringing the bell any time a class was going to start or end. Frequently, that person was busy with other functions so there was a delay ringing the bell. As a solution, I proposed a computer program that would automatically ring the bell. The program was successfully used in the school for a number of years.

HOW IT WORKED

The bell needed to be connected to the parallel port of the computer through an electric relay or other power device. The program ran as a Windows NT service. A small icon appeared in the system tray bar identifying the program. You clicked the icon to get a form where you could set a list of days, hours and minutes when the bell should ring and defining the duration of the ring. In order for the bell to ring, the parallel port was set to 0xFF. The bell then stopped ringing when a 0x00 value was sent to the port.  

REMARKS

The program was made using Borland Delphi 6 for Microsoft Windows. It was running on a Windows NT Server. 

ACKNOWLEDGEMENT

The component for controlling the system try icon was developed by Erik Sperling Johansen.
