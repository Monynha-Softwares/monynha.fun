-- Create the 'fun' schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS fun;

-- Create the memes table
CREATE TABLE fun.memes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id UUID REFERENCES fun.videos(id) ON DELETE SET NULL,
  image_url TEXT NOT NULL,
  caption_pt TEXT,
  caption_en TEXT,
  caption_es TEXT,
  caption_fr TEXT,
  author_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE fun.memes ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Enable read access for all users" ON fun.memes FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON fun.memes FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for users based on author_id" ON fun.memes FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Enable delete for users based on author_id" ON fun.memes FOR DELETE USING (auth.uid() = author_id);

-- Function to set updated_at timestamp
CREATE OR REPLACE FUNCTION fun.set_current_timestamp_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update 'updated_at' on each row update
CREATE TRIGGER set_memes_updated_at
BEFORE UPDATE ON fun.memes
FOR EACH ROW
EXECUTE FUNCTION fun.set_current_timestamp_updated_at();