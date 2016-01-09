TelegramBot = require './helpers/node-telegram-bot'
botJunction = require './functions/_parser'

subJunction = require './functions/dice'
botname = 'CasinoBot'

token = process.argv[2]

if not token
  console.log 'First argument must be bot token'
  process.exit()

botcmds = [
  'dice'
]

console.log botname + ' started...'

bot = new TelegramBot
  token: token

.on('message', (incoming) ->

  if incoming.text

    incoming.bot = bot

    botJunction.junction incoming, botname, botcmds, subJunction

  )
  .start();
