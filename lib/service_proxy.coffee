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

reqHasBody = (req) ->
  switch req.method.toLowerCase()
    when "get", "head", "del" then return true
    when "post", "put" then return false
    else throw new Error "I don't support HTTP #{req.method} method yet!"

buildRequestObject = (req, hasBody, options) ->
  {transformUrl, host, requestOpts} = options

  requestOpts = _.extend requestOpts, {
    url: transformUrl host, req.url
    method: req.method.toLowerCase()
  }

  requestOpts.body = req.body if hasBody

  return requestOpts

handleError = (pipe, onError, req, res) ->
  pipe.on "error", (exception) ->
    onError exception, req, res

proxy = (req, res, options) ->
  options = makeDefaults options

  hasBody = reqHasBody
  requestOpts = buildRequestObject req, hasBody, options

  pipe = null
  if hasBody
    pipe = req.pipe(request(requestOpts)).pipe res
  else 
    pipe = request(requestOpts).pipe res

  handleError pipe, options.onError, req, res
  
class ServiceProxy
  constructor: (options) ->
    # add the properties onto us
    @savedOpts = makeDefaults options

  proxy: (req, res, options) ->
    allOpts = _.extend @savedOpts, options
    proxy req, res, allOpts

ServiceProxy.proxy = proxy

module.exports = ServiceProxy
