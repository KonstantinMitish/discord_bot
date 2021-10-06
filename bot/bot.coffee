fs = require 'fs'
{ Client, Intents }  = require 'discord.js'
commands = require './commands'

config = require '../config.json'
token = process.env.TOKEN
prefix = config.prefix
clientId = config.clientId

bot = client = new Client { 
  intents: [
    Intents.FLAGS.GUILDS, 
    Intents.FLAGS.GUILD_VOICE_STATES,
    Intents.FLAGS.GUILD_MESSAGES] 
}

bot.once "ready", () ->
  console.log bot.user.username + " started!"  

bot.on "debug", (info) ->
  console.log info

bot.on 'messageCreate', (message) ->
  if message.author.username == bot.user.username || message.author.discriminator == bot.user.discriminator
    return
  text = message.content.trim()
  if !text.startsWith(config.prefix)
    return

  argv = text.split " "
  argv[0] = argv[0].slice 1, argv[0].size
  handle = commands[argv[0]]

  if !handle
    console.log "no handle for #{argv[0]}"
    return
  if handle.argc > argv.size + 1
    console.log "not enough args for #{argv[0]}"
    return
  handle.call message, argv
  .then (data) ->
    console.log "executed command #{argv[0]}"
  .catch (e) ->
    console.log "ERROR in command #{argv[0]}\n#{e}"

bot.login token