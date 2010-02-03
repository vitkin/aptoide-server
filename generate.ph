#!/usr/bin/php -q
<?
// Copyright (C) 2009  Roberto Jacinto
// roberto.jacinto@caixamagica.com
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

/***************************************/
/*
 * Directory where apk's are stored
 * Configuration changes go here! 
 */
$DIR = "</your/repo/path/here/>";
$ICON_DIR_OUT = "icons/";

/****************************************/
$ICON_DIR = $DIR.$ICON_DIR_OUT;
$xml_path = $DIR."info.xml";

exec('rm ' . $DIR . '*.xml');
exec('rm -rf ' . $ICON_DIR);
exec('mkdir ' . $ICON_DIR);
exec('ls ' . $DIR, $dump);
$dom = new DomDocument("1.0","UTF-8");
$root = $dom->createElement('apklst');
$root = $dom->appendChild($root);

foreach ($dump as $apk) {

	echo "\nAPK: " . $apk;

	if(ends($apk, "apk")){

	$rtrn = getInfo($apk);

	if($rtrn["icon"] == ""){
		$icon = "";
	}else{
		$icon = getIcon($DIR.'/'.$apk, $rtrn["icon"], $rtrn["pkg"]);
	}

	echo "\nPackage (hasID): " . $rtrn["pkg"];
	echo "\nVersion: " . $rtrn["ver"];
	echo "\nVersion Code: " . $rtrn["vercode"];
	echo "\nName: " . $rtrn["name"];
	echo "\nIcon: " . $rtrn["icon"];
	echo "\nIcon(L): " . $icon;
	echo "\nDate: " . $rtrn["date"];
	echo "\n ======================== \n";
	
	$occ = $dom->createElement('package');
	$occ = $root->appendChild($occ);

	$child = $dom->createElement('name');
	$child = $occ->appendChild($child);
	$value = $dom->createTextNode($rtrn["name"]);
	$value = $child->appendChild($value);
       
	$child = $dom->createElement('path');
        $child = $occ->appendChild($child);
        $value = $dom->createTextNode($apk);
        $value = $child->appendChild($value);

	$child = $dom->createElement('ver');
        $child = $occ->appendChild($child);
        $value = $dom->createTextNode($rtrn["ver"]);
        $value = $child->appendChild($value);

	$child = $dom->createElement('vercode');
        $child = $occ->appendChild($child);
        $value = $dom->createTextNode($rtrn["vercode"]);
        $value = $child->appendChild($value);

        $child = $dom->createElement('apkid');
        $child = $occ->appendChild($child);
        $value = $dom->createTextNode($rtrn["pkg"]);
	$value = $child->appendChild($value);
	
       	$child = $dom->createElement('icon');
        $child = $occ->appendChild($child);
        $value = $dom->createTextNode($icon);
	$value = $child->appendChild($value);

	$child = $dom->createElement('date');
        $child = $occ->appendChild($child);
        $value = $dom->createTextNode($rtrn["date"]);
	$value = $child->appendChild($value);
		
	}

}
$xml_string = $dom->saveXML();
$fp = @fopen($xml_path,'w');
if(!$fp) {
       die('Error cannot create XML file');
}
fwrite($fp,$xml_string);
fclose($fp);
echo "\nXML FILE SUCCESSFULLY CREATED!\n";

function getIcon($file, $icon, $apk){
	global $ICON_DIR;
	global $ICON_DIR_OUT;
	exec('unzip ' . $file . ' -d .tmp');
	exec('mv ./.tmp/'.$icon . ' ' . $ICON_DIR.$apk);
	exec('rm -rf ./.tmp');
	return($ICON_DIR_OUT.$apk); 
}


function getInfo($file){
	global $DIR;
	$send = array();
	exec("./aapt d badging " . $DIR . $file . "|grep application| cut -d\' -f2", $out);
	$send["name"] = implode("",$out);
	$out = "";
	exec("./aapt d badging " . $DIR . $file . "|grep application| cut -d\' -f4", $out);
	$send["icon"] = implode("",$out);
	$out = "";
	exec("./aapt d badging " . $DIR . $file . "|grep package| cut -d\' -f2", $out);
	$send["pkg"] = implode("",$out);
	$out = "";
	exec("./aapt d badging " . $DIR . $file . "|grep package| cut -d\' -f6", $out);
	$send["ver"] = implode("",$out);
	$out = "";
	exec("/srv/www/aptoide/aapt d badging " . $DIR . $file . "|grep package| cut -d\' -f4", $out);
	$send["vercode"] = implode("",$out);
	$out = "";
	exec("stat " .$DIR . $file . "|grep Change| cut -d ' ' -f2", $out);
	$send["date"] = implode("",$out);
	return($send);
}

function ends($string, $end){
	$len = strlen($end);
	$string_end = substr($string, strlen($string) - $len);
	return $string_end == $end;
}
?>
