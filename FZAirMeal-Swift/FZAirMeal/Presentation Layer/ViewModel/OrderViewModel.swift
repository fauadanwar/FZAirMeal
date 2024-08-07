//
//  OrderViewModel.swift
//  FZAirOrder
//
//  Created by Fanwar on 04/01/24.
//

import Foundation

protocol OrderViewModelDelegate: AnyObject
{
    func orderDataUpdated()
}

protocol OrderViewModelProtocol {
    var orderViewModelDelegate: OrderViewModelDelegate? { get set }
    func getOrderAt(indexPath: IndexPath) -> Order?
    func getPassengerMealAndOrderAt(indexPath: IndexPath) -> (Passenger?, Meal?, Order?)
    func getOrdersCount() -> Int
    func cancelOrder(order: Order) -> Bool
}

class OrderViewModel: OrderViewModelProtocol
{
    private var orderDataManager: OrderDataManagerProtocol
    weak var orderViewModelDelegate: OrderViewModelDelegate?
    
    init(orderDataManager: OrderDataManagerProtocol = OrderDataManager()) {
        self.orderDataManager = orderDataManager
        self.orderDataManager.orderDataManagerDelegate = self
    }
    
    func getOrderAt(indexPath: IndexPath) -> Order? {
        return orderDataManager.getOrderAt(indexPath: indexPath)
    }
    
    func getPassengerMealAndOrderAt(indexPath: IndexPath) -> (Passenger?, Meal?, Order?) {
        return orderDataManager.getPassengerMealAndOrderAt(indexPath: indexPath)
    }
    
    func getOrdersCount() -> Int {
        switch ConnectivityData.shared.pairingRole {
        case .host:
            guard ConnectivityData.shared.isServiceStarted else { return 0 }
            return orderDataManager.getOrdersCount()
        case .peer:
            guard let selectedHost = ConnectivityData.shared.selectedHost,
                  selectedHost.connectionStatus == .connected,
                  ConnectivityData.shared.isServiceStarted else { return 0 }
            return orderDataManager.getOrdersCount()
        case .unknown:
            return 0
        }        
    }
    
    func cancelOrder(order: Order) -> Bool {
        switch ConnectivityData.shared.pairingRole {
        case .host:
            return orderDataManager.deleteAndSendOrderToPeers(order: order)
        case .peer:
            guard let selectedHost = ConnectivityData.shared.selectedHost else { return false }
            return orderDataManager.sendOrderDeleteRequestToHost(order: order, toHost: selectedHost)
        case .unknown:
            return false
        }
    }
}

extension OrderViewModel : OrderDataManagerDelegate
{
    func orderDataUpdated() {
        orderViewModelDelegate?.orderDataUpdated()
    }
}
