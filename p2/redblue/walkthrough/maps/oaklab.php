<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($ver)) {$ver="1";}
?>
<HTML>
<HEAD>
<TITLE>Professor Oak's Laboratory</TITLE>
<LINK rel=stylesheet type=text/css href=../../../../site/style.css>
</HEAD>
<BODY>
<CENTER>
<?php echo "<IMG src='../../img/maps/oaklab/$ver.gif'>"; ?><BR>
<A href="javascript:window.close()">Close Window</A>
</CENTER>
</BODY>
</HTML>