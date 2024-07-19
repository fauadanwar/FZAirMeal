# FZAirMeal
FZAirMeal application is POC for meal ordering by using Apple's Multi-peer connectivity framework.<br />
Details documentation of case study: https://docs.google.com/document/d/1ZbVjy8rZb3_XCzA05dnZeMYzEHVSffeRITkenvKjK4c/edit?usp=sharing

<br><br>
# Technologies Used:
- MVVM based architecture.
- SOLID principles with Protocol oriented programming and Dependency injection.
- Provider and repository, singleton and delegation design patterns.
- Multipeer connectivity framework used to enstablish connection between Host and perr devices.
- CoreData framework used to store data.
- Swift programming language with combine framework and UIKit.
- Used layer architecture to separate Presentation layer from Buisness layer.

<br><br>
## Connecting Host and Peers
https://github.com/user-attachments/assets/2389f8bc-c75f-4e9f-9e53-987da1be4398

<br><br>
## Fetching Data
- Host Fetch data from API (For POC Currently getting data from JSON file once API return failure error)
- Peers fetch data from Host using local network.
https://github.com/user-attachments/assets/9bca2384-ccba-4c54-89a7-d5a0322c7616

<br><br>
## Sending Order from Host device to Peers
https://github.com/user-attachments/assets/46f788f7-1f38-4be8-9dba-4bfd7d32b64b

<br><br>
## Sending Order from Peer device to Host and other Peers
https://github.com/user-attachments/assets/b048e24d-5b96-4cb7-8ded-5be9c50ec8e7

<br><br>
## Fetch exsisting order from Host
https://github.com/user-attachments/assets/2034fe7b-afea-458d-8467-35fe7d19657f

<br><br>
## Change Admin device.
https://github.com/user-attachments/assets/31369dee-b87f-4c3b-841b-97c22e401079

<br><br>
## Cancel order.
https://github.com/user-attachments/assets/e17dd8ed-9b48-455d-8381-70a490b4ed6b

<br><br>
## Future implementations
- Error handling:
  - Curruntly all error mesages are getting logged in console.
  - The error messages should get shown to user as an alert.
  - Also error message should get logged locally using file or database.
  - Peer will share logs with host and host will upload log on server.
- Order options:
  - User should be able to add more then 1 meal for passenger in order.
  - Order sholud get stored locally in case of connection issue and sync later after reconnecting.
- Online support:
  - Add option to configure server url, so host can fetch data from online server.
  - Add support for logs/error message upload.

 
