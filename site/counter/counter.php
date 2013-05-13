<?php
//Copyright Cgixp Team
//http://www.cgixp.tk
extract($HTTP_GET_VARS);
extract($HTTP_POST_VARS);
$ip = getenv(REMOTE_ADDR);
$date = date("d");
$today = date("d:M:Y");
$user = file("counter.txt");
$lis = 0;
$log_file = "log.txt";
$log_lenght = 30;
$max_file_size = 3;
$file_size= filesize($log_file);
$log_size =	$file_size/1024;
if ($action!="stats"){
$qwe = file("raw.txt");
for($b = 0; $b <sizeof($qwe);$b++){
$last = explode("|",$qwe[$b]);
}
$last1file = fopen ("raw.txt", "w");
fwrite ($last1file, $last[0]+1);
fclose ($last1file);
if ($log_size > $max_file_size) {
$filename = "log.txt"; 
$fd = fopen ($filename, "r"); 
$stuff = fread ($fd, filesize($filename)); 
fclose ($fd);
$last_file = fopen ("temp.txt", "a+");
fwrite ($last_file, $stuff);
fclose($last_file);
$fz = fopen ("log.txt", "w");
fwrite ($fz, "");
fclose($fz);
$filename1 = "temp.txt"; 
$fd1 = fopen ($filename1, "r"); 
$stuff1 = fread ($fd1, filesize($filename1)-1024); 
fclose ($fd1);
$fm = fopen ("log.txt", "a+");
fwrite ($fm, $stuff1);
fclose ($fm);
$fy = fopen ("temp.txt", "w");
fwrite ($fy, "");
fclose($fy);
}
for($x=0;$x<sizeof($user);$x++) {
$temp = explode(";",$user[$x]);
$opp[$x] = "$temp[0];$temp[1];$temp[2];";
$such = strstr($temp[0],$ip.".6978521");
if($such) {
$list[$lis] = $opp[$x];
$lis++; 
}
if($temp[1] != $date) {
$fp = fopen ("log.txt", "a+");
$fw = fwrite ($fp, sizeof($user));
$fw = fwrite ($fp, ";");
$fw = fwrite ($fp, $temp[2]);
$fw = fwrite ($fp, ";");
$fw = fwrite ($fp, "$last[0]");
$fw = fwrite ($fp, ";");
$fw = fwrite ($fp, "\n");
fclose ($fp);
$last2file = fopen ("raw.txt", "w");
$mm =  fwrite ($last2file, "1");
fclose ($last2file);
$fq = fopen ("counter.txt", "w");
$fy = fwrite ($fq, $ip);
$fy = fwrite ($fq, ".6978521");
$fy = fwrite ($fq, ";");
$fy = fwrite ($fq, $date);
$fy = fwrite ($fq, ";");
$fy = fwrite ($fq, $today);
$fy = fwrite ($fq, ";");
$fy = fwrite ($fq, "\n");
fclose ($fq);
break;		
}
}
if(sizeof($list) != "0") {
}else{
$fp = fopen ("counter.txt", "a+");
$fw = fwrite ($fp, $ip);
$fw = fwrite ($fp, ".6978521");
$fw = fwrite ($fp, ";");
$fw = fwrite ($fp, $date);
$fw = fwrite ($fp, ";");
$fw = fwrite ($fp, $today);
$fw = fwrite ($fp, ";");
$fw = fwrite ($fp, "\n");
fclose ($fp);
}
}
if($action == "stats"){
$db_file = "log.txt";
$latest_max = 30;
$lines = file($db_file);
$a = count($lines)-1;
$u = $a - $latest_max;
$unique = file("counter.txt");
$ut = count($unique);
$file_size= filesize("log.txt");
$log_size =	$file_size/1024;
$raw = "raw.txt"; 
$fn = fopen ($raw, "r"); 
$puff = fread ($fn, filesize($raw)); 
fclose ($fn);
echo "<font face=arial size=2>Unique Hits Today: <B>$ut</B><BR> Raw Hits Today: <B>$puff </B></font><HR color=#CCCCCC>";
?>
<STYLE type=text/css>
TD {
COLOR: #000000; FONT-FAMILY: Verdana, Helvetica, Arial; FONT-SIZE: 13px
}
</STYLE>
<font face=arial size=2><U><B>Statistics of last 30 days</B></U> (Days with 0 visits are not shown)<table border=1 cellspacing=0 bordercolor=#00000 width=50% bgcolor=#AFC6DB><td border=1 width=15%><B>Day</B></td><td width=15%  border=1><B>Unique Visits</B></td><td border=1 width=15%><B>Raw Visits</B></td>
<?php
for($i = $a; $i >= $u ;$i--){
$temp = explode(";",$lines[$i]);
echo "<tr><td border=1 width=15%>$temp[1]</td><td width=15% border=1>$temp[0]</td><td width=15% border=1>$temp[2]</td>";
}
?>
</table></font><BR><FONT face=arial SIZE="2" COLOR="#00000">Powered By:<A HREF="http://www.cgixp.tk">Unique Visitors Counter</A></FONT>
<?php
}
?> 