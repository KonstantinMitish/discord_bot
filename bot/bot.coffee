fs = require 'fs'
discord = require 'discord.js'
commands = require './commands'

config = require '../config.json'
token = process.env.TOKEN
prefix = config.prefix
clientId = config.clientId

bot = client = new discord.Client { 
  intents: [
    discord.Intents.FLAGS.GUILDS, 
    discord.Intents.FLAGS.GUILD_VOICE_STATES,
    discord.Intents.FLAGS.GUILD_MESSAGES] 
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

  handle = null
  for name, c of commands
    if argv[0] in c.alias
      handle = c

  if !handle
    console.log "no handle for #{argv[0]}"
    return
  if handle.argc > argv.length - 1
    console.log "not enough args for #{argv[0]}"
    return
  handle.call message, argv
  .then (data) ->
    console.log "executed command #{argv[0]}"
  .catch (e) ->
    console.log "ERROR in command #{argv[0]}\n#{JSON.stringify e}"

bot.login token