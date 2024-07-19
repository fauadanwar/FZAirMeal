//
//  OrderDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

protocol OrderDataManagerProtocol
{
    var orderDataManagerDelegate: OrderDataManagerDelegate? { get set }
    func createAndSendOrderToPeers(order: Order) -> Bool
    func sendOrderToHost(order: Order, toHost: PairingDevice) -> Bool
    func deleteAndSendOrderToPeers(order: Order) -> Bool
    func updateOrder(record: Order) -> Bool
    func resetCoreData()
    func getOrderRecord() -> Array<Order>?
    func getOrderRecordForPeer(host: PairingDevice, completionHandler:@escaping(_ result: Array<Order>?)-> Void)
    func getOrdersCount() -> Int
    func getOrderAt(indexPath: IndexPath) -> Order?
    func getPassengerMealAndOrderAt(indexPath: IndexPath) -> (Passenger?, Meal?, Order?)
    func getOrderWith(orderid: String) -> Order?
}

protocol OrderDataManagerDelegate: AnyObject
{
    func orderDataUpdated()
}

class OrderDataManager: OrderDataManagerProtocol
{
    private var _cdOrderRepository : any OrderCoreDataRepositoryProtocol
    private let _orderResourceRepository: any OrderResourceRepositoryProtocol
    private let peerRepository: PeerConnectionRepositoryProtocol
    private let hostRepository: HostConnectionRepositoryProtocol
    weak var orderDataManagerDelegate: OrderDataManagerDelegate?

    init(_cdOrderRepository: any OrderCoreDataRepositoryProtocol = OrderCoreDataRepository.shared,
         _orderResourceRepository: any OrderResourceRepositoryProtocol = OrderResourceRepository.shared,
         peerRepository: PeerConnectionRepositoryProtocol = PeerConnectionRepository.shared,
         hostRepository: HostConnectionRepositoryProtocol = HostConnectionRepository.shared) {
        self._cdOrderRepository = _cdOrderRepository
        self._orderResourceRepository = _orderResourceRepository
        self.peerRepository = peerRepository
        self.hostRepository = hostRepository
        self._cdOrderRepository.orderCoreDataRepositoryDelegate = self
    }
    
    
    func sendOrderToHost(order: Order, toHost: PairingDevice) -> Bool {
        return peerRepository.sendData(order, type: .order, toHost: toHost)
    }
    
    func sendOrderDeleteRequestToHost(order: Order, toHost: PairingDevice) -> Bool {
        return peerRepository.sendData(order, type: .deleteOrder, toHost: toHost)
    }
    
    func createAndSendOrderToPeers(order: Order) -> Bool
    {
        guard _cdOrderRepository.create(record: order) else { return false }
        //brodcast data
        return hostRepository.brodcastData(order, type: .order)
    }

    func deleteAndSendOrderToPeers(order: Order) -> Bool
    {
        guard _cdOrderRepository.delete(byIdentifier: order.id) else { return false }
        //brodcast data
        return hostRepository.brodcastData(order, type: .deleteOrder)
    }

    func updateOrder(record: Order) -> Bool
    {
        return _cdOrderRepository.update(record: record)
    }
    
    func resetCoreData()
    {
        return _cdOrderRepository.resetCoreData()
    }
    
    func getOrderRecordForPeer(host: PairingDevice, completionHandler:@escaping(_ result: Array<Order>?)-> Void) {
        _orderResourceRepository.getOrderRecordsFromHost(host: host) { [weak self] orders in
            guard let orders = orders,
                  let self,
                  orders.count > 0 else {
                completionHandler(nil)
                return
            }
            // insert record in core data
            _ = _cdOrderRepository.batchInsertOrderRecords(records: orders)
            completionHandler(orders)
        }
    }
    
    func getOrdersCount() -> Int {
        return _cdOrderRepository.getOrdersCount()
    }
    
    func getOrderAt(indexPath: IndexPath) -> Order? {
        return _cdOrderRepository.getOrderAt(indexPath: indexPath)
    }
    
    func getPassengerMealAndOrderAt(indexPath: IndexPath) -> (Passenger?, Meal?, Order?) {
        return _cdOrderRepository.getPassengerMealAndOrderAt(indexPath: indexPath)
    }
    
    func getOrderWith(orderid: String) -> Order? {
        return _cdOrderRepository.get(byIdentifier: orderid)
    }
    
    func getOrderRecord() -> Array<Order>? {
        let response = _cdOrderRepository.getAll()
        if(response.count != 0) {
            return response
        }
        else {
            return nil
        }
    }
}

extension OrderDataManager: OrderCoreDataRepositoryDelegate {
    func orderDataUpdated() {
        orderDataManagerDelegate?.orderDataUpdated()
    }
}
