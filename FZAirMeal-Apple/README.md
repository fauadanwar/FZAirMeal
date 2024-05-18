# FZAirMeal application is POC for meal ordering by using Apple's Multi-peer connectivity framework.
## Logical design:
1. The app has 3 main Screens(Pair, Passenger, Order) and 1 sub-screen (Meal).
2. Pair view allows devices to discover and connect, using Multi-peer connectivity.
3. The Passenger screen shows the passenger list with the seat and ordered meal name.
4. The Order screen shows currently placed orders.
5. Users can Navigate from the Passenger screen to the meals screen to select the ordered meal type.
6. The app has code available to fetch Initial Passenger and Meals data from API, But for now, it's using local JSON files to get dummy data.
7. The data then gets stored in Core Data which has Entities for Orders, Passenger and Meals.
8. Once the User selects the meal for the passenger and presses the "place order" button the order gets added to the DB table.
9. The same order gets shared with other paired devices and the database gets updated on them as well.
10. Users can also see available meal quantities while placing an order. If still try to order "Out of stock" meal app will show an alert and revert that order.
11. The app will clear all databases before fetching the initial record in each app launch.
## Future implementations:
1. If the device gets disconnected keep track of the last order's timestamp. and on connectivity, send new records only to sync with others.
2. Also, fetch records from other devices post the last order's timestamp to update local data.
3. In case a meal order gets out of stock during the offline time, add code to delete/revert the order which came last or based on predefined priority(This needs business logic).
4. ]Optimize PairingViewModel to better fit in this architecture.
5. UI optimizations are possible.
6. The app should also have a delete order and changing meal option.
## App Architect.
1. The app uses an MVVM-based architecture with the Repository pattern.
2. Used protocol-oriented. programming to support dependency injection and testing. which will increase reliability.
3. Used Manager classes to separate UI layer architecture from Backend dependencies. This will help in future to Scale the app more and we can add/remove different components as per requirement.
4. Using Local data and a local network the app will reduce the cost of server dependency.
### Note:
1. It's not a 100% accurate solution, some times syncing does not work and need to re-pair devices.
2. Because of the time shortage, I have done a few hardcoding and compromised architecture at some places.
3. No test case as it's a 1-2 day POC.
4. For master-slave going offline, handling can be done using the "Placed Order" time stamp. I have added a comment where it should be done. But didn't get a chance to implement it.
