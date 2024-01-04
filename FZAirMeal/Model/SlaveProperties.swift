//
//  SlaveProperties.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation
import MultipeerConnectivity

struct SlaveProperties {
    /// The service type for this peer session.
    /// You could specify this whatever you like.
    let serviceType = "video-peer"

    /// The peer identifier for this device. You could also
    /// specify this whatever you like, but here I used the
    /// device's name from the `UIDevice` object.
    let peerId = MCPeerID(displayName: UIDevice.current.name)

    /// The service advertiser so that the host/browser
    /// could invite and connect to this device.
    let peerAdvertiser: MCNearbyServiceAdvertiser

    /// The current peer session.
    let peerSession: MCSession

    /// I'm storing the connected peer ID so I could access
    /// this easier when there's a host connected. I set this
    /// to `nil` when the host is disconnected.
    var connectedPeer: MCPeerID? = nil
}

