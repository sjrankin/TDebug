//
//  Command_AddToID.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Command_AddToID: CommandObject
{
    override init()
    {
        super.init()
        Operator = .AddToID
        Operand = nil
    }
    
    func CommandName() -> String
    {
        return "AddToID"
    }
    
    func OperandType() -> String
    {
        return "Tuple"
    }
    
    func CommandID() -> Int
    {
        return CommandOperators.AddToID.rawValue
    }
    
    func CommandFormat() -> String
    {
        return "CMD,(Name,Value)"
    }
}
