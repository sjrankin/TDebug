//
//  MainController.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let IDTableTag = 100
    let StatusTableTag = 200
    let LogTableTag = 300
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeUI()
        
        IDTable.delegate = self
        IDTable.dataSource = self
        IDTable.reloadData()
        
        StatusTable.delegate = self
        StatusTable.dataSource = self
        StatusTable.reloadData()
        
        LogTable.delegate = self
        LogTable.dataSource = self
        LogTable.reloadData()
        
        IdiotLightContainer.layer.cornerRadius = 5.0
        IdiotLightContainer.layer.borderWidth = 0.5
        IdiotLightContainer.layer.borderColor = UIColor.darkGray.cgColor
        LoadIdiotLights()
        
        AddIDData("Program", "TDebug")
        AddIDData("Version", "1.0")
        
        AddStatusData("Status", "Waiting for connection")
        SetIdiotLight("A", 1, "Not Connected", UIColor.white, UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0))
        EnableIdiotLight("A", 2, false)
        EnableIdiotLight("A", 3, false)
        EnableIdiotLight("B", 1, false)
        EnableIdiotLight("B", 2, false)
        EnableIdiotLight("B", 3, false)
        EnableIdiotLight("C", 1, false)
        EnableIdiotLight("C", 2, false)
        EnableIdiotLight("C", 3, false)
    }
    
    func InitializeUI()
    {
        IDTable.layer.cornerRadius = 5.0
        IDTable.layer.borderColor = UIColor.black.cgColor
        IDTable.layer.borderWidth = 0.5
        
        StatusTable.layer.cornerRadius = 5.0
        StatusTable.layer.borderColor = UIColor.black.cgColor
        StatusTable.layer.borderWidth = 0.5
        
        LogTable.layer.cornerRadius = 5.0
        LogTable.layer.borderColor = UIColor.black.cgColor
        LogTable.layer.borderWidth = 0.5
    }
    
    func AddIDData(_ Name: String, _ Value: String)
    {
        IDList.append((Name, Value))
        IDTable.reloadData()
    }
    
    func ClearIDList()
    {
        IDList.removeAll()
        IDTable.reloadData()
    }
    
    func AddStatusData(_ Name: String, _ Value: String)
    {
        StatusList.append((Name, Value))
        StatusTable.reloadData()
    }
    
    func ClearStatusList()
    {
        StatusList.removeAll()
        StatusTable.reloadData()
    }
    
    func EnableIdiotLight(_ Row: String, _ Column: Int, _ DoEnable: Bool,
                          _ EnableFGColor: UIColor = UIColor.black,
                          _ EnableBGColor: UIColor = UIColor.white)
    {
        if DoEnable
        {
            UIView.animate(withDuration: 0.2, animations:
                {
                    self.IdiotLightAt(Row, Column)!.1.textColor = EnableFGColor
                    self.IdiotLightAt(Row, Column)!.0.backgroundColor = EnableBGColor
            })
        }
        else
        {
            UIView.animate(withDuration: 0.35, animations:
                {
                    self.IdiotLightAt(Row, Column)!.1.textColor = UIColor.clear
                    self.IdiotLightAt(Row, Column)!.0.backgroundColor = UIColor.white
            })
        }
    }
    
    func IdiotLightAt(_ Row: String, _ Column: Int) -> (UIView, UILabel)?
    {
        for (IRow, IColumn, IView, ILabel) in IdiotLightTable
        {
            if IRow == Row && IColumn == Column
            {
                return (IView, ILabel)
            }
        }
        return nil
    }
    
    func LoadIdiotLights()
    {
        InitializeIdiotLight("A", 1, View: A1, Label: A1Label)
        InitializeIdiotLight("A", 2, View: A2, Label: A2Label)
        InitializeIdiotLight("A", 3, View: A3, Label: A3Label)
        InitializeIdiotLight("B", 1, View: B1, Label: B1Label)
        InitializeIdiotLight("B", 2, View: B2, Label: B2Label)
        InitializeIdiotLight("B", 3, View: B3, Label: B3Label)
        InitializeIdiotLight("C", 1, View: C1, Label: C1Label)
        InitializeIdiotLight("C", 2, View: C2, Label: C2Label)
        InitializeIdiotLight("C", 3, View: C3, Label: C3Label)
    }
    
    func InitializeIdiotLight(_ Row: String, _ Column: Int, View: UIView, Label: UILabel)
    {
        View.layer.cornerRadius = 5.0
        View.layer.borderColor = UIColor.black.cgColor
        View.layer.borderWidth = 0.5
        View.backgroundColor = UIColor.white
        Label.textColor = UIColor.black
        IdiotLightTable.append((Row, Column, View, Label))
    }
    
    var IdiotLightTable = [(String, Int, UIView, UILabel)]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch tableView.tag
        {
        case IDTableTag:
            return IDTableCell.CellHeight
            
        case StatusTableTag:
            return StatusTableCell.CellHeight
            
        case LogTableTag:
            return LogTableCell.CellHeight
            
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView.tag
        {
        case IDTableTag:
            return IDList.count
            
        case StatusTableTag:
            return StatusList.count
            
        case LogTableTag:
            return LogList.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView.tag
        {
        case IDTableTag:
            return MakeIDCell(indexPath.row)
            
        case StatusTableTag:
            return MakeStatusCell(indexPath.row)
            
        case LogTableTag:
            return MakeLogCell(indexPath.row)
            
        default:
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "UnexpectedTableTag")
        }
    }
    
    func MakeIDCell(_ Row: Int) -> UITableViewCell
    {
        let IDCell = IDTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "IDTableCell")
        IDCell.SetData(Name: IDList[Row].0, Value: IDList[Row].1)
        return IDCell
    }
    
    func MakeStatusCell(_ Row: Int) -> UITableViewCell
    {
        let StatusCell = StatusTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StatusTableCell")
        StatusCell.SetData(Name: StatusList[Row].0, Value: StatusList[Row].1)
        return StatusCell
    }
    
    func MakeLogCell(_ Row: Int) -> UITableViewCell
    {
        let LogCell = LogTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "LogTableCell")
        LogCell.SetData(Name: LogList[Row].Title, Value: LogList[Row].Message)
        return LogCell
    }
    
    func SetIdiotLight(_ Row: String, _ Column: Int, _ Text: String, _ TextColor: UIColor = UIColor.black,
                       _ BGColor: UIColor = UIColor.white)
    {
        EnableIdiotLight(Row, Column, true)
        IdiotLightAt(Row, Column)!.0.backgroundColor = BGColor
        IdiotLightAt(Row, Column)!.1.textColor = TextColor
        IdiotLightAt(Row, Column)!.1.text = Text
    }
    
    @IBAction func HandleClearLogButton(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Clear Log Display?",
                                      message: "Do you really want to clear the contents of the log? You can save the log first if you want.",
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: HandleClearLogButtonAction))
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: HandleClearLogButtonAction))
        present(Alert, animated: true)
    }
    
    @objc func HandleClearLogButtonAction(Alert: UIAlertAction)
    {
        switch Alert.title
        {
        case "OK":
            LogList.removeAll()
            LogTable.reloadData()
            
        default:
            break
        }
    }
    
    @IBAction func HandleDisconnectButton(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Really Disconnect?",
                                      message: "Do you really want to disconnect from the remote process?",
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: HandleDisconnectAction))
        Alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: HandleDisconnectAction))
    }
    
    @objc func HandleDisconnectAction(Alert: UIAlertAction)
    {
        switch Alert.title
        {
        case "Yes":
            //disconnect here
            break
            
        default:
            break
        }
    }
    
    @IBAction func HandlePauseButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleConnectButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleSendButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleActionButton(_ sender: Any)
    {
    }
    
    var IDList = [(String, String)]()
    var StatusList = [(String, String)]()
    var LogList = [LogItem]()
    
    @IBOutlet weak var A1Label: UILabel!
    @IBOutlet weak var A2Label: UILabel!
    @IBOutlet weak var A3Label: UILabel!
    @IBOutlet weak var B1Label: UILabel!
    @IBOutlet weak var B2Label: UILabel!
    @IBOutlet weak var B3Label: UILabel!
    @IBOutlet weak var C1Label: UILabel!
    @IBOutlet weak var C2Label: UILabel!
    @IBOutlet weak var C3Label: UILabel!
    @IBOutlet weak var A1: UIView!
    @IBOutlet weak var A2: UIView!
    @IBOutlet weak var A3: UIView!
    @IBOutlet weak var B1: UIView!
    @IBOutlet weak var B2: UIView!
    @IBOutlet weak var B3: UIView!
    @IBOutlet weak var C1: UIView!
    @IBOutlet weak var C2: UIView!
    @IBOutlet weak var C3: UIView!
    @IBOutlet weak var IdiotLightContainer: UIView!
    @IBOutlet weak var IDTable: UITableView!
    @IBOutlet weak var StatusTable: UITableView!
    @IBOutlet weak var LogTable: UITableView!
}
