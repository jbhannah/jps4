<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : tcg : card of the week</TITLE>
<SCRIPT language="JavaScript" type="text/JavaScript" src="site/newwindow.js"></SCRIPT>
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
Pok&eacute;mon Card of the Week
<?php
if(isset($week)) {echo " : Week $week";}
else {echo " Archives";}
?>
</DIV>
<?php
include("p3/db/index.txt");
if(isset($week)) {
	include("p3/cotw/$week.txt");
	include("p3/db/$set/$card.txt"); ?>
<DIV class=subhead><?= $cotwdate; ?> : <A href="p3_database.php?set=<?= $set; ?>&card=<?= $card; ?>"><?= $name; ?> : <?= $setlist[$set]['name']; ?></A></DIV><BR>
<A href="javascript:;" onClick="MM_openBrWindow('p3/cardview.php?set=<?= $set; ?>&card=<?= $card; ?>','cardWin','width=320,height=450')"><IMG src="p3/pics/<?= $set; ?>/sm/<?= $card; ?>.jpg" alt="<?= $name; ?> : <?= $setlist[$set]['name']; ?>" align=right></A>
<?= $review; ?>
<P>
<B>Score : </B><?php
for($y=1;$y<=$rating;$y++) {
	echo "<IMG src='p3/cotw/1.gif' align=middle>";
;}
for($y=1;$y<=10-$rating;$y++) {
	echo "<IMG src='p3/cotw/0.gif' align=middle>";
;}
echo " $rating/10";
?>
<P><A href='p3_cardoftheweek.php'>Card of the Week Archives</A>
<?php
;}
else {
	echo "<BR>";
	if(!isset($page)) {$page=1;}
	$x=1;
	if(file_exists("p3/cotw/101.txt")) { ?>
<DIV align=right>Page <?php
while(file_exists("p3/cotw/".(($x*100)-99).".txt")) {
	if($x!=$page) {echo "<A href=\"p3_cardoftheweek.php?page=$x\">$x</A>";}
	else {echo $x;}
	$x++;
	if(file_exists("p3/cotw/".(($x*100)-99).".txt")) {echo " : ";}
;}
?>
</DIV>
<?php ;}
	$i=($page*100)-99;
	while(file_exists("p3/cotw/$i.txt") and $i<=(100*$page)) {
		include("p3/cotw/$i.txt");
		include("p3/db/$set/$card.txt");
		echo "Week $i : <A href=\"p3_cardoftheweek.php?week=$i\">$cotwdate : $name : ",$setlist[$set]['name'],"</A><BR>";
		$i++;
	;}
	$x=1;
	if(file_exists("p3/cotw/101.txt")) { ?>
<DIV align=right>Page <?php
while(file_exists("p3/cotw/".(($x*100)-99).".txt")) {
	if($x!=$page) {echo "<A href=\"p3_cardoftheweek.php?page=$x\">$x</A>";}
	else {echo $x;}
	$x++;
	if(file_exists("p3/cotw/".(($x*100)-99).".txt")) {echo " : ";}
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