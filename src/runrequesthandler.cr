require "json"
require "benchmark"
require "./CodeRunRequest"
require "./CommandParser"

path = ENV["SCUFFLE_TMPFS_PATH"]? || "/tmpfs"
compile_command = ENV["SCUFFLE_COMPILATION_COMMAND"]?
run_command = ENV["SCUFFLE_RUN_COMMAND"]

codefile = "#{path}/code"
binaryfile = "#{path}/code.exe"

cmd_parser = CommandParser.new(codefile, binaryfile)

# the json containing run request is currently passed as a string argument for the program,
# not sure if I like this...
req = CodeRunRequest.from_json(ARGV[0])

File.write(codefile, req.code)

io_out_comp = IO::Memory.new
io_err_comp = IO::Memory.new
compile_time = 0_f64

# Compilation - this is skipped for interpreted languages
if compile_command
  cmd, args = cmd_parser.parse(compile_command)
  compile_bm = Benchmark.measure do
    Process.run(cmd, args, output: io_out_comp, error: io_err_comp)
  end
  compile_time = compile_bm.cstime + compile_bm.cutime
end

io_in = IO::Memory.new(req.stdin)
io_out = IO::Memory.new
io_err = IO::Memory.new
execution_time = 0_f64

# Execution - this is skipped if compilation failed
# TODO: currently relies on compilation printing something to stderr when it fails,
# which might not be the case for all languages
if io_err_comp.size == 0
  cmd, args = cmd_parser.parse(run_command)
  run_bm = Benchmark.measure do
    Process.run(cmd, args, input: io_in, output: io_out, error: io_err)
  end
  execution_time = run_bm.cstime + run_bm.cutime
end

json = JSON.build do |json|
  json.object do
    json.field "stdout", io_out.to_s
    json.field "stderr", io_err.to_s
    json.field "compilation_stdout", io_out_comp.to_s
    json.field "compilation_stderr", io_err_comp.to_s
    # times are currently child process system + user time
    json.field "compilation_time", compile_time
    json.field "execution_time", execution_time
  end
end

puts json
