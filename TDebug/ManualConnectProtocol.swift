//
//  ManualConnectProtocol.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol ManualConnectProtocol: class
{
    func SetSelectedHost(HostName: String)
    var HostNames: [String]? {get set}
    func RefreshList() -> [String]
}
