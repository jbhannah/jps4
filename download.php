<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=1;}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : et cetera : downloads</TITLE>
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
<?php
if(isset($file) and isset($scn) and isset($cat) and isset($ext)) {
	if(file_exists($file) && is_file($file)) {
		echo "<DIV class=head>Downloading /$cat/$file.$ext</DIV>";
		echo "Your download should begin automatically. If it doesn't, click <A href=\"ftp://anonymous@ftp.jps.hostultra.com/$scn/$cat/$file.$ext\">here</A>.";
		header("Cache-control: private");
		header("Content-Type: application/octet-stream");
		header("Content-Length: ".filesize("ftp://anonymous@ftp.jps.hostultra.com/$scn/$cat/$file.$ext"));
		header("Content-Disposition: filename=$file.$ext" . "%20");
		flush();
		$fd = fopen("ftp://anonymous@ftp.jps.hostultra.com/$scn/$cat/$file.$ext", "r");
		while(!feof($fd)) {
			echo fread($fd);
			flush();
			sleep(1);
		;}
		fclose($fd);
	;}
	else { ?>
<DIV class=head>
Download unavailable
</DIV>
Either the server is currently having difficulties, or the file you requested doesn't exist or is otherwise currently unavailable. Try going <A href="javascript:history.back(1)">back</A> to the previous page and trying a different link.
<?php
	;}
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
