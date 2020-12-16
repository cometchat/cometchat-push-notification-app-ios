
<div>
<img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/Screenshot.png">

<br></br><br></br>

CometChat Push Notification Sample App (built using **CometChat Pro SDK**) is a fully functional push notification app capable of **one-on-one** (private) and **group** messaging as well as Calling. This sample app enables users to send and receive push notifications for  **text** and **multimedia messages like  images, videos, documents** as well as ** Custom Messages** . Also, users can make  push notifications for **Audio** and **Video** calls to other users or groups.


___

## Table of Contents

1. [Pre-requisite](#Pre-requisite)

2. [Installation](#Installation)

3. [Running the sample app](#Running-the-sample-app)

4. [Increment Badge Count](#Increment-Badge-Count)

5. [Hide Push Notifications from Blocked Users](#Hide-Push-Notifications-from-Blocked-Users)

6. [Troubleshooting](#Troubleshooting)


# Pre-requisite
1. Login to the <a href="https://app.cometchat.io/" target="_blank">CometChat Dashboard</a>.
2. Select an existing app or create a new one.
3. Go to "API & Auth Keys" section and copy the `REST API` key from the "REST API Keys" tab.
4. Go to the "Extensions" section and Enable the Push Notifications extension.
5. Go to the "Installed" tab in the same section and open the settings for this extension and Set the version to `V2`.
6. Also, save the `REST API` key in the Settings and click on Save.
7. Copy the `APP_ID`, `REGION` and `AUTH_KEY` for your app.

# Installation 
      
   Simply clone the project from ios-swift-push-notification-app repository. After cloning the repository navigate to project's folder and use below command to install the require pods.
   
   ```
   $ pod install
  ```
  
  2. Select the appropriate version as per your Xcode version.

  3. Navigate to project's folder and use below command to install the require pods.
  
  4. Create certificates for your bundle ID and replace `GoogleService-Info.plist` and  bundle ID.
  
   Build and run the Sample App.
   
   
   ### Add CometChatPro SDK in project
   
   ### CocoaPods:
   
   We recommend using CocoaPods, as they are the most advanced way of managing iOS project dependencies. Open a terminal   window, move to your project directory, and then update the SDK  by running the following command.
   
   ```
   $ pod install
   ```
   
   If the pod installation fails due to Cocoapods dependancy issue then use the below command to install the framework through cocoapods.
  
  ```
   pod install --repo-update
   ```
   
 <br></br>  


# Running the sample app

   To run the Sample App follow the below steps:
         
   - Open the project in Xcode. 
          
   - Go to CometChatPro-PushNotification-SampleApp -->  **Constants.swift**.
                  
   - modify **apiKey** **appID** and **region** with your own **apiKey** **appID** and **region**.
   
   - Enter **toUserUID**(receiver's UID) or **toGroupUID**(receiver's GUID) to whom you want to send the push notifications.

___

# Increment Badge Count

Learn more about how to [Increment Badge Count](https://github.com/cometchat-pro-samples/ios-swift-push-notifications-app/blob/master/IncrementBadgeCount.md) using Notification service Extension.
___

# Hide Push Notifications from Blocked Users

Learn more about how to [hide push notification](https://github.com/cometchat-pro-samples/ios-swift-push-notifications-app/blob/master/Customize.md) for blocked users using Notification service Extension.
    
___   

## Documentation
​
<a href="https://prodocs.cometchat.com/docs/ios-extensions-enhanced-push-notification" target="_blank">Token-based Push Notifications</a>

___ 
