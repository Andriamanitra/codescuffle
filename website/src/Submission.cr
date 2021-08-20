require "json"

class Submission
  include JSON::Serializable
  property language : String
  property code : String
end
