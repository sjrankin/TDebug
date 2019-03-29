//
//  MultiPeerDelegate.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultiPeerDelegate
{
    func ConnectedDeviceChanged(Manager: MultiPeerManager, ConnectedDevices: [MCPeerID], Changed: MCPeerID, NewState: MCSessionState)
    func ReceivedData(Manager: MultiPeerManager, Peer: MCPeerID, RawData: String)
}
