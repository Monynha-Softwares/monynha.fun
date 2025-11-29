-- Create the 'fun' schema if it doesn't exist (redundant if previous migration ran, but safe)
CREATE SCHEMA IF NOT EXISTS fun;

-- Create the materialized view for video suggestions count
CREATE MATERIALIZED VIEW fun.video_suggestions_count AS
  SELECT video_id, SUM(vote) AS total_votes
  FROM fun.suggestions
  GROUP BY video_id;

-- Create a unique index on the materialized view for efficient refreshes
CREATE UNIQUE INDEX video_suggestions_count_video_id_idx ON fun.video_suggestions_count (video_id);

-- Enable Row Level Security (RLS) for the materialized view
ALTER MATERIALIZED VIEW fun.video_suggestions_count ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Allow all users to read the view
CREATE POLICY "Enable read access for all users" ON fun.video_suggestions_count FOR SELECT USING (true);

-- Note: Materialized views need to be refreshed periodically.
-- You can set up a Supabase database function or a cron job to run:
-- REFRESH MATERIALIZED VIEW CONCURRENTLY fun.video_suggestions_count;