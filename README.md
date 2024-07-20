
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
- If the host becomes disconnected or stops its service, an existing host can change its role to become the new host. Other peers or newly joining devices can connect to this new host, allowing the ordering process to continue uninterrupted.
  
https://github.com/user-attachments/assets/5adcf970-046a-4861-8388-13636c1c3a53

<br><br>
## Cancel order.
- Both peers and the host can cancel an order at any time. This action is broadcast to all connected devices, resulting in the order's removal from passenger records and an adjustment of item quantities accordingly.

https://github.com/user-attachments/assets/10674b89-1647-4e46-af67-7a9d142e50eb

<br><br>
## Future Enhancements
- Error Handling
  - Implement a robust error logging and reporting system, capturing detailed error messages and stack traces.
  - Provide informative user alerts for critical errors, while logging all errors for analysis.
  - Utilize local file or database storage for persistent error logging.
  - Facilitate centralized error management by enabling peer-to-host and host-to-server log sharing.
- Order Management
  - Expand order functionality to accommodate multiple meal selections per passenger.
  - Implement local order storage for offline order placement and synchronization upon reconnection.
- System Integration
  - Configure the system to retrieve data from an external server through a customizable URL.
  - Integrate log and error data upload capabilities for centralized monitoring and analysis.
    
Note: These enhancements aim to improve system reliability, user experience, and data management.

 
