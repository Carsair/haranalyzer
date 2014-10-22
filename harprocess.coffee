_      = require "lodash"
Moment = require "moment"
url    = require "url"
path   = require "path"
fs     = require "fs"

showRequesters = false
isVerbose      = false
maxWaitAllowed = 200
maxTimeAllowed = 400
fileName       = null

RE_HAR         = /\.har$/

processHar = (fname) ->
  data       = JSON.parse(fs.readFileSync(fname, 'utf8'));

  entries    = data.log.entries
  offenders  = {}
  requesters = {}

  _.each entries, (val, idx) ->
    requester  = url.parse(val?.request?.url).hostname
    requesters[requester]  = 0 unless requesters[requester]?
    requesters[requester] += 1

    # Record "slow" requests.
    if val.timings.wait > maxWaitAllowed or val.time > maxTimeAllowed
      offender = requester
      offenders[offender]  = 0 unless offenders[offender]?
      offenders[offender] += 1

      # Print individual data
      if isVerbose
        console.log "***************************"
        console.log "Idx: ", idx
        console.log "URL: ", offender
        console.log "TIME  ", val.time
        console.log val?.timings
        console.log "^^^^^^^^^^^^^^^^^^^^^^^^^^^"

  return [requesters, offenders]

accumulateFiles = (files) ->
  totalOffenders  = {}
  totalRequesters = {}

  for file, idx in files
    [requesters, offenders] = processHar(file)

    # Keep track of requester counts.
    mergeElement totalRequesters, requesters

    # Keep track of offender counts.
    mergeElement totalOffenders, offenders

  # Sort and reverse.
  totalOffenders = _.sortBy(_.pairs(totalOffenders), (val, idx) ->
    val[1])
  totalRequesters = _.sortBy(_.pairs(totalRequesters), (val, idx) ->
    val[1])
  if process.argv.indexOf("--reverse") > -1
    totalOffenders  = totalOffenders.reverse()
    totalRequesters = totalRequesters.reverse()

  if showRequesters
    console.log "Requesters: \n", totalRequesters
  else
    console.log "Offenders: \n", totalOffenders

mergeElement = (list, elements) ->
  _.assign list, elements, (existingVal, newVal) ->
    if existingVal
      return existingVal + newVal
    else
      return newVal

main = ->
  showRequesters = process.argv.indexOf("--requesters") > -1
  isVerbose      = process.argv.indexOf("--verbose") > -1
  if (idx = process.argv.indexOf("--max-wait")) > -1
    maxWaitAllowed = process.argv[idx + 1]
  if (idx = process.argv.indexOf("--max-time")) > -1
    maxTimeAllowed = process.argv[idx + 1]
  if (idx = process.argv.indexOf("--file-re")) > -1
    fileRe = process.argv[idx + 1]

  # Extract .har files from current directory.
  files = _.filter fs.readdirSync(__dirname), (val, idx) ->
    if fileRe?
      return RegExp(fileRe).test val
    else
      return RE_HAR.test val

  accumulateFiles(files)


# Faux "main" method.
main()
