voice = require '@discordjs/voice'

create = (channelId, guildId, voiceAdapterCreator) ->
    callbacks = {
        stop: []
        error: []
    }
    player = voice.createAudioPlayer()
    connection = voice.joinVoiceChannel {
                channelId: channelId
                guildId: guildId
                adapterCreator: voiceAdapterCreator
            }
    player.on "debug", (info)->
        console.log info 
    subscription = connection.subscribe(player)

    player.on voice.AudioPlayerStatus.Idle , () ->
        for i in callbacks.stop
            i()

    player.on 'error', (e) ->
        for i in callbacks.error
            i(e)

    return 
        play: (stream) ->
            resource = voice.createAudioResource stream
            player.play(resource)
        pause: () ->
            player.pause()
        stop: () ->
            player.stop()
            connection.destroy()
        unpause: () ->
            player.unpause()
        addCallback: (type, callback) ->
            callbacks[type].push callback
        
module.exports = create