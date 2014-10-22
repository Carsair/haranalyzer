# Purpose
This is a script for processing ".har" files which can be downloaded from the Chrome inspector https://developer.chrome.com/devtools/docs/network#saving_network_data.
There are tools for visualizing this data: http://ericduran.github.io/chromeHAR/ , https://toolbox.googleapps.com/apps/har_analyzer/ , but while they may provide a visual representation, I created this script to slice the data the way we want to.  It probably will not be useful for the majority of people.  It is best suited to seeing which requests to external servers take the most time and which domains make the most requests.

# Usage

To return the basic information about slow requests:

  $ coffee harprocess.coffee

To specify the maximum acceptable "wait" for requests or the maximum total "time" for requests, use command line arguments like this:

  $ coffee harprocess.coffee --max-wait 200 --max-time 400

which will slice requests that have wait longer than 200ms or total time longer than 400ms.  (These are also the default values if none are provided)

To show requesters (summing number of requests, does not use --max-wait or --max-time parameters), use the --requesters flag:

  $ coffee harprocess.coffee --requesters

By default, the script will use any .har files in the current directory.  To modify this, use the --file-re flag:

  $ coffee harprocess.coffee --file-re network-data-1

which will only perform calculations using files that match the provided regex (in this case "network-data-1").

You can also provide the verbose parameter to print timing data on each request.

  $ coffee harprocess.coffee --verbose

Use this sparingly, as it is basically useless to the human eye, especially if you iterate over a large set of .har files.

# Analyzing Results

In general, a high number of requests violating the max wait time shows a server slow to respond; try: "--max-wait 150 --max-time 2000" to single out these requests.

A high number of requests violating the max time but not max wait time indicates problems with DNS resolution, large file transfer size, or large network latency; try "--max-wait 150 --max-time 150" or similar to single out these requests.  Use the --verbose and --file-re flag to diagnose the timing data for individual requests for a page load.  That timing data has stages "blocked", "dns", "send", "receive" among others, which can be useful to inspect.
