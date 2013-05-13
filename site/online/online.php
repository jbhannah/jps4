<?php
	if(phpversion() >= 4.2) {
	 $DOCUMENT_ROOT = $_SERVER[DOCUMENT_ROOT];
	 $REQUEST_URI = $_SERVER[REQUEST_URI];
	 $REMOTE_ADDR = $_SERVER[REMOTE_ADDR];
	 $HTTP_HOST = $_SERVER[HTTP_HOST];
	}
 $REQUEST_URI = "http://".$HTTP_HOST.$REQUEST_URI;
	
	if(!$settings) {
	 include("site/online/settings.php");
	}
 $seconds = 60;
 $past = time()-$seconds;
 $now = time();


 $file = file($datafile);
$write = "$REMOTE_ADDR|$REQUEST_URI|$now|\n";
	for($i=0;$i<count($file);$i++){
	 list($ip,$url,$date,) = explode("|", $file[$i]);
		if($date > $past) {
			if($ip != $REMOTE_ADDR){
			 $write .= "$ip|$url|$date|\n";
			}
		}
	}
if($ofile = fopen($datafile,w)){
 fputs ($ofile, $write);
 fclose($ofile);
} else {
 echo "<font color=red>YOU NEED TO CHMOD $datafile TO 666 OR 777</font>";
}

 $count = count(file($datafile));
 $record = file($recordfile);
 $record = explode("``x",$record[0]);
	if($count > $record[0]){
		if($rfile = fopen($recordfile,w)){
		 $data = $count."``x".time();
		 fputs ($rfile, $data);
		 fclose($rfile);
		} else {
		 echo "<font color=red>YOU NEED TO CHMOD $recordfile TO 666 OR 777</font>";
		}
	}
	if($count > 1){
	 $visitors = str_replace("<online>","$count",$displayonline);
	} else {
	 $visitors = str_replace("<online>","$count",$display1online);
	}
echo ("$visitors");
?>