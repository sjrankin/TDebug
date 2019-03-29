//
//  MultiPeerDelegate.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol MultiPeerDelegate
{
    func ConnectedDeviceChanged(Manager: MultiPeerManager, ConnectedDevices: [String])
    func ReceivedData(Manager: MultiPeerManager, RawData: String)
}
