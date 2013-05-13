<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&#233;mon : pok&#233;mon : games : emerald</TITLE>
<LINK rel=stylesheet type=text/css href=site/style.css>
<?php include("site/meta.txt"); ?>
</HEAD>
<BODY>
<CENTER>
<TABLE width=750 border=0 cellpadding=0>
<TR>
<TD width=625 colspan=2 rowspan=2 class=light>
<?php include("site/head.txt"); ?>
</TD>
<TD width=125 align=center class=light>
Latest News
</TD>
</TR>
<TR>
<TD width=125>
<?php include("site/ticker.txt"); ?>
</TD>
</TR>
<TR>
<TD width=125 rowspan=2 class=light>
<?php include("site/left.txt"); ?>
</TD>
<TD width=500>
<DIV class=head>
Pok&#233;mon Emerald
</DIV><BR>
<IMG src="p2/emerald/screenshots/title.gif" align=left alt="Pok&eacute;mon Emerald title screen">
Pok&eacute;mon Emerald was released in Japan in 2004 as the successor to Pok&eacute;mon Ruby &amp; Sapphire, featuring the same main character in the same region, with some storyline and gameplay changes, a la Pok&eacute;mon Crystal and its relationship to the Gold &amp; Silver series. In Pok&eacute;mon Emerald, the featured Pok&eacute;mon is Rayquaza, but both Kyogre and Groudon, as well as Teams Magma and Aqua, appear and are part of the storyline. A number of new locations in the Hoenn region are accessible as well, such as a Theme Park that introduces seven new battle types. Other trainers in the game can now make comments on your battles as they are in progress. Design-wise, many of the characters and Pok&eacute;mon have been redrawn (as they were for Yellow and Crystal after Red/Blue and Gold/Silver, respectively), and the Pok&eacute;mon animations introduced in Crystal have been brought back. The game is bundled and compatible with the FireRed/LeafGreen wireless adapter. A United States release is projected for Spring 2005.
</TD>
<TD width=125 class=light>
<?php include("site/right.txt"); ?>
</TD>
</TR>
<TR>
<TD width=625 height=13 align=right colspan=2>
<?php include("site/footer.txt"); ?>
</TD>
</TR>
</TABLE>
</CENTER>
</BODY>
</HTML>
