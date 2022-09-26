

<div style="width:100%">
	<div style="width:50%; display:inline-block">
		<p align="center">
		<img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro-samples/ios-swift-push-notification-app/blob/master/Screenshots/badgeCount.png">	
		</p>	
	</div>	
</div>
</br>
</br>
</div>




# Increment app badge count on incoming push notifications.

## UNNotificationServiceExtension: 

This sevice grabs the data from the push notification payload and user can modify it's content and display the customized data on to the push notification.

In our case, we are modifying the data of the push notification and incrementing the badge count when new push notification is received.

___

## Implementation: 

### Step 1. Add  UNNotificationServiceExtension inside the app.

1. Click on `File` --> `New` --> `Targets`  --> `Application Extension` --> `Notification Service Extension`.

![Studio Guide](https://github.com/cometchat-pro-samples/ios-swift-push-notification-app/blob/master/Screenshots/addNotificationServiceExtension.png)  
    

2. Add  `Product Name` and click on `Finish`. 

 ![Studio Guide](https://github.com/cometchat-pro-samples/ios-swift-push-notification-app/blob/master/Screenshots/selectNotificationServiceExtension.png)

___

### Step 2. Setup App Groups.

1 . Click on `Project` --> `Targets` --> `Your app Target`  --> `Signing & Capabilities` --> `[+]` --> `App Groups`.

![Studio Guide](https://github.com/cometchat-pro-samples/ios-swift-push-notification-app/blob/master/Screenshots/appGroups.png)

2. In App Groups, click on `[+]` --> `Add a new container` -->  `Enter group name` --> `OK`. 

**Note:** Kindly, create group name using the combination of 'group' and 'App's bundle identifier' i.e `group.com.yourApp.bundleId`.

![Studio Guide](https://github.com/cometchat-pro-samples/ios-swift-push-notification-app/blob/master/Screenshots/addNewContainer.png). 

3. Make sure you've selected app group which you've created earlier. If it is selected then it will look like below mentioned image. 

![Studio Guide](https://github.com/cometchat-pro-samples/ios-swift-push-notification-app/blob/master/Screenshots/selectAppGroup.png). 

4. Click on `Project` --> `Targets` --> `Notification Service Extension Target`  --> `Signing & Capabilities` --> [+] --> `App Groups`.

![Studio Guide](https://github.com/cometchat-pro-samples/ios-swift-push-notification-app/blob/master/Screenshots/appGroups.png)

5. Select the same App Group which you've created in  `Your app Target`.

![Studio Guide](https://github.com/cometchat-pro-samples/ios-swift-push-notification-app/blob/master/Screenshots/selectSameAppGroup.png). 

___

### Step 3. Setup user suit for storing badge count. 


1. Open `AppDelegate.swift` and add below code in `applicationWillEnterForeground(_ application: UIApplication)`.

```swift

func applicationWillEnterForeground(_ application: UIApplication) {

    UserDefaults(suiteName: "group.com.inscripts.cometchat.dev2")?.set(1, forKey: "count") 
    UIApplication.shared.applicationIconBadgeNumber = 0

}

```

___

### Step 4. Setup Notification service extension to increment badge count. 

1. Open `NotificationService.swift` and replace below code in it.

```swift

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let defaults = UserDefaults(suiteName: "group.com.inscripts.cometchat.dev2")
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        var count: Int = defaults?.value(forKey: "count") as! Int
        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = "\(bestAttemptContent.title) "
            bestAttemptContent.body = "\(bestAttemptContent.body) "
            bestAttemptContent.badge = count as? NSNumber
            count = count + 1
            defaults?.set(count, forKey: "count")
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
     
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

```

___
