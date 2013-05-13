<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : et cetera : fan fiction library : printable view</TITLE>
</HEAD>
<STYLE type="text/css">
BODY {
	font-family: Verdana, Helvetica, Arial, sans-serif;
	font-size: 10px;
}
DIV.head {
	font-weight: bold;
	font-size: 16px;
}
DIV.subhead {
	font-weight: bold;
	font-size: 13px;
}
</STYLE>
<BODY>
<?php include("p1/fanfiction/$story/index.txt"); ?>
<DIV class="head">
<?php echo $title; ?>
</DIV>
<DIV class="subhead">
By <A href="donotsendmailto:<?= $author['email']; ?>"><?= $author['name']; ?></A><BR>
Chapter <?php echo $chapter;
if(isset($chaptitle[$chtitle])) {echo " : $chaptitle[$chtitle]";}
?>
</DIV>
<BR>
<?php include("p1/fanfiction/$story/$chapter.txt"); ?>
<P>
<A href="javascript:print()">Print</A> : <A href="javascript:window.close()">Close Window</A>
</BODY>
</HTML>
