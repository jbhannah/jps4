<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=rand(1,2);}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : about jps4</TITLE>
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
About jps4
</DIV>
<DIV class=subhead>About JB</DIV>
<IMG src="site/img/_jb_.gif" alt="JB" align=left>
<B>Full Name</B> : Jesse Bruce Hannah<BR>
<B>Age</B> : 15<BR>
<B>Birthdate</B> : 20 March 1989<BR>
<B>E-mail</B> : <A href="donotsendmailto:jb@jps.hostultra.com">jb@jps.hostultra.com</A><BR>
<B>AIM</B> : jb1489 <B>MSN</B> : gymleaderzap@msn.com <B>Yahoo!</B> : gymleaderzap<BR>
<B>Hobbies</B> : Web design/programming, video games, DDR, e-mail, violin, web comics<BR>
<B>Favorite bands</B> : <A href="http://www.linkinpark.com/" target=_blank>Linkin Park</A>, <A href="http://www.afireinside.net/" target=_blank>AFI</A>, <A href="http://www.theataris.com/" target=_blank>The Ataris</A>, <A href="http://www.evanescence.com/" target=_blank>Evanescence</A>, <A href="http://www.simpleplan.com/" target=_blank>Simple Plan</A>, Eiffel 65, <A href="http://www.holdenrock.com/" target=_blank>Holden</A>, U2, Savage Garden, Creed<BR>
<B>Favorite foods</B> : (Almost) anything caffeinated (Dr. Pepper and Vanilla Coke especially), shrimp ramen<BR>
<B>Favorite web sites</B> : <A href="http://www.lifeisleet.com/" target=_blank>l1f3 !$ l33t</A>, <A href="http://www.megatokyo.com/" target=_blank>MegaTokyo</A>, <A href="http://www.questionablecontent.net/" target=_blank>Questionable Content</A>, <A href="http://www.ddruk.com/" target=_blank>DDRUK</A>, <A href="http://www.thinkgeek.com/" target=_blank>ThinkGeek</A>, <A href="http://www.bungie.net/" target=_blank>Bungie</A>, <A href="http://www.10kcommotion.com/" target=_blank>The Tenkay Commotion</A><BR>
<B>Favorite Quote</B> : "Dude, you're so hot for her it's kinda uncomfortable to sit near you... No offense, scoot over." &mdash;<A href="http://www.10kcommotion.com/" target=_blank>The Tenkay Commotion</A>
<BR><BR>
<DIV class=subhead>History of jps4</DIV>
JB first learned to write web pages in HTML from his mom in 2000, and caught on quickly. In January 2001, he uploaded his first Pok&eacute;mon site: "Jesse's Ultimate Fan-Based Pok&eacute;mon Website" on <A href="http://www.angelfire.com/" target=_blank>Angelfire</A>; a simple site with reviews of some of his favorite cards, Pok&eacute;mon news updates, and some anime and video game information. One year and several experiments later, he released jessespokesite v2.0, a frames-based site and the first to carry the jessespokesite name (although it had been a nickname under the site's first version). Content-wise, it was little different from the original site, but still had more content and was more thoroughly planned and better organized and designed.
<P>
In May 2003, jessespok&eacute;site&sup3; was uploaded as a complete redesign of v2.0, and though it was never completed, it was far more so than either of its predecessors. It was the first of the three to make an attempt at becoming a major, mainstream Pok&eacute;mon information source and fan site; and, temporarily, it succeeded. It had some video game hints, a thoroughly researched news section, TCG set lists and Card of the Week, an anime episode list complete up to season six with some episode and movie reviews and season summaries, and even (somewhat feeble) attempts at guest interaction, via an online trading card game league, a message board, and fan art and ficiton sections.
<P>
For a time, jps&sup3; (as it was called for short) averaged nearly 100 hits per day, and in July 2003 recorded more than 2400 hits for the month. But it didn't last; over time, school and other matters prevented JB from updating the site as regularly as he had, and the hit count fell. Also about that time, in late 2003, JB also concieved the idea of what was then called "The jessespok&eacute;site Network", which he aspired to turn into not merely a Pok&eacute;mon site, but a major web portal. He recruited two of his friends, Cody and Zach, to help him, but the project never made it past the planning stages. However, it had rekindled his interest in web design, and for the project he had started to learn PHP, which he began to program web pages in regularly.
<P>
Several months later, he and his friend Ryan began the web comic <A href="http://www.lifeisleet.com/" target="_blank">l1f3 !$ l33t</A>, purchased a domain name and server space on <A href="http://www.hostultra.com/" target=_blank>Host Ultra</A>, and uploaded it, in June 2004. While he was working on l1f3 !$ l33t, JB also created the design for jps4 and began development on it based loosely on jps&sup3;, with the major difference being the inclusion of Duel Masters as a subject of the site. He finally uploaded it in October 2004, but with only a few pages, and he is currently working on completing the content of the site, while at the same time managing it as a normal informational site.
<P>
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
