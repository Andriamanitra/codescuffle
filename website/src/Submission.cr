require "json"
require "uuid"

struct ReceivedSubmission
  include JSON::Serializable
  getter language : String
  getter code : String
end

class Submission
  getter id, player, language, code, time

  def initialize(
    @id : UUID,
    @player : String,
    @language : String,
    @code : String,
    @time : Time
  )
  end

  def self.from_json(src, submitter)
    recvd_subm = ReceivedSubmission.from_json(src)
    self.new(
      UUID.random,
      submitter,
      recvd_subm.language,
      recvd_subm.code,
      Time.utc
    )
  end
end
