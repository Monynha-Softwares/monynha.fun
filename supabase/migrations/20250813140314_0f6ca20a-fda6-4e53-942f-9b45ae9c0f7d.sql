SET search_path TO fun, public;

-- This migration creates the initial tables for the Monynha Fun application.

-- Create 'categories' table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    title_pt TEXT NOT NULL,
    title_en TEXT NOT NULL,
    title_es TEXT NOT NULL,
    title_fr TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create 'tags' table
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    color TEXT,
    is_special BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create 'videos' table
CREATE TABLE videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    embed_url TEXT NOT NULL,
    platform TEXT NOT NULL,
    platform_id TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'pt',
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    storage_mode TEXT NOT NULL DEFAULT 'remote', -- 'remote', 'hosted'
    votes_count INTEGER DEFAULT 0,
    submitted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    approved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    approved_at TIMESTAMP WITH TIME ZONE,
    UNIQUE (platform, platform_id)
);

-- Create 'video_categories' join table
CREATE TABLE video_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (video_id, category_id)
);

-- Create 'video_tags' join table
CREATE TABLE video_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (video_id, tag_id)
);

-- Create 'suggestions' table for votes
CREATE TABLE suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    vote INTEGER NOT NULL DEFAULT 1, -- 1 for upvote, -1 for downvote
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (video_id, user_id)
);

-- Create 'profiles' table for user metadata
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    role TEXT NOT NULL DEFAULT 'user', -- 'user', 'moderator', 'admin'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for 'categories'
CREATE POLICY "Public categories are viewable by everyone." ON categories FOR SELECT USING (TRUE);

-- RLS Policies for 'tags'
CREATE POLICY "Public tags are viewable by everyone." ON tags FOR SELECT USING (TRUE);

-- RLS Policies for 'videos'
CREATE POLICY "Approved videos are viewable by everyone." ON videos FOR SELECT USING (status = 'approved');
CREATE POLICY "Users can view their own pending videos." ON videos FOR SELECT USING (auth.uid() = submitted_by);
CREATE POLICY "Authenticated users can insert videos." ON videos FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can update their own pending videos." ON videos FOR UPDATE USING (auth.uid() = submitted_by AND status = 'pending');
CREATE POLICY "Moderators can update any video." ON videos FOR UPDATE USING (auth.uid() IN (SELECT user_id FROM profiles WHERE role IN ('moderator', 'admin')));

-- RLS Policies for 'video_categories'
CREATE POLICY "Video categories are viewable by everyone." ON video_categories FOR SELECT USING (TRUE);
CREATE POLICY "Authenticated users can insert video categories." ON video_categories FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can delete their own video categories." ON video_categories FOR DELETE USING (auth.uid() IN (SELECT submitted_by FROM videos WHERE id = video_id));

-- RLS Policies for 'video_tags'
CREATE POLICY "Video tags are viewable by everyone." ON video_tags FOR SELECT USING (TRUE);
CREATE POLICY "Authenticated users can insert video tags." ON video_tags FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can delete their own video tags." ON video_tags FOR DELETE USING (auth.uid() IN (SELECT submitted_by FROM videos WHERE id = video_id));

-- RLS Policies for 'suggestions'
CREATE POLICY "Suggestions are viewable by everyone." ON suggestions FOR SELECT USING (TRUE);
CREATE POLICY "Authenticated users can insert suggestions." ON suggestions FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can delete their own suggestions." ON suggestions FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for 'profiles'
CREATE POLICY "Public profiles are viewable by everyone." ON profiles FOR SELECT USING (TRUE);
CREATE POLICY "Users can create their own profile." ON profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own profile." ON profiles FOR UPDATE USING (auth.uid() = user_id);