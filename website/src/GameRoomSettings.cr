enum GameMode
  Shortest
  Fastest
  MostLanguages
end

class GameRoomSettings
  @time_per_round : Time::Span
  @mode : GameMode

  getter :time_per_round

  def initialize
    @time_per_round = 15.minutes
    @mode = GameMode::Fastest
  end
end
