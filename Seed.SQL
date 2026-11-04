-- =====================================================================
--  Seed.SQL — Jeu de données d'exemple
--  Base : gestion_stock_ventes (voir mpd_gestion_stock_ventes.sql)
--
--  À exécuter APRÈS le script du MPD, sur une base vide :
--      mysql -u root -p < Seed.SQL
--
--  Contenu : 4 rôles, 8 utilisateurs, 6 catégories, 18 produits,
--            12 clients, 10 commandes, 15 ventes, 15 factures,
--            et l'historique complet des mouvements de stock.
--
--  Mot de passe de TOUS les utilisateurs de test : Passer@123
--  (stocké en SHA-256 pour l'exemple ; en vrai projet, utiliser bcrypt)
-- =====================================================================

USE gestion_stock_ventes;
SET NAMES utf8mb4;

-- (Optionnel) Pour rejouer le script sur une base déjà remplie, décommenter :
-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE facture;        TRUNCATE TABLE ligne_vente;   TRUNCATE TABLE vente;
-- TRUNCATE TABLE ligne_commande; TRUNCATE TABLE commande;      TRUNCATE TABLE client;
-- TRUNCATE TABLE mouvement_stock; TRUNCATE TABLE produit;      TRUNCATE TABLE categorie;
-- TRUNCATE TABLE utilisateur;    TRUNCATE TABLE role;
-- SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- Table des Rôles (INSERT IGNORE : les 3 premiers existent déjà dans le MPD)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO role (libelle)
VALUES ('Administrateur'),
       ('Vendeur'),
       ('Gestionnaire de stock'),
       ('Comptable');

-- ---------------------------------------------------------------------
-- Table des Utilisateurs
-- Le dernier utilisateur est inactif (actif = FALSE) pour tester les filtres.
-- ---------------------------------------------------------------------
INSERT INTO utilisateur (nom, prenom, email, mot_de_passe, actif, id_role)
VALUES ('Traoré', 'Aminata', 'aminata.traore@boutique-demo.ml', SHA2('Passer@123', 256), TRUE, 1),
       ('Diarra', 'Moussa', 'moussa.diarra@boutique-demo.ml', SHA2('Passer@123', 256), TRUE, 2),
       ('Keïta', 'Fatoumata', 'fatoumata.keita@boutique-demo.ml', SHA2('Passer@123', 256), TRUE, 2),
       ('Coulibaly', 'Ibrahim', 'ibrahim.coulibaly@boutique-demo.ml', SHA2('Passer@123', 256), TRUE, 3),
       ('Sangaré', 'Awa', 'awa.sangare@boutique-demo.ml', SHA2('Passer@123', 256), TRUE, 2),
       ('Camara', 'Seydou', 'seydou.camara@boutique-demo.ml', SHA2('Passer@123', 256), TRUE, 4),
       ('Doumbia', 'Mariam', 'mariam.doumbia@boutique-demo.ml', SHA2('Passer@123', 256), TRUE, 3),
       ('Sidibé', 'Oumar', 'oumar.sidibe@boutique-demo.ml', SHA2('Passer@123', 256), FALSE, 2);

-- ---------------------------------------------------------------------
-- Table des Catégories
-- ---------------------------------------------------------------------
INSERT INTO categorie (nom_categorie, description)
VALUES ('T-shirts', 'Hauts à manches courtes, coton et mélanges'),
       ('Hoodies et Vestes', 'Pièces chaudes et vêtements d''extérieur'),
       ('Pantalons', 'Jeans, cargos, joggings et shorts'),
       ('Chaussures', 'Baskets et sandales'),
       ('Casquettes et Bonnets', 'Couvre-chefs pour toute la famille'),
       ('Accessoires', 'Ceintures, sacs et petits articles');

-- ---------------------------------------------------------------------
-- Table des Produits
-- quantite_stock = résultat de tous les mouvements de stock ci-dessous. Plusieurs produits sont sous le seuil d'alerte, un est à 0.
-- ---------------------------------------------------------------------
INSERT INTO produit (reference, nom_produit, description, prix_unitaire, quantite_stock, seuil_alerte, id_categorie)
VALUES ('TSH-001', 'T-shirt Basic Noir', 'Coton 100 %, coupe regular', 7500.00, 105, 15, 1),
       ('TSH-002', 'T-shirt Oversize Blanc', 'Coupe oversize, coton épais', 9500.00, 55, 15, 1),
       ('TSH-003', 'T-shirt Graphique Savane', 'Impression sérigraphiée', 12000.00, 42, 10, 1),
       ('HOO-001', 'Hoodie Capuche Gris', 'Molleton intérieur gratté', 22000.00, 48, 8, 2),
       ('HOO-002', 'Hoodie Zippé Noir', 'Fermeture zippée, deux poches', 25000.00, 29, 8, 2),
       ('VES-001', 'Veste Bomber Kaki', 'Doublure légère, col côtelé', 38000.00, 5, 5, 2),
       ('VES-002', 'Veste Coupe-vent', 'Légère et imperméable', 27500.00, 24, 6, 2),
       ('PAN-001', 'Jean Slim Bleu', 'Denim stretch, coupe slim', 18500.00, 47, 10, 3),
       ('PAN-002', 'Pantalon Cargo Beige', 'Six poches, coupe droite', 21000.00, 40, 8, 3),
       ('PAN-003', 'Jogging Noir', 'Taille élastique, intérieur doux', 15000.00, 52, 10, 3),
       ('PAN-004', 'Short en Jean', 'Denim délavé', 12500.00, 0, 8, 3),
       ('CHA-001', 'Baskets Blanches Urban', 'Semelle épaisse, cuir synthétique', 32000.00, 58, 8, 4),
       ('CHA-002', 'Baskets Montantes Noires', 'Tige haute, lacets renforcés', 36000.00, 4, 6, 4),
       ('CHA-003', 'Sandales Cuir', 'Cuir véritable, semelle souple', 14000.00, 28, 8, 4),
       ('CAS-001', 'Casquette Snapback Noire', 'Réglable, visière plate', 6500.00, 104, 15, 5),
       ('CAS-002', 'Bonnet Côtelé Gris', 'Maille côtelée', 5000.00, 8, 10, 5),
       ('ACC-001', 'Ceinture en Cuir', 'Boucle métal, largeur 3,5 cm', 9000.00, 2, 6, 6),
       ('ACC-002', 'Sac à Dos Urbain', 'Compartiment ordinateur 15 pouces', 24000.00, 3, 5, 6);

-- ---------------------------------------------------------------------
-- Table des Clients
-- Certains clients n'ont ni téléphone ni email (NULL) pour tester les champs facultatifs.
-- ---------------------------------------------------------------------
INSERT INTO client (nom, prenom, telephone, email, adresse)
VALUES ('Konaté', 'Bakary', '+223 76 12 34 56', 'bakary.konate@mail-demo.ml', 'Hamdallaye ACI 2000, Bamako'),
       ('Maïga', 'Aïssata', '+223 66 23 45 67', 'aissata.maiga@mail-demo.ml', 'Badalabougou, Bamako'),
       ('Touré', 'Lassana', NULL, NULL, 'Magnambougou, Bamako'),
       ('Dembélé', 'Kadiatou', '+223 65 45 67 89', 'kadiatou.dembele@mail-demo.ml', 'Lafiabougou, Bamako'),
       ('Sow', 'Amadou', '+223 77 56 78 90', 'amadou.sow@mail-demo.ml', 'Korofina Nord, Bamako'),
       ('Ouédraogo', 'Salimata', '+223 70 67 89 01', 'salimata.ouedraogo@mail-demo.ml', 'Sogoniko, Bamako'),
       ('Cissé', 'Boubacar', '+223 76 78 90 12', NULL, 'Niamakoro, Bamako'),
       ('Bagayoko', 'Nana', '+223 66 89 01 23', 'nana.bagayoko@mail-demo.ml', 'Kalaban Coura, Bamako'),
       ('Haïdara', 'Mahamadou', '+223 79 90 12 34', 'mahamadou.haidara@mail-demo.ml', 'Sabalibougou, Bamako'),
       ('Samaké', 'Rokia', '+223 65 01 23 45', 'rokia.samake@mail-demo.ml', 'Hippodrome, Bamako'),
       ('Diakité', 'Souleymane', '+223 77 12 43 65', NULL, 'Djicoroni Para, Bamako'),
       ('Berthé', 'Hawa', '+223 70 21 32 43', 'hawa.berthe@mail-demo.ml', 'Quinzambougou, Bamako');

-- ---------------------------------------------------------------------
-- Table des Commandes
-- IDs générés : 1 à 10. Les commandes ne modifient pas le stock : seules les ventes le font.
-- ---------------------------------------------------------------------
INSERT INTO commande (id_client, date_commande, statut)
VALUES (1, '2026-09-03 10:15:00', 'LIVREE'),
       (2, '2026-09-10 14:30:00', 'LIVREE'),
       (5, '2026-09-18 09:05:00', 'LIVREE'),
       (4, '2026-09-25 16:45:00', 'ANNULEE'),
       (7, '2026-10-02 11:20:00', 'LIVREE'),
       (9, '2026-10-08 13:10:00', 'CONFIRMEE'),
       (10, '2026-10-15 15:40:00', 'CONFIRMEE'),
       (12, '2026-10-22 10:00:00', 'EN_ATTENTE'),
       (3, '2026-10-28 17:25:00', 'EN_ATTENTE'),
       (6, '2026-11-02 12:35:00', 'EN_ATTENTE');

-- ---------------------------------------------------------------------
-- Table des Lignes de commande
-- La commande 9 demande 2 shorts alors que le stock est à 0 : utile pour tester un contrôle de stock.
-- ---------------------------------------------------------------------
INSERT INTO ligne_commande (id_commande, id_produit, quantite, prix_unitaire)
VALUES (1, 3, 2, 12000.00),
       (1, 15, 1, 6500.00),
       (2, 4, 1, 22000.00),
       (2, 10, 1, 15000.00),
       (3, 12, 2, 32000.00),
       (4, 6, 1, 38000.00),
       (5, 1, 3, 7500.00),
       (5, 2, 2, 9500.00),
       (5, 16, 2, 5000.00),
       (6, 8, 2, 18500.00),
       (6, 17, 2, 9000.00),
       (7, 13, 1, 36000.00),
       (7, 18, 1, 24000.00),
       (8, 5, 2, 25000.00),
       (9, 9, 1, 21000.00),
       (9, 11, 2, 12500.00),
       (9, 15, 2, 6500.00),
       (10, 7, 1, 27500.00),
       (10, 14, 2, 14000.00);

-- ---------------------------------------------------------------------
-- Table des Ventes
-- IDs générés : 1 à 15. montant_total = somme des lignes de vente.
-- ---------------------------------------------------------------------
INSERT INTO vente (id_client, date_vente, montant_total)
VALUES (1, '2026-08-18 10:30:00', 21500.00),
       (2, '2026-08-25 15:10:00', 40500.00),
       (5, '2026-09-01 11:45:00', 45000.00),
       (3, '2026-09-05 09:20:00', 34000.00),
       (4, '2026-09-12 16:05:00', 47000.00),
       (8, '2026-09-19 12:40:00', 45000.00),
       (6, '2026-09-27 14:55:00', 36000.00),
       (11, '2026-10-03 10:10:00', 19000.00),
       (10, '2026-10-09 17:00:00', 37500.00),
       (12, '2026-10-14 13:25:00', 38000.00),
       (9, '2026-10-18 11:15:00', 64500.00),
       (7, '2026-10-24 15:50:00', 34500.00),
       (1, '2026-10-29 10:35:00', 41000.00),
       (2, '2026-11-01 12:00:00', 49000.00),
       (5, '2026-11-03 16:20:00', 29000.00);

-- ---------------------------------------------------------------------
-- Table des Lignes de vente
-- La vente 14 contient un prix promotionnel (jogging à 13 500 au lieu de 15 000).
-- ---------------------------------------------------------------------
INSERT INTO ligne_vente (id_vente, id_produit, quantite, prix_unitaire)
VALUES (1, 1, 2, 7500.00),
       (1, 15, 1, 6500.00),
       (2, 4, 1, 22000.00),
       (2, 8, 1, 18500.00),
       (3, 12, 1, 32000.00),
       (3, 15, 2, 6500.00),
       (4, 2, 2, 9500.00),
       (4, 10, 1, 15000.00),
       (5, 6, 1, 38000.00),
       (5, 17, 1, 9000.00),
       (6, 9, 1, 21000.00),
       (6, 3, 2, 12000.00),
       (7, 13, 1, 36000.00),
       (8, 1, 1, 7500.00),
       (8, 16, 1, 5000.00),
       (8, 15, 1, 6500.00),
       (9, 5, 1, 25000.00),
       (9, 11, 1, 12500.00),
       (10, 18, 1, 24000.00),
       (10, 14, 1, 14000.00),
       (11, 7, 1, 27500.00),
       (11, 8, 2, 18500.00),
       (12, 3, 1, 12000.00),
       (12, 2, 1, 9500.00),
       (12, 15, 2, 6500.00),
       (13, 12, 1, 32000.00),
       (13, 17, 1, 9000.00),
       (14, 10, 2, 13500.00),
       (14, 4, 1, 22000.00),
       (15, 14, 1, 14000.00),
       (15, 1, 2, 7500.00);

-- ---------------------------------------------------------------------
-- Table des Factures
-- Une facture par vente. La dernière n'a pas encore de PDF (chemin_pdf = NULL).
-- ---------------------------------------------------------------------
INSERT INTO facture (numero_facture, date_facture, montant_total, chemin_pdf, id_vente)
VALUES ('FAC-2026-0001', '2026-08-18 10:30:00', 21500.00, 'factures/2026/FAC-2026-0001.pdf', 1),
       ('FAC-2026-0002', '2026-08-25 15:10:00', 40500.00, 'factures/2026/FAC-2026-0002.pdf', 2),
       ('FAC-2026-0003', '2026-09-01 11:45:00', 45000.00, 'factures/2026/FAC-2026-0003.pdf', 3),
       ('FAC-2026-0004', '2026-09-05 09:20:00', 34000.00, 'factures/2026/FAC-2026-0004.pdf', 4),
       ('FAC-2026-0005', '2026-09-12 16:05:00', 47000.00, 'factures/2026/FAC-2026-0005.pdf', 5),
       ('FAC-2026-0006', '2026-09-19 12:40:00', 45000.00, 'factures/2026/FAC-2026-0006.pdf', 6),
       ('FAC-2026-0007', '2026-09-27 14:55:00', 36000.00, 'factures/2026/FAC-2026-0007.pdf', 7),
       ('FAC-2026-0008', '2026-10-03 10:10:00', 19000.00, 'factures/2026/FAC-2026-0008.pdf', 8),
       ('FAC-2026-0009', '2026-10-09 17:00:00', 37500.00, 'factures/2026/FAC-2026-0009.pdf', 9),
       ('FAC-2026-0010', '2026-10-14 13:25:00', 38000.00, 'factures/2026/FAC-2026-0010.pdf', 10),
       ('FAC-2026-0011', '2026-10-18 11:15:00', 64500.00, 'factures/2026/FAC-2026-0011.pdf', 11),
       ('FAC-2026-0012', '2026-10-24 15:50:00', 34500.00, 'factures/2026/FAC-2026-0012.pdf', 12),
       ('FAC-2026-0013', '2026-10-29 10:35:00', 41000.00, 'factures/2026/FAC-2026-0013.pdf', 13),
       ('FAC-2026-0014', '2026-11-01 12:00:00', 49000.00, 'factures/2026/FAC-2026-0014.pdf', 14),
       ('FAC-2026-0015', '2026-11-03 16:20:00', 29000.00, NULL, 15);

-- ---------------------------------------------------------------------
-- Table des Mouvements de stock
-- Stock initial (ENTREE), réassorts, ajustements (quantité négative = perte) et une SORTIE par ligne de vente.
-- ---------------------------------------------------------------------
INSERT INTO mouvement_stock (type_mouvement, quantite, date_mouvement, id_produit, id_utilisateur)
VALUES ('ENTREE', 80, '2026-08-01 08:00:00', 1, 4),
       ('ENTREE', 60, '2026-08-01 08:00:00', 2, 4),
       ('ENTREE', 45, '2026-08-01 08:00:00', 3, 4),
       ('ENTREE', 35, '2026-08-01 08:00:00', 4, 4),
       ('ENTREE', 30, '2026-08-01 08:00:00', 5, 4),
       ('ENTREE', 6, '2026-08-01 08:00:00', 6, 4),
       ('ENTREE', 25, '2026-08-01 08:00:00', 7, 4),
       ('ENTREE', 50, '2026-08-01 08:00:00', 8, 4),
       ('ENTREE', 40, '2026-08-01 08:00:00', 9, 4),
       ('ENTREE', 55, '2026-08-01 08:00:00', 10, 4),
       ('ENTREE', 1, '2026-08-01 08:00:00', 11, 4),
       ('ENTREE', 40, '2026-08-01 08:00:00', 12, 4),
       ('ENTREE', 5, '2026-08-01 08:00:00', 13, 4),
       ('ENTREE', 30, '2026-08-01 08:00:00', 14, 4),
       ('ENTREE', 70, '2026-08-01 08:00:00', 15, 4),
       ('ENTREE', 12, '2026-08-01 08:00:00', 16, 4),
       ('ENTREE', 4, '2026-08-01 08:00:00', 17, 4),
       ('ENTREE', 4, '2026-08-01 08:00:00', 18, 4),
       ('SORTIE', 2, '2026-08-18 10:30:00', 1, 2),
       ('SORTIE', 1, '2026-08-18 10:30:00', 15, 2),
       ('SORTIE', 1, '2026-08-25 15:10:00', 4, 3),
       ('SORTIE', 1, '2026-08-25 15:10:00', 8, 3),
       ('SORTIE', 1, '2026-09-01 11:45:00', 12, 5),
       ('SORTIE', 2, '2026-09-01 11:45:00', 15, 5),
       ('SORTIE', 2, '2026-09-05 09:20:00', 2, 2),
       ('SORTIE', 1, '2026-09-05 09:20:00', 10, 2),
       ('SORTIE', 1, '2026-09-12 16:05:00', 6, 3),
       ('SORTIE', 1, '2026-09-12 16:05:00', 17, 3),
       ('ENTREE', 30, '2026-09-15 09:30:00', 1, 7),
       ('ENTREE', 40, '2026-09-15 09:30:00', 15, 7),
       ('ENTREE', 20, '2026-09-15 09:30:00', 12, 7),
       ('ENTREE', 15, '2026-09-15 09:30:00', 4, 7),
       ('SORTIE', 1, '2026-09-19 12:40:00', 9, 5),
       ('SORTIE', 2, '2026-09-19 12:40:00', 3, 5),
       ('SORTIE', 1, '2026-09-27 14:55:00', 13, 2),
       ('SORTIE', 1, '2026-10-03 10:10:00', 1, 3),
       ('SORTIE', 1, '2026-10-03 10:10:00', 16, 3),
       ('SORTIE', 1, '2026-10-03 10:10:00', 15, 3),
       ('AJUSTEMENT', -3, '2026-10-05 08:45:00', 16, 4),
       ('SORTIE', 1, '2026-10-09 17:00:00', 5, 5),
       ('SORTIE', 1, '2026-10-09 17:00:00', 11, 5),
       ('SORTIE', 1, '2026-10-14 13:25:00', 18, 2),
       ('SORTIE', 1, '2026-10-14 13:25:00', 14, 2),
       ('SORTIE', 1, '2026-10-18 11:15:00', 7, 3),
       ('SORTIE', 2, '2026-10-18 11:15:00', 8, 3),
       ('AJUSTEMENT', -2, '2026-10-20 09:00:00', 2, 1),
       ('SORTIE', 1, '2026-10-24 15:50:00', 3, 5),
       ('SORTIE', 1, '2026-10-24 15:50:00', 2, 5),
       ('SORTIE', 2, '2026-10-24 15:50:00', 15, 5),
       ('AJUSTEMENT', 1, '2026-10-25 08:30:00', 9, 7),
       ('SORTIE', 1, '2026-10-29 10:35:00', 12, 2),
       ('SORTIE', 1, '2026-10-29 10:35:00', 17, 2),
       ('SORTIE', 2, '2026-11-01 12:00:00', 10, 3),
       ('SORTIE', 1, '2026-11-01 12:00:00', 4, 3),
       ('SORTIE', 1, '2026-11-03 16:20:00', 14, 5),
       ('SORTIE', 2, '2026-11-03 16:20:00', 1, 5);

-- =====================================================================
--  Vérifications rapides
-- =====================================================================
SELECT 'role' AS table_nom, COUNT(*) AS nb FROM role
UNION ALL SELECT 'utilisateur', COUNT(*) FROM utilisateur
UNION ALL SELECT 'categorie', COUNT(*) FROM categorie
UNION ALL SELECT 'produit', COUNT(*) FROM produit
UNION ALL SELECT 'mouvement_stock', COUNT(*) FROM mouvement_stock
UNION ALL SELECT 'client', COUNT(*) FROM client
UNION ALL SELECT 'commande', COUNT(*) FROM commande
UNION ALL SELECT 'ligne_commande', COUNT(*) FROM ligne_commande
UNION ALL SELECT 'vente', COUNT(*) FROM vente
UNION ALL SELECT 'ligne_vente', COUNT(*) FROM ligne_vente
UNION ALL SELECT 'facture', COUNT(*) FROM facture;

-- Cohérence du stock : doit retourner 0 ligne
SELECT p.id_produit, p.nom_produit, p.quantite_stock,
       SUM(CASE m.type_mouvement WHEN 'SORTIE' THEN -m.quantite ELSE m.quantite END) AS stock_calcule
FROM produit p
JOIN mouvement_stock m ON m.id_produit = p.id_produit
GROUP BY p.id_produit, p.nom_produit, p.quantite_stock
HAVING p.quantite_stock <> stock_calcule;

-- =====================================================================
--  Requêtes à essayer (décommenter au besoin)
-- =====================================================================
-- Produits à réapprovisionner :
-- SELECT reference, nom_produit, quantite_stock, seuil_alerte FROM produit WHERE quantite_stock <= seuil_alerte ORDER BY quantite_stock;

-- Chiffre d'affaires par mois :
-- SELECT DATE_FORMAT(date_vente, '%Y-%m') AS mois, SUM(montant_total) AS ca FROM vente GROUP BY mois ORDER BY mois;

-- Meilleurs clients :
-- SELECT c.nom, c.prenom, COUNT(v.id_vente) AS nb_ventes, SUM(v.montant_total) AS total
-- FROM client c JOIN vente v ON v.id_client = c.id_client GROUP BY c.id_client ORDER BY total DESC;

-- Détail d'une facture :
-- SELECT f.numero_facture, c.nom, p.nom_produit, lv.quantite, lv.prix_unitaire
-- FROM facture f JOIN vente v ON v.id_vente = f.id_vente JOIN client c ON c.id_client = v.id_client
-- JOIN ligne_vente lv ON lv.id_vente = v.id_vente JOIN produit p ON p.id_produit = lv.id_produit
-- WHERE f.numero_facture = 'FAC-2026-0005';

-- Commandes par statut :
-- SELECT statut, COUNT(*) AS nb FROM commande GROUP BY statut;

-- Test d'une contrainte (doit échouer) : quantité négative
-- INSERT INTO ligne_vente (id_vente, id_produit, quantite, prix_unitaire) VALUES (1, 5, -1, 25000.00);
