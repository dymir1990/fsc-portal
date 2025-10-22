-- Emergency fix: Create the missing providers directly
-- Based on the flagged items showing Will Corley, Sharon Alexander, etc.

INSERT INTO providers (name) VALUES
('David Chen'),
('Lauren Rivera')
ON CONFLICT (name) DO NOTHING;

-- Also create common providers from the CSV
INSERT INTO providers (name) VALUES
('Will Corley'),
('Sharon Alexander'),
('Angie Ortiz'),
('Josh Steeley'),
('Leesi Cruz'),
('Janet McDonald'),
('Keith McDonald')
ON CONFLICT (name) DO NOTHING;

-- Check what we created
SELECT * FROM providers ORDER BY name;
