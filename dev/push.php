<?php

// this script will copy the files to our server via my remote ssh mount.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

define('ProjectRoot','..');
define('ModDir', '/avorion-event-balance/data/scripts');
define('PatchDir', '/avorion-event-balance/patches');
define('RemoteDir','z:\home\avorion\steamcmd\avorion\data\scripts');

define('Files',[
	'/lib/dcc-event-balance/main.lua' => '/patch-lib-dcc-event-balance-main.diff',
	'/events/pirateattack.lua'        => '/patch-events-pirateattack.diff',
	'/player/eventscheduler.lua'      => '/patch-player-eventscheduler.diff'
]);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function
Pathify(String $Filepath):
String {
/*//
generate proper file paths for the os given that we are writing the code for
forward slashes in mind. seems to be needed for some windows commands.
//*/

	$Filepath = str_replace('%VERSION%','Version',$Filepath);

	return str_replace('/',DIRECTORY_SEPARATOR,$Filepath);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

$File;
$Patch;
$Command;

foreach(Files as $File => $Patch) {
	$Command = sprintf(
		'xcopy /R /Y %s %s',
		escapeshellarg(Pathify(ProjectRoot.ModDir.$File)),
		escapeshellarg(Pathify(RemoteDir.$File))
	);

	echo $Command, PHP_EOL;
	system($Command);
}
