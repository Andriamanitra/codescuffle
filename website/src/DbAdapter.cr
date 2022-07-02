require "db"
require "uuid"
require "pg"

DB_URL = "postgres://postgres:example@localhost:5432"

def put_results(
  end_time : Time,
  puzzle : Puzzle,
  submissions : Array(Submission)
)
  result_id = UUID.random
  DB.open(DB_URL) do |db|
    db.exec(
      "INSERT INTO results(id, round_end_time, puzzle) VALUES ($1, $2, $3)",
      result_id,
      end_time.to_rfc3339,
      puzzle.title
    )
    submissions.each do |subm|
      db.exec(
        "INSERT INTO submissions(id, player, lang, code, submission_time, num_bytes) VALUES ($1, $2, $3, $4, $5, $6)",
        subm.id,
        subm.player,
        subm.language,
        subm.code,
        subm.time,
        subm.code.bytesize
      )
      db.exec(
        "INSERT INTO result_submission(result, submission) VALUES ($1, $2)",
        result_id,
        subm.id
      )
    end
  end
  result_id
end

def fetch_result(result_id : String)
  DB.open(DB_URL) do |db|
    db.query_one("SELECT round_end_time, puzzle FROM results where id = $1", result_id, as: {Time, String})
  end
end

def fetch_submissions(result_id : String)
  DB.open(DB_URL) do |db|
    submissions = db.query_all(
      "SELECT player, lang, code, submission_time, num_bytes
      FROM submissions
      JOIN result_submission ON (submissions.id = result_submission.submission)
      WHERE result = $1",
      result_id,
      as: {String, String, String, Time, Int32}
    )
    return submissions
  end
end
