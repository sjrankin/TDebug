//
//  ManualConnectCode.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ManualConnectCode: UITableViewController, ManualConnectProtocol
{
    weak var ParentDelegate: ManualConnectProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let count: Int = HostNames!.count
        print("At ManualConnectCode. HostNamesCount=\(count)")
    }
    
    private var _HostNames: [String]? = nil
    public var HostNames: [String]?
    {
        get
        {
            return _HostNames
        }
        set
        {
            _HostNames = newValue
        }
    }
    
    func SetSelectedHost(HostName: String)
    {
        //Not used in this class.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let Names = HostNames
        {
            return Names.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if HostNames == nil
        {
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "RemoteHostCell")
        }
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "RemoteHostCell")
        Cell.textLabel!.text = HostNames![indexPath.row]
        return Cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let Names = HostNames
        {
            ParentDelegate?.SetSelectedHost(HostName: Names[indexPath.row])
        }
        else
        {
            ParentDelegate?.SetSelectedHost(HostName: "")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleRefreshButton(_ sender: Any)
    {
        HostNames = ParentDelegate?.RefreshList()
        self.tableView.reloadData()
    }
    
    func RefreshList() -> [String]
    {
        //Not used in this class.
        return [String]()
    }
    
    @IBAction func HandleBackButton(_ sender: Any)
    {
        ParentDelegate?.SetSelectedHost(HostName: "")
        dismiss(animated: true, completion: nil)
    }
}
