require "kemal"
require "json"
require "./CodeRunRequest"

PORT = 8080

serve_static false

# Look for languages (docker images tagged "scuffle_<language_name>")
SUPPORTED_LANGUAGES =
  `docker images --filter=reference='scuffle_*:latest' --format '{{.Repository}}'`
    .split
    .map(&.lchop("scuffle_"))

p! SUPPORTED_LANGUAGES

def docker_run(docker_image : String, code_run_request : CodeRunRequest)
  stdout = IO::Memory.new

  process = Process.new(
    "docker",
    args: [
      "run", "-a", "stdout", "-a", "stderr", "--rm",
      "--network", "none",
      "--tmpfs", "/tmpfs:exec",
      docker_image, "runreqhandler", code_run_request.to_json,
    ],
    output: stdout
  )

  # TODO: make it timeout after a few seconds
  process.wait

  # TODO: maybe it would be a good idea to verify that this json
  # (currently stored in a string) is in the right format
  stdout.to_s
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
    puts ex.message # TODO: probably want to log errors
    env.response.respond_with_status(400, "Invalid request: Failed to parse request body")
    next
  end

  env.response.content_type = "application/json"

  # TODO: this currently allows requests from any site, not sure if good idea?
  env.response.headers.add("Access-Control-Allow-Origin", "*")

  docker_run("scuffle_#{language}", code_run_request)
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

# TODO: figure out this CORS nonsense.. currently this says that basically everything is allowed
# at any end point
options "/api/v1/*" do |env|
  env.response.headers.add("Allow", "HEAD,GET,PUT,POST,DELETE,OPTIONS")
  env.response.headers.add("Access-Control-Allow-Headers", "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept")
  env.response.headers.add("Access-Control-Allow-Origin", "*")
end

Kemal.run(PORT)
