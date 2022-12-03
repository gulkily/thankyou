#!/usr/bin/perl -T
#
# _dev_archive.pl
# 
# archive current data/user state into .tar.gz file
#   html/txt/
#   html/image/
#   log/access.log
#   html/chain.log
#   config/
# rebuild basic frontend
#
#

print "========================================\n";
print "About to archive content and reset site!\n";
print "========================================\n";
print "You have 3 seconds to press Ctrl + C ...\n";
print "========================================\n";
print "  NO DATA ?\n";
print "   (..)   ATTENTION! \n";
print "   < /   Improper use may cause data loss.\n";
print "   ^/ \n";
print "========================================\n";
print "3...\n";
sleep 1;
print "2...\n";
sleep 2;
print "1...\n";
sleep 3;

use strict;
use 5.010;
use warnings;
use utf8;

sub GetYes { # $message, $defaultYes ; print $message, and get Y response from the user
	# $message is printed to output
	# $defaultYes true:  allows pressing enter
	# $defaultYes false: user must type Y or y

	my $message = shift;
	my $defaultYes = shift;

	if ($message) {
		chomp $message;
	}
	$defaultYes = ($defaultYes ? 1 : 0);

	print "=" x length($message);
	print "\n";
	print $message;
	print "\n";
	print "=" x length($message);
	print "\n";
	if ($defaultYes) {
		print ' [Y] ';
	} else {
		print " Enter 'Y' to proceed: ";
	}

	my $input = <STDIN>;
	chomp $input;

	if ($input eq 'Y' || $input eq 'y' || ($defaultYes && $input eq '')) {
		print "====================================================\n";
		print "====== Thank you for your vote of confidence! ======\n";
		print "====================================================\n";

		return 1;
	}
	return 0;
}

if (!GetYes('Archive content and reset website?')) {
	exit;
}

$ENV{PATH}="/bin:/usr/bin";

use Cwd qw(cwd);
use File::Copy qw(copy);

my $date = '';
if (`date +%s` =~ m/^([0-9]{10})/) { #good for a few years
	$date = $1;
} else {
	die "\$date should be a decimal number, but it's actually $date";
}

my $SCRIPTDIR = cwd();
chomp $SCRIPTDIR;
if ($SCRIPTDIR =~ m/^([^\s]+)$/) { #security #taint
	$SCRIPTDIR = $1;
} else {
	print "sanity check failed #\n";
	exit;
}

my $ARCHIVEDIR = $SCRIPTDIR . '/archive';

if (!-e $ARCHIVEDIR) {
	mkdir($ARCHIVEDIR);
}

my $ARCHIVE_DATE_DIR = '';

if (-d $ARCHIVEDIR) {
	while (-e "$ARCHIVEDIR/$date") {
		$date++;
	}
	$ARCHIVE_DATE_DIR = "$ARCHIVEDIR/$date";
	mkdir("$ARCHIVE_DATE_DIR");
}

my $CACHEDIR = $SCRIPTDIR . '/cache/b';
my $CONFIGDIR = $SCRIPTDIR . '/config';
my $LOGDIR = $SCRIPTDIR . '/log';
my $HTMLDIR = $SCRIPTDIR . '/html';

my $TXTDIR = $HTMLDIR . '/txt';
my $IMAGEDIR = $HTMLDIR . '/image';

{
	print("rename($TXTDIR, $ARCHIVE_DATE_DIR/txt)\n");
	rename("$TXTDIR", "$ARCHIVE_DATE_DIR/txt");

	print("rename($IMAGEDIR, $ARCHIVE_DATE_DIR/image)\n");
	rename("$IMAGEDIR", "$ARCHIVE_DATE_DIR/image");

	if (0) {
		# this needs to happen after txt and image above
		#print("rename($HTMLDIR, $ARCHIVE_DATE_DIR/html)\n");
		#rename("$HTMLDIR", "$ARCHIVE_DATE_DIR/html");
		#
		# print("rename($LOGDIR, $ARCHIVE_DATE_DIR/log)\n");
		# rename("$LOGDIR", "$ARCHIVE_DATE_DIR/log");
	} else {
		print("mkdir($ARCHIVE_DATE_DIR/html)\n");
		mkdir("$ARCHIVE_DATE_DIR/html");
	}

	print("copy($HTMLDIR/chain.log, $ARCHIVE_DATE_DIR/html/chain.log)\n");
	copy("$HTMLDIR/chain.log", "$ARCHIVE_DATE_DIR/html/chain.log");
	unlink("$HTMLDIR/chain.log");

	print("copy($CACHEDIR/index.sqlite3, $ARCHIVE_DATE_DIR/index.sqlite3)\n");
	copy("$CACHEDIR/index.sqlite3", "$ARCHIVE_DATE_DIR/index.sqlite3");
	#unlink("$HTMLDIR/chain.log");

	if (-e "$LOGDIR/access.log" && !-l "$LOGDIR/access.log") {
		print("copy($LOGDIR/access.log, $ARCHIVE_DATE_DIR/html/access.log)\n");
		copy("$LOGDIR/access.log", "$ARCHIVE_DATE_DIR/html/access.log");
		unlink("$LOGDIR/access.log");
	}

	print("cp -rv \"$CONFIGDIR\" \"$ARCHIVE_DATE_DIR/config\"\n");
	system("cp -rv \"$CONFIGDIR\" \"$ARCHIVE_DATE_DIR/config\""); #todo not fast enough

	print("mkdir($HTMLDIR)\n");
	mkdir("$HTMLDIR");

	print("mkdir($TXTDIR)\n");
	mkdir("$TXTDIR");


	my $pwd = `pwd`; chomp $pwd;
	my $archiveDirRelative = $ARCHIVE_DATE_DIR;
	if (index($archiveDirRelative . '/', $pwd) == 0 && length($archiveDirRelative) > length($pwd)) {
		$archiveDirRelative = substr($archiveDirRelative, length($pwd . '/'));
	}

	if ($archiveDirRelative =~ m/^([^\s]+)$/) { #security #taint
		$archiveDirRelative = $1;
	} else {
		print ('sanity check failed on $archiveDirRelative' . "\n");
		exit;
	}

	print("tar -acf $archiveDirRelative.tar.gz $archiveDirRelative\n");
	system("tar -acf $archiveDirRelative.tar.gz $archiveDirRelative");

	print("rm -rf $ARCHIVE_DATE_DIR\n");
	system("rm -rf $ARCHIVE_DATE_DIR");

	print("echo \"Notice: Content was archived by the operator at $date\" > $TXTDIR/archived_$date\.txt\n");
	system("echo \"Notice: Content was archived by the operator at $date\" > $TXTDIR/archived_$date\.txt");

	print("=================\n");
	print("Archive finished!\n");
	print("=================\n");

	#system('echo "\n"');
	#system('echo "Running ./_dev_clean_ALL.sh in 3..."; sleep 2');
	#system('echo "2..."; sleep 2');
	#system('echo "1..."; sleep 2');

	system('./clean.sh');

	system('./build.sh');

	print("=============================\n");
	print("Archive and Rebuild finished!\n");
	print("=============================\n");


}

1;
