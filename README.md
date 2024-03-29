# iOS Push Notification Sample App

CometChat Push Notification Sample App is a fully functional push notification app capable of one-on-one (private) and group messaging, and Calling. This sample app enables users to send and receive push notifications for text and multimedia messages like **images, videos, documents** and **Custom Messages**. Also, users can make push notifications for Audio and Video calls to other users or groups.

<hr>

# Installation 
      
  1.  Clone the repository.
```sh
      git clone https://github.com/cometchat/cometchat-push-notification-app-ios.git
```
  2.  Open the project in Xcode and navigate to select your push notification configuration:
      - APNS + Callkit (Recommended)
      - Firebase
  4. Install the pods.

```sh
   $ pod install
```
  4. Create certificates for your bundle ID as mentioned in our [documentation](https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification).
  5.  Build and run the Sample App.

# Running the sample app

   To Run the sample App make the following changes by Adding **APP_ID**, **API_KEY**and **REGION** and the user's **UID** for which you want to send the push notification.
   
   You can obtain your  *APP_ID* and *API_KEY* from [CometChat Dashboard](https://app.cometchat.com/)
   
   - Enable to Push notification Extension from  [CometChat Dashboard](https://app.cometchat.com/). To Enable Push notification extension, please navigate to Extensions --> Push Notification --> Add Extension. 
   
   - Add Title and Firebase Server Key received from Firebase Console. 
          
   - Open the project in Xcode. 
          
   - Go to CometChatPro-PushNotification-SampleApp -->  **Constants.swift**.
                  
   - Modify *apiKey* and *appID* with your own **apiKey** and **appID**.
   
   - Enter **toUserUID** for which you want to send the push notification.

___

# Add Push Notification inside your project

CometChat provides two ways to implement push notifications for your app. 
   
   1. [Firebase](https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification)
   2. [APNS (Supports Callkit)](https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification-apns)



