# play-bell
Plays the school bell at scheduled times

ORIGEN

When I was a student in the school of computer sciences, back in 1997, there was a person in charge of making the bell ring any time a class was going to start or end. Frequently, that person was busy with other functions so he used to be delayed to play the bell. So I proposed this solution: a computer program to automatically play the bell. It was successfully used in the school for a number of years.

HOW IT WORKS

The bell needs to be connented to the parallel port of the computer throught an electric relay or other power device. The program runs as a Windows NT service. A small icon appears in the trybar identifying the program. You click the icon to get a form where you can set a list of days, hours and minutes where you want the bell to be played. In order to play the bell, a 0xFF value is set to the computer parrallel port. For turning off the bell, a 0x00 value is set to the port.

REMARKS

The program was made with Borland Delphi 6 for Microsoft Windows. It was running on Windows NT Server. 
