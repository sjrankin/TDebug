//
//  ClientTestUICode.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class ClientTestUICode: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,
    UIPickerViewDataSource
{

    
    let ServerTableTag = 100
    let ServerMessageTableTag = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ServerTable.layer.cornerRadius = 5.0
        ServerTable.layer.borderColor = UIColor.black.cgColor
        ServerTable.layer.borderWidth = 0.5
        ServerMessageTable.layer.cornerRadius = 5.0
        ServerMessageTable.layer.borderColor = UIColor.black.cgColor
        ServerMessageTable.layer.borderWidth = 0.5
        IdiotLightPicker.layer.cornerRadius = 5.0
        IdiotLightPicker.layer.borderWidth = 0.5
        IdiotLightPicker.layer.borderColor = UIColor.black.cgColor
        
        IdiotLightPicker.delegate = self
        IdiotLightPicker.dataSource = self
        IdiotLightPicker.reloadAllComponents()
        
        ServerTable.delegate = self
        ServerTable.dataSource = self
        ServerTable.reloadData()
        
        ServerMessageTable.delegate = self
        ServerMessageTable.dataSource = self
        ServerMessageTable.reloadData()
    }
    
    var ServerList = [MCPeerID]()
    var MessageList = [String]()
    var IdiotLightList = ["A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return IdiotLightList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return IdiotLightList[row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView.tag
        {
        case ServerTableTag:
            return ServerList.count
            
        case ServerMessageTableTag:
            return MessageList.count
            
        default:
            return 0
        }
    }
    
    func MakeServerTableCell(ServerName: String) -> UITableViewCell
    {
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ServerCell")
        Cell.textLabel!.text = ServerName
        return Cell
    }
    
    func MakeServerMessageTableCell(Message: String) -> UITableViewCell
    {
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ServerMessageCell")
        Cell.textLabel!.text = Message
        return Cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView.tag
        {
        case ServerTableTag:
            return MakeServerTableCell(ServerName: ServerList[indexPath.row].displayName)
            
        case ServerMessageTableTag:
            return MakeServerMessageTableCell(Message: MessageList[indexPath.row])
            
        default:
            break
        }
        return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "NotUsed")
    }
    
    @IBAction func HandleStartStopButton(_ sender: Any)
    {
        if IsRunning
        {
            IsRunning = false
            StartStopButton.title = "Start"
        }
        else
        {
            IsRunning = true
            StartStopButton.title = "Stop"
        }
    }
    
    func SetRunning(To: Bool)
    {
        
    }
    
    var IsRunning = false
    {
        didSet
        {
            SetRunning(To: IsRunning)
        }
    }
    
    @IBOutlet weak var StartStopButton: UIBarButtonItem!
    
    
    @IBOutlet weak var ServerMessageTable: UITableView!
    @IBOutlet weak var ServerTable: UITableView!
    
    @IBAction func HandleBackButtonPressed(_ sender: Any)
    {
        IsRunning = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var IdiotLightPicker: UIPickerView!
}
