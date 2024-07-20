
# FZAirMeal
FZAirMeal is a Proof of Concept (POC) application for meal ordering, leveraging Apple's Multi-peer connectivity framework.<br>
## Case Study Documentation: 
For detailed documentation, refer to the [case study](https://docs.google.com/document/d/1ZbVjy8rZb3_XCzA05dnZeMYzEHVSffeRITkenvKjK4c/edit?usp=sharing).

<br><br>
# Technologies Used:
- MVVM based architecture.
- SOLID principles with Protocol Oriented Programming and Dependency Injection.
- Provider, Repository, Singleton and Delegation design patterns.
- Multipeer connectivity framework for establishing connections between host and peer devices.
- CoreData framework for data storage.
- Swift programming language with Combine framework and UIKit.
- Layered architecture to separate Presentation layer from Business layer.
  
<br><br>
# Key Functionalities
<br><br>
## Connecting Host and Peers
- You can designate any device as a host and the others as peers. Start and stop the sharing service on any device. Once started, the host will listen for incoming connections while peers search for available hosts. When a peer finds a host, it can request a connection, which the host can accept or deny. This establishes a real-time connection between the two devices.
  
https://github.com/user-attachments/assets/909a6c91-e313-4265-b5fa-86ef792e792d



<br><br>
## Fetching Data
- Host fetches data from an API (Currently retrieves data from a JSON file in case of API failure).
- Peers fetch data from the Host using the local network.
  
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
  - Currently, all error messages are logged in the console.
  - Error messages should be shown to users as alerts.
  - Errors should also be logged locally using a file or database.
  - Peers will share logs with the host, and the host will upload logs to the server.
- Order options:
  - Users should be able to add more than one meal per passenger in an order.
  - Orders should be stored locally in case of connection issues and synced later after reconnecting.
- Online support:
  - Add an option to configure the server URL so the host can fetch data from an online server.
  - Add support for logs/error message uploads.

 
