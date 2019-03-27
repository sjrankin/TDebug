//
//  Command_NOP.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Command_NOP: CommandObject
{
    override init()
    {
        super.init()
        Operator = .NOP
        Operand = nil
    }
    
    func CommandName() -> String
    {
        return "NOP"
    }
    
    func OperandType() -> String
    {
        return ""
    }
    
    func CommandID() -> Int
    {
        return CommandOperators.NOP.rawValue
    }
    
    func CommandFormat() -> String
    {
        return "CMD"
    }
}
