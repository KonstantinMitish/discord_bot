Q = require 'q'
fs = require 'fs'
axios = require 'axios'

vk_token = process.env.VK_CODE
version = '5.116'
userAgent = 'KateMobileAndroid/56 lite-460 (Android 4.4.2; SDK 19; x86; unknown Android SDK built for x86; en)'

url_converter = (url) ->
  if !url.includes 'index.m3u8?'
    return url
  if url.includes '/audios/'
    return url.replace /^(.+?)\/[^/]+?\/audios\/([^/]+)\/.+$/, '$1/audios/$2.mp3'
  url.replace /^(.+?)\/(p[0-9]+)\/[^/]+?\/([^/]+)\/.+$/, '$1/$2/$3.mp3'

sendRequest = (path, opts) ->
    defer = Q.defer()
    urlParams = new URLSearchParams()
    urlParams.append 'v', version
    urlParams.append 'access_token', vk_token

    for key, value of opts
      urlParams.append key, value

    axios.get "https://api.vk.com/method/#{path}", {
        headers:
          'User-Agent': userAgent
        params: urlParams
    }
    .then (res) ->
        if res.data.error
            defer.reject res.data.error
            return
        if res.data.execute_errors
            defer.reject res.data.execute_errors
            return
        fs.writeFileSync "test.json", JSON.stringify res, null, 4
        defer.resolve res.data
    .catch (e) ->
        defer.reject e

    defer.promise

loader = (url) -> () ->
    return url

module.exports = (url) ->
    defer = Q.defer()
    opts = {
        owner_id: 20046621
        album_id: 22
        access_key: vk_token
    }

    code = "var playlistInfoAPI = API.audio.getPlaylistById({
      owner_id: #{opts.owner_id},
      playlist_id: #{opts.album_id}"

    if opts.access_key
        code += ",access_key: '#{opts.access_key}'"
    code += "
    });
    
    var playlistListAPI = API.audio.get({
      owner_id: #{opts.owner_id},
      playlist_id: #{opts.album_id}
      "
    if opts.access_key
        code += ",access_key: '#{opts.access_key}'"
    if opts.offset
        code += ",offset: '#{opts.offset}'"
    if opts.count
        code += ",count: '#{opts.count}'"
    code += "});
    
    var data = {
      'info': playlistInfoAPI,
      'list': playlistListAPI
    };
    return data;"
    fs.writeFileSync "code.js", code
    sendRequest 'execute', {code: code}
    .then (result) ->
        info = res.response.info
        list = res.response.list

        if list.items.length == 0
            defer.reject 'empty'
            return
        defer.resolve res
    .catch (e) ->
        defer.reject e
    defer.promise