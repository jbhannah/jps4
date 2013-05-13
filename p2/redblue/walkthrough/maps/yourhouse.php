<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($floor)) {$floor="1";}
?>
<HTML>
<HEAD>
<TITLE>Your House</TITLE>
<LINK rel=stylesheet type=text/css href=../../../../site/style.css>
</HEAD>
<BODY>
Floor: <A href="yourhouse.php?floor=1">1</A> <A href="yourhouse.php?floor=2">2</A>
<CENTER>
<?php echo "<IMG src='../../img/maps/yourhouse/$floor.gif'>"; ?><BR>
<A href="javascript:window.close()">Close Window</A>
</CENTER>
</BODY>
</HTML>