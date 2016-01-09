telegram = require './_telegram'

module.exports =

  junction: (incoming, cmd) ->

    if cmd.indexOf('dice') == 0 then cmd = cmd.substring('dice'.length).trim()

    if not cmd then cmd = '1d6'
    if cmd.substring(0, 1) == 'd' then cmd = '1' + cmd # fix dX to 1dX

    subcmd = cmd.split(' ')[0]

    switch subcmd
      when 'help', 'start', '?'
        diceHelp incoming
      when 'settings'
        diceSettings incoming
      else
        diceParse incoming, cmd

diceMessage = (incoming, result) ->
  diceInput = result.input

  if result.modifier
    diceInput += result.modifier

  telegram.textMessage incoming, 'Dice (' + diceInput + ') roll result: ' + result.value
  # console.log 'dice output: ' + result.value

diceInvalidMessage = (incoming) ->
  telegram.textMessage incoming, 'Dice input is invalid. Try the following format: dice 1d6 + 2'
  return

diceRoll = (incoming, diceInput, callback) ->
  # console.log 'rolling: ' + diceInput

  if not diceInput.match /^\d+d\d+/
    diceInvalidMessage incoming
    return

  diceAmount = parseInt(diceInput.substring(0, diceInput.indexOf('d')))
  diceSize = parseInt(diceInput.substring(diceInput.indexOf('d') + 1))

  diceResult =
    value: 0
    input: diceInput

  if diceAmount > 0 and diceSize > 0 and diceSize < 1000 and diceAmount < 1000
    for i in [0..diceAmount-1]
      diceResult.value += (Math.floor(Math.random() * diceSize) + 1)

    callback(diceResult)
  else
    telegram.textMessage incoming, 'Sorry, those dice values are invalid...'


diceParse = (incoming, cmd) ->
  # console.log 'dice parsing: ' + cmd

  diceInput = null

  if cmd.indexOf('+') != -1
    diceInput = cmd.substring(0, cmd.indexOf('+')).trim()
    modifier = parseInt(cmd.substring(cmd.indexOf('+') + 1).trim())

    # console.log 'dice modifier: ' + modifier

    if not modifier
      diceInvalidMessage incoming
    else
      diceRoll incoming, diceInput, (result) ->
        result.modifier = '+' + modifier
        result.value += modifier
        diceMessage incoming, result

  else if cmd.indexOf('-') != -1
    diceInput = cmd.substring(0, cmd.indexOf('-')).trim()
    modifier = parseInt(cmd.substring(cmd.indexOf('-') + 1).trim())

    # console.log 'dice modifier: ' + modifier

    if not modifier
      diceInvalidMessage incoming
    else
      diceRoll incoming, diceInput, (result) ->
        result.modifier = '-' + modifier
        result.value -= modifier
        diceMessage incoming, result

  else if cmd.indexOf('*') != -1
    diceInput = cmd.substring(0, cmd.indexOf('*')).trim()
    modifier = parseInt(cmd.substring(cmd.indexOf('*') + 1).trim())

    # console.log 'dice modifier: ' + modifier

    if not modifier
      diceInvalidMessage incoming
    else
      diceRoll incoming, diceInput, (result) ->
        result.modifier = '*' + modifier
        result.value *= modifier
        diceMessage incoming, result

  else if cmd.indexOf('/') != -1
    diceInput = cmd.substring(0, cmd.indexOf('/')).trim()
    modifier = parseInt(cmd.substring(cmd.indexOf('/') + 1).trim())

    # console.log 'dice modifier: ' + modifier

    if not modifier
      diceInvalidMessage incoming
    else
      diceRoll incoming, diceInput, (result) ->
        result.modifier = '/' + modifier
        result.value /= modifier
        diceMessage incoming, result

  else
    diceRoll incoming, cmd, (result) ->
      diceMessage incoming, result


diceSettings = (incoming) ->
  # console.log 'dice settings requested'

  telegram.textMessage incoming, 'No settings are available.'

diceHelp = (incoming) ->
  # console.log 'dice help requested'

  telegram.textMessage incoming,
  'Dice roller\n\n

  The following subcommands are available:\n
  - dice\n
  - dice 1d6\n
  - dice 1d10 + 10\n
  \n
  Input must be in the AdX+B format. Subtraction (-), multiplication (*) and division (/) are also possible.\n
  \n
  Results are guaranteed to be pseudo-random.'
