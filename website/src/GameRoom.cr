require "http"
require "./Puzzle"

class Player
  @name : String
  @websocket : HTTP::WebSocket
  getter :name, :websocket

  def initialize(@name, @websocket)
  end
end

class GameRoom
  @@next_id = 0_u64
  @id : String
  @players : Array(Player)
  # TODO: eventually this should instance of the dedicated Problem class,
  # but for now just use string containing JSON
  @problem : String

  getter :problem

  def initialize
    @id = next_id
    @players = [] of Player
    @problem = Puzzle.random
  end

  def add_player(player : Player)
    @players << player

    player.websocket.on_close do
      @players.delete(player)
      broadcast("QUIT:#{player.name}")
    end

    player.websocket.on_message do |msg|
      handle_message(player, msg)
    end

    player.websocket.send("PROBLEM:#{@problem}")
    broadcast("JOIN:#{player.name}")
  end

  def broadcast(msg)
    @players.each do |player|
      player.websocket.send(msg)
    end
  end

  def handle_message(from : Player, msg : String)
    if msg.starts_with?("SUBMIT:")
      # TODO: verify submission format, get results using code execution API, broadcast results
      broadcast("SUBMITTED:#{from.name}")
    end
  end

  def next_id : String
    id = @@next_id.to_s
    @@next_id += 1
    id
  end
end
