<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=rand(1,2);}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : links/link to jps4</TITLE>
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
Links/Link to jps4
</DIV>
<DIV class=subhead>
Links
</DIV>
<P>
<DIV class=subhead>
Link to jps4
</DIV>
If you want to put a link to jps4 on your site without becoming an affiliate, select one of the images below and copy the text in the box next to it.
<P>
<IMG src="site/img/link/jps4button1.gif" alt="jps4 : more than just pok&eacute;mon">88&times;16 (Donphan)<BR>
<TEXTAREA rows=3 cols=70 readonly><A href="http://jps.hostultra.com/" target=_blank><IMG src="http://jps.hostultra.com/site/img/link/jps4button1.gif" alt="jps4 : more than just pok&eacute;mon"></A></TEXTAREA>
<P>
<IMG src="site/img/link/jps4button2.gif" alt="jps4 : more than just pok&eacute;mon">88&times;16 (Shobu)<BR>
<TEXTAREA rows=3 cols=70 readonly><A href="http://jps.hostultra.com/" target=_blank><IMG src="http://jps.hostultra.com/site/img/link/jps4button2.gif" alt="jps4 : more than just pok&eacute;mon"></A></TEXTAREA>
<P>
<IMG src="site/img/link/jps4banner.gif" alt="jps4 : more than just pok&eacute;mon"><BR>468&times;60<BR>
<TEXTAREA rows=3 cols=70 readonly><A href="http://jps.hostultra.com/" target=_blank><IMG src="http://jps.hostultra.com/site/img/link/jps4banner.gif" alt="jps4 : more than just pok&eacute;mon"></A></TEXTAREA>
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
