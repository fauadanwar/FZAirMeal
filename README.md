
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
- The host attempts to fetch passenger and meal data from a remote server using APIs. If the API call fails, the host retrieves the data from local JSON files as a fallback. Once obtained, peers can access this data directly from the host over the local network.
  
https://github.com/user-attachments/assets/b41617db-3e5d-4061-b59c-4baa866c31c0

<br><br>
## Sending Order from Host device to Peers
- When an order is placed on the host device, order details are instantly transmitted to all connected peers. Peers display this updated order information on their order list. The available meal quantity is dynamically adjusted on all devices to reflect the number of meals ordered.

https://github.com/user-attachments/assets/a6346086-069e-428d-ad6e-3be1ff504a70

<br><br>
## Sending Order from Peer device to Host and other Peers
- Orders placed on a peer device are transmitted to the host. The host updates its database and subsequently broadcasts these changes to all connected peers. Each peer then updates its local database to reflect the new order information.

https://github.com/user-attachments/assets/431efc5b-9b7f-4c72-9684-5a770917cada

<br><br>
## Fetch exsisting order from Host
- If existing orders have been placed, a newly joined peer can retrieve this order information from the host device to align its order list with the current booking status.
 
https://github.com/user-attachments/assets/e2cfe5dd-227f-42e4-a81e-c03fe4beb393

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

 
