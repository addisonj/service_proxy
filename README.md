#ServiceProxy

###What is it?
A small wrapper around request (https://github.com/mikeal/request) that eases proxying services.

###Example

myApp proxies all calls to myService with the same URL scheme used except for all calls proxied to myService
have a "/service" prepended to the url.

```
#myApp.coffee

app.get '/service/resource', serviceController.proxy
app.post '/service/resource', serviceController.proxy


#serviceController.coffee
ServiceProxy = require 'service_proxy'
serviceProxy = new ServiceProxy {
  host: "localhost:4001"
  transformUrl: (host, path) ->
    return host + path.replace "/service", ""
  onError: (req, res) ->
    res.send err.message, 500
}

module.exports.proxy = (req, res) ->
  serviceProxy.proxy req, res, { requestOpts: {json: true} }
```

### API
Can either be used as a static method:

```
ServiceProxy.proxy req, res, opts
```

or as a class as in the example above

### Options
host: the hostname to proxy to (is not required, can be done in transformUrl)
transformUrl: a function that returns the route to the service, gets passed the host and request path
onError: a function to run when a pipe error occurs
requestOpts: a hash of options to be passed to request
