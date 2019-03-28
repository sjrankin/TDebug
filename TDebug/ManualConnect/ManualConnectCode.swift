//
//  ManualConnectCode.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ManualConnectCode: UIViewController, ManualConnectProtocol, CommDelegate,
    UITableViewDelegate, UITableViewDataSource
{
    var TComm: Comm!
    weak var ParentDelegate: ManualConnectProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let AppDel = UIApplication.shared.delegate as! AppDelegate
        TComm = AppDel.TComm
        
        WaitingIndicator.color = UIColor(named: "Pistachio")
        WaitingIndicator.startAnimating()
        WaitingIndicator.isHidden = false
        
        ServerTable.layer.cornerRadius = 5.0
        ServerTable.layer.borderColor = UIColor.black.cgColor
        ServerTable.layer.borderWidth = 0.5
        ServerTable.delegate = self
        ServerTable.dataSource = self
        
        let OK = TComm.SearchForServices(Delegate: self)
        if (!OK)
        {
            print("Comm class busy.")
        }
        
        //self.tableView.tableFooterView = UIView()
    }
    
    private var _HostNames: [(String, NetService)]? = nil
    public var HostNames: [(String, NetService)]?
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
    
    func SetSelectedHost(HostName: String, Server: NetService?)
    {
        //Not used in this class.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let Names = HostNames
        {
            return Names.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if HostNames == nil
        {
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "RemoteHostCell")
        }
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "RemoteHostCell")
        Cell.textLabel!.text = HostNames![indexPath.row].0
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let Names = HostNames
        {
            ParentDelegate?.SetSelectedHost(HostName: Names[indexPath.row].0, Server: Names[indexPath.row].1)
        }
        else
        {
            ParentDelegate?.SetSelectedHost(HostName: "", Server: nil)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleRefreshButton(_ sender: Any)
    {
        HostNames?.removeAll()
        ServerTable.reloadData()
        WaitingIndicator.isHidden = false
        let OK = TComm.SearchForServices(Delegate: self)
        if (!OK)
        {
            print("Comm class busy.")
        }
    }
    
    func RawDataReceived(_ RawData: String, _ BytesRead: Int)
    {
        //Not used in this class.
    }
    
    func RemoteServerList(_ List: [(String, NetService)])
    {
        HostNames = List
        WaitingIndicator.isHidden = true
        ServerTable.reloadData()
    }
    
    @IBAction func HandleBackButton(_ sender: Any)
    {
        ParentDelegate?.SetSelectedHost(HostName: "", Server: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var WaitingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ServerTable: UITableView!
}
