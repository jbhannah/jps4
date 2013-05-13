<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : tcg : card database</TITLE>
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
<DIV class=head>Pok&eacute;mon Card Database
<?php
include("p3/db/index.txt");
if(isset($set)) {
	echo " : ",$setlist[$set]['name'];
;}
?>
</DIV>
<?php
if(isset($set)) {
	echo "<DIV class=subhead>";
	if(isset($card) and file_exists("p3/db/$set/$card.txt")) {
		include("p3/db/$set/$card.txt");
		echo "#$card : $name";
	;}
	elseif(isset($card) and !file_exists("p3/db/$set/$card.txt")) {echo "No data file for this card";}
	echo "</DIV>";
;}
if(!isset($set)) {
	foreach ($setlist as $m=>$n) {
		if(!isset($n['setcount'])) {$n['setcount']="???";}
		if(!isset($n['release'])) {$n['release']="???"; } ?>
<BR><A href="p3_database.php?set=<?= $m; ?>"><?= $n['name']; ?></A> : <?= $n['setcount']; ?> cards : Released <?= $n['release']; ?>
<?php ;}
;}
elseif(!isset($card)) {
	if(!isset($setlist[$set]['setcount'])) {$setcount="???";}
	else {$setcount=$setlist[$set]['setcount']+$setlist[$set]['srcount'];}
	if(!isset($setlist[$set]['release'])) {$setlist[$set]['release']="???";}
	echo "$setcount cards : Released ",$setlist[$set]['release'],"<P>"; ?>
<CENTER>
<?php
if(isset($setlist[$set]['notes'])) {echo $setlist[$set]['notes'],"<BR>";}
if($set=="12w" or $set>12) {echo "Alternate/reverse holofoils are worth 2&times; listed price<BR>";}
?>
<TABLE width=490 border=1 cellpadding=0>
<TR>
<TD width=30><B>No.</B></TD>
<TD><B>Name</B></TD>
<TD width=60><B>Type</B></TD>
<TD width=50><B>Element</B></TD>
<TD width=40><B>Rarity</B></TD>
<?php if(($set<12 and $set!=4) or $set=="12j") {
?><TD width=70><B>1st Edition</B></TD>
<?php ;} ?>
<TD width=50><B>Price</B></TD>
</TR>
<?php
for($x=1;$x<=$setlist[$set]['setcount'];$x++) {
	if(file_exists("p3/db/$set/$x.txt")) {
		include("p3/db/$set/$x.txt"); ?>
<TR>
<TD><?= $x; ?></TD>
<TD><A href="p3_database.php?set=<?= $set; ?>&card=<?= $x; ?>"><?= $name; ?></A></TD>
<TD><?php
if($type=="pkmn") {echo "Pok&eacute;mon";}
elseif($type=="trainer" or $type=="stadium" or $type=="tm" or $type=="supporter" or $type=="tool") {echo "Trainer";}
elseif($type=="energy-basic" or $type=="energy-other") {echo "Energy";}
?></TD>
<TD align=center><?php if(isset($element)) { ?><IMG src="p3/db/images/elements/<?= $element; ?>.gif" alt="<?= $element; ?>" align=middle><?php ;} if(isset($element2)) { ?><IMG src="p3/db/images/elements/<?= $element2; ?>.gif" alt="<?= $element2; ?>" align=middle><?php ;} ?></TD>
<TD align=center><IMG src="p3/db/images/rarity/<?= $rarity; ?>.gif" alt="<?= $rarity; ?>" align=middle></TD>
<?php if(($set<12 and $set!=4) or $set=="12j") { ?><TD>$<?= $firstedn; ?></TD><?php ;} ?>
<TD><?= $price; ?></TD>
</TR>
<?php unset($name,$type,$element,$element2,$rarity,$price,$firstedn);
	;}
;}
?>
</TABLE>
</CENTER>
<? ;}
elseif(isset($card)) {
	if(file_exists("p3/db/$set/$card.txt")) {
?>
<TABLE width=490 align=center><TR><TD width=175 align=center>
<?php if(file_exists("p3/pics/$set/sm/$card.jpg")) { ?><A href="javascript:;" onClick="MM_openBrWindow('p3/cardview.php?set=<?= $set; ?>&card=<?= $card; ?>','cardWin','width=320,height=450')"><IMG src="p3/pics/<?= $set; ?>/sm/<?= $card; ?>.jpg" alt="<?= $name; ?> : <?= $setlist[$set]['name']; ?>" align=left></A><?php ;} else { ?><IMG src="p3/pics/cardback_sm.jpg" alt="<?= $name; ?> : <?= $setlist[$set]['name']; ?> : No image available" align=left><?php ;} ?></TD>
<TD>
<?php if($type=="pkmn") { ?>
<B><?= $hp; ?> HP <IMG src="p3/db/images/elements/<?= $element; ?>.gif" alt="<?= $element; ?>" align=middle><?php if(isset($element2)) { ?><IMG src="p3/db/images/elements/<?= $element2; ?>.gif" align=middle><?php ;} ?><?php if(isset($lv)) { ?> Lv.<?= $lv; ?><?php ;} ?><BR>
<?php if(isset($stage)) { ?>Stage <?= $stage['num']; ?> : Evolves from <A href="p3_database.php?set=<?= $stage['set']; ?>&card=<?= $stage['card']; ?>"><?= $stage['name']; ?></A><?php ;}
elseif(isset($baby)) { ?>Baby Pok&eacute;mon : Evolves into <A href="p3_database.php?set=<?= $baby['set']; ?>&card=<?= $baby['card']; ?>"><?= $baby['name']; ?></A> : </B>Put <?= $baby['name']; ?> on the Baby Pok&eacute;mon<BR>
Baby Pok&eacute;mon counts as a Basic Pok&eacute;mon<BR><? ;}
else { ?>Basic Pok&eacute;mon<?php ;} ?></B><BR>
<B>Weakness :</B> <?php if(isset($weak)) { ?><IMG src="p3/db/images/elements/<?= $weak; ?>.gif" align=middle><?php if(isset($weak2)) { ?><IMG src="p3/db/images/elements/<?= $weak2; ?>.gif" align=middle><?php ;} ?><?php ;} ?><BR>
<B>Resistance :</B> <?php if(isset($resist)) { ?><IMG src="p3/db/images/elements/<?= $resist; ?>.gif" align=middle><?php if(isset($resist2)) { ?><IMG src="p3/db/images/elements/<?= $resist2; ?>.gif" align=middle><?php ;} ?> -30<?php ;} ?><BR>
<B>Retreat Cost :</B> <?php for($y=1;$y<=$retreat;$y++) { ?><IMG src="p3/db/images/elements/colorless.gif" align=middle><?php ;} ?>
<?php
if(isset($baby)) { ?><P>If your Active Pok&eacute;mon is a Baby Pok&eacute;mon and your opponent announces an attack, your opponent flips a coin (before doing anything else). If tails, your opponent's turn ends.<?php ;}
if($rarity=="ex") { ?><P>When Pok&eacute;mon-ex is Knocked Out, your opponent takes 2 Prize cards.<?php ;}
if(isset($element2)) { ?><P>This Pok&eacute;mon is both <IMG src="p3/db/images/elements/<?= $element; ?>.gif" align=middle><IMG src="p3/db/images/elements/<?= $element2; ?>.gif" align=middle> type.<?php ;}
if(isset($pkmnpower)) { ?><P><B>Pok&eacute;mon Power : <?= $pkmnpower['name']; ?></B><BR>
<?= $pkmnpower['text']; ?>
<?php
;}
elseif(isset($pokepower)) { ?><P><IMG src="p3/db/images/pokepower.gif" align=middle> <B><?= $pokepower['name']; ?></B><BR>
<?= $pokepower['text']; ?>
<?php
;}
elseif(isset($pokebody)) { ?><P><IMG src="p3/db/images/pokebody.gif" align=middle> <B><?= $pokebody['name']; ?></B><BR>
<?= $pokebody['text']; ?>
<?php ;} ?>
<?php foreach($attack as $n) { ?>
<P>
<TABLE width=300 border=0 cellpadding=0>
<TR><TD width=<?= 11*count($n['cost'])+2; ?> align=left><?php foreach($n['cost'] as $m) { ?><IMG src="p3/db/images/elements/<?= $m; ?>.gif" align=middle><?php ;} ?></TD>
<TD width=* <?php if(!isset($n['text'])) {echo "align=center";} ?>><B><?= $n['name']; ?></B></TD>
<TD width=20 align=right><B><?= $n['damage'] ?></B>
</TD></TR></TABLE>
<?= $n['text'] ?>
<?php ;} ?>
<?php
;}
elseif($type=="tm") { ?>
<?= $text; ?>
<P>
<TABLE width=100% boder=0 cellpadding=0>
<TR><TD align=left>
<?php foreach($attack['cost'] as $m) { ?><IMG src="p3/db/images/elements/<?= $m; ?>.gif" alt="<?= $m; ?>" align=middle><?php ;} ?> <B><?= $attack['name']; ?></B>
</TD><TD align=right>
<B><?= $attack['damage'] ?></B>
</TD></TR></TABLE>
<?= $attack['text'] ?>
<?php
;}
elseif($type=="supporter" or $type=="tool" or $type=="stadium") { ?>
<B><?php if($type=="supporter") {echo "Supporter";} if($type=="tool") {echo "Pok&eacute;mon Tool";} if($type=="stadium") {echo "Stadium";}?></B>
<P>
<?php
if($type=="supporter") {echo "You can play only one Supporter card each turn. When you play this card, put it next to your Active Pok&eacute;mon. When your turn ends, discard this card.";}
if($type=="tool") {echo "Attach $name to 1 of your Pok&eacute;mon that doesn't already have a Pok&eacute;mon Tool attached to it. If that Pok&eacute;mon is Knocked Out, discard this card.";}
if($type=="stadium") {echo "This card stays in play when you play it. Discard this card if another Stadium card comes into play.";}
?>
<P>
<?= $text; ?>
<?php
;}
elseif($type=="trainer") {echo $text;}
elseif($type=="energy-other") { ?>
<B>Special Energy Card</B><P>
<?= $text; ?>
<?php
;}
elseif($type=="energy-basic") { ?>This card provides 1 <IMG src="p3/db/images/elements/<?= $element; ?>.gif alt="<?= $element; ?>" align=middle> energy.<?php ;} ?>
</TD></TR></TABLE><P>
<B>Rarity :</B> <IMG src="p3/db/images/rarity/<?= $rarity; ?>.gif" align=middle><BR>
<B>Price :</B> $<?= $price; ?>
<?php if(isset($firstedn)) { ?><BR><B>1st Edition Price :</B> $<?= $firstedn; ?><?php ;} ?>
<?php if($set=="12w" or $set>12 and $rarity!="ex") { ?><BR><B>Alternate (reverse) holofoil :</B> $<?= $price*2; ?><?php ;} ?>
<P>
<B>Score :</B> <?php
for($y=1;$y<=$rating;$y++) {
		echo "<IMG src='p3/cotw/1.gif' align=middle>";
	;}
	for($y=1;$y<=10-$rating;$y++) {
		echo "<IMG src='p3/cotw/0.gif' align=middle>";
	;}
	echo " $rating/10";
?>
<P>
<?php if(isset($other)) {echo "<P>$other";} ?>
<?php ;} ?>
<P>
<A href="p3_database.php?set=<?= $set; ?>">Back to <?= $setlist[$set]['name']; ?></A>
<?php ;} ?>
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