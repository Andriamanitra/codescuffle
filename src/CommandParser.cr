class CommandParser
  def initialize(@codefile : String, @binaryfile : String)
  end

  def parse(command : String)
    cmd_parts = command.sub("%CODE%", @codefile).sub("%EXECUTABLE%", @binaryfile).split
    cmd = cmd_parts[0]
    args = cmd_parts[1..]
    return {cmd, args}
  end
end
