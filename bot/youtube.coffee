Q = require 'q'
ytplaylist = require 'youtube-playlist-summary'
ytstream = require 'youtube-audio-stream'

ytconfig = 
    GOOGLE_API_KEY: process.env.GOOGLE_KEY
    PLAYLIST_ITEM_KEY: ['publishedAt', 'title', 'description', 'videoId', 'videoUrl']

loader = (url) -> () ->
    ytstream(url)

module.exports = (url) ->
    defer = Q.defer()
    ti_chego_namashupil = /^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))\/(playlist|watch)?(\?(v=|list=))?(((?!&)(\S))+)/gm
    groups = ti_chego_namashupil.exec url
    if !groups
        defer.reject "not a youtube url"
        return defer.promise
    type = groups[4] || "watch"
    id = groups[7]
    result = []
    if type == 'playlist'
        ps = new ytplaylist(ytconfig)
        ps.getPlaylistItems(id)
        .then (pl) ->
            m = ""
            for i in pl.items
                result.push {
                    desc: i.title
                    reader: loader(i.videoUrl)
                }
            defer.resolve result
        .catch (e) ->
            defer.reject e
        return defer.promise
    result.push {
        desc: "TODO"
        reader: loader(url)
    }
    defer.resolve result
    defer.promise