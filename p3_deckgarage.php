<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : tcg : deck garage</TITLE>
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
Pok&eacute;mon Deck Garage
<?php
if(!isset($deck)) {echo " Archives";}
?>
</DIV>
<?php
if(isset($deck)) {
	include("p3/deckg/$deck.txt");
	echo "<DIV class=subhead>$deckgdate : $title</DIV>";
;}
?>
<BR>
<?php
if(isset($deck)) { ?>
<?php if(isset($listorig)) { ?>
<TABLE align=left width=140 border=1 cellpadding=0>
<TR><TD width=25><B>Qty.</B></TD><TD width=100><B>Name</B></TD></TR>
<?php foreach($listorig as $x=>$y) { ?>
<TR><TD colspan=2><B><?= $x; ?><!-- : <?/* = count($y); */?> cards</B>--></TD></TR>
<?php
foreach($y as $z) {
	include("p3/db/".$z['set']."/".$z['card'].".txt");
	echo "<TR><TD>",$z['qty'],"</TD><TD><A href=\"p3_database.php?set=",$z['set'],"&card=",$z['card'],"\">$name</A></TD></TR>";
	unset($z);
;}
;} ?>
</TABLE>
<?php ;} ?>
<?php if(isset($listrev)) { ?>
<TABLE align=right width=140 border=1 cellpadding=0>
<TR><TD width=25><B>Qty.</B></TD><TD width=100><B>Name</B></TD></TR>
<?php foreach($listrev as $a=>$b) { ?>
<TR><TD colspan=2><B><?= $a; ?><!-- : <?/* = count($y); */?> cards</B>--></TD></TR>
<?php
foreach($b as $c) {
	include("p3/db/".$c['set']."/".$c['card'].".txt");
	echo "<TR><TD>",$c['qty'],"</TD><TD><A href=\"p3_database.php?set=",$c['set'],"&card=",$c['card'],"\">$name</A></TD></TR>";
	unset($c);
;}
;} ?>
</TABLE>
<?php ;} ?>
<?= $review; ?>
<P>
Designed by <?php if(isset($designer['email'])) { ?><A href="donotsendmailto:<?= $designer['email']; ?>"><?= $designer['name']; ?></A><?php ;} else { echo $designer['name'];} ?>. Reviewed by <?php if(isset($reviewer['email'])) { ?><A href="donotsendmailto:<?= $reviewer['email']; ?>"><?= $reviewer['name']; ?></A><?php ;} else { echo $reviewer['name'];} ?>.
<P>
<A href="p3_deckgarage.php">Deck Garage Archives</A>
<?php ;}
else {
	if(!isset($page)) {$page=1;}
	$x=1;
	if(file_exists("p3/deckg/101.txt")) { ?>
<DIV align=right>Page <?php
while(file_exists("p3/deckg/".(($x*100)-99).".txt")) {
	if($x!=$page) {echo "<A href=\"p3_deckgarage.php?page=$x\">$x</A>";}
	else {echo $x;}
	$x++;
	if(file_exists("p3/deckg/".(($x*100)-99).".txt")) {echo " : ";}
;}
?>
</DIV>
<?php ;}
	$i=($page*100)-99;
	while(file_exists("p3/deckg/$i.txt") and $i<=(100*$page)) {
		include("p3/deckg/$i.txt");
		echo "<A href=\"p3_deckgarage.php?deck=$i\">Deck $i : $deckgdate : $title</A><BR>";
		$i++;
	;}
	$x=1;
	if(file_exists("p3/deckg/101.txt")) { ?>
<DIV align=right>Page <?php
while(file_exists("p3/deckg/".(($x*100)-99).".txt")) {
	if($x!=$page) {echo "<A href=\"p3_deckgarage.php?page=$x\">$x</A>";}
	else {echo $x;}
	$x++;
	if(file_exists("p3/deckg/".(($x*100)-99).".txt")) {echo " : ";}
;}
?>
</DIV>
<?php ;}
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
