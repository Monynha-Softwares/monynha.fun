SET search_path TO fun, public;

-- This migration adds triggers and functions for managing video votes and status.

-- Function to update votes_count on videos table
CREATE OR REPLACE FUNCTION update_video_votes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE videos
        SET votes_count = votes_count + NEW.vote
        WHERE id = NEW.video_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE videos
        SET votes_count = votes_count - OLD.vote
        WHERE id = OLD.video_id;
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE videos
        SET votes_count = votes_count - OLD.vote + NEW.vote
        WHERE id = NEW.video_id;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call update_video_votes after insert/update/delete on suggestions
CREATE TRIGGER tr_update_video_votes
AFTER INSERT OR UPDATE OR DELETE ON suggestions
FOR EACH ROW EXECUTE FUNCTION update_video_votes();

-- Function to automatically approve videos when votes_count reaches a threshold
CREATE OR REPLACE FUNCTION check_video_approval()
RETURNS TRIGGER AS $$
DECLARE
    approval_threshold INTEGER := 5; -- Default threshold, can be configured via environment variable or settings table
BEGIN
    -- Check if the video status is pending and votes_count reaches the threshold
    IF NEW.status = 'pending' AND NEW.votes_count >= approval_threshold THEN
        NEW.status = 'approved';
        NEW.approved_at = NOW();
        NEW.approved_by = NULL; -- Approved by community, not a specific user
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call check_video_approval before update on videos
CREATE TRIGGER tr_check_video_approval
BEFORE UPDATE ON videos
FOR EACH ROW EXECUTE FUNCTION check_video_approval();

-- Seed data for categories
INSERT INTO categories (slug, title_pt, title_en, title_es, title_fr) VALUES
('memes', 'Memes', 'Memes', 'Memes', 'Mèmes'),
('educacao', 'Educação', 'Education', 'Educación', 'Éducation'),
('cultura', 'Cultura Pop', 'Pop Culture', 'Cultura Pop', 'Culture Pop'),
('receitas', 'Receitas', 'Recipes', 'Recetas', 'Recettes'),
('musica', 'Música', 'Music', 'Música', 'Musique'),
('tecnologia', 'Tecnologia', 'Technology', 'Tecnología', 'Technologie'),
('humor', 'Humor', 'Humor', 'Humor', 'Humour'),
('noticias', 'Notícias', 'News', 'Noticias', 'Actualités');

-- Seed data for tags
INSERT INTO tags (name, is_special, color) VALUES
('biscoito', TRUE, '#FFD700'),
('viral', TRUE, '#FF6347'),
('clássico', TRUE, '#9370DB'),
('engraçado', FALSE, NULL),
('curioso', FALSE, NULL),
('tutorial', FALSE, NULL),
('dica', FALSE, NULL),
('nostalgia', FALSE, NULL);

-- Seed data for example videos (adjust as needed)
INSERT INTO videos (title, description, embed_url, platform, platform_id, language, status, storage_mode, submitted_by, votes_count) VALUES
('Gato tocando piano', 'Um gato muito talentoso mostrando suas habilidades musicais.', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 'youtube', 'dQw4w9WgXcQ', 'pt', 'approved', 'remote', NULL, 10),
('Receita de bolo de cenoura', 'Aprenda a fazer um delicioso bolo de cenoura com cobertura de chocolate.', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 'youtube', 'dQw4w9WgXcQ', 'pt', 'approved', 'remote', NULL, 15),
('Documentário sobre o espaço', 'Uma jornada fascinante pelo universo e seus mistérios.', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 'youtube', 'dQw4w9WgXcQ', 'pt', 'pending', 'remote', NULL, 3),
('Cachorro surfista', 'Um cachorro radical pegando ondas como um profissional.', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 'youtube', 'dQw4w9WgXcQ', 'en', 'pending', 'remote', NULL, 2),
('Melhores memes de 2024', 'Uma compilação dos memes mais engraçados do ano.', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 'youtube', 'dQw4w9WgXcQ', 'pt', 'approved', 'remote', NULL, 20);

-- Link videos to categories
INSERT INTO video_categories (video_id, category_id) VALUES
((SELECT id FROM videos WHERE title = 'Gato tocando piano'), (SELECT id FROM categories WHERE slug = 'musica')),
((SELECT id FROM videos WHERE title = 'Gato tocando piano'), (SELECT id FROM categories WHERE slug = 'humor')),
((SELECT id FROM videos WHERE title = 'Receita de bolo de cenoura'), (SELECT id FROM categories WHERE slug = 'receitas')),
((SELECT id FROM videos WHERE title = 'Documentário sobre o espaço'), (SELECT id FROM categories WHERE slug = 'educacao')),
((SELECT id FROM videos WHERE title = 'Cachorro surfista'), (SELECT id FROM categories WHERE slug = 'cultura')),
((SELECT id FROM videos WHERE title = 'Melhores memes de 2024'), (SELECT id FROM categories WHERE slug = 'memes'));

-- Link videos to tags
INSERT INTO video_tags (video_id, tag_id) VALUES
((SELECT id FROM videos WHERE title = 'Gato tocando piano'), (SELECT id FROM tags WHERE name = 'engraçado')),
((SELECT id FROM videos WHERE title = 'Receita de bolo de cenoura'), (SELECT id FROM tags WHERE name = 'dica')),
((SELECT id FROM videos WHERE title = 'Documentário sobre o espaço'), (SELECT id FROM tags WHERE name = 'curioso')),
((SELECT id FROM videos WHERE title = 'Cachorro surfista'), (SELECT id FROM tags WHERE name = 'viral')),
((SELECT id FROM videos WHERE title = 'Melhores memes de 2024'), (SELECT id FROM tags WHERE name = 'viral'));