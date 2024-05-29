<p align="center">
  <img alt="CometChat" src="https://assets.cometchat.io/website/images/logos/banner.png">
</p>

# iOS Enhanced Push Notifications (Beta) Sample App

The CometChat iOS [Enhanced Push Notifications (Beta)](https://www.cometchat.com/docs-beta/notifications/push-overview) Sample App is capable of handling push notifications for one-on-one (private), group messaging, and even call notifications. This sample app enables users to send and receive text messages, make and receive calls, and effectively displays push notifications for these interactions.

The sample triggers Push notifications using:

1. Apple Push Notifications service - APNs (Recommended).
2. Firebase Cloud Messaging - FCM.

> [!NOTE]
> If you are using Push Notifications (Extension), please refer to our [iOS Push Notifications (Extension)](https://github.com/cometchat/cometchat-push-notification-app-ios/tree/v4-push-notifications-extension) sample app.

## Pre-requisite

1. Login to the [CometChat Dashboard](https://app.cometchat.com/).
2. Select an existing app or create a new one.
3. Click on the Notifications section from the menu on the left.
4. Enable Push Notifications by clicking on the toggle bar and configure the push notifications.
5. Add credentials for FCM or APNs.
6. Make a note of the Provider ID.

## Run the Sample App

1. Clone this repository.
2. Install the dependencies.

```
pod install
```

3. Add your app credentials like `appId`, `region`, and `authKey` in the `Constants.swift` file. Keep the value of `notificationMode` as `APNs` (Recommended for iOS).
4. Add the Provider ID for registering the APNS and VoIP (or FCM) tokens.
5. In case you're using FCM, change the value `notificationMode` to `FCM` and add the GoogleServices-Info.plist file as per FCM's documentation.
6. Run the sample app.
7. Put the app in the background or terminate it.
8. Send a message or call to the logged in user from another device.
9. You should see a push notification for a message and call notification for a call.
10. Tap on the notification to open the Sample app for message.
11. Tap on accept/decline on call notification to initiate or decline call.
    </br>

## Help and Support

For issues running the project or integrating with our UI Kits, consult our [documentation](https://www.cometchat.com/docs-beta/notifications/push-overview) or create a [support ticket](https://help.cometchat.com/hc/en-us) or seek real-time support via the [CometChat Dashboard](https://app.cometchat.com/).
