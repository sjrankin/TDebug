//
//  CommandProtocol.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol CommandProtocol: class
{
    func GetCommands() -> [CommandObject]
}
