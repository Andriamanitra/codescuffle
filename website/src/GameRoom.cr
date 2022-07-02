require "http"
require "./GameRoomSettings"
require "./Puzzle"
require "./Submission"
require "./DbAdapter"

class Player
  @name : String
  @websocket : HTTP::WebSocket
  @submissions : Array(Submission)
  getter :name, :websocket, :submissions

  def initialize(@name, @websocket)
    @submissions = [] of Submission
  end

  def add_submission(subm : Submission)
    @submissions << subm
  end

  def clear_submissions
    @submissions = [] of Submission
  end
end

class GameRoom
  @@next_id = 0_u64
  @id : String
  @players : Array(Player)
  # TODO: eventually this should instance of the dedicated Puzzle class,
  # but for now just use string containing JSON
  @puzzle : Puzzle?
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

    player.websocket.send(msg_puzzle) if @puzzle
    player.websocket.send(msg_time_left) if time_left > 0

    player.websocket.send(msg_players)

    broadcast("JOIN:#{player.name}")
  end

  def broadcast(msg)
    p msg
    @players.each do |player|
      player.websocket.send(msg)
    end
  end

  def end_round
    submissions = @players.flat_map(&.submissions)
    result_id = put_results(
      @round_end,
      @puzzle.not_nil!,
      submissions
    )
    # TODO: figure out the right url
    broadcast("ROUND_END:https://localhost:8081/results/#{result_id}")
  end

  def handle_message(sender : Player, msg : String)
    if msg.starts_with?("SUBMIT:")
      if !round_in_progress?
        sender.websocket.send("ERROR: Round is over")
        return
      end
      # TODO: check if submission code produces correct output
      begin
        submission = Submission.from_json(msg[7..], sender.name)
        sender.add_submission(submission)
        broadcast("SUBMITTED:#{sender.name}")
      rescue JSON::ParseException
        # TODO: proper error logging
        sender.websocket.send("ERROR: Invalid submission")
        return
      end
      # end round if everyone has submitted at least once
      if @players.all? { |player| player.submissions.size > 0 }
        @round_end = Time.utc
      end
    elsif sender == @owner && handle_owner_message(msg)
      return
    else
      sender.websocket.send("ERROR: Unrecognized message")
    end
  end

  private def handle_owner_message(msg)
    if msg.starts_with?("START_ROUND:") && !round_in_progress?
      start_round
    else
      return false # Unrecognized message
    end
    true
  end

  def msg_puzzle
    if puzzle = @puzzle
      "PUZZLE:#{puzzle.json}"
    else
      "PUZZLE:{}" # TODO: this *shouldn't* ever happen, restructure code so this can be removed
    end
  end

  def msg_players
    "PLAYERS:#{@players.map(&.name).to_json}"
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
    broadcast(msg_puzzle) if @puzzle
    broadcast(msg_time_left)
    spawn do
      loop do
        sleep(1)
        if Time.utc > @round_end
          end_round
          break
        end
      end
    end
  end

  def time_left
    (@round_end - Time.utc).total_seconds.to_i
  end

  def round_in_progress?
    @round_end > Time.utc
  end
end
