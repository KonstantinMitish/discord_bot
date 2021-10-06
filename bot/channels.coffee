queue = require './queue'
player = require './player'

channels = {}

get = (message) ->
    channels.guildId ?= {}
    channels.guildId.channelId ?= queue player(message.member.voice.channelId, message.member.voice.guild.id, message.member.voice.guild.voiceAdapterCreator), 
        (msg) ->
            message.channel.send msg.slice 0, 1000
    channels.guildId.channelId

module.exports = get