//
//  CommandObject.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CommandObject: CommandObjectProtocol
{
    private var _Operator: CommandOperators = .NOP
    public var Operator: CommandOperators
    {
        get
        {
            return _Operator
        }
        set
        {
            _Operator = newValue
        }
    }
    
    private var _Operand: Any? = nil
    public var Operand: Any?
    {
        get
        {
            return _Operand
        }
        set
        {
            _Operand = newValue
        }
    }
}

enum CommandOperators: Int
{
    case NOP = 0
    case AddToID = 1
    case AddToStatus = 2
    case AddToLog = 3
    case UpdateStatus = 4
    case DisableIdiotLight = 5
    case SetIdiotLight = 6
    case UpdateIdiotLight = 7
    case Acknowledge = 8
    case ReturnCommandList = 9
    case ReturnHostInformation = 10
    case GetHostFunctionality = 11
    case HeartBeat = 12
}
