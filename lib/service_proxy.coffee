request = require 'request'
_ = require 'underscore'

defaultTransform = (host, url) ->
  return host + url

defaultError = (err, req, res) ->
  res.send "an error occurred", 500

makeDefaults = (options) ->
  options ?= {}
  return {
    transformUrl: options.transformUrl || defaultTransform
    onError: options.onError || defaultError
    host: options.host || "http://localhost"
    requestOpts: options.requestOpts || {}
  }

buildRequestObject = (req, options) ->
  {transformUrl, host, requestOpts} = options

  requestOpts = _.extend requestOpts, {
    url: transformUrl host, req.url
    method: req.method.toLowerCase()
  }

  requestOpts.body = req.body if req.body?

  return requestOpts

handleError = (pipe, onError, req, res) ->
  pipe.on "error", (exception) ->
    onError exception, req, res

proxy = (req, res, options) ->
  options = makeDefaults options

  requestOpts = buildRequestObject req, options

  remotePipe = req.pipe(request(requestOpts))
  handleError remotePipe, options.onError, req, res
  reqPipe = remotePipe.pipe res
  handleError reqPipe, options.onError, req, res

  
class ServiceProxy
  constructor: (options) ->
    # add the properties onto us
    @savedOpts = makeDefaults options

  proxy: (req, res, options) ->
    allOpts = _.extend @savedOpts, options
    proxy req, res, allOpts

ServiceProxy.proxy = proxy

module.exports = ServiceProxy
