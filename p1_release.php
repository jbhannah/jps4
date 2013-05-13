<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : et cetera : release dates</TITLE>
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
Pok&eacute;mon Release Dates
</DIV>
<?php
include("p1/release.txt");
if(!isset($item)) { ?>
<P align=center>
<TABLE width=490 border=1>
<TR>
<TD width=330><B>Event</B></TD>
<TD width=80><B>Date</B></TD>
<TD width=80><B>Platform</B></TD>
</TR>
<?php
foreach($release as $n=>$r) { ?>
<TR><TD><A href="p1_release.php?item=<?= $n+1; ?>"><?= $r['event']; ?></A></TD><TD><?= $r['date']; ?></TD><TD><?= $r['platform']; ?></TD></TR>
<?php ;} ?>
</TABLE>
<P>
<?php ;}
else { ?>
<DIV class=subhead><?= $release[$item-1]['event']; ?></DIV>
<?php if(isset($release[$item-1]['img'])) { ?><IMG src="p1/release/<?= $release[$item-1]['img']; ?>" alt="<?= $release[$item-1]['name']; ?>" align=left><?php ;} ?>
<B>Release date :</B> <?= $release[$item-1]['date']; ?><BR>
<B>Platform :</B> <?= $release[$item-1]['platform']; ?>
<?php if(isset($release[$item-1]['notes'])) { ?><P><?= $release[$item-1]['notes']; ?><?php ;} ?>
<P><A href="p1_release.php">Pok&eacute;mon Release Dates</A>
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