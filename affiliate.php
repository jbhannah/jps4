<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=rand(1,2);}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : become an affiliate</TITLE>
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
Become an Affiliate
</DIV>
Most web sites have a minimum hits-per-day requirement for sites who want to affiliate with them; since I've only come close to meeting them only recently, and since I've never really understod the reasoning beind them, I've never believed in those. I'll let you affiliate with me if your site is related to Pok&eacute;mon or Duel Masters, has a decent amount of original content, and is updated reasonably often&mdash;all at my discretion&mdash;no matter how many hits your site gets. All your site needs besides that is a 88&times;32 or 88&times;16 banner and a visible place to display affiliates.
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