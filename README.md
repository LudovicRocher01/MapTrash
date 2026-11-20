# MapTrash ♻️ – Application iOS de localisation des points de tri

**MapTrash** est une application iOS qui permet de localiser les points d’apport volontaire pour le tri des déchets (verre, textile, papier, etc.) à proximité de l’utilisateur, dans la métropole de Nice Côte d’Azur.

L’application repose sur des données publiques fournies par la métropole et propose une interface claire, intuitive et informative pour faciliter les bons gestes de tri au quotidien.

## 🗑️ Fonctionnalités principales

- **Carte des 3 000+ conteneurs** de la métropole avec regroupement automatique (clusters) : verre 🍾, papier 📰, emballages 🛍️, textile 👕, ordures ménagères 🗑️
- **Déchetteries** sur la carte avec horaires, téléphone et badge « Ouvert / Fermé » en temps réel
- **Le plus proche** : distance et temps à pied jusqu'au conteneur le plus proche de chaque type, et liste « Autour de moi »
- **Itinéraire dans l'app** (à pied pour les conteneurs, en voiture pour les déchetteries), ou ouverture dans Plans / Google Maps
- **« Où jeter… ? »** : recherche hors-ligne parmi des dizaines d'objets du quotidien (pile, pot de yaourt, ampoule, huile de friture…)
- **Favoris** enregistrés sur l'appareil
- **Guide du tri** pour chaque type de déchet + bonnes pratiques
- **Widget** écran d'accueil et écran verrouillé « conteneur le plus proche »
- **Siri et Raccourcis** : « Où est le conteneur Verre le plus proche avec Tri Nice »
- Design **Liquid Glass** sur iOS 26 (repli matériau sur iOS 17/18), mode sombre, Dynamic Type et VoiceOver

## 🧱 Architecture

```
Shared/            Modèle partagé app + widget (WasteType, Container, containers.json)
MapTrash/
  Store/           État de l'app (AppState), localisation, favoris, itinéraires, routage Siri/URL
  Map/             ClusteredMapView : MKMapView + clustering natif (fluide avec des milliers de points)
  View/            Feuille du bas, fiches, recherche « Où jeter… ? », guide du tri
  Model/           Déchetteries, contenu du guide, dictionnaire de tri
  Intents/         App Intents (Siri / Raccourcis)
MapTrashWidget/    Extension WidgetKit
```

## 🔗 Source des données

Les données utilisées sont publiées par la [Métropole Nice Côte d’Azur](https://www.nicecotedazur.org/services/dechets/collecte-et-tri-dechets/les-points-dapports-volontaires/)  
📄 Jeu de données : *Points d’apport volontaire pour le tri des déchets*

## 📱 Technologies

- Swift / SwiftUI (Observation)  
- MapKit (UIKit `MKMapView` pour le clustering)  
- WidgetKit, App Intents  
- Xcode 26 – iOS 17.6 minimum

## 🙋‍♂️ Auteur

Développée par **Ludovic Rocher**  
Projet personnel – 2025-2026

---

*MapTrash n’est pas une application officielle de la Métropole Nice Côte d’Azur, mais un projet indépendant réalisé à partir de données ouvertes.*
