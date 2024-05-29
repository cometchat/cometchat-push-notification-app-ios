<p align="center">
  <img alt="CometChat" src="https://assets.cometchat.io/website/images/logos/banner.png">
</p>

# iOS Push Notifications (Extension) Sample App

The CometChat iOS [Push Notifications (Extension)](https://www.cometchat.com/docs-beta/extensions/ios-apns-push-notifications) Sample App is a fully functional push notifications app capable of one-on-one (private) and group messaging, and Calling. This sample app enables users to send and receive push notifications for text and multimedia messages like **images, videos, documents** and **Custom Messages**. Also, users can make push notifications for Audio and Video calls to other users or groups.

> [!NOTE]
> If you use Enhanced Push Notifications, please refer to our [iOS Enhanced Push Notifications (Beta)](https://github.com/cometchat/cometchat-push-notification-app-ios) Sample app for guidance

# Installation

1.  Clone the repository and switch to this branch.
2.  Open the project in Xcode and install the dependencies.

```sh
   $ pod install
```

3. Create certificates for your bundle ID as mentioned in our [documentation](https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification).
4. Build and run the Sample App.

# Running the sample app

To Run the sample App make the following changes by Adding **APP_ID**, **API_KEY**and **REGION** and the user's **UID** for which you want to send the push notification.

You can obtain your _APP_ID_ and _API_KEY_ from [CometChat Dashboard](https://app.cometchat.com/)

- Enable to Push notification Extension from [CometChat Dashboard](https://app.cometchat.com/). To Enable Push notification extension, please navigate to Extensions --> Push Notification --> Add Extension.

- Add Firebase Server Key received from Firebase Console.
- Open the project in Xcode.
- Go to CometChatPro-PushNotification-SampleApp --> **Constants.swift**.
- Enter your _APP_ID_, _REGION_ and _AUTH_KEY_

## Help and Support

For issues running the project or integrating with our UI Kits, consult our [documentation](https://www.cometchat.com/docs-beta/extensions/ios-apns-push-notifications) or create a [support ticket](https://help.cometchat.com/hc/en-us) or seek real-time support via the [CometChat Dashboard](https://app.cometchat.com/).
