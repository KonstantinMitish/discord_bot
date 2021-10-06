Q = require 'q'
fs = require 'fs'
path = require 'path'
voice = require '@discordjs/voice'
stream = require('youtube-audio-stream')

module.exports =
    ping: 
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
        argc: 1
        call: (message, argv) ->
            defer = Q.defer()
            voiceChannel = 
            player = voice.createAudioPlayer()

            connection = voice.joinVoiceChannel {
                channelId: message.member.voice.channelId
                guildId: message.member.voice.guild.id
                adapterCreator: message.member.voice.guild.voiceAdapterCreator
            }
            player.on voice.AudioPlayerStatus.Playing, ()->
                console.log('The audio player has started playing!')
              
            player.on "debug", (info)->
                console.log info 

            stream = stream(argv[1])

            resource = voice.createAudioResource stream

            player.play(resource)
            subscription = connection.subscribe(player)
            defer.resolve {}
            defer.promise
