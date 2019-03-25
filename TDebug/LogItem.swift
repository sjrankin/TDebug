//
//  LogItem.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LogItem
{
    private var _Title: String = ""
    public var Title: String
    {
        get
        {
            return _Title
        }
        set
        {
            _Title = newValue
        }
    }
    
    private var _Message: String = ""
    public var Message: String
    {
        get
        {
            return _Message
        }
        set
        {
            _Message = newValue
        }
    }
}
