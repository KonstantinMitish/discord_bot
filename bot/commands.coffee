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
                c = channels.get message
                if !c
                    defer.resolve {}
                    return defer.promise
                c.add playlist.items
                c.play()
                defer.resolve {}
            .catch (e) ->
                defer.reject e
            defer.promise
    clear:
        alias: ['clear', 'c']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            c = channels.get message
            if !c
                defer.resolve {}
                return defer.promise
            c.clear()
            defer.resolve {}
            defer.promise

    stop:
        alias: ['leave', 'stop']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            c = channels.get message
            if !c
                defer.resolve {}
                return defer.promise

            c.stop()
            channels.remove message
            defer.resolve {}
            defer.promise

    pause:
        alias: ['pause']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            c = channels.get message
            if !c
                defer.resolve {}
                return defer.promise
            c.pause()
            defer.resolve {}
            defer.promise

    unpause:
        alias: ['unpause']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            c = channels.get message
            if !c
                defer.resolve {}
                return defer.promise
            c.unpause()
            defer.resolve {}
            defer.promise

    next:
        alias: ['n', 'next', 's', 'skip']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            c = channels.get message
            if !c
                defer.resolve {}
                return defer.promise
            c.next()
            defer.resolve {}
            defer.promise
