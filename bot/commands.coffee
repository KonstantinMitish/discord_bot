Q = require 'q'

channels = require './channels'
youtube = require './streamers/youtube'
vk = require './streamers/vk'
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

    playnext:
        alias: ['playnext', 'pn']
        argc: 1
        call: (message, argv) ->
            defer = Q.defer()
            youtube argv[1]
            .then (playlist) ->
                c = channels.get message
                if !c
                    defer.resolve {}
                    return defer.promise
                c.addnext playlist.items
                c.play()
                defer.resolve {}
            .catch (e) ->
                defer.reject e
            defer.promise

    vk: 
        alias: ['vk']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            vk 123
            .then (res) ->
                defer.resolve res
            .catch (e) ->
                defer.reject e
            defer.promise
    clear:
        alias: ['clear', 'c', 'leave', 'stop']
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

    shuffle:
        alias: ['shuffle', 'random', 'ыргааду', 'shuffl', 'shuffel', 'shullfe', 'shuflle']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            c = channels.get message
            if !c
                defer.resolve {}
                return defer.promise
            c.shuffle()
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

    check:
        alias: ['debug_check']
        argc: 0
        call: (message, argv) ->
            defer = Q.defer()
            channels.check message.guildId
            defer.resolve {}
            defer.promise
        syscall: (guildId) ->
            channels.check guildId