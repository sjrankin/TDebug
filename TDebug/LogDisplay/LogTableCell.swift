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
    
    var HostLabel: UILabel!
    var TimeStampLabel: UILabel!
    var ValueLabel: UILabel!
    
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        let TableWidth = self.contentView.bounds.width
        
        HostLabel = UILabel(frame: CGRect(x: 15, y: 10, width: 100, height: 20))
        HostLabel.font = UIFont(name: "Avenir", size: 16.0)
        HostLabel.textColor = UIColor.black
        self.contentView.addSubview(HostLabel)
        
        TimeStampLabel = UILabel(frame: CGRect(x: 125, y: 10, width: TableWidth - 125, height: 20))
        TimeStampLabel.font = UIFont(name: "Avenir", size: 16.0)
        TimeStampLabel.textColor = UIColor.darkGray
        self.contentView.addSubview(TimeStampLabel)
        
        ValueLabel = UILabel(frame: CGRect(x: 15, y: 30, width: TableWidth - 15, height: 45))
        ValueLabel.font = UIFont(name: "Avenir-Bold", size: 18.0)
        ValueLabel.textColor = UIColor.black
        ValueLabel.numberOfLines = 2
        self.contentView.addSubview(ValueLabel)
        
        self.accessoryType = .disclosureIndicator
    }
    
    var TheItem: LogItem!
    
    public func SetData(Item: LogItem)
    {
        TheItem = Item
        TimeStampLabel.text = TheItem.Title
        ValueLabel.text = TheItem.Message
        if let HostName = TheItem.HostName
        {
            HostLabel.text = HostName
        }
        else
        {
            HostLabel.text = "{unknown}"
        }
        if let BGColor = TheItem.BGColor
        {
            self.backgroundColor = BGColor
        }
        if let FGColor = TheItem.FGColor
        {
            ValueLabel.textColor = FGColor
        }
        if TheItem.DoAnimateBGColor
        {
            if TheItem.HasAnimated
            {
                self.backgroundColor = TheItem.BGAnimateTargetColor
            }
            else
            {
                UIView.animate(withDuration: TheItem.BGAnimateColorDuration, animations:
                    {
                        self.backgroundColor = self.TheItem.BGAnimateTargetColor
                }, completion:
                    {
                        _ in
                        self.TheItem.HasAnimated = true
                })
            }
        }
    }
    
    public func GetID() -> UUID
    {
        return TheItem.ID!
    }
}
