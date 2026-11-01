-- =====================================================================
--  MPD MySQL — Gestion de Stock & Ventes
--  11 tables · MySQL 8.0.16+ (les CHECK ne sont appliquées qu'à partir de cette version)
-- =====================================================================

DROP DATABASE IF EXISTS gestion_stock_ventes;
CREATE DATABASE gestion_stock_ventes
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE gestion_stock_ventes;

-- ---------------------------------------------------------------------
--  1. ACCÈS
-- ---------------------------------------------------------------------
CREATE TABLE role (
    id_role  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    libelle  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id_role),
    UNIQUE KEY uq_role_libelle (libelle)
) ENGINE=InnoDB;

CREATE TABLE utilisateur (
    id_utilisateur  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom             VARCHAR(80)  NOT NULL,
    prenom          VARCHAR(80)  NOT NULL,
    email           VARCHAR(150) NOT NULL,
    mot_de_passe    VARCHAR(255) NOT NULL,          -- stocker un hash, jamais le mot de passe en clair
    actif           BOOLEAN      NOT NULL DEFAULT TRUE,
    id_role         INT UNSIGNED NOT NULL,          -- relation "possède" (1,1)
    PRIMARY KEY (id_utilisateur),
    UNIQUE KEY uq_utilisateur_email (email),
    CONSTRAINT fk_utilisateur_role
        FOREIGN KEY (id_role) REFERENCES role (id_role)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  2. CATALOGUE & STOCK
-- ---------------------------------------------------------------------
CREATE TABLE categorie (
    id_categorie   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom_categorie  VARCHAR(100) NOT NULL,
    description    TEXT NULL,
    PRIMARY KEY (id_categorie),
    UNIQUE KEY uq_categorie_nom (nom_categorie)
) ENGINE=InnoDB;

CREATE TABLE produit (
    id_produit      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    reference       VARCHAR(50)   NOT NULL,
    nom_produit     VARCHAR(150)  NOT NULL,
    description     TEXT NULL,
    prix_unitaire   DECIMAL(12,2) NOT NULL,
    quantite_stock  INT           NOT NULL DEFAULT 0,
    seuil_alerte    INT           NOT NULL DEFAULT 5,
    id_categorie    INT UNSIGNED  NOT NULL,         -- relation "appartient à" (1,1)
    PRIMARY KEY (id_produit),
    UNIQUE KEY uq_produit_reference (reference),
    KEY idx_produit_nom (nom_produit),
    CONSTRAINT fk_produit_categorie
        FOREIGN KEY (id_categorie) REFERENCES categorie (id_categorie)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_produit_prix   CHECK (prix_unitaire >= 0),
    CONSTRAINT ck_produit_stock  CHECK (quantite_stock >= 0),
    CONSTRAINT ck_produit_seuil  CHECK (seuil_alerte >= 0)
) ENGINE=InnoDB;

CREATE TABLE mouvement_stock (
    id_mouvement    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type_mouvement  ENUM('ENTREE','SORTIE','AJUSTEMENT') NOT NULL,
    quantite        INT          NOT NULL,
    date_mouvement  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_produit      INT UNSIGNED NOT NULL,          -- relation "concerne" (1,1)
    id_utilisateur  INT UNSIGNED NOT NULL,          -- relation "enregistre" (1,1)
    PRIMARY KEY (id_mouvement),
    KEY idx_mouvement_date (date_mouvement),
    CONSTRAINT fk_mouvement_produit
        FOREIGN KEY (id_produit) REFERENCES produit (id_produit)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_mouvement_utilisateur
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateur (id_utilisateur)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_mouvement_quantite CHECK (quantite <> 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  3. CLIENTS & COMMANDES
-- ---------------------------------------------------------------------
CREATE TABLE client (
    id_client  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom        VARCHAR(80)  NOT NULL,
    prenom     VARCHAR(80)  NOT NULL,
    telephone  VARCHAR(30)  NULL,
    email      VARCHAR(150) NULL,
    adresse    VARCHAR(255) NULL,
    PRIMARY KEY (id_client),
    UNIQUE KEY uq_client_email (email),             -- plusieurs NULL sont autorisés
    KEY idx_client_nom (nom, prenom)
) ENGINE=InnoDB;

CREATE TABLE commande (
    id_commande    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    date_commande  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    statut         ENUM('EN_ATTENTE','CONFIRMEE','LIVREE','ANNULEE') NOT NULL DEFAULT 'EN_ATTENTE',
    id_client      INT UNSIGNED NOT NULL,           -- relation "passe" (1,1)
    PRIMARY KEY (id_commande),
    KEY idx_commande_statut (statut),
    CONSTRAINT fk_commande_client
        FOREIGN KEY (id_client) REFERENCES client (id_client)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE ligne_commande (
    id_commande    INT UNSIGNED  NOT NULL,          -- relation "contient"
    id_produit     INT UNSIGNED  NOT NULL,          -- relation "concerne"
    quantite       INT           NOT NULL,
    prix_unitaire  DECIMAL(12,2) NOT NULL,          -- prix figé au moment de la commande
    PRIMARY KEY (id_commande, id_produit),
    CONSTRAINT fk_lcommande_commande
        FOREIGN KEY (id_commande) REFERENCES commande (id_commande)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lcommande_produit
        FOREIGN KEY (id_produit) REFERENCES produit (id_produit)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_lcommande_quantite CHECK (quantite > 0),
    CONSTRAINT ck_lcommande_prix     CHECK (prix_unitaire >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  4. VENTES & FACTURATION
-- ---------------------------------------------------------------------
CREATE TABLE vente (
    id_vente       INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    date_vente     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    montant_total  DECIMAL(14,2) NOT NULL DEFAULT 0,
    id_client      INT UNSIGNED  NOT NULL,          -- relation "effectue" (1,1)
    PRIMARY KEY (id_vente),
    KEY idx_vente_date (date_vente),
    CONSTRAINT fk_vente_client
        FOREIGN KEY (id_client) REFERENCES client (id_client)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_vente_montant CHECK (montant_total >= 0)
) ENGINE=InnoDB;

CREATE TABLE ligne_vente (
    id_vente       INT UNSIGNED  NOT NULL,          -- relation "contient"
    id_produit     INT UNSIGNED  NOT NULL,          -- relation "concerne"
    quantite       INT           NOT NULL,
    prix_unitaire  DECIMAL(12,2) NOT NULL,          -- prix figé au moment de la vente
    PRIMARY KEY (id_vente, id_produit),
    CONSTRAINT fk_lvente_vente
        FOREIGN KEY (id_vente) REFERENCES vente (id_vente)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lvente_produit
        FOREIGN KEY (id_produit) REFERENCES produit (id_produit)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_lvente_quantite CHECK (quantite > 0),
    CONSTRAINT ck_lvente_prix     CHECK (prix_unitaire >= 0)
) ENGINE=InnoDB;

CREATE TABLE facture (
    id_facture      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    numero_facture  VARCHAR(30)   NOT NULL,
    date_facture    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    montant_total   DECIMAL(14,2) NOT NULL,
    chemin_pdf      VARCHAR(255)  NULL,
    id_vente        INT UNSIGNED  NOT NULL,         -- relation "génère" (1,1) - (1,1)
    PRIMARY KEY (id_facture),
    UNIQUE KEY uq_facture_numero (numero_facture),
    UNIQUE KEY uq_facture_vente (id_vente),         -- une vente = une seule facture
    CONSTRAINT fk_facture_vente
        FOREIGN KEY (id_vente) REFERENCES vente (id_vente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_facture_montant CHECK (montant_total >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  Données de départ (exemple, à adapter)
-- ---------------------------------------------------------------------
INSERT INTO role (libelle) VALUES ('Administrateur'), ('Vendeur'), ('Gestionnaire de stock');
