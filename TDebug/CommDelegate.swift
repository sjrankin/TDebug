//
//  CommDelegate.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol CommDelegate: class
{
    func RawDataReceived(_ RawData: String, _ BytesRead: Int)
}
