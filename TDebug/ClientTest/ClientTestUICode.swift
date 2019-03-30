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
    UIPickerViewDataSource, MultiPeerDelegate
{
    let ServerMessageTableTag = 200
    weak var Main: MainProtocol? = nil
    var MPMgr: MultiPeerManager? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        MPMgr = MultiPeerManager()
        MPMgr?.Delegate = self
        MPMgr?.IsDebugHost = false
        ServerList = (MPMgr?.GetPeerList())!
        
        ServerMessageTable.layer.cornerRadius = 5.0
        ServerMessageTable.layer.borderColor = UIColor.black.cgColor
        ServerMessageTable.layer.borderWidth = 0.5
        IdiotLightPicker.layer.cornerRadius = 5.0
        IdiotLightPicker.layer.borderWidth = 0.5
        IdiotLightPicker.layer.borderColor = UIColor.black.cgColor
        
        IdiotLightPicker.delegate = self
        IdiotLightPicker.dataSource = self
        IdiotLightPicker.reloadAllComponents()
        
        ServerMessageTable.delegate = self
        ServerMessageTable.dataSource = self
        ServerMessageTable.reloadData()
    }
    
    func ConnectedDeviceChanged(Manager: MultiPeerManager, ConnectedDevices: [MCPeerID], Changed: MCPeerID, NewState: MCSessionState)
    {
        
    }
    
    func ReceivedData(Manager: MultiPeerManager, Peer: MCPeerID, RawData: String)
    {
        
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
    
    @IBAction func HandleBackButtonPressed(_ sender: Any)
    {
        IsRunning = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleHeartbeatPayloadChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleSendTextButtonPressed(_ sender: Any)
    {
        if let Message = SendTextBox.text
        {
            MPMgr?.Broadcast(Message: Message, To: ServerList[CurrentHostIndex])
            SendTextBox.text = ""
        }
        else
        {
            print("No text to send.")
        }
    }
    
    @IBAction func HandleEchoButtonPressed(_ sender: Any)
    {
    }
    
    @IBAction func HandleIdiotLightButtonPressed(_ sender: Any)
    {
    }
    
    func ConvertToNetworkName(_ Raw: String) -> String
    {
        return Raw.replacingOccurrences(of: " ", with: "-")
    }
    
    @IBAction func HandleServerButtonPressed(_ sender: Any)
    {
        if ServerList.count < 1
        {
            //search for servers first
            ServerList = (MPMgr?.GetPeerList())!
        }
        if ServerList.count < 1
        {
            ServerButton.title = "Server: none found"
            return
        }
        
        let Button = sender as? UIBarButtonItem
        
        let ThisDevice = ConvertToNetworkName(GetDeviceName())
        let Alert = UIAlertController(title: "Server List", message: "Select server to test.", preferredStyle: UIAlertController.Style.alert)
        for Index in 0 ..< ServerList.count
        {
            var IsSelf = false
            print("\(ThisDevice): \(ConvertToNetworkName(ServerList[Index].displayName))")
            if ConvertToNetworkName(ServerList[Index].displayName) == ThisDevice
            {
                IsSelf = true
            }
            let Title = "\(Index + 1). " + ServerList[Index].displayName
            let AAction = UIAlertAction(title: Title, style: UIAlertAction.Style.default, handler: HandleServerSelection)
            Alert.addAction(AAction)
            if IsSelf
            {
                Alert.actions[Index].isEnabled = false
                Alert.actions[Index].setValue(UIColor.darkGray, forKey: "titleTextColor")
            }
        }
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: HandleServerSelection))
        
        let Presenter = Alert.popoverPresentationController
        Presenter?.barButtonItem = Button
        present(Alert, animated: true, completion: nil)
    }
    
    @objc func HandleServerSelection(Alert: UIAlertAction)
    {
        if Alert.title == "Cancel"
        {
            return
        }
        if !Alert.isEnabled
        {
            return
        }
        let Parts = Alert.title!.split(separator: ".")
        let Index = Int(String(Parts[0]))! - 1
        CurrentHostIndex = Index
        ServerButton.title = "Server: " + ServerList[Index].displayName
    }
    
    var CurrentHostIndex: Int = -1
    {
        didSet
        {
            let HaveHost = CurrentHostIndex >= 0
            SendTextButton.isEnabled = HaveHost
            EchoButton.isEnabled = HaveHost
            SetIdiotLightButton.isEnabled = HaveHost
            StartStopButton.isEnabled = HaveHost
            if HeartbeatTimer != nil
            {
                HeartbeatTimer?.invalidate()
                HeartbeatTimer = nil
            }
        }
    }
    
    func GetEchoDelay() -> Int
    {
        let Index = EchoDelaySegment.selectedSegmentIndex
        return [0, 1, 5, 10, 30, 60][Index]
    }
    
    func GetHeartbeatInterval() -> Int
    {
        let Index = HeartbeatIntervalSegment.selectedSegmentIndex
        return [1, 5, 10, 30, 60, 120, 300][Index]
    }
    
    @IBAction func HandleHeartbeatIntervalChanged(_ sender: Any)
    {
        HandleEnableHeartbeatChanged(EnableHeartbeatSwitch as Any)
    }
    
    @IBAction func HandleEnableHeartbeatChanged(_ sender: Any)
    {
        if EnableHeartbeatSwitch.isOn
        {
            if HeartbeatTimer != nil
            {
                HeartbeatTimer?.invalidate()
                HeartbeatTimer = nil
            }
            let Interval = Double(GetHeartbeatInterval())
            HeartbeatTimer = Timer.scheduledTimer(timeInterval: Interval, target: self,
                                                  selector: #selector(HandleHeartbeat),
                                                  userInfo: nil, repeats: true)
        }
        else
        {
            if HeartbeatTimer != nil
            {
                HeartbeatTimer?.invalidate()
                HeartbeatTimer = nil
            }
        }
    }
    
    @objc func HandleHeartbeat()
    {
        let NextExpected = GetHeartbeatInterval()
        var HeartbeatMessage: String = ""
        if HeartbeatPayloadSwitch.isOn
        {
            HeartbeatMessage = MessageHelper.MakeHeartbeatMessage(Payload: HeartbeatPayload,
                                                                  NextExpectedIn: NextExpected,
                                                                  GetDeviceName())
        }
        else
        {
            HeartbeatMessage = MessageHelper.MakeHeartbeatMessage(NextExpectedIn: NextExpected,
                                                                  GetDeviceName())
        }
        MPMgr?.SendPreformatted(Message: HeartbeatMessage, To: ServerList[CurrentHostIndex])
    }
    
    /// Returns the name of the device. In this case, "name" means the name the user gave the device.
    ///
    /// - Returns: Name of the device.
    func GetDeviceName() -> String
    {
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.nodename.0)
        {
            ptr in
            return String(cString: ptr)
        }
        let Parts = Name.split(separator: ".")
        return String(Parts[0])
    }
    
    var HeartbeatTimer: Timer? = nil
    
    @IBOutlet weak var EchoDelaySegment: UISegmentedControl!
    @IBOutlet weak var HeartbeatIntervalSegment: UISegmentedControl!
    @IBOutlet weak var ServerButton: UIBarButtonItem!
    @IBOutlet weak var EchoButton: UIButton!
    @IBOutlet weak var SendTextButton: UIButton!
    @IBOutlet weak var EchoTextBox: UITextField!
    @IBOutlet weak var SendTextBox: UITextField!
    @IBOutlet weak var HeartbeatPayloadSwitch: UISwitch!
    @IBOutlet weak var IdiotLightPicker: UIPickerView!
    @IBOutlet weak var EnableHeartbeatSwitch: UISwitch!
    @IBOutlet weak var SetIdiotLightButton: UIButton!
    
    let HeartbeatPayload = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a leo blandit, commodo nunc sit amet, euismod eros. Pellentesque varius ornare est sit amet accumsan. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla lectus ante, lacinia eget odio ac, facilisis consectetur lacus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Praesent pulvinar fermentum ante in cursus. Ut ac ullamcorper enim.
"""
}
