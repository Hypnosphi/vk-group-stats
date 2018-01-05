https = require 'https'
apiUrl = ''
version = 5.62

# serialize a simple one-level JSON object
serialize = (object) ->
  pairs = for key, value of object
    "#{encodeURIComponent key}=#{encodeURIComponent value}"
  pairs.join '&'

makeParser = (cb = ->) ->
  (res) ->
    body = ''
    res.setEncoding 'utf8'
    res.on 'data', (chunk) ->
      body += chunk
    res.on 'end', (end) ->
      data = JSON.parse body
      throw data.error if data.error
      cb data.response

module.exports = (token) ->
  get: (method, params = {}, cb = ->) ->
    params.v ?= version
    params.access_token ?= token
    url = "https://api.vk.com/method/#{method}?#{serialize params}"
    https.get url, makeParser cb
  post: (method, params = {}, cb = ->) ->
    params.v ?= version
    params.access_token ?= token
    data = serialize params
    options =
      host: 'api.vk.com'
      path: "/method/#{method}"
      method: 'POST'
      headers:
        'Content-Type': 'application/x-www-form-urlencoded'
        'Content-Length': data.length
    req = https.request options, makeParser cb
    req.write data
    req.end()



      

