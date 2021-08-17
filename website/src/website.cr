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

  get "/test" do |env|
    editor = render("src/views/editor.ecr")
    render "src/views/gameroom.ecr", "src/views/layouts/layout.ecr"
  end

  get "/editor" do |env|
    render "src/views/editor.ecr", "src/views/layouts/layout.ecr"
  end

  get "/puzzles" do |env|
    # TODO: show actual puzzles :D
    render "src/views/puzzles.ecr", "src/views/layouts/layout.ecr"
  end

  ws "/room/:id" do |socket, context|
    id = context.ws_route_lookup.params["id"]
    room = gamerooms[id]?
    if room.nil?
      socket.close
      next
    end
    player = Player.new("Player1", socket)
    room.add_player(player)
  end

  Kemal.run(PORT)
end
