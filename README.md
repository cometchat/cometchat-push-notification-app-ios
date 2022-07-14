
<div>
<img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/Screenshot.png">

<br></br><br></br>

CometChat Push Notification Sample App (built using **CometChat Pro SDK**) is a fully functional push notification app capable of **one-on-one** (private) and **group** messaging as well as Calling. This sample app enables users to send and receive push notifications for  **text** and **multimedia messages like  images, videos, documents** as well as ** Custom Messages** . Also, users can make  push notifications for **Audio** and **Video** calls to other users or groups.


___


## Table of Contents


1. [Installation](#Installation)

2. [Xcode and iOS compatible version](#Xcode-and-iOS-compatible-version)

3. [Running the sample app](#Running-the-sample-app)

4. [Add Push Notification inside your project](#Add-Push-Notification-inside-your-project)

5. [Increment Badge Count](#Increment-Badge-Count)

6. [Hide Push Notifications from Blocked Users](#Hide-Push-Notifications-from-Blocked-Users)

7. [Troubleshooting](#Troubleshooting)



# Installation 
      
  1.  Simply clone the project from ios-swift-push-notification-app repository. 
  
  2.  After cloning the repository navigate & Select your push notification configuration. i.e Firebase or APNS + Callkit (Recomended). 
  
  3. Use below command to install required pods.
   
   ```
   $ pod install
  ```

  
  4. Create certificates for your bundle ID as per mentioned in our [documentation](https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification).

  5.  Build and run the Sample App.
  
# Xcode and iOS compatible versions

  To build the sample app you are required to have **xcode** version greater than or equal to **11.4** and **iOS** version should be greater than or equal to **11.0**

# Running the sample app

   To Run to sample App you have to do the following changes by Adding **APP_ID**, **AUTH_KEY**and **REGION CODE** and s user's **UID** for which you wants to send the push notification.
   
   You can obtain your  *APP_ID* and *AUTH_KEY* from [CometChat-Pro Dashboard](https://app.cometchat.com/)
   
   - Enable to Push notification Extension from [CometChat-Pro Dashboard]. To Enable Push notification extension, please navigate to Extensions --> Enable Push Notification 
   
   <img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/addExtension.png"> <br></br> <br></br>
   
   - Click on **Settings** button.
   
   - Set extension version.
     - Select V2 to start using the enhanced version of the Push Notification extension. The enhanced version uses Token-based approach for sending Push Notifications and is simple to implement.
     
   - Select platform for which you wish to implement Push Notifications.
   
   <img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/platformSelection.png"> <br></br> 
   
   - There are two ways to implement Push Notifications:
     a. For Firebase Cloud Messaging (FCM)
        - Add the **Server Key** which was generated after registering the app in firebase console.
        
        <img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/fcmServerKey.png"> <br></br>
        
        **Notification Payload Setting**
        - You can control if the notification key should be in the payload or not.
        
        <img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/notificationPayload.png"> <br></br><br></br>
        
     b. For Apple Push Notifications (APNs)
        - Enable Apple Push Notification.
        - Upload .p8 or .p12 file
        
        <img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/apnsEnabling.png"> <br></br>
                
   - Select the triggers for sending the Push Notifications.
   
    <img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/triggerSelection.png"> <br></br>
   
   - Save the settings.
   
   - Open the project in Xcode. 
          
   - Go to CometChatPro-PushNotification-SampleApp -->  **Constants.swift**.
                  
   - modify *authKey* and *appID* with your own **authKey** and **appID**.
   
   - Enter **toUserUID** for which you wants to send the push notification.

___

# Add Push Notification inside your project
   
   1. Add CometChat SDK.
   
   We recommend using CocoaPods, as they are the most advanced way of managing iOS project dependencies. Open a terminal   window, move to your project directory, and then update the SDK  by running the following command.
   
   ```
   $ pod install
   ```
   
   If the pod installation fails due to Cocoapods dependancy issue then use the below command to install the framework through cocoapods.
  
  ```
   pod install --repo-update
   ```
   2. We are providing two ways to implement push notification for your app. 
   
   1. [Firebase](https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification)
   2. [APNS (Supports Callkit)](https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification-apns)
   
   Please refer our documentation to intergrate push notification inside your app.
   
   ### Note: 
   
   1. Ignore firebase setup if you're using APNS based approach. 
   2. Please add Callkit related code carefully to avoid issues.

   
 <br></br>  

___

# Increment Badge Count

Learn more about how to [Increment Badge Count](https://github.com/cometchat-pro-samples/ios-swift-push-notifications-app/blob/master/IncrementBadgeCount.md) using Notification service Extension.
___

# Hide Push Notifications from Blocked Users

Learn more about how to [hide push notification](https://github.com/cometchat-pro-samples/ios-swift-push-notifications-app/blob/master/Customize.md) for blocked users using Notification service Extension.
    
___   

# Troubleshooting

- To read the full dcoumentation on UI Kit integration visit our [Documentation](https://prodocs.cometchat.com/docs/ios-ui-kit)  .

- Facing any issues while integrating or installing the UI Kit please <a href="https://app.cometchat.io/"> connect with us via real time support present in CometChat Dashboard.</a>

---

# Contributors

Thanks to the following people who have contributed to this project:

[@pushpsenairekar2911 👨‍💻](https://github.com/pushpsenairekar2911) <br>
[@jeetkapadia 👨‍💻](https://github.com/jeetkapadia)
<br>
[@ajayv-cometchat 👨‍💻](https://github.com/ajayv-cometchat)
<br>

---

# Contact

Contact us via real time support present in [CometChat Dashboard.](https://app.cometchat.io/)

---

# License

---

This project uses the following [license](https://github.com/cometchat-pro/ios-swift-chat-app/blob/master/License.md).
