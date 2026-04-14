# Projet solidity: RENTART

## 1. Mise en place de l'environnement de développement
 
### Prérequis
- **Remix IDE** : environnement de développement en ligne pour Solidity
- **MetaMask** : portefeuille Ethereum pour interagir avec les contrats
  
  Normalement suffit pour mettre en place des portefeuilles de test et initier les transactions. Le cas échéant:
- **Réseau de test** : Sepolia, une blockchain publique sur laquelle Google Cloud octroie 0.05 ETH gratuitement. Elle permet de facilement la lier à mon interface web.

### Étapes d'installation
1. Ouvrir [Remix IDE](https://remix.ethereum.org)
2. Importer les trois fichiers de contrats dans le dossier `contracts/`
3. Compiler avec Solidity 0.8.x
4. Connecter MetaMask au réseau de test
5. Déployer les contrats dans l'ordre : Token → NFT → DAPP

---

## 2. Introduction

RentART est une plateforme Web3 de location d'œuvres d'art tokenisées. Elle permet aux artistes de monétiser leurs créations via des locations sécurisées par smart contracts, tout en garantissant traçabilité et transparence grâce à la blockchain. Le projet repose sur trois contrats : un token ERC-20 ($RENTART), un contrat NFT pour les œuvres, et un contrat principal gérant les locations.

---

## 3. Explication détaillée de l'implémentation

### 3.1 contractTOKENRentArt.sol - Token $RENTART

| Fonction | Description |
|----------|-------------|
| `constructor()` | Initialise le token avec nom, symbole et supply initiale |
| `mint(address, uint256)` | Crée de nouveaux tokens (réservé admin) |
| `burn(uint256)` | Détruit des tokens du caller |
| `transfer(address, uint256)` | Transfère des tokens entre utilisateurs |
| `approve(address, uint256)` | Autorise un tiers à dépenser des tokens |

### 3.2 contractNFTRentArt.sol - NFTs des œuvres

| Fonction | Description |
|----------|-------------|
| `mintArtwork(string uri)` | Crée un NFT lié à une œuvre (artiste uniquement) |
| `setRoyalties(uint256 tokenId, uint256 percent)` | Définit le pourcentage de royalties |
| `tokenURI(uint256 tokenId)` | Retourne les métadonnées IPFS de l'œuvre |
| `ownerOf(uint256 tokenId)` | Retourne le propriétaire actuel |
| `transferFrom(address, address, uint256)` | Transfère la propriété du NFT |

### 3.3 contractDAPPRentArt.sol - Gestion des locations

| Fonction | Description |
|----------|-------------|
| `listForRent(uint256 tokenId, uint256 price, uint256 duration)` | Met une œuvre en location |
| `rent(uint256 tokenId)` | Loue une œuvre (paiement en $RENTART) |
| `returnArtwork(uint256 tokenId)` | Retourne l'œuvre et libère le dépôt |
| `claimRoyalties(uint256 tokenId)` | L'artiste récupère ses royalties |
| `openDispute(uint256 rentalId)` | Ouvre un litige pour arbitrage DAO |
| `resolveDispute(uint256 rentalId, bool refund)` | Résout le litige (arbitres DAO) |
| `withdrawDeposit(uint256 rentalId)` | Récupère le dépôt après location |

### Architecture des données

```
Rental {
    tokenId: uint256
    renter: address
    owner: address
    pricePerDay: uint256
    deposit: uint256
    startTime: uint256
    endTime: uint256
    active: bool
}
```

---

## 4. Flux de location

1. **Artiste** : mint NFT → `listForRent()`
2. **Locataire** : `approve()` tokens → `rent()`
3. **Fin de location** : `returnArtwork()` → dépôt libéré
4. **Litige** : `openDispute()` → vote DAO → `resolveDispute()`

## mise en place de l'environnement de développement
## introduction résumer briévement le but du projet
## explication détaillée de l'implémentation, fonction par fonction

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
