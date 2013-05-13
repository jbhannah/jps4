<?php
$loc = parse_url($_SERVER[REQUEST_URI]);
parse_str($loc['query']);
if(!isset($menu)) {$menu=rand(1,2);}
?>
<HTML>
<HEAD>
<TITLE>jps4 beta : more than just pok&eacute;mon : users online</TITLE>
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
Users Online
</DIV>
<?php
	if(phpversion() >= 4.2) {
	 $DOCUMENT_ROOT = $_SERVER[DOCUMENT_ROOT];
	 $REMOTE_ADDR = $_SERVER[REMOTE_ADDR];
	 $REQUEST_URI = $_SERVER[REQUEST_URI];
	 $HTTP_HOST = $_SERVER[HTTP_HOST];
	}

	if(!$settings) {
	 include("site/online/settings.php");
	}
 $recordexe = file($recordfile);
 $record = explode("``x",$recordexe[0]);
 $recorddate = date("j F Y \@ g:i A",$record[1]);
?>
<?php include("site/online/online.php")?> at: http://<?php echo $HTTP_HOST?><BR>
Most users ever online was <?php echo $record[0]?> on <?php echo $recorddate?><BR><BR>
<CENTER>
<TABLE cellpadding="2" cellspacing="<?php echo $border?>" bgcolor="<?php echo $bordercolor?>" width="<?php echo $width?>" style="font-size: <?php echo $fontsize?>px">
 <TR bgcolor="<?php echo $tableheader?>" style="color: <?php echo $headfontcolor?>">
  <TD width="100">
	<B>Total</B> 
  </TD>
  <TD width="400">
	<B>Page</B>
  </TD>
 </TR>
<?php
 $onlineexe = file($datafile);
	for($b=0;$b<count($onlineexe);$b++){
	 $newcount=0;
	 $online=explode("|",$onlineexe[$b]);
		if(!strstr($array, $online[1]."||")){
		 $poo = file($datafile);
			for($a = 0; $a < count($poo); $a++){
			 $countpage = explode("|", $poo[$a]);
				if($online[1] == $countpage[1]){
				 $newcount++;
				}
			}
		 $array .= "$newcount||$online[1]||\n";
		}
	}
 $array = substr($array, 0,-1);
 $newarray = explode("\n",$array);
 rsort($newarray, SORT_NUMERIC);
	for($i = 0; $i < count($newarray); $i++) {
		$page=explode("||",$newarray[$i]);
		if($bgcolor==$tablerow1){
		 $bgcolor = $tablerow2;
		 $fontcolor = $fontcolor2;
		} else {
		 $bgcolor = $tablerow1;
		 $fontcolor = $fontcolor1;
		}
	 echo " <tr bgcolor='$bgcolor' style='color: $fontcolor'>\n";
	 echo "  <td>\n";
	 echo "	$page[0]\n";
	 echo "  </td>\n";
	 echo "  <td>\n";
	 echo "	<a href='$page[1]' target='$page[1]' style='color: $fontcolor'>$page[1]</a>\n";
	 echo "  </td>\n";
	 echo " </tr>\n";
	}
?>
</TABLE>
</CENTER>
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