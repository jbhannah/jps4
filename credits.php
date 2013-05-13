<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=rand(1,2);}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : credits &amp; legal</TITLE>
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
Credits &amp; Legal
</DIV>
<DIV class=subhead>Acknowledgements</DIV>
Thank you to my mom, for teaching me the tools of my trade and helping me out in the real world...to Rebecca; no matter how many times I say "I love you," it isn't enough...to Eric, Auston, Cody, and the rest of the gang at school, for putting up with my obsession and being my beta testers...to Rayne, for introducing me to Duel Masters; j00 r0x0r, k33p t3h l337 &lt;0m1x0r5 c0|\/|1n...to Madden, for having the most awesome computer lab in existence...and to all of j00 for checking out 71h5 133+ 5173. Arigato gozaimasu!
<P>
<DIV class=subhead>Credits</DIV>
Web site designed, built and maintained by <A href="mailto:jb@jps.hostultra.com">JB Hannah</A>. All pages were hand coded using Hypertext Markup Language (HTML), Hypertext Preprocessing (PHP), Cascading Style Sheets (CSS), and Javascript in <A href="http://www.macromedia.com/dreamweaver/" target=_blank>Macromedia Dreamweaver MX</A>. Images created using <A href="http://www.macromedia.com/fireworks/" target=_blank>Macromedia Fireworks MX</A>. GameBoy game screenshots taken using <A href="http://vba.ngemu.com/" target=_blank>VisualBoyAdvance</A> 1.7.2. JB's avatar image from <A href="http://www.10kcommotion.com/" target=_blank>The Tenkay Commotion</A>. Image font is Bring Tha Noize; default page font is Verdana. Forums powered by <A href="http://www.phpbb.com/" target=_blank>phpBB 2.0.11</A>. Site testing done using <A href="http://httpd.apache.org/" target=_blank>Apache 2.0.49</A>, <A href="http://www.php.net/" target=_blank>PHP 4.3.10</A>, <A href="http://www.microsoft.com/ie/" target=_blank>Microsoft Internet Explorer 6</A>, <A href="http://www.netscape.com/" target=_blank>Netscape 7.2</A>, <A href="http://www.mozilla.org/" target=_blank>Mozilla Firefox 1.0</A> and <A href="http://www.opera.com/" target=_blank>Opera 7.54</A> on <A href="http://www.microsoft.com/windows/" target=_blank>Microsoft Windows XP</A>. Hosted by <A href="http://www.hostultra.com/" target=_blank>HostUltra</A>. Site reccomended for viewing at 800&times;600 or higher screen resolution with 16-bit color depth or better in a Mozilla/5.0 compatible browser (Firefox 1.0, Netscape 6, MSIE 5.5 or higer).
<P>
<DIV class=subhead>Legal</DIV>
Pok&eacute;mon &copy;1995-2004 <A href="http://www.nintendo.com/" target=_blank>Nintendo</A>/Creatures Inc./GAME FREAK Inc., &copy;2003-2004 Pok&eacute;mon, &trade; Nintendo. Pok&eacute;mon Trading Card Game &copy;1998-2003 <A href="http://www.wizards.com/" target=_blank>Wizards of the Coast</A>, &copy;2003-2004 The Pok&eacute;mon Company. Duel Masters &trade; &amp; &copy;2004 Wizards of the Coast/ Shogakukan/Mitsui-Kids. Game Boy Advance &trade; Nintendo. Macromedia Dreamweaver MX &copy;1997-2002, Macromedia Fireworks MX &copy;1998-2002 <A href="http://www.macromedia.com/" target="_blank">Macromedia, Inc.</A> and its licensors. <A href="http://vba.ngemu.com/" target=_blank>VisualBoyAdvance</A> &copy;2001-2003 by Forgotton. phpBB &copy;2001-2004 <A href="http://www.phpbb.com/" target=_blank>phpBB Group</A>. Microsoft Internet Explorer &copy;1995-2001, Microsoft Windows &copy;1985-2001 <A href="http://www.microsoft.com/" target=_blank>Microsoft Corporation</A>. Netscape &copy;2000-2003 <A href="http://www.netscape.com/" target="_blank">Netscape Communications Corporation</A>. Mozilla Firefox &copy;1998-2004 Contributors, &trade; <A href="http://www.mozilla.org/" target=_blank>Mozilla Foundation</A>. Opera &copy;1995-2004 <A href="http://www.opera.com/" target="_blank">Opera Software ASA</A>. Bring Tha Noize &copy; <A href="http://www.pizzadude.dk/" target="_blank">Jakob Fischer</A>. The Tenkay Commotion &copy; <A href="http://www.yukonmakoto.com/" target=_blank>Yukon Makoto</A>.
<P>
jps4, jessespok&eacute;site, jps&sup3;, "more than just pok&eacute;mon" &trade; &amp; &copy;2001-2004 <A href="mailto:jb@jps.hostultra.com">JB Hannah</A>. All rights reserved.
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
