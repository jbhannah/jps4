<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : tcg : rulebook</TITLE>
<LINK rel=stylesheet type=text/css href=site/style.css>
<?php include("site/meta.txt"); ?>
<STYLE type="text/css">
DT {font-weight:bold;}
</STYLE>
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
Pok&eacute;mon TCG Official Rulebook
</DIV>
<DIV class=subhead>
<?php
$title=file("p3/rules/title.txt");
if(isset($section)) {
	$secnum=$section-1;
	echo $title[$secnum];
;} ?>
</DIV>
<?php if(isset($section)) { ?><P><TABLE width=100% border=0 cellpadding=0 cellspacing=0><TR><TD width=33% align=left>
<?php
$sectionprev=$section-1;
$secnumprev=$sectionprev-1;
if($sectionprev>0) { ?><A href="p3_rulebook.php?section=<?= $sectionprev; ?>">&lt; <?= $title[$secnumprev]; ?></A>
<?php ;} ?></TD><TD width=34% align=center><A href="p3_rulebook.php">Section Index</A></TD><TD width=33% align=right>
<?php
$sectionnext=$section+1;
$secnumnext=$sectionnext-1;
if($sectionnext<count($title)+1) { ?><A href="p3_rulebook.php?section=<?= $sectionnext; ?>"><?= $title[$secnumnext]; ?> &gt;</A>
<?php ;} ?></TD></TR></TABLE><?php ;} ?>
<P>
<?php
if(!isset($section)) {
	echo "<OL>";
	for($x=0;$x<count($title);$x++) { ?>
<LI><A href="p3_rulebook.php?section=<?= $x+1; ?>"><?= $title[$x]; ?></A>
<?php
;}
echo "</OL>";
;}
else {include("p3/rules/$section.txt");}
?>
<?php if(isset($section)) { ?><P><TABLE width=100% border=0 cellpadding=0 cellspacing=0><TR><TD width=33% align=left>
<?php
$sectionprev=$section-1;
$secnumprev=$sectionprev-1;
if($sectionprev>0) { ?><A href="p3_rulebook.php?section=<?= $sectionprev; ?>">&lt; <?= $title[$secnumprev]; ?></A>
<?php ;} ?></TD><TD width=34% align=center><A href="p3_rulebook.php">Section Index</A></TD><TD width=33% align=right>
<?php
$sectionnext=$section+1;
$secnumnext=$sectionnext-1;
if($sectionnext<count($title)+1) { ?><A href="p3_rulebook.php?section=<?= $sectionnext; ?>"><?= $title[$secnumnext]; ?> &gt;</A>
<?php ;} ?></TD></TR></TABLE><?php ;} ?>
<P>
Text from the Pok&eacute;mon-e Trading Card Game EX Team Magma vs. Team Aqua Rulebook, &copy;2004 Pok&eacute;mon.
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
