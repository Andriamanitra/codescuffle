/*
-- TODO: properly design a model for puzzles
CREATE TABLE puzzles (
    id serial primary key,
    title varchar(120),
    last_edited timestamp,
    problem text,
    input_description text,
    output_description text,
    constraints text,
    testcases
);
*/

CREATE TABLE results (
    id uuid primary key,
    -- TODO: round_start_time timestamp,
    round_end_time timestamp,
    -- puzzle serial references puzzles(id);
    puzzle varchar(127)
);

CREATE TABLE submissions (
    id uuid primary key,
    player varchar(127),
    lang varchar(127),
    code text,
    submission_time timestamp,
    num_bytes int
);

CREATE TABLE result_submission (
    result uuid references results(id),
    submission uuid references submissions(id)
);
