# Description:
#   Create new cards in Trello
#
# Dependencies:
#   "node-trello": "latest"
#
# Configuration:
#   HUBOT_TRELLO_KEY - Trello application key
#   HUBOT_TRELLO_TOKEN - Trello API token
#   HUBOT_TRELLO_LIST - The list ID that you'd like to create cards for
#
# Commands:
#   hubot trello card <name> - Create a new Trello card
#   hubot trello show - Show cards on list
#
# Notes:
#   To get your key, go to: https://trello.com/1/appKey/generate
#   To get your token, go to: https://trello.com/1/authorize?key=<<your key>>&name=Hubot+Trello&expiration=never&response_type=token&scope=read,write
#   Figure out what board you want to use, grab it's id from the url (https://trello.com/board/<<board name>>/<<board id>>)
#   To get your list ID, go to: https://trello.com/1/boards/<<board id>>/lists?key=<<your key>>&token=<<your token>>  "id" elements are the list ids.
#
# Author:
#   carmstrong

users = [
  {"hipchat":"Jan Henckens","trello":"janhenckens2"}
  {"hipchat":"Filip Vanderstappen","trello":"filipvds"}
]

myMap = {}
for row in users
  myMap[row.hipchat] = row.trello



module.exports = (robot) ->

  robot.hear /board (.*)/i, (msg) ->
    boardName = msg.match[1]
    getBoard msg, boardName

  robot.hear  /show cards (.*) (.*)/i, (msg)->
    boardName = msg.match[1]
    userName = msg.match[2]
    Cards msg, boardName, userName

  robot.hear  /(mijn|my) (kaartjes|cards) (on|in) (.*)/i, (msg)->
    boardName = msg.match[2]
    sender = msg.message.user.name
    myCards msg, boardName, sender

myCards = (msg, boardName, sender) ->
  msg.send console.log(JSON.stringify(myMap[sender], 4, 10));
  msg.send console.log(JSON.stringify(boardName, 4, 10));
  Trello = require("node-trello")
  t = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
  t.get "/1/search/", {query: boardName}, (err, data) -> t.get "/1/board/#{data['boards']['0']['id']}/members/#{myMap[sender]}/cards", (err, result) ->
    if err
      msg.send "There was an error showing the list."
      return
    msg.send "* #{card.shortUrl} - #{card.name}" for card in result
    # msg.send result.url;


getBoard = (msg, boardName) ->
  Trello = require("node-trello")
  t = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
  t.get "/1/search/", {query: boardName}, (err, data) -> t.get "/1/board/#{data['boards']['0']['id']}", (err, result) ->
    if err
      msg.send "There was an error showing the list."
      return
    msg.send result.url;

Cards = (msg, boardName, userName) ->
  Trello = require("node-trello")
  t = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
  t.get "/1/search/", {query: boardName}, (err, data) -> t.get "/1/boards/#{data['boards']['0']['id']}/members/#{userName}/cards", (err, result) ->
    if err
      msg.send "There was an error showing the list." 
      msg.send console.log(err);
      return
    # msg.send console.log(JSON.stringify(result, 4, 10));
    msg.send "* #{card.shortUrl} - #{card.name}" for card in result



## Examples:
#
#
#/1/boards/[board_id]/members/[idMember]/cards
#  robot.respond /trello card (.*)/i, (msg) ->
  # cardName = msg.match[1]
  # if not cardName.length
  #   msg.send "You must give the card a name"
  #   return
  # if not process.env.HUBOT_TRELLO_KEY
  #   msg.send "Error: Trello app key is not specified"
  # if not process.env.HUBOT_TRELLO_TOKEN
  #   msg.send "Error: Trello token is not specified"
  # if not process.env.HUBOT_TRELLO_LIST
  #   msg.send "Error: Trello list ID is not specified"
  # if not (process.env.HUBOT_TRELLO_KEY and process.env.HUBOT_TRELLO_TOKEN and process.env.HUBOT_TRELLO_LIST)
  #   return
  # createCard msg, cardName

  # robot.respond /trello show/i, (msg) ->
  # showCards msg

# createCard = (msg, cardName) ->
#   Trello = require("node-trello")
#   t = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
#   t.post "/1/cards", {name: cardName, idList: process.env.HUBOT_TRELLO_LIST}, (err, data) ->
#     if err
#       msg.send "There was an error creating the card"
#       return
#       msg.send console.log(JSON.stringify(data, 4, 10));
#     msg.send data.url

# showCards = (msg) ->
#   Trello = require("node-trello")
#   t = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
#   t.get "/1/lists/"+process.env.HUBOT_TRELLO_LIST, {cards: "open"}, (err, data) ->
#     if err
#       msg.send "There was an error showing the list."
#       return

#     msg.send "Cards in " + data.name + ":"
#     msg.send "- " + card.name for card in data.cards