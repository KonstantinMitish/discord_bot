_ = require 'lodash'
fs = require 'fs'
discord = require 'discord.js'
player = require './player'

channels = {}

create = (player_creator, channel) ->
    q = []
    q_top = []
    isPlaying = false
    current = {}
    message = undefined
    p = undefined
    getPlayer = () ->
        p ?= player_creator()
        p

    add = (track) ->
        if !_.isArray track
            q.push track
            return
        q = q.concat track

    addnext = () ->
        if !_.isArray track
            q_top.push track
            return
        q_top = q_top.concat track

    play = () ->
        if !isPlaying
            next()

    shuffle = () ->
        q = _.shuffle q
        update()

    stop = () ->
        if p
            getPlayer().stop()

    pause = () ->
        if p
            getPlayer().pause()

    unpause = () ->
        if p
            getPlayer().unpause()

    clear = () ->
        q = []
        q_top = []
        update()
        stop()

    next = () ->
        isPlaying = true
        
        n = undefined
        if !_.isEmpty q_top
            n = q_top.shift()
        else if !_.isEmpty q
            n = q.shift()
        else
            stop()
            return
        current = n
        update()
        getPlayer().play n.reader()

    getPlayer().addCallback "stop", ()->
        isPlaying = false
        next()
        
    getPlayer().addCallback "error", (e)->
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
        for i in q_top
            embeds.addFields {name: i.title, value: '\u200B'}
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
        shuffle: shuffle

get = (message) ->
    if !(message?.member?.voice?.channelId)
        return
    channels[message.member.voice.guild.id] ?= {}
    channels[message.member.voice.guild.id][message.member.voice.channelId] ?= create((() -> player(message.member.voice.channelId, message.member.voice.guild.id, message.member.voice.guild.voiceAdapterCreator)), message.channel)
    channels[message.member.voice.guild.id][message.member.voice.channelId]

remove = (message) ->
    channels[message.member.voice.guild.id][message.member.voice.channelId] = undefined

module.exports = 
    get: get
    remove: remove