_ = require 'lodash'
fs = require 'fs'
discord = require 'discord.js'
player = require './player'

channels = {}

create = (player, channel) ->
    q = []
    isPlaying = false
    current = {}
    message = undefined
    getPlayer = () ->
        player

    add = (track) ->
        if !_.isArray track
            q.push track
            return
        q = q.concat track

    play = () ->
        if !isPlaying
            next()

    stop = () ->
        player.stop()

    pause = () ->
        player.pause()

    unpause = () ->
        player.unpause()

    clear = () ->
        q = []
        update()
        stop()

    next = () ->
        isPlaying = true
        n = q.shift()
        if !n
            stop()
            return
        current = n
        update()
        player.play n.reader()

    player.addCallback "stop", ()->
        isPlaying = false
        next()
        
    player.addCallback "error", (e)->
        isPlaying = false
        update()
        next()

    createMessage = () ->
        embeds = new discord.MessageEmbed()
        .setColor '#ffff00'
        .setAuthor 'Now playing', 'https://13hgames.net/13hmail.png', 'https://13hgames.net/'
        .setTitle current.title
        .setURL current.url
        .setThumbnail current.image
        .setDescription "Queue:"
        for i in [0..Math.min(q.length, 10)]
            embeds.addFields {name: q[i].title, value: '\u200B'}
        console.log q.length
        if q.length > 10
            embeds.setFooter "and #{q.length - 10} more"
        embeds: [embeds]

    update = () ->
        if message && channel.lastMessageId == message.id
            message.edit createMessage()
            return
        if message
            message.delete()
        channel.send createMessage()
        .then (m) ->
            message = m

    return
        getPlayer: getPlayer
        add: add
        next: next
        clear: clear
        play: play
        pause: pause
        unpause: unpause
        stop: stop

get = (message) ->
    if !(message?.member?.voice?.channelId)
        return
    channels[message.member.voice.guild.id] ?= {}
    channels[message.member.voice.guild.id][message.member.voice.channelId] ?= create player(message.member.voice.channelId, message.member.voice.guild.id, message.member.voice.guild.voiceAdapterCreator), message.channel
    channels[message.member.voice.guild.id][message.member.voice.channelId]

remove = (message) ->
    channels[message.member.voice.guild.id][message.member.voice.channelId] = undefined

module.exports = 
    get: get
    remove: remove