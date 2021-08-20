require "json"

class Submission
  include JSON::Serializable
  property code : String
end
