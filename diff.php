<?php

// this script will generate all the diffs that can be used for patching the
// avorion source with these modifications.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

define('ProjectRoot','..');
define('StockDir', '/avorion-0.10.5/data/scripts');
define('ModDir', '/avorion-event-balance/data/scripts');
define('PatchDir', '/avorion-event-balance/patches');

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
		'diff -urN --strip-trailing-cr %s %s > %s',
		escapeshellarg(Pathify(ProjectRoot.StockDir.$File)),
		escapeshellarg(Pathify(ProjectRoot.ModDir.$File)),
		escapeshellarg(Pathify(ProjectRoot.PatchDir.$Patch))
	);

	echo $Command, PHP_EOL;
	system($Command);
}
