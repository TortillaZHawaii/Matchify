# matchify

Find sports locations near you.

## Project description

The matchify app lets you find sports locations near you.
You can look up locations using a map or a list.
You can see and provide feedback on how busy a location is.
You can share places with deeplinks, so you can invite friends to play.

As a user, you can:
 - filter by sport type,
 - sort by name,
 - filter by busyness.

If your area is lacking a location you can simply add it.

## Integrations

Project uses Google Maps widget to display locations and Firebase to store data and manage users.
Project was only tested on an Android.

## List of optional requirements

- Implementing BLoC pattern - done to manage auth and locations data.
- Animations - animating my location fab while location is provided by platform.
- Tests - mostly done to test the BLoCs, some tests to string extensions.
- Singing in process - simple sing in using email and password. Adapted from labs.
- Deep links - you can share places with deeplinks.
- Using Camera/Bluetooth/Other platform features - sharing and my location. Both implemented using external packages.


## Instructions

- Sign in using test account.
- To add a location, long press on the map. A dialog will appear with a form to fill in the location details. You can move the marker to the desired location by long pressing on the map or by long pressing the marker and dragging it around.
- To see a list of locations, click on the list floating action button.
- To see a map, click on the map floating action button.
- App bar contains two buttons on a map view: one to switch between sattelite and standard view, and manage account. List view contains only account button.
- To see details of a location, click on the location icon on the map or on the list. You can provide feedback on location busyness by tapping one of three buttons. You can also share the location with a deeplink using share button or navigate to it using directions button, which will open Google Maps app.
- To use filters simply press chips on the top of the screen. Note that due to Firestore not supporting geo queries, you can only really sort by name. You can pick which sports would you like to see as well as how busy a location is.
- You can refresh the list by swiping down on the list or by pressing the refresh button on the top of the screen in the map view (refresh button will show up if you are far from the last refreshed location).
- You can log out by pressing the logout button on the top of the screen in the account button.
- To use location simply press location fab on the map view. It will blink during loading and then it will smoothly animate the map to the current location. Note that the animation won't be visible if location is provided quickly. This is especially true on emulators. You can modify ```_setMapToCurrentLocation``` in ```poi_map.dart``` to prolong the animation.

## Test account
<details>
    <summary>Test account</summary>

    test@matchify.com
    pass123
</details>


## Firestore schema
```json
{
    "locations": { // collection
        "locationId1": {
            "name": "SP 7 Orlik", // String
            "sport": "football", // String
            "latLng": [54.124545, 22.938418], // Geopoint
            "busyness": "moderate", // String
        },
        "locationId2": {
            "name": "Zalew Tenis 🎾", // String
            "sport": "other", // String
            "latLng": [54.09065298628576, 22.923175804316998], // Geopoint
            "busyness": "unknown", // String
        }
    }
}
```

