require "json"

class CodeRunRequest
  include JSON::Serializable
  property code : String
  property stdin : String
end
