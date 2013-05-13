<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=2;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : duel masters : tcg : card database</TITLE>
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
<DIV class=head>Duel Masters Card Database
<?php
include("d3/db/index.txt");
if(isset($set)) {
	echo " : ",$setlist[$set]['name'];
;}
?>
</DIV>
<?php
if(isset($set)) {
	echo "<DIV class=subhead>";
	if(isset($card) and file_exists("d3/db/$set/$card.txt")) {
		include("d3/db/$set/$card.txt");
		echo "#";
		if(isset($cardnum)) {echo $cardnum;}
		else {echo $card;}
		echo " : $name";
	;}
	elseif(isset($card) and !file_exists("d3/db/$set/$card.txt")) {echo "No data file for this card";}
	echo "</DIV>";
;}
if(!isset($set)) {
	foreach ($setlist as $m=>$n) {
		if(!isset($n['setcount'])) {$setcount="???";}
		else {$setcount=$n['setcount']+$n['srcount'];}
		if(!isset($n['release'])) {$n['release']="???";} ?>
<BR><A href="d3_database.php?set=<?= $m; ?>"><?= $n['name']; ?></A> : <?= $setcount; ?> cards : Released <?= $n['release']; ?>
<?php ;}
;}
elseif(!isset($card)) {
	if(!isset($setlist[$set]['setcount'])) {$setcount="???";}
	else {$setcount=$setlist[$set]['setcount']+$setlist[$set]['srcount'];}
	if(!isset($setlist[$set]['release'])) {$setlist[$set]['release']="???";}
	echo "$setcount cards : Released ",$setlist[$set]['release'],"<P>"; ?>
<CENTER>
<TABLE width=490 border=1 cellpadding=0>
<TR>
<TD width=30><B>No.</B></TD>
<TD><B>Name</B></TD>
<TD width=90><B>Civilization</B></TD>
<TD width=50><B>Rarity</B></TD>
<TD width=50><B>Price</B></TD>
</TR>
<?php
for($x=1;$x<=$setlist[$set]['srcount'];$x++) {
	if(file_exists("d3/db/$set/s$x.txt")) {
		include("d3/db/$set/s$x.txt"); ?>
<TR><TD>S<?= $x; ?></TD><TD><A href="d3_database.php?set=<?= $set; ?>&card=s<?= $x; ?>"><?= $name; ?></A></TD><TD><?= $civ; ?></TD><TD align=center><IMG src="d3/db/images/<?= $rarity; ?>.gif" align=middle></TD><TD>$<?= $price; ?></TD></TR>
<?php ;}
;}
for($y=1;$y<=$setlist[$set]['setcount'];$y++) {
	if(file_exists("d3/db/$set/$y.txt")) {
		include("d3/db/$set/$y.txt"); ?>
<TR><TD><?= $y; ?></TD><TD><A href="d3_database.php?set=<?= $set; ?>&card=<?= $y; ?>"><?= $name; ?></A></TD><TD><?= $civ; ?></TD><TD align=center><IMG src="d3/db/images/<?= $rarity; ?>.gif" align=middle></TD><TD>$<?= $price; ?></TD></TR>
<?php ;}
;} ?>
</TABLE>
</CENTER>
<?php ;}
elseif(isset($card)) {
	if(file_exists("d3/db/$set/$card.txt")) {
?>
<TABLE width=490 align=center><TR><TD width=175 align=center>
<?php if(file_exists("d3/pics/$set/sm/$card.jpg")) { ?><A href="javascript:;" onClick="MM_openBrWindow('d3/cardview.php?set=<?= $set; ?>&card=<?= $card; ?>','cardWin','width=320,height=450')"><IMG src="d3/pics/<?= $set; ?>/sm/<?= $card; ?>.jpg" alt="<?= $name; ?> : <?= $setlist[$set]['name']; ?>" align=left></A><?php ;} else { ?><IMG src="d3/pics/cardback_sm.jpg" alt="<?= $name; ?> : <?= $setlist[$set]['name']; ?> : No image available" align=left><?php ;} ?></TD>
<TD>
<B><?php if($type=="creature") { ?><?= $power; ?> : <?php if(isset($survivor)) {echo "Survivor / ";} ?><?= $race; ?><BR><?php ;} ?>
<?= $civ; ?> civilization : <?= $cost; ?> cost</B>
<P>
<?php if(isset($blocker)) { ?>
<IMG src="d3/db/images/blocker.gif" align=middle><B>Blocker</B> <I>(Whenever an opponent's creature attacks, you may tap this creature to stop the attack. Then the two creatures battle.)</I><BR>
<?php ;} ?>
<?php
if(isset($trigger)) { ?>
<IMG src="d3/db/images/trigger.gif" align=middle><B>Shield trigger</B> <I>(When this <?= $type; ?> is put into your hand from your shield zone, you may <?php
if($type=="spell") {echo "cast";}
if($type=="creature") {echo "summon";}
?> it immediately for no cost.)</I><BR>
<?php ;}
if(isset($evolution)) {echo "&#8226; Evolution&mdash;Put on one of your ",$race,"s.<BR>";}
if(isset($survivor)) { ?>
&#8226; Survivor <I>(Each of your Survivors has this creature's <IMG src="d3/db/images/survivor.gif" align=middle> ability.)</I>
<BLOCKQUOTE><IMG src="d3/db/images/survivor.gif" align=middle> <?= $survivor; ?></BLOCKQUOTE>
<?php ;}
if(isset($effect)) {
	foreach($effect as $n) { ?>
&#8226; <?= $n; ?><BR>
<?php ;}
;}
if(isset($flavtext)) {echo "<P><I>$flavtext</I>";} ?>
</TD></TR></TABLE>
<P>
<B>Rarity:</B> <IMG src="d3/db/images/<?= $rarity; ?>.gif" align=middle><BR>
<B>Price:</B> $<?= $price; ?>
<P>
<B>Score :</B> <?php
for($y=1;$y<=$rating;$y++) {
		echo "<IMG src=\"p3/cotw/1.gif\" align=middle>";
	;}
	for($y=1;$y<=10-$rating;$y++) {
		echo "<IMG src=\"p3/cotw/0.gif\" align=middle>";
	;}
	echo " $rating/10";
?>
<P>
<?php if(isset($other)) {echo "<P>$other";} ?>
<P>
<A href="d3_database.php?set=<?= $set; ?>">Back to <?= $setlist[$set]['name']; ?></A>
<?php ;}
;} ?>
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