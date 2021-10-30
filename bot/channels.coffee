_ = require 'lodash'
fs = require 'fs'
Mutex = require('async-mutex').Mutex;
discord = require 'discord.js'
player = require './player'

channels = {}

create = (player_creator, player_destroyer, channel, voice) ->
    q = []
    mutex = new Mutex()
    q_top = []
    isPlaying = false
    current = undefined
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
        update()

    addnext = (track) ->
        if !_.isArray track
            q_top.push track
            return
        q_top = q_top.concat track
        update()

    play = () ->
        if !isPlaying
            next()

    shuffle = () ->
        q = _.shuffle q
        update()

    stop = () ->
        if p
            getPlayer().stop()
            player_destroyer()

    pause = () ->
        if p
            getPlayer().pause()

    unpause = () ->
        if p
            getPlayer().unpause()

    clear = () ->
        q = []
        q_top = []
        current = undefined
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
            clear()
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
        counter = 0
        for i in q_top
            if ++counter > 10
                break
            embeds.addFields {name: i.title, value: '\u200B'}
        for i in q
            if ++counter > 10
                break
            embeds.addFields {name: i.title, value: '\u200B'}

        if q.length > 10
            embeds.setFooter "and #{q.length - 10} more"
        embeds: [embeds]

    update = () ->
        mutex
        .runExclusive () ->    
            if message && channel.lastMessageId == message.id && current
                message.edit createMessage()
                return
            if message
                message.delete()
            if current
                message = await channel.send createMessage()

    check = () ->
        fs.writeFileSync "test.json", JSON.stringify voice.members, null, 4
        flag = false
        voice.members.each (member, id) ->
            if !member.user.bot
                flag = true
        !flag

    return
        getPlayer: getPlayer
        add: add
        addnext: addnext
        next: next
        clear: clear
        play: play
        pause: pause
        unpause: unpause
        shuffle: shuffle
        check: check 

remove = (message) ->
    channels[message.member.voice.guild.id] = undefined

get = (message) ->
    if !(message?.member?.voice?.channelId)
        return
    channels[message.member.voice.guild.id] ?= create((() -> player(message.member.voice.channelId, message.member.voice.guild.id, message.member.voice.guild.voiceAdapterCreator)), (() -> remove(message)), message.channel, message.member.voice.channel)
    channels[message.member.voice.guild.id]

check = (guildId) ->
    c = channels[guildId]
    if c && c.check()
        c.clear()
        channels[guildId] = undefined
    

module.exports = 
    get: get
    remove: remove
    check: check