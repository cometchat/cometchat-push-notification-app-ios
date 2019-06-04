
<div style="width:100%">
	<div style="width:50%; display:inline-block">
		<p align="center">
		<img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-swift-chat-app/blob/master/Screenshots/CometChat%20Logo.png">	
		</p>	
	</div>	
</div>
</br>
</br>
</div>



[![Platform](https://img.shields.io/badge/Platform-iOS-orange.svg)](https://cocoapods.org/pods/CometChatPro)
[![Languages](https://img.shields.io/badge/Language-Swift-orange.svg)](https://github.com/cometchat-pro/ios-swift-chat-app)


## Table of Contents

1. [Screenshots](#Screenshots)

2. [Installation](#Installation)

3. [Running the sample app](#Running-the-sample-app)

3. [Hide Push Notifications from Blocked Users(#Hide-Push-Notifications-from-Blocked-Users)

4. [Troubleshoot](#Troubleshoot)

5. [Contributing](#Contributing)



# Screenshots

<img align="left" src="https://github.com/cometchat-pro-extensions/ios-swift-push-notifications-app/blob/master/Screenshots/Screenshot.png">
   
<br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br>


# Installation 
      
   Simply clone the project from iOS-swift-chat-app repository. After cloning the repository navigate to project's folder and use below command to install the require pods.
   
   ```
   $ pod install
   ```
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
   
   ### Manually:
   
   You can download the CometChatPro SDK from link below and manually add it in the project.
   
   Download CometChatPro SDK from [ios-chat-sdk](https://github.com/cometchat-pro/ios-chat-sdk)
   
 <br></br>  


# Running the sample app

   To Run to sample App you have to do the following changes by Adding **APP_ID** and **API_KEY** and s user's **UID** for which you wants to send the push notification.
   
   You can obtain your  *APP_ID* and *API_KEY* from [CometChat-Pro Dashboard](https://app.cometchat.com/)
          
   - Open the project in Xcode. 
          
   - Go to CometChatPro-PushNotification-SampleApp -->  **Constants.swift**.
                  
   - modify *apiKey* and *appID* with your own **apiKey** and **appID**.
   
   - Enter **toUserUID** for which you wants to send the push notification.
   
   
# Hide Push Notifications from Blocked Users

Want to Customize or hide push Notification. [Click here](https://github.com/cometchat-pro-samples/ios-swift-push-notifications-app/blob/master/Customize.md)
    
# Troubleshoot  

Facing any issues while running or installing the app. [Click here](https://github.com/cometchat-pro-samples/ios-swift-push-notifications-app/blob/master/troubleshoot.md)

# Contribute 
   
   Feel free to make a suggestion by creating a pull request.




