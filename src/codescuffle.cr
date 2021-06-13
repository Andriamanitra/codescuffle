require "kemal"

PORT = 8080

# Look for languages (docker images tagged "scuffle_<language_name>")
SUPPORTED_LANGUAGES =
  `docker images --filter=reference='scuffle_*:latest' --format '{{.Repository}}'`
    .split
    .map(&.lchop("scuffle_"))

p! SUPPORTED_LANGUAGES

def docker_run(docker_image : String, code : String)
  stdout = IO::Memory.new
  stderr = IO::Memory.new

  process = Process.new(
    "docker",
    args: ["run", "--rm", "--network", "none", docker_image, code],
    output: stdout,
    error: stderr
  )

  # TODO: make it timeout after a few seconds
  process.wait

  # TODO: add some information about execution time and other good stuff
  run_result = JSON.build do |json|
    json.object do
      json.field "stdout", stdout.to_s
      json.field "stderr", stderr.to_s
    end
  end
end

post "/api/v1/run/:language" do |env|
  language = SUPPORTED_LANGUAGES.find(&.==(env.params.url["language"]))

  # TODO: proper response (with status code)
  next "Unknown language, add it?" if language.nil?

  # TODO: Error handling
  code = env.params.json["code"].as(String)

  # TODO: proper response
  docker_run("scuffle_#{language}", code)
end

Kemal.run(PORT)
