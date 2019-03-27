//
//  Command_SetIdiotLight.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Command_SetIdiotLight: CommandObject
{
    override init()
    {
        super.init()
        Operator = .SetIdiotLight
        Operand = nil
    }
    
    func CommandName() -> String
    {
        return "SetIdiotLight"
    }
    
    func OperandType() -> String
    {
        return "(Coordinate,Text,FGColor,BGColor)"
    }
    
    func CommandID() -> Int
    {
        return CommandOperators.SetIdiotLight.rawValue
    }
    
    func CommandFormat() -> String
    {
        return "CMD,Coordinate,Text,FGColor,BGColor"
    }
}
