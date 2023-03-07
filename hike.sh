#!/bin/bash

#if [ $1 = sql ]
#	then
#		#sqlite3 cache/b/index.sqlite3 "${@:2}"
#		#sqlite3 cache/b/index.sqlite3 "${*:2}"
#		exit
#fi

#todo sanity checks for git and cut
echo =================
echo Rejoice always
echo Pray without ceasing
echo Give thanks in all circumstances
echo =================
echo "thankyou" `git rev-parse HEAD | cut -c 1-8`
echo =================

#Matthew 5:37
#Let what you say be simply ‘Yes’ or ‘No’; anything more than this comes from evil.

alias hike='./hike.sh'
alias clean='hike clean'
alias build='hike build'

if [ ! $1 ]
	then
		set 1=help
fi

if [ $1 = set ]
	then
		default/template/perl/script/set.pl $2 $3
		exit
fi

if [ $1 = test ]
	then
		echo testing 1 2 3
fi

if [ $1 = stats ]
	then
		echo text files: `find html/txt -type f -name '*.txt' | wc -l`
fi

if [ $1 = status ]
	then
		ps aux | grep lighttpd
fi

if [ $1 = version ]
	then
		sqlite3 --version
		git --version
		perl --version
		php --version
		bash --version
		#perl -e 'print "Perl " . $^V . "\n"'
		echo '==='
		git rev-parse HEAD
fi

if [ $1 = build ]
	then
		time ./build.sh
fi

if [ $1 = clean ]
	then
		time ./clean.sh
fi

if [ $1 = rebuild ]
	then
		time ./rebuild.sh
fi

if [ $1 = index ]
	then
		time ./index.pl --chain
		sleep 1
		time ./index.pl --all
fi

if [ $1 = update ]
	then
		perl -T default/template/perl/script/template_refresh.pl
		./build.sh
fi

if [ $1 = frontend ]
	then
		perl -T default/template/perl/script/template_refresh.pl
		default/template/sh/_dev_clean_html.sh
		time ./config/template/perl/pages.pl --system
fi

if [ $1 = pages ]
  then
    perl -T ./config/template/perl/pages.pl --all
    # should it be config? #todo
fi

if [ $1 = page ]
	then
		time ./config/template/perl/pages.pl -M $2
fi

if [ $1 = restart ]
	then
		killall lighttpd
		time config/template/perl/server_local_lighttpd.pl
fi

if [ $1 = start ] # hike start
	then
		if [ ! -e  config/template/perl/server_local_lighttpd.pl ]
			then
				/bin/sh ./build.sh
		fi
		echo 1 > config/setting/admin/lighttpd/server_started
		time config/template/perl/server_local_lighttpd.pl
		rm config/setting/admin/lighttpd/server_started
fi

if [ $1 = stop ]
	then
		killall -v lighttpd
fi

if [ $1 = alog ]
	then
		time ./default/template/perl/script/access_log_read.pl --all
		echo About to index and build pages...
		sleep 3
		./index.pl --all
		./config/template/perl/pages.pl --all
fi

if [ $1 = db ]
	then
		sqlite3 -echo -cmd ".headers on" -cmd ".timeout 500" -cmd ".mode column" -cmd ".tables" cache/b/index.sqlite3
fi

if [ $1 = guidb ]
	then
		echo 'Opening database browser...'
		sqlitebrowser cache/b/index.sqlite3
fi

if [ $1 = sweep ]
	then
		time ./index.pl --sweep
fi

if [ $1 = flush ]
	then
		time ./default/template/sh/flush_votes.sh
fi

if [ $1 = open ]
	then
		time ./default/template/perl/browser_open.pl
		#todo reduce hard-coding
fi

if [ $1 = refresh ]
	then
		#time ./default/template/perl/browser_open.pl
		time ./default/template/perl/_dev_refresh.pl
		#todo reduce hard-coding
fi

if [ $1 = archive ]
	then
		time ./default/template/perl/script/_dev_archive.pl
		sleep 1
		time ./index.pl --sweep
		time ./index.pl --all
		time ./index.pl --all
		./hike.sh frontend
fi

echo source hike.sh = enable these commands
echo hike clean = clean including templates
echo hike build = build base
echo hike start = start local server
echo hike archive = archive all content
echo hike help = see more commands

if [ $1 = help ]
	then
		echo hike index = reindex chain and data
		echo hike frontend = refresh frontend
		echo hike alog = import access log
		echo hike help = see more commands
		echo hike db = open sqlite3 command line
		echo hike guidb = open sqlitebrowser
		echo hike flush = flush unsigned votes
		echo hike sweep = sweep deleted items
		echo hike open = open browser
		echo hike rebuild = clean, build, and index
		echo hike test = testing 1 2 3
		echo hike version = show version
		echo hike refresh = refresh updated defaults
fi

