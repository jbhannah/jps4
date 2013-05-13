<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
include("db/index.txt");
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : pok&eacute;mon : tcg : card view</TITLE>
<LINK rel=stylesheet type=text/css href=../site/style.css>
</HEAD>
<BODY>
<CENTER>
<?php include("db/$set/$card.txt"); ?>
<IMG src="pics/<?= $set; ?>/<?= $card; ?>.jpg" alt="<?= $name; ?> : <?= $setlist[$set]['name']; ?>"><BR>
<A href="javascript:window.close()">Close Window</A>
</CENTER>
</BODY>
</HTML>