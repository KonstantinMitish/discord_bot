queue = require 'queue'

create = (player, send) ->
    q = queue()
    isPlaying = false
    current = ""
    getPlayer = () ->
        player
    add = (desc, reader) ->
        q.push 
            reader: reader
            desc: desc
        if !isPlaying
            next()
            
    stop = () ->
        isPlaying = false
        #player.stop() discord.js docs are shit
        player.pause()
    
    clear = () ->
        q.end()
        send "cleared queue"
        stop()

    next = () ->
        isPlaying = true
        n = q.shift()
        if !n
            stop()
            return
        send "now playing #{n.desc}"
        current = n.desc
        player.play n.reader()

    player.addCallback "stop", ()->
        isPlaying = false
        next()
        
    player.addCallback "error", (e)->
        isPlaying = false
        send "failed to load #{current}"
        next()
        
    return
        getPlayer: getPlayer
        add: add
        next: next
        clear: clear
module.exports = create
