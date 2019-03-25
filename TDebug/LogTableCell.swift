//
//  LogTableCell.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LogTableCell: UITableViewCell
{
    public static var CellHeight: CGFloat = 80.0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    var TitleLabel: UILabel!
    var ValueLabel: UILabel!
    
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        let TableWidth = self.contentView.bounds.width
        
        TitleLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 40))
        TitleLabel.font = UIFont(name: "Avenir", size: 18.0)
        TitleLabel.textColor = UIColor.blue
        self.contentView.addSubview(TitleLabel)
        
        ValueLabel = UILabel(frame: CGRect(x: 110, y: 5, width: TableWidth - 110, height: 40))
        ValueLabel.font = UIFont(name: "Avenir-Bold", size: 18.0)
        ValueLabel.textColor = UIColor.black
        self.contentView.addSubview(TitleLabel)
    }
    
    public func SetData(Name: String, Value: String)
    {
        TitleLabel.text = Name
        ValueLabel.text = Value
    }
}
