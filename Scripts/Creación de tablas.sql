-- Habilita la extensión para generar UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE recipes (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  user_id UUID NOT NULL REFERENCES usuarios(id) ,
  subtitle TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE recipe_images (
  id SERIAL PRIMARY KEY,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  position INTEGER DEFAULT 0 -- opcional: orden de las imágenes
);

CREATE TABLE ingredients (
  id SERIAL PRIMARY KEY,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  amount NUMERIC,           -- soporta decimales
  measure VARCHAR(50),      -- ej. "g", "cup", "tbsp"
  name VARCHAR(255) NOT NULL,
  position INTEGER DEFAULT 0
);

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  group_id INTEGER REFERENCES category_groups(id) ON DELETE SET null,
  image_url TEXT
);

CREATE TABLE category_groups (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL unique,
  image_url TEXT
);

CREATE TABLE recipe_categories (
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (recipe_id, category_id)
);

CREATE TABLE preparation_steps (
  id SERIAL PRIMARY KEY,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  step_number INTEGER NOT NULL, -- 1,2,3...
  description TEXT NOT NULL
);

-- Asignar dueño a todas las tablas
ALTER TABLE usuarios OWNER TO backend;
ALTER TABLE recipes OWNER TO backend;
ALTER TABLE recipe_images OWNER TO backend;
ALTER TABLE categories OWNER TO backend;
ALTER TABLE recipe_categories OWNER TO backend;
ALTER TABLE ingredients OWNER TO backend;
ALTER TABLE preparation_steps OWNER TO backend;
ALTER TABLE category_groups OWNER TO backend;

-- Asignar dueño a las secuencias (muy importante si usás SERIAL)
ALTER SEQUENCE recipes_id_seq OWNER TO backend;
ALTER SEQUENCE categories_id_seq OWNER TO backend;
ALTER SEQUENCE ingredients_id_seq OWNER TO backend;
ALTER SEQUENCE preparation_steps_id_seq OWNER TO backend;
ALTER SEQUENCE category_groups_id_seq OWNER TO backend;

ALTER TABLE category_groups OWNER TO backend;
ALTER SEQUENCE category_groups_id_seq OWNER TO backend;

-- Reemplazá papeeta_user por tu usuario real
GRANT ALL ON SCHEMA public TO backend;

-- Dar permisos para crear objetos dentro del esquema
ALTER SCHEMA public OWNER TO backend;

INSERT INTO category_groups (name)
VALUES 
  ('Categorías Generales'),
  ('Por Tiempo / Dificultad'),
  ('Por Tipo de Cocina'),
  ('Por Ingrediente Principal');

-- Categorías Generales
INSERT INTO categories (name, group_id) VALUES
('Entradas / Aperitivos', 1),
('Platos principales', 1),
('Postres', 1),
('Sopas y caldos', 1),
('Ensaladas', 1),
('Salsas y aderezos', 1),
('Bebidas', 1),
('Snacks / Bocadillos', 1),
('Panadería y repostería', 1);

-- Por Tiempo / Dificultad
INSERT INTO categories (name, group_id) VALUES
('Recetas rápidas (menos de 30 minutos)', 2),
('Recetas fáciles', 2),
('Recetas con pocos ingredientes (5 o menos)', 2),
('Para ocasiones especiales', 2);

-- Por Tipo de Cocina
INSERT INTO categories (name, group_id) VALUES
('Mexicana', 3),
('Italiana', 3),
('Árabe', 3),
('Asiática', 3),
('Mediterránea', 3),
('Estadounidense', 3),
('Argentina', 3);

-- Por Ingrediente Principal
INSERT INTO categories (name, group_id) VALUES
('Pollo', 4),
('Carne vacuna', 4),
('Cerdo', 4),
('Pescado / Mariscos', 4),
('Huevos', 4),
('Queso', 4),
('Pasta', 4),
('Arroz', 4),
('Legumbres', 4),
('Verduras', 4),
('Frutas', 4),
('Papa', 4);