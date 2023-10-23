
<div>
<img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/Screenshot.png">

<br></br><br></br>

CometChat Push Notification Sample App (built using **CometChatSDK**) is a fully functional push notification app capable of **one-on-one** (private) and **group** messaging as well as Calling. This sample app enables users to send and receive push notifications for  **text** and **multimedia messages like  images, videos, documents** as well as ** Custom Messages** . Also, users can make  push notifications for **Audio** and **Video** calls to other users or groups.


___


## Table of Contents


1. [Installation](#Installation)

2. [Running the sample app](#Running-the-sample-app)

3. [Add Push Notification inside your project](#Add-Push-Notification-inside-your-project)

4. [Increment Badge Count](#Increment-Badge-Count)

5. [Hide Push Notifications from Blocked Users](#Hide-Push-Notifications-from-Blocked-Users)

6. [Troubleshooting](#Troubleshooting)



# Installation 
      
  1.  Simply clone the project from ios-swift-push-notification-app repository. 
  
  2.  After cloning the repository navigate & Select your push notification configuration. i.e Firebase or APNS + Callkit (Recomended). 
  
  3. Use below command to install required pods.
   
   ```
   $ pod install
  ```

  
  4. Create certificates for your bundle ID as per mentioned in our [documentation](https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification).

  5.  Build and run the Sample App.
   
  


# Running the sample app

   To Run to sample App you have to do the following changes by Adding **APP_ID**, **API_KEY**and **REGION CODE** and s user's **UID** for which you wants to send the push notification.
   
   You can obtain your  *APP_ID* and *API_KEY* from [CometChat-Dashboard](https://app.cometchat.com/)
   
   - Enable to Push notification Extension from  [CometChat-Pro Dashboard] . To Enable Push notification extension, please navigate to Extensions --> Push Notification --> Add Extension. 
   
   <img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/addExtension.png"> <br></br>  
   
   - Add Title and Firebase Server Key received from Firebase Console. 
   
   <img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/settings.png"><br></br> <br></br><br></br> <br></br><br></br>
          
   - Open the project in Xcode. 
          
   - Go to CometChatPro-PushNotification-SampleApp -->  **Constants.swift**.
                  
   - modify *apiKey* and *appID* with your own **apiKey** and **appID**.
   
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

# Hide Push Notifications from Blocked Users

Learn more about how to [hide push notification](https://github.com/cometchat-pro-samples/ios-swift-push-notifications-app/blob/master/Customize.md) for blocked users using Notification service Extension.
    
___   

# Troubleshooting

Facing any issues while integrating or installing the sample app please <a href="https://forum.cometchat.com/"> visit our forum</a>.

___

# Contribute 
   
   Feel free to make a suggestion by creating a pull request.

___


