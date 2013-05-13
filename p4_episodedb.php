<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : anime : episode database</TITLE>
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
<DIV class=head>Pok&eacute;mon Episode Database</DIV>
<?php
include("p4/episodedb/seasons.txt");
if(isset($season)) {
	echo "<DIV class=subhead>";
	if(isset($episode)) {
		$title=file("p4/episodedb/$season/list.txt");
		if($season==1) {
			if($episode=="34b") {$epnum=34;}
			elseif($episode=="35" or $episode=="36") {$epnum=$episode;}
			elseif($episode=="36b") {$epnum=37;}
			elseif($episode>=37) {$epnum=$episode+1;}
			else {$epnum=$episode-1;}
		;}
		else {$epnum=$episode-1;}
		echo "#$season";
		if($episode<10) {echo "0";}
		echo "$episode : $title[$epnum]";
	;}
	else {
		echo "Season $season : ",$snlist[$season]['title'];
	;}
	echo "</DIV>";
;}
?>
<?php
if(!isset($season)) {
	for($w=1;$w<=count($snlist);$w++) {
		echo "<A href=\"#$w\">Season $w</A>";
		if($w<count($snlist)) {echo " : ";}
	;}
;}
elseif(!isset($episode)) {
	$list=file("p4/episodedb/$season/list.txt");
	echo count($list)," episodes : Aired ",$snlist[$season]['released'];
;}
if(isset($episode)) {include("p4/episodedb/nav.txt");}
echo "<P>";
if(isset($episode)) {include("p4/episodedb/$season/$episode.txt");}
elseif(isset($season)) {
	include("p4/episodedb/$season/index.txt");
	echo "<BR><BR><DIV class=subhead>Episode List</DIV>";
	for($x=0;$x<count($list);$x++) {
		if($season==1) {
			if($x==34) {$listnum="34b";}
			elseif($x==35 or $x==36) {$listnum=$x;}
			elseif($x==37) {$listnum="36b";}
			elseif($x>37) {$listnum=$x-1;}
			else {$listnum=$x+1;}
		;}
		else {$listnum=$x+1;}
		echo "#$season";
		if($listnum<=9) {echo "0";}
		echo "$listnum : <A href=\"p4_episodedb.php?season=$season&episode=$listnum\">$list[$x]</A>";
		if($x<count($list)-1) {echo "<BR>";}
	;}
;}
else {
	for($y=1;$y<=count($snlist);$y++){
		$ctlist=file("p4/episodedb/$y/list.txt");
		echo "<DIV class=subhead><A href=\"p4_episodedb.php?season=$y\">Season $y : ",$snlist[$y]['title'],"</A></DIV>";
		echo count($ctlist)," episodes : Aired ",$snlist[$y]['released'],"<BR>";
		for($z=0;$z<count($ctlist);$z++) {
			if($y==1) {
				if($z==34) {$ctlistnum="34b";}
				elseif($z==35 or $z==36) {$ctlistnum=$z;}
				elseif($z==37) {$ctlistnum="36b";}
				elseif($z>37) {$ctlistnum=$z-1;}
				else {$ctlistnum=$z+1;}
			;}
			else {$ctlistnum=$z+1;}
			echo "#$y";
			if($ctlistnum<=9) {echo "0";}
			echo "$ctlistnum : <A href=\"p4_episodedb.php?season=$y&episode=$ctlistnum\">$ctlist[$z]</A>";
			if($z<count($ctlist)) {echo "<BR>";}
			if($y<count($snlist) and $z==count($ctlist)-1) {echo "<P>";}
		;}
	;}
;}
if(isset($episode)) {
	include("p4/episodedb/nav.txt");
	echo "<P><A href=\"p4_episodedb.php?season=$season\">Back to ",$snlist[$season]['title'],"</A><P>";
;}
?>
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
