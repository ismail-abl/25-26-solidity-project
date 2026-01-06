# 25-26-solidity-project

## RentART - Plateforme de Location d'Art en Web3

### 1. Introduction
Le marché de l’art souffre d’un paradoxe : des œuvres de grande valeur restent inaccessibles ou peu monétisées hors ventes directes. Les artistes peinent à générer des revenus récurrents, tandis que les collectionneurs et institutions manquent d’outils sécurisés pour louer des pièces exceptionnelles. RentART propose une solution via la blockchain et les NFT, transformant la location d’art en un écosystème transparent, sécurisé et économiquement viable. La plateforme Web3 intègre un token utilitaire ($RENTART), des contrats intelligents et une gouvernance DAO pour répondre aux défis du secteur.

### 2. Problème
- Monétisation limitée : dépendance aux ventes ponctuelles.
- Risques de location : absence de cadre sécurisé pour les prêts temporaires (dégradations, litiges, frais cachés).
- Opacité du marché : traçabilité insuffisante, limitant la confiance.
- Accès élitiste : les pièces d’exception restent réservées aux grands acteurs.

### 3. Solution Web3/Blockchain
- **NFTs** : certificats d’authenticité et de propriété immuables.
- **Smart Contracts** : automatisent la location (durée, prix, dépôt en $RENTART), gèrent les royalties (5-10% aux artistes).
- **Token $RENTART** : paiements des loyers et dépôts, récompenses de staking pour artistes et curateurs.
- **DAO d’Arbitrage** : résolution décentralisée des litiges (ex. dégradation d’une œuvre).
- **Traçabilité** : historique public des locations sur blockchain.
- **Avantages clés** : frais réduits vs plateformes traditionnelles, zéro fraude grâce aux NFTs.

### 4. Concurrents et Positionnement

| Plateforme | Offre | Limites | Avantage RentART |
| --- | --- | --- | --- |
| Artsy | Vente/location Web2 | Frais élevés (~25%), traçabilité limitée | Frais réduits (5-10%), transparence blockchain |
| Maecenas | Fractionnement tokenisé | Faible notoriété, accès limité | Accès simplifié, meilleure UX, intégration location |
| OpenSea (Web3) | Vente/échange NFT | Focus spéculatif, peu centré art physique | Hybridation physique/digital, focus artistique et locatif |
| Airbnb (Web2) | Location d’espaces | Non conçu pour l’art, aucun suivi d’œuvres | Spécialisé art, gestion d’inventaire, traçabilité blockchain |
| Async Art (Web3) | Art programmable (NFT) | Complexité, marché de niche | Interface simplifiée, ciblage collectionneurs physiques |

### 5. Business Model
1. **Commissions sur locations** : ~5% par transaction (artiste + plateforme).
2. **Frais de tokenisation** : coût unique en $RENTART pour créer un NFT lié à une œuvre physique.
3. **Frais de sous-location** : ~2% lorsqu’un locataire reloue une œuvre.

### 6. Aspects Légaux (Suisse)
- **Token utilitaire** : $RENTART (non security).
- **Smart contracts** : reconnus dans le cadre DLT.
- **NFTs** : preuve de propriété avec lien physique-numérique (certification).
- **Conformité** : KYC pour artistes/locataires ; DAO d’arbitrage structurée en association (art. 60 CC).
- **Assurances** : couverture des œuvres physiques envisageable.

### 7. Design

#### 7.1 Grandes Fonctionnalités
- **Marketplace** : filtres par type d’art (physique/digital), prix, durée, localisation.
- **Gestion des locations** : calendrier de disponibilité, alertes (fin de location, retour).
- **DAO d’Arbitrage** : jurés votants rémunérés en $RENTART, escrow des fonds en cas de litige.
- **Portefeuille utilisateur** : historique des locations, NFTs détenus, récompenses de staking.

#### 7.2 Utilisateurs, Rôles et Permissions

| Rôle | Permissions | Accès |
| --- | --- | --- |
| Artiste | Tokeniser une œuvre (NFT), fixer prix/durée, recevoir royalties | Marketplace, portefeuille, dashboard ventes |
| Locataire | Louer/sous-louer, option d’achat, noter les œuvres | Recherche, calendrier, portefeuille |
| Curateur | Voter en DAO pour valider les artistes, proposer des expositions virtuelles | Dashboard DAO, catalogue d’artistes |
| Admin | Modérer les contenus, mettre à jour les paramètres du protocole | Backend, outils de modération |
| Arbitre DAO | Résoudre les litiges (vote), bloquer les dépôts litigieux | Interface d’arbitrage, historique des transactions |

#### 7.3 Stockage des Données
- **Blockchain** : NFTs, smart contracts de location (durée, prix, clauses), transactions $RENTART (ERC-20), votes DAO.
- **Off-Chain** : profils utilisateurs (KYC, historiques), métadonnées non sensibles (descriptions, avis), logs d’activité.
- **Stockage décentralisé (IPFS/Filecoin)** : fichiers haute résolution (images, vidéos), certificats d’authentification.

### Conclusion
- **Pour les artistes** : revenus récurrents et royalties automatiques.
- **Pour les collectionneurs** : accès sécurisé à des œuvres exclusives, traçabilité blockchain.
- **Pour l’écosystème** : modèle légal (Suisse) et économique soutenable (frais + commissions).

**Prochaines étapes**
1. Implémentation complète durant le projet.
2. Ciblage d’un marché de l’art estimé à ~65 milliards USD avec une solution décentralisée, accessible et rentable.
