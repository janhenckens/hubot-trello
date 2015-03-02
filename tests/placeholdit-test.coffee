# Hubot classes
Robot = require("hubot/src/robot")
TextMessage = require("hubot/src/message").TextMessage

chai = require 'chai'
mocha = require 'mocha'

{ expect } = chai

describe 'a hubot doing his thing', () ->
  user = null
  robot = null
  beforeEach (done) ->
    robot = new Robot null, 'mock-adapter', yes, 'TestHubot'
    robot.adapter.on 'connected', ->
      require("../index")(robot)
      # create a user
      user = robot.brain.userForId "1", {
        name: "mocha",
        room: "#mocha"
      }
      done()
    robot.run()

  afterEach (done) ->
    robot.server.close()
    robot.shutdown()
    done()
