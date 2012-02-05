# hs-gauges

hs-gauges is primarily a CLI for the [Gauges API](http://get.gaug.es/) but also exposes an API client library. 

Mostly, this is a project I am writing to learn [Haskell](http://www.haskell.org/haskellwiki/Haskell) (read: most of this code is likely abysmal). It is also very incomplete. Check out the [TODO](https://github.com/jrwest/hs-gauges/blob/master/TODO.md) for what is left to be done. 

This code has only been tested & run on OS X Lion running ghc 7.0.4 and cabal 1.10.2.0.

### Installation

For now, you will need the Haskell Platform (ghc and cabal specifically) to install hs-gauges. In the future I'll figure out some way to build and upload a binary -- and since I plan to learn how to build Homebrew packages maybe one of those two. 

You will also need to have [cURL](http://curl.haxx.se/) installed.

### Installing the Haskell Platform

If you are on OS X you can use [Homebrew](http://mxcl.github.com/homebrew/) to install the Haskell Platform

	$ brew install ghc

If you are not on OS X, or don't wish to use Homebrew, follow the instructions for you're platform [here](http://hackage.haskell.org/platform/)

Note: I have no idea if or how this code will work/perform on Windows.

### Installing hs-gauges

You can build hs-gauges using `cabal`, which is provided as part of the Haskell Platform. First clone the repository:

	$ git clone https://github.com/jrwest/hs-gauges.git
	$ cd hs-gauges

Then build the project:

	$ cabal build

If the build is successful, the CLI binary can be found at `dist/build/Gauges/gauges`. You can run it directly from there or you can move this binary to some directory that is on your `PATH`, it doesn't need any of the other files in the `dist/build/Gauges` directory.

## Usage 

`gauges` runs in 2 modes, a *Command Mode* which takes command-line parameters and *Interactive Mode* which will be entered when no command-line parameters are given. In *Interactive Mode* you can run multiple commands in a single session. To exit enter `quit` or `q`. All commands in both modes should take identical arguments. 

### Setup

The first time you run any `gauges` command (besides `help`) it will ask you for an API Token. You will need to create or reuse one which you can do from the [Gauges Account Settings Page](https://secure.gaug.es/dashboard#/account/clients).

### Listing All Gauges

The `list` command prints the names and current view/people tallies for all of your gauges.

	~ $  gauges                                                                                                                                                                                       	Using credential from /Users/jrwest/.gauges
	Welcome to Gauges Haskell CLI
	type "help" and press ENTER to see what's up

	> list
	Blog views: 123 people: 456
	Website views: 789 people: 123
	Admin views: 456 people: 123

In order to use any of the commands that take gauge names as arguments you must first run `list`. Because the Gauges API requires use of a String representation of a [BSON ObjectID](http://www.mongodb.org/display/DOCS/Object+IDs) for most of the interesting calls, `gauges` keeps a cache of gauge name, gauge id pairs. This cache is used to lookup information by gauge name (gauge names are case insensitive). If you run a command that takes a gauge name and it reports that the gauge is not found, try running `list` again. 

### Getting Help

Currently, the help section is woefully incomplete. See this README for more info. 

From the command-line you can either call the `help` command or pass in the `--help` and `-h` switches as the first command-line parameter. 

In *Interactive Mode* use the `help` command

### Displaying Traffic for a Gauge

The `traffic [GAUGE NAME] [--spark]` command lists the people/view tallies for the current month by day and in total. 

	$ gauges traffic blog
	...
	2012-02-01 | views: 123 people: 456
	2012-02-02 | views: 789 people: 123
	2012-02-03 | views: 456 people: 789
	2012-02-04 | views: 123 people: 456
	2012-02-05 | views: 789 people: 123

	total | views: 456 people: 789

## Spark Integration

Some `gauges` commands integrate with [Spark](https://github.com/holman/spark). In order to use the integration you will need it installed. 

The only command that currently supports this is `traffic` which optionally takes the `--spark` switch after the gauge name. 

	$  gauges traffic blog --spark                                                                                                                                                                  	...
	Showing spark for: views
	▁▂▅▆▆▁▃▅▅▃▆▇▇▄▅▇█▃▃▁▂▇█▇▁▃▂
	Showing spark for: people
	▁▂▅▆▆▁▃▅▅▃▆▇▇▄▅▇█▃▃▁▂▇█▇▁▃▂

