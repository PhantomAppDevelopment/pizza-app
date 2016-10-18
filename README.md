# Pizza App 1.0.0

Pizza App is a mobile application developed with Starling Framework and FeathersUI. It showcases how to use Firebase services with ActionScript to create a small social network.

It uses the following APIs and technologies:

* REST requests from the Firebase Database (JSON)
* Realtime requests (JSON & URLStream)
* User Auth with Facebook, Twitter and Google using Firebase Auth
* File uploading and downloading with Firebase Storage
* CameraUI & CameraRoll
* Geolocation API
* OpenStreetMaps using the [AS3 Starling/Feathers maps](https://github.com/ZwickTheGreat/feathers-maps)

Some of the techniques covered are:

* Creating and managing a file to store user credentials.
* Material Design inspired custom theme.
* Passing data between screens.
* Remembering the app's state between screens.
* Correctly disposing unused objects.
* Multi DPI development.

To compile this application you require to provide your own Yelp Fusion API Key and Secret. You will also need to provide your Firebase API key which can be obtained for free on the Firebase developer console (see below), this project only works with Firebase V3 and its newer console located at https://console.firebase.google.com/ 

AIR 23 or greater is required, FeathersUI 3.1.0 and Starling 2.1 are required as well.

## What is Firebase?

Firebase is a set of tools and services that are designed to ease the development of server side infrastructure for apps and games. You can easily and securely save and retrieve data from the cloud.

It also offers a user management service which allows your users to register an account in your app and have personalized experiences.
In this app the users can upload images, post real time messages, post comments and vote on pictures.

## Firebase Rules

The following Database rules are used for this app:

```json
{
    "rules": {
        "images": {
            "$other": {
                "$views": {
                    ".write": true
                }
            },
            ".indexOn": [
                "status",
                "views"
            ],
            ".read": true,
            ".write": "auth != null"
        },
        "images_comments": {
            "$other": {
                ".indexOn": [
                    "timestamp"
                ]
            },
            ".read": true,
            ".write": "auth != null"
        },
        "images_votes": {
            "$other": {
                ".indexOn": [
                    "value"
                ]
            },
            ".read": true,
            ".write": "auth != null"
        },
        "rooms": {
            ".read": true,
            ".write": false
        },
        "messages": {
            "$other": {
                ".indexOn": [
                    "timestamp"
                ]
            },
            ".read": "auth != null",
            ".write": "auth != null"
        }
    }
}
```

There are several nodes that contain information on the app's content: 

* `images` contains the metadata about the uploaded images.
* `images_comments` contains the comments of each uploaded image.
* `images_votes` contains the votes of each uploaded image.
* `rooms` contains the metadata of the chat rooms.
* `messages` contains the messages of each chat room.

The following rule means that we want all the childs of the node to be indexable by their timestamp. This is used to load the latest messages and comments.

```json
"$other": {
    ".indexOn": [
        "timestamp"
    ]
 },
```

All the data from this app is dynamically generated except for the Chat Rooms.

Chat rooms JSON structure:

```json
{
    "room1": {
        "description": "Yum, delicious meat.",
        "image": "assets/rooms/room1.png",
        "internal_id": 1,
        "name": "Meat Lovers"
    },
    "room2": {
        "description": "Don't like meat? No problem!",
        "image": "assets/rooms/room2.png",
        "internal_id": 2,
        "name": "Veggie Lovers"
    },
    "room3": {
        "description": "Everyone loves cheese, right?",
        "image": "assets/rooms/room3.png",
        "internal_id": 3,
        "name": "Cheese Lovers"
    }
}
```

The following Storage rules are used for this app:

```
service firebase.storage {
  match /b/<YOUR-PROJECT-ID>.appspot.com/o {
    match /images/{allPaths=**} {
      allow read;
      allow write: if request.auth != null;
    }   
  }
}
```

These rules mean that any user can download the pictures and their respective thumbnails but only registered users are able to create them.

Follow these steps to locate your Firebase API Key:

1. Login to the [Firebase console](https://console.firebase.google.com/) and select a project or create a new one.
2. In the project home page you will be prompted to add Firebase to `Android`, `iOS` or `Web`.
3. Select `Web`, a popup will appear.
4. Copy the `apiKey` from the JavaScript code block.
5. Open the `Constants.as` file and set your variables and constants accordingly.

Don't forget to enable Google, Facebook and Twitter authentication from the Auth section in the Firebase console.

[![Watch on Youtube](http://i.imgur.com/pVtSIr0.png)](https://www.youtube.com/watch?v=klJvYV7Twv8)

## Download

You can test this app by downloading it directly from Google Play.

[![Download](http://i.imgur.com/He0deVa.png)](https://play.google.com/store/apps/details?id=air.im.phantom.pizza)