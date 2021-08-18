
# Hide Push Notifications from Blocked Users

## UNNotificationServiceExtension: 

This sevice grabs the data from the push notification payload and user can modify it's content and display the customized data on to the push notification.

In our case, we are modifying the data or hiding the push notification for those users which are blocked from the loggedInUser.



## Implementation: 

### Add  UNNotificationServiceExtension inside the app:

1. Click on `File` --> `New` --> `Targets`  --> `Application Extension` --> `Notification Service Extension`.

2. Add  `Product Name` and click on `Finish`. 


###  WorkFlow:

1. When the user login, fetch the blockedUsersList using  `blockedUserRequest`. 

```
let blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 20).build()

blockedUserRequest.fetchNext(onSuccess : { (users) in
print("blocked users : \(String(describing: users))")

for user in users! {

self.blockedUsersArray.append(user.uid!)

}
}, onError : { (error) in
print("error while fetching the blocked user request :  \(String(describing: error?.errorDescription))")
})
}
```

 2. Store the `'blockedUsersList` in UserDefaults with key `blockedUsers`.
 
 ```
 
 var defaults = UserDefaults.standard
 defaults = UserDefaults(suiteName: "group.com.inscripts.comatchat.dev2")!
 defaults.set(self.blockedUsersArray, forKey: "blockedUsers")
 
 ```
 
 3. Grab the value of push notification `sender` from push notification using PNExtension data.
 
  ```
  PNExtension.getMessageFrom(json: json, onSuccess: { (message) in
  
  print("received sender Object: \(String(describing: (message as? TextMessage)?.sender))")
  print("received sender UID: \(String(describing: (message as? TextMessage)?.sender.uid))")
  
  
  }) { (error) in
  
  print("error %@",error.errorDescription);
  }
  
  ```
  
 4. Check the same user is contains in the `blockedUsersList`.
 
 5. If the user contains in the `blockedUsersList` then modify the playload if you want to show custom message for eg. `New Message from Blocked User` and provide the `bestAttemptContent` UNNotificationRequest to contentHandler.
 
  ```
  bestAttemptContent.title = ""
  bestAttemptContent.body = "New Message from Blocked User"
  contentHandler(bestAttemptContent)
  
   ```

 5. If you want hide the push notification from blocked user then simply don't provide the `bestAttemptContent` UNNotificationRequest to contentHandler.This will not trigger the modified push notification but system automatically sends defult notification after 30 seconds if custom  notification dosen't trigger.
 
 6. To stop the system generated push notification use `removePendingNotificationRequests(withIdentifiers:)` and provide the push notifcation identifier to it. It will remove pendingNotificationRequests with same identifier.
 
 
 ```
 
 if(blockedUsersArray.contains(sender)){
 UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(notification.request.identifier)"])
 }else{
 completionHandler([.alert, .badge, .sound])
 }
 
 ```
 
