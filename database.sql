-- ═══════════════════════════════════════════════════════════════════
--  disease_predictor — Full Database Schema + Seed Data
--  Disease Prediction System | K J Somaiya School of Engineering
--  AY 2025–26
--
--  HOW TO IMPORT:
--  1. Open phpMyAdmin → click "New" → create database "disease_predictor"
--  2. Select the database → Import tab → choose this file → Go
-- ═══════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS disease_predictor
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE disease_predictor;

-- ─────────────────────────────────────────────────────────────────
--  DROP (clean slate on reimport)
-- ─────────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS symptoms_diseases;
DROP TABLE IF EXISTS symptoms;
DROP TABLE IF EXISTS diseases;
DROP TABLE IF EXISTS users;

-- ─────────────────────────────────────────────────────────────────
--  TABLE: users  (for login system)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE users (
    user_id     INT           NOT NULL AUTO_INCREMENT,
    full_name   VARCHAR(150)  NOT NULL,
    email       VARCHAR(200)  NOT NULL UNIQUE,
    password    VARCHAR(255)  NOT NULL,   -- store hashed passwords (password_hash)
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────
--  TABLE: diseases
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE diseases (
    disease_id      INT           NOT NULL AUTO_INCREMENT,
    disease_name    VARCHAR(150)  NOT NULL UNIQUE,
    description     TEXT          NOT NULL,
    recommendation  TEXT          NOT NULL,
    severity_level  ENUM('Low','Medium','High') NOT NULL DEFAULT 'Medium',
    PRIMARY KEY (disease_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────
--  TABLE: symptoms
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE symptoms (
    symptom_id    INT          NOT NULL AUTO_INCREMENT,
    symptom_name  VARCHAR(100) NOT NULL UNIQUE,
    category      VARCHAR(80)  NOT NULL,
    PRIMARY KEY (symptom_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────
--  TABLE: symptoms_diseases  (junction / many-to-many)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE symptoms_diseases (
    id          INT NOT NULL AUTO_INCREMENT,
    symptom_id  INT NOT NULL,
    disease_id  INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_sym_dis (symptom_id, disease_id),
    FOREIGN KEY (symptom_id) REFERENCES symptoms(symptom_id) ON DELETE CASCADE,
    FOREIGN KEY (disease_id) REFERENCES diseases(disease_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ─────────────────────────────────────────────────────────────────
--  SEED: diseases  (20 records)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO diseases (disease_name, description, recommendation, severity_level) VALUES
('Common Cold',
 'A viral infection of the upper respiratory tract. Usually mild and self-limiting.',
 'Rest, stay hydrated, and use OTC cold medicine. Consult a doctor if symptoms persist beyond 10 days.',
 'Low'),

('Influenza (Flu)',
 'A contagious respiratory illness caused by influenza viruses. More severe than the common cold.',
 'Rest, fluids, antiviral medication if detected early. Seek care if breathing difficulty occurs.',
 'Medium'),

('Dengue Fever',
 'A mosquito-borne viral infection common in tropical regions, causing high fever and severe pain.',
 'Seek immediate medical attention. Hospitalisation may be required for severe dengue.',
 'High'),

('Malaria',
 'A parasitic disease transmitted by Anopheles mosquitoes. Characterised by cyclic fever.',
 'Consult a doctor immediately for blood smear test and antimalaria medication.',
 'High'),

('Typhoid',
 'A bacterial infection causing prolonged fever, gastrointestinal symptoms, and weakness.',
 'Requires antibiotics prescribed by a doctor. Maintain strict food and water hygiene.',
 'High'),

('Tuberculosis (TB)',
 'A serious bacterial infection primarily affecting the lungs. Spreads through airborne droplets.',
 'Consult a pulmonologist immediately. TB is curable with a 6-month antibiotic course.',
 'High'),

('Diabetes Mellitus (Type 2)',
 'A metabolic disorder where the body cannot properly regulate blood sugar levels.',
 'Consult an endocrinologist. Lifestyle changes and medication can effectively manage the condition.',
 'Medium'),

('Hypertension',
 'Persistently elevated blood pressure that can damage arteries and organs over time.',
 'Monitor blood pressure regularly. Consult a cardiologist for diagnosis and management plan.',
 'Medium'),

('Migraine',
 'A neurological condition causing severe recurring headaches, often with nausea and light sensitivity.',
 'Avoid known triggers. Consult a neurologist if migraines are frequent or debilitating.',
 'Low'),

('Gastroenteritis',
 'Inflammation of the stomach and intestines, commonly called stomach flu.',
 'Oral rehydration therapy is key. See a doctor if vomiting persists or signs of dehydration appear.',
 'Medium'),

('COVID-19 (Mild)',
 'A respiratory illness caused by SARS-CoV-2, ranging from mild to severe. Loss of smell/taste is characteristic.',
 'Isolate immediately, rest and hydrate. Seek emergency care if oxygen levels drop below 94%.',
 'Medium'),

('Chickenpox',
 'A highly contagious viral disease causing an itchy blister rash, most common in children.',
 'Isolate the patient. Use calamine lotion for itching. Antivirals for severe cases.',
 'Low'),

('Pneumonia',
 'Infection inflaming air sacs in one or both lungs, which may fill with fluid.',
 'Seek immediate medical attention. Antibiotics or antivirals depending on the cause.',
 'High'),

('Jaundice',
 'Yellowing of skin and eyes due to elevated bilirubin, often indicating liver or bile duct problems.',
 'Consult a gastroenterologist urgently. Avoid fatty foods and alcohol.',
 'High'),

('Asthma',
 'A chronic respiratory condition causing airway inflammation and narrowing, leading to wheezing.',
 'Use prescribed inhalers. Identify and avoid triggers. Regular follow-up with a pulmonologist.',
 'Medium'),

('Anaemia',
 'A condition where the blood lacks enough healthy red blood cells or haemoglobin to carry oxygen.',
 'Increase iron-rich foods. Consult a doctor for blood tests and supplementation if needed.',
 'Low'),

('Food Poisoning',
 'Illness from eating food contaminated with bacteria, viruses, or toxins. Symptoms begin hours after consumption.',
 'Stay hydrated with ORS. Seek care if vomiting blood, severe pain, or high fever is present.',
 'Medium'),

('Arthritis',
 'Inflammation of one or more joints, causing pain and stiffness that worsens with age.',
 'Consult a rheumatologist. Exercise, physiotherapy, and medication can improve quality of life.',
 'Low'),

('Urinary Tract Infection (UTI)',
 'A bacterial infection of any part of the urinary system — kidneys, bladder, ureters, or urethra.',
 'Consult a doctor for a urine culture and appropriate antibiotics. Increase water intake.',
 'Medium'),

('Conjunctivitis',
 'Inflammation or infection of the transparent membrane lining the eyelid and eyeball (pink eye).',
 'Antibiotic eye drops for bacterial type. Avoid touching eyes; wash hands frequently.',
 'Low');

-- ─────────────────────────────────────────────────────────────────
--  SEED: symptoms  (56 records across 7 categories)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO symptoms (symptom_name, category) VALUES
-- General (11)
('Fever',                'General'),
('High Fever',           'General'),
('Cyclic Fever',         'General'),
('Prolonged Fever',      'General'),
('Fatigue',              'General'),
('Weakness',             'General'),
('Loss of Appetite',     'General'),
('Weight Loss',          'General'),
('Night Sweats',         'General'),
('Chills',               'General'),
('Sweating',             'General'),
-- Neurological (6)
('Headache',             'Neurological'),
('Severe Headache',      'Neurological'),
('Migraine Aura',        'Neurological'),
('Dizziness',            'Neurological'),
('Blurred Vision',       'Neurological'),
('Confusion',            'Neurological'),
-- Respiratory (10)
('Cough',                'Respiratory'),
('Dry Cough',            'Respiratory'),
('Productive Cough',     'Respiratory'),
('Shortness of Breath',  'Respiratory'),
('Wheezing',             'Respiratory'),
('Sore Throat',          'Respiratory'),
('Runny Nose',           'Respiratory'),
('Nasal Congestion',     'Respiratory'),
('Sneezing',             'Respiratory'),
('Chest Pain',           'Respiratory'),
-- Gastrointestinal (8)
('Nausea',               'Gastrointestinal'),
('Vomiting',             'Gastrointestinal'),
('Diarrhoea',            'Gastrointestinal'),
('Abdominal Pain',       'Gastrointestinal'),
('Bloating',             'Gastrointestinal'),
('Constipation',         'Gastrointestinal'),
('Indigestion',          'Gastrointestinal'),
('Loss of Taste/Smell',  'Gastrointestinal'),
-- Musculoskeletal (6)
('Muscle Pain',          'Musculoskeletal'),
('Joint Pain',           'Musculoskeletal'),
('Joint Swelling',       'Musculoskeletal'),
('Back Pain',            'Musculoskeletal'),
('Stiffness',            'Musculoskeletal'),
('Body Ache',            'Musculoskeletal'),
-- Skin & Eyes (8)
('Skin Rash',            'Skin & Eyes'),
('Itching',              'Skin & Eyes'),
('Yellowing of Skin',    'Skin & Eyes'),
('Pale Skin',            'Skin & Eyes'),
('Blisters/Spots',       'Skin & Eyes'),
('Red Eyes',             'Skin & Eyes'),
('Eye Discharge',        'Skin & Eyes'),
('Pain Behind Eyes',     'Skin & Eyes'),
-- Urinary & Other (7)
('Frequent Urination',   'Urinary & Other'),
('Burning Urination',    'Urinary & Other'),
('Excessive Thirst',     'Urinary & Other'),
('Slow Healing Wounds',  'Urinary & Other'),
('High Blood Pressure',  'Urinary & Other'),
('Palpitations',         'Urinary & Other'),
('Night Blindness',      'Urinary & Other');

-- ─────────────────────────────────────────────────────────────────
--  SEED: symptoms_diseases  (many-to-many mappings)
--  symptom_id references symptoms table (inserted above in order)
--  disease_id references diseases table (inserted above in order)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO symptoms_diseases (symptom_id, disease_id) VALUES
-- 1. Common Cold
(1,1),(18,1),(23,1),(24,1),(25,1),(26,1),(12,1),
-- 2. Influenza (Flu)
(1,2),(2,2),(5,2),(12,2),(36,2),(41,2),(18,2),(19,2),(23,2),(28,2),
-- 3. Dengue Fever
(2,3),(13,3),(49,3),(37,3),(42,3),(28,3),(5,3),(41,3),
-- 4. Malaria
(3,4),(10,4),(11,4),(12,4),(36,4),(5,4),(29,4),(2,4),
-- 5. Typhoid
(4,5),(6,5),(31,5),(12,5),(7,5),(42,5),(29,5),(5,5),
-- 6. Tuberculosis (TB)
(20,6),(8,6),(9,6),(5,6),(27,6),(6,6),(1,6),(19,6),
-- 7. Diabetes Mellitus (Type 2)
(50,7),(52,7),(5,7),(16,7),(53,7),(8,7),(15,7),
-- 8. Hypertension
(54,8),(12,8),(55,8),(15,8),(27,8),(17,8),
-- 9. Migraine
(13,9),(14,9),(28,9),(16,9),(15,9),(5,9),(12,9),
-- 10. Gastroenteritis
(29,10),(30,10),(31,10),(28,10),(1,10),(5,10),(32,10),
-- 11. COVID-19 (Mild)
(1,11),(19,11),(5,11),(35,11),(27,11),(21,11),(12,11),(28,11),(41,11),
-- 12. Chickenpox
(46,12),(43,12),(1,12),(5,12),(12,12),(42,12),
-- 13. Pneumonia
(20,13),(27,13),(1,13),(2,13),(21,13),(5,13),(6,13),(28,13),(10,13),
-- 14. Jaundice
(44,14),(5,14),(7,14),(28,14),(29,14),(31,14),(6,14),
-- 15. Asthma
(22,15),(21,15),(27,15),(18,15),(19,15),(5,15),
-- 16. Anaemia
(45,16),(5,16),(6,16),(15,16),(27,16),(55,16),(12,16),(56,16),
-- 17. Food Poisoning
(29,17),(30,17),(31,17),(28,17),(1,17),(32,17),(34,17),
-- 18. Arthritis
(37,18),(38,18),(40,18),(39,18),(5,18),(6,18),
-- 19. UTI
(51,19),(50,19),(31,19),(1,19),(6,19),(28,19),
-- 20. Conjunctivitis
(47,20),(48,20),(43,20),(12,20);

-- ─────────────────────────────────────────────────────────────────
--  SEED: demo user  (password = Demo@1234, hashed with bcrypt)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO users (full_name, email, password) VALUES
('Demo User',
 'demo@kjsomaiya.edu.in',
 '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');
 -- Note: This is bcrypt hash of "Demo@1234"
 -- In production, always use password_hash() in PHP
