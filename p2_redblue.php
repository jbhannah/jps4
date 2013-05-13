<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&#233;mon : pok&#233;mon : games : red &amp; blue/green</TITLE>
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
Pok&#233;mon Red &amp; Blue/Green : <?php include("p2/redblue/title.txt"); ?>
</DIV>
<A href="p2_redblue.php?page=index">Information</A> : <A href="p2_redblue.php?page=walkthrough">Walkthrough</A> : <A href="p2_redblue.php?page=cheats">Cheats</A>
<P>
<?php
if(!isset($page)) {$page="index";}
include("p2/redblue/$page.txt");
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
