require "http"
require "./GameRoomSettings"
require "./Puzzle"
require "./Submission"

class Player
  @name : String
  @websocket : HTTP::WebSocket
  @submissions : Array(Submission)
  getter :name, :websocket

  def initialize(@name, @websocket)
    @submissions = [] of Submission
  end

  def add_submission(subm : Submission)
    @submissions << subm
  end

  def clear_submissions
    @submissions = [] of Submission
  end

  def summary
    JSON.build do |json|
      json.object do
        json.field "name", @name
        json.field "submissions", @submissions
      end
    end
  end
end

class GameRoom
  @@next_id = 0_u64
  @id : String
  @players : Array(Player)
  # TODO: eventually this should instance of the dedicated Puzzle class,
  # but for now just use string containing JSON
  @puzzle : String?
  @owner : Player?
  @round_end : Time

  getter :puzzle

  def initialize
    @id = next_id
    @players = [] of Player
    @puzzle = nil
    @settings = GameRoomSettings.new
    @owner = nil
    @round_end = Time.utc
  end

  def add_player(player : Player)
    if @players.empty?
      @players << player
      set_owner(player)
    else
      @players << player
    end

    player.websocket.on_close do
      @players.delete(player)
      broadcast("QUIT:#{player.name}")
    end

    player.websocket.on_message do |msg|
      handle_message(player, msg)
    end

    if @puzzle
      player.websocket.send(msg_puzzle)
      player.websocket.send(msg_time_left)
    end
    broadcast("JOIN:#{player.name}")
  end

  def broadcast(msg)
    p msg
    @players.each do |player|
      player.websocket.send(msg)
    end
  end

  def end_round
    puts @players.map(&.summary).to_json
    broadcast("ROUND_END:{}")
  end

  def handle_message(sender : Player, msg : String)
    if msg.starts_with?("SUBMIT:")
      # TODO: check if submission code produces correct output
      begin
        submission = Submission.from_json(msg[7..])
        sender.add_submission(submission)
        broadcast("SUBMITTED:#{sender.name}")
      rescue JSON::ParseException
        # TODO: proper error logging
        sender.websocket.send("ERROR: Invalid submission")
        return
      end
    elsif sender == @owner && handle_owner_message(msg)
      return
    else
      sender.websocket.send("ERROR: Unrecognized message")
    end
  end

  private def handle_owner_message(msg)
    if msg.starts_with?("START_ROUND:")
      start_round
    else
      return false # Unrecognized message
    end
    true
  end

  def msg_puzzle
    "PUZZLE:#{@puzzle}"
  end

  def msg_time_left
    "TIME_LEFT:#{time_left}"
  end

  private def next_id : String
    id = @@next_id.to_s
    @@next_id += 1
    id
  end

  def set_owner(player : Player)
    @owner = player
    broadcast("OWNER:#{player.name}")

    player.websocket.on_close do
      begin
        @players.delete(player)
        set_owner(@players.sample)
      rescue IndexError # owner was the last person in the room
        @owner = nil
      end
    end
  end

  def start_round
    @players.each(&.clear_submissions)
    @puzzle = Puzzle.random
    @round_end = Time.utc + @settings.time_per_round
    broadcast(msg_puzzle)
    broadcast(msg_time_left)
    spawn do
      sleep(@settings.time_per_round)
      end_round
    end
  end

  def time_left
    (@round_end - Time.utc).total_seconds.to_i
  end
end
