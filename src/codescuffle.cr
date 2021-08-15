require "kemal"
require "json"

PORT = 8080

# Look for languages (docker images tagged "scuffle_<language_name>")
SUPPORTED_LANGUAGES =
  `docker images --filter=reference='scuffle_*:latest' --format '{{.Repository}}'`
    .split
    .map(&.lchop("scuffle_"))

p! SUPPORTED_LANGUAGES

# TODO: move this to a separate file
class CodeRunRequest
  include JSON::Serializable
  property code : String
end

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
  # - How to measure execution time, preferably without the time it takes
  #   for docker container to spin up?
  run_result = JSON.build do |json|
    json.object do
      json.field "stdout", stdout.to_s
      json.field "stderr", stderr.to_s
    end
  end
end

post "/api/v1/run/:language" do |env|
  language = SUPPORTED_LANGUAGES.find(&.==(env.params.url["language"]))

  if language.nil?
    env.response.respond_with_status(404, "Not found: Invalid or unsupported language specified")
    next
  end

  begin
    code_run_request = CodeRunRequest.from_json(env.request.body.not_nil!)
  rescue ex
    puts ex.message
    env.response.respond_with_status(400, "Invalid request: Failed to parse request body")
    next
  end

  env.response.content_type = "application/json"
  docker_run("scuffle_#{language}", code_run_request.code)
end

get "/api/v1/languages" do |env|
  env.response.content_type = "application/json"
  JSON.build do |json|
    json.object do
      json.field "languages" do
        json.array do
          SUPPORTED_LANGUAGES.each do |language_name|
            json.object do
              json.field "name", language_name
              json.field "version", "unknown" # TODO
            end
          end
        end
      end
    end
  end
end

Kemal.run(PORT)
