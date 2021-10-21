Q = require 'q'
fs = require 'fs'
ytdl = require 'ytdl-core'
ytpl = require 'ytpl'

loader = (url) -> () ->
    ytdl url, {
        filter: 'audioonly'
        quality: 'highestaudio'
    }

module.exports = (url) ->
    defer = Q.defer()
    ti_chego_namashupil = /^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))\/(playlist|watch)?(\?(v=|list=))?(((?!&)(\S))+)/gm
    groups = ti_chego_namashupil.exec url
    if !groups
        defer.reject "not a youtube url"
        return defer.promise
    type = groups[4] || "watch"
    id = groups[7]
    result = 
        items: []
    if type == 'playlist'
        ytpl(url, {limit: Infinity})
        .then (pl) ->
            result.title = pl.title
            result.url = pl.url
            result.image = pl.bestThumbnail.url
            for i in pl.items
                if !i.isPlayable
                    continue
                result.items.push {
                    title: i.title
                    url: i.url
                    duration: i.duration
                    image: i.bestThumbnail.url
                    reader: loader(i.url)
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