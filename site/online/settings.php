<?php
###############################
# Format variables				#
###############################
# enter <online> where you want the amount of users online to appear
# escape quotes with a backslash like: '
# Enter the format of the display of the users online if there is over 1 user:
 $displayonline = "There are <A href='usersonline.php?menu=$menu'><online> guests online</A>";
# now enter ther display for if there is only 1 user:
 $display1online = "There is <A href='usersonline.php?menu=$menu'>1 guest online</A>";
# Enter the body background color
 $bodybg = "393939";
 $bodyfontcolor = "C0C0C0";
# Enter the font face and size in pixels
 $fontface = "Arial";
 $fontsize = 12;
# Enter how wide you want the table
 $width = "480";
# Enter how big you want the border to be in pixels and the border color
 $border = 1;
 $bordercolor = "000000";
# Enter the color of the table header and font
 $tableheader = "666666";
 $headfontcolor = "FFFFFF";
# Enter table background color and font color #1
 $tablerow1 = "C0C0C0";
 $fontcolor1 = "000000";
# Enter table background color #2
 $tablerow2 = "FFFFFF";
 $fontcolor2 = "000000";


# name of the data file (CHMOD 666)
# DO NOT CHANGE
 $datafile = $DOCUMENT_ROOT."/site/online/online.txt";
 $recordfile = $DOCUMENT_ROOT."/site/online/record.txt";
 $settings = 1;
?>