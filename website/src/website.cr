require "kemal"
require "./GameRoom"

module Website
  VERSION = "0.1.0"
  PORT    = 8081

  gamerooms = Hash(String, GameRoom).new
  gamerooms["test"] = GameRoom.new

  get "/" do |env|
    render "src/views/index.ecr", "src/views/layouts/layout.ecr"
  end

  get "/play" do |env|
    room_id = env.params.query["rid"]?
    if room = gamerooms[room_id]?
      is_gameroom = true
      editor = render("src/views/editor.ecr")
      render "src/views/gameroom.ecr", "src/views/layouts/layout.ecr"
    else
      # TODO: proper error page
      env.response.respond_with_status(404, "Game room not found")
    end
  end

  get "/editor" do |env|
    is_gameroom = false
    render "src/views/editor.ecr", "src/views/layouts/layout.ecr"
  end

  get "/puzzles" do |env|
    # TODO: show actual puzzles :D
    render "src/views/puzzles.ecr", "src/views/layouts/layout.ecr"
  end

  ws "/play" do |socket, env|
    rid = env.params.query["rid"]?
    room = gamerooms[rid]?
    if room.nil?
      socket.send "ERROR: Game room doesn't exist"
      socket.close
      next
    end
    nickname = env.params.query["name"]? || "Player#{rand(10..80)}"
    player = Player.new(nickname, socket)
    room.add_player(player)
  end

  Kemal.run(PORT)
end
