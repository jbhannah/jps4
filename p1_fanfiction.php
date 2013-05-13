<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : et cetera : fan fiction library</TITLE>
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
<?php
if(!isset($story)) {echo "Fan Fiction Library";}
else {
	include("p1/fanfiction/$story/index.txt");
	echo $title;
}
?>
</DIV>
<?php
if(isset($story)) {
	if(!isset($chapter)) {$chapter=1;}
	echo "<DIV class=subhead>By <A href=\"mailto:",$author['email'],"\">",$author['name'],"</A></DIV><BR>";
	$x=1;
	if(file_exists("p1/fanfiction/$story/2.txt")) {
		echo "Chapter ";
		while(file_exists("p1/fanfiction/$story/$x.txt")) {
			if($x!=$chapter) {echo "<A href=\"p1_fanfiction.php?story=$story&chapter=$x\">$x</A> ";}
			else {echo $x;}
			$x++;
			if(file_exists("p1/fanfiction/$story/$x.txt")) {echo " : ";}
		;}
	;}
	echo "<P><DIV class=subhead>Chapter $chapter";
	$chtitle=$chapter-1;
	if(isset($chaptitle[$chtitle])) {echo " : $chaptitle[$chtitle]";}
	echo "</DIV>";
;}
else {echo "<BR>";}
?>
<?php
if(!isset($story)) {
	$i=1;
	while(file_exists("p1/fanfiction/$i/index.txt")) {
		include("p1/fanfiction/$i/index.txt"); ?>
<DIV class=subhead><A href="p1_fanfiction.php?story=<?= $i; ?>"><?= $title; ?></A></DIV>
<B>By <A href="mailto:<?= $author['email']; ?>"><?= $author['name']; ?></A></B><BR>
<?= $desc; ?><BR>
<B>Rated <?= $rating; ?> : <?php
$x=0;
while(file_exists("p1/fanfiction/$i/".($x+1).".txt")) {$x++;}
echo $x; ?> chapters : Uploaded <?= $upload; ?> : Updated <?= $update; ?></B>
<?php $i++;
	;}
;}
elseif(isset($story)) {
	if(!isset($chapter)) {$chapter="1";}
	include("p1/fanfiction/$story/$chapter.txt");
	echo "<P>";
	$x=1;
	if(file_exists("p1/fanfiction/$story/2.txt")) {
		echo "Chapter ";
		while(file_exists("p1/fanfiction/$story/$x.txt")) {
			if($x!=$chapter) {echo "<A href=\"p1_fanfiction.php?story=$story&chapter=$x\">$x</A> ";}
			else {echo $x;}
			$x++;
			if(file_exists("p1/fanfiction/$story/$x.txt")) {echo " : ";}
		;}
	;}
	echo "<BR><A href=\"p1_fanfiction_print.php?story=$story&chapter=$chapter\" target=_blank>Printable View</A> : <A href=\"p1_fanfiction.php\">Fan Fiction Library</A>";
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