-- Creating tables 
-- Enable the UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the tables
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4() NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL DEFAULT '',
    email TEXT NOT NULL DEFAULT '',
    photo TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS candidates (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE NOT NULL,
    current_position TEXT NOT NULL DEFAULT '',
    education TEXT NOT NULL DEFAULT '',
    resume TEXT NOT NULL DEFAULT '',
    bio TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS recruiters (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE NOT NULL,
    company_public_id UUID NOT NULL
);

CREATE TABLE IF NOT EXISTS companies (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4() NOT NULL,
    name TEXT NOT NULL,
    logo TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS positions (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4() NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    name TEXT NOT NULL DEFAULT '',
    status int DEFAULT 0,
    recruiter_public_id UUID NOT NULL
);

CREATE TABLE IF NOT EXISTS skills (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4() NOT NULL,
    name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS areas (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4() NOT NULL,
    position_id INT,
    name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS interviews (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4() NOT NULL,
    status int DEFAULT 0,
    results JSONB
);

CREATE TABLE IF NOT EXISTS auth (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE,
    login TEXT UNIQUE,
    password TEXT
);

CREATE TABLE IF NOT EXISTS position_skills (
    position_id INT,
    skill_id INT,
    PRIMARY KEY (position_id, skill_id),
    CONSTRAINT fk_position_skills_positions FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
    CONSTRAINT fk_position_skills_skills FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS candidate_skills (
    candidate_id INT,
    skill_id INT,
    PRIMARY KEY (candidate_id, skill_id),
    CONSTRAINT fk_candidate_skills_candidates FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    CONSTRAINT fk_candidate_skills_skills FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_interviews (
    candidate_id INT NOT NULL,
    position_id INT NOT NULL,
    interview_id INT UNIQUE NOT NULL,
    PRIMARY KEY (candidate_id, position_id, interview_id),
    CONSTRAINT fk_user_interviews_candidates FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_interviews_positions FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_interviews_interviews FOREIGN KEY (interview_id) REFERENCES interviews(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS questions (
    id int,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4() NOT NULL,
    name TEXT NOT NULL,
    position_public_id UUID NOT NULL,
    position_id int NOT NULL,
    read_duration int,
    answer_duration int,
    CONSTRAINT fk_question_position FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE,
    CONSTRAINT fk_question_public_position FOREIGN KEY (position_public_id) REFERENCES positions(public_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS videos (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4() NOT NULL,
    question_public_id UUID,
    interviews_public_id UUID,
    CONSTRAINT fk_video_question FOREIGN KEY (question_public_id) REFERENCES questions(public_id) ON DELETE CASCADE,
    path TEXT NOT NULL DEFAULT ''
);

-- Creating references
ALTER TABLE recruiters ADD CONSTRAINT fk_recruiters_users FOREIGN KEY (public_id) REFERENCES users(public_id) ON DELETE CASCADE;
ALTER TABLE candidates ADD CONSTRAINT fk_candidates_users FOREIGN KEY (public_id) REFERENCES users(public_id) ON DELETE CASCADE;
ALTER TABLE auth ADD CONSTRAINT fk_auth_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE positions ADD CONSTRAINT fk_positions_recruiters FOREIGN KEY (recruiter_public_id) REFERENCES recruiters(public_id) ON DELETE CASCADE;
ALTER TABLE videos ADD CONSTRAINT fk_videos_interviews FOREIGN KEY (interviews_public_id) REFERENCES interviews(public_id) ON DELETE CASCADE;



INSERT INTO users (first_name, last_name, photo, email)
VALUES
    ('John', 'Doe', '', 'example@mail.com'),
    ('Jane', 'Smith', '', 'example@mail.com'),
    ('Michael', 'Johnson', '', 'example@mail.com'),
    ('Emily', 'Williams', '', 'example@mail.com'),
    ('David', 'Brown', '', 'example@mail.com'),
    ('Olivia', 'Jones', '', 'example@mail.com'),
    ('Daniel', 'Miller','', 'example@mail.com'),
    ('Sophia', 'Taylor','', 'example@mail.com'),
    ('Matthew', 'Anderson','', 'example@mail.com'),
    ('Ava', 'Thomas','', 'example@mail.com');


INSERT INTO candidates (public_id, current_position, resume, bio, education)
SELECT public_id, 'Software Engineer', 'John Doe Resume', 'John Doe Bio',  'MTI'
FROM users
WHERE id <= 5;

INSERT INTO companies (name, description, logo)
VALUES
    ('Company A', 'A technology company that specializes in software development.',''),
    ('Company B', 'A global retail company with a focus on e-commerce.',''),
    ('Company C', 'A financial services company providing investment and banking solutions.','');

INSERT INTO recruiters (public_id, company_public_id)
SELECT public_id, (SELECT public_id FROM companies WHERE name = 'Company A')
FROM users
WHERE id > 5;




INSERT INTO positions (public_id, name, recruiter_public_id, description)
SELECT public_id, 'Software Engineer', (SELECT public_id FROM recruiters WHERE id = 1), 'This position is awesome'
FROM candidates;

INSERT INTO skills (name)
VALUES
    ('Java'),
    ('Python'),
    ('JavaScript'),
    ('SQL'),
    ('HTML'),
    ('CSS'),
    ('React'),
    ('Node.js'),
    ('AWS'),
    ('Agile Methodology');

INSERT INTO areas (position_id, name)
SELECT id, 'Area ' || id
FROM positions;


INSERT INTO interviews (public_id, results)
SELECT public_id, '
{
  "questions": [
    {
      "question": "What is your experience with object-oriented programming?",
      "evaluation": "Good",
      "score": 8,
      "video_link": "",
      "emotion_results": [
        {
          "emotion": "Happiness",
          "exact_time": 24.5,
          "duration": 10.2
        },
        {
          "emotion": "Neutral",
          "exact_time": 36.2,
          "duration": 5.7
        }
      ]
    },
    {
      "question": "Describe a challenging project you have worked on.",
      "evaluation": "Excellent performance with exceptional problem-solving skills",
      "score": 9,
      "video_link": "",
      "emotion_results": [
        {
          "emotion": "Confidence",
          "exact_time": 45.8,
          "duration": 8.5
        },
        {
          "emotion": "Determination",
          "exact_time": 56.3,
          "duration": 7.1
        }
      ]
    }
  ],
  "score": 17,
  "video": ""
}'
FROM candidates;


INSERT INTO videos (public_id, interviews_public_id, path)
SELECT public_id, (SELECT public_id FROM interviews WHERE id = 1), ''
FROM candidates;


INSERT INTO auth (user_id, login, password)
SELECT id, 'user' || id, '$2a$12$TPhE59oXJf8TBvbDRiBghu7jcgVppHgYPLmZr7ePf9rjNwVWJJDuO'
FROM users;


insert into position_skills values (1,2);
insert into position_skills values (2,2);
insert into position_skills values (1,3);
insert into position_skills values (3,4);

insert into candidate_skills values (1,2);
insert into candidate_skills values (2,2);
insert into candidate_skills values (1,3);
insert into candidate_skills values (3,4);

insert into user_interviews values (1,1,1);
insert into user_interviews values (1,1,2);
insert into user_interviews values (1,2,3);
insert into user_interviews values (1,2,4);
insert into user_interviews values (2,2,5);



INSERT INTO questions (id, name, position_public_id, position_id, read_duration, answer_duration)
SELECT
    q.id,
    'Question ' || q.id,
    p.public_id,
    p.id,
    FLOOR(RANDOM() * 50) + 10 as read_duration,
    FLOOR(RANDOM() * 50) + 10 as answer_duration
FROM
    generate_series(1, 10) as q(id),
    (SELECT id, public_id FROM positions ORDER BY RANDOM() LIMIT 1) as p;


