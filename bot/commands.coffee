Q = require 'q'
channels = require './channels'
youtube = require './youtube'
fs = require 'fs'
path = require 'path'


module.exports =
    ping: 
        alias: ['ping']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            message.channel.send "pong"
            .then (data) ->
                defer.resolve data
            .catch (e) ->
                defer.reject e
            defer.promise
    play:
        alias: ['play', 'p']
        argc: 1
        call: (message, argv) ->
            defer = Q.defer()
            youtube argv[1]
            .then (playlist) ->
                c = channels message
                m = ""
                for track, i in playlist
                    c.add track.desc, track.reader
                    if i < 10
                        m += track.desc + "\n"
                message.channel.send m
                defer.resolve {}
            .catch (e) ->
                defer.reject e
            defer.promise
    clear:
        alias: ['clear', 'c']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            c = channels message.member.voice.guild.id, message.member.voice.channelId, message.member.voice.guild.voiceAdapterCreator
            c.clear()
            defer.resolve {}
            defer.promise
    next:
        alias: ['n', 'next', 's', 'skip']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            c = channels message.member.voice.guild.id, message.member.voice.channelId, message.member.voice.guild.voiceAdapterCreator
            c.next()
            defer.resolve {}
            defer.promise
