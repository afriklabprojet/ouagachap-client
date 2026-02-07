# Configuration Google Maps

## Obtenir une clé API Google Maps

1. Accédez à la [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez l'API "Maps SDK for Android" et "Maps SDK for iOS"
4. Allez dans "Credentials" et créez une clé API
5. (Optionnel) Restreignez la clé à vos applications

## Configuration Android

1. Ouvrez le fichier `android/local.properties`
2. Ajoutez votre clé API :
   ```properties
   MAPS_API_KEY=VOTRE_CLE_API_ICI
   ```

## Configuration iOS

1. Ouvrez le fichier `ios/Runner/Info.plist`
2. Ajoutez avant la balise `</dict>` finale :
   ```xml
   <key>GOOGLE_MAPS_API_KEY</key>
   <string>VOTRE_CLE_API_ICI</string>
   ```

Ou via Xcode :
1. Ouvrez `ios/Runner.xcworkspace` dans Xcode
2. Sélectionnez Runner > Info
3. Ajoutez une nouvelle entrée `GOOGLE_MAPS_API_KEY` avec votre clé

## Sans clé API (Mode développement)

L'application utilise **Nominatim** (OpenStreetMap) pour le géocodage, qui ne nécessite pas de clé API.

Cependant, Google Maps nécessite une clé valide pour afficher la carte. Sans clé :
- La carte affichera une erreur ou sera vide
- La recherche d'adresses fonctionnera (via Nominatim)
- La géolocalisation fonctionnera

## Alternatives gratuites

Si vous ne souhaitez pas utiliser Google Maps, vous pouvez intégrer :
- **flutter_map** avec OpenStreetMap (gratuit)
- **mapbox_maps_flutter** (gratuit jusqu'à 50k requêtes/mois)

## Fichiers modifiés

- `android/app/src/main/AndroidManifest.xml` - Permissions et meta-data
- `android/app/build.gradle.kts` - Lecture de local.properties
- `ios/Runner/Info.plist` - Permissions localisation
- `ios/Runner/AppDelegate.swift` - Initialisation Google Maps
