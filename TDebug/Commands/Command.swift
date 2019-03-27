//
//  Command.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Command: CommandProtocol
{
    private var CommandList = [CommandObject]()
    
    func GetCommands() -> [CommandObject]
    {
        return CommandList
    }
}
