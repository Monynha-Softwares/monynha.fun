-- This script will be executed every time you run `supabase db reset` or `supabase db seed`.
-- It's useful for populating your database with initial data for development or testing.

-- Ensure the 'fun' schema exists
CREATE SCHEMA IF NOT EXISTS fun;

-- Insert example memes into the 'fun.memes' table
-- Note: video_id and author_id should reference existing videos and auth.users.
-- For demonstration, we'll use placeholder UUIDs. Replace with actual IDs if needed for testing.
INSERT INTO fun.memes (id, video_id, image_url, caption_pt, caption_en, status, author_id, created_at)
VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 'https://example.com/meme1.jpg', 'Quando a Monynha Fun te salva do tédio', 'When Monynha Fun saves you from boredom', 'approved', '00000000-0000-0000-0000-000000000000', now()),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', NULL, 'https://example.com/meme2.gif', 'Eu depois de ver um biscoito viral', 'Me after seeing a viral thirst trap', 'pending', '00000000-0000-0000-0000-000000000000', now()),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', NULL, 'https://example.com/meme3.png', 'Aquele momento que você encontra a pérola rara', 'That moment you find the rare gem', 'approved', '00000000-0000-0000-0000-000000000000', now());

-- Important: Replace '00000000-0000-0000-0000-000000000000' with actual user IDs from auth.users
-- if you want these memes to be associated with specific users.
-- For video_id, replace NULL with actual video IDs from fun.videos if you want to link memes to videos.

-- Refresh the materialized view after seeding data that might affect it
REFRESH MATERIALIZED VIEW CONCURRENTLY fun.video_suggestions_count;