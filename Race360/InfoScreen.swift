//
//  InfoScreen.swift
//  Race360
//
//  Created by Ammar Khawaja on 1/3/24.
//

import Foundation
import UIKit
import FirebaseDatabase

var leaderboardList = [(String, Int, String, String)]()
var allleaderboardList = [(String, Int, String, String)]()

class InfoScreen: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var userTopSpeed: UILabel!
    @IBOutlet weak var userRank: UILabel!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var vehicleTextField: UITextField!
    
    @IBOutlet weak var zoneSelector: UISegmentedControl!
    @IBOutlet weak var timeSelector: UISegmentedControl!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if timeSelector.selectedSegmentIndex == 0 {
            return leaderboardList.count
        }else {
            return allleaderboardList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.positionText.text = String(indexPath.row + 1)
        
        if timeSelector.selectedSegmentIndex == 0 {
            if indexPath.row < leaderboardList.count {
                cell.descriptionText.text = String(leaderboardList[indexPath.row].3) + " - " + String(leaderboardList[indexPath.row].1) + "mph"
            }
        }else {
            if indexPath.row < allleaderboardList.count {
                cell.descriptionText.text = String(allleaderboardList[indexPath.row].3) + " - " + String(allleaderboardList[indexPath.row].1) + "mph"
            }
        }
        return cell
    }
    
    @IBOutlet weak var leaderboardView: UITableView!
    
    let date = Date()
    let formatter = DateFormatter()
    var dailyUserRank = 0
    var allUserRank = 0
    
    override func viewDidLoad() {
        leaderboardView.dataSource = self
        formatter.dateFormat = "dd-MM-yyyy"
        let currDate = formatter.string(from: date)
        
        userTextField.delegate = self
        vehicleTextField.delegate = self
        
        zoneSelector.isEnabled = false
        zoneSelector.selectedSegmentIndex = 1
        leaderboardList = []
        allleaderboardList = []
        r.child("users").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    let cs = child as! DataSnapshot
                    let user = cs.childSnapshot(forPath: "name").value as! String
                    if cs.childSnapshot(forPath: "speed").childSnapshot(forPath: currDate).childSnapshot(forPath: "spe").exists() {
                        let spe = cs.childSnapshot(forPath: "speed").childSnapshot(forPath: currDate).childSnapshot(forPath: "spe").value as! Int
                        let loc = cs.childSnapshot(forPath: "speed").childSnapshot(forPath: currDate).childSnapshot(forPath: "loc").value as! String
                        leaderboardList.append((cs.key as! String, spe, loc, user))
                        leaderboardList = leaderboardList.sorted { $0.1 > $1.1 }
                        for i in 0...leaderboardList.count - 1{
                            if leaderboardList[i].0 == USERID {
                                self.dailyUserRank = i + 1
                            }
                        }
                        self.userRank.text = "Rank: \(self.dailyUserRank)"
                        self.leaderboardView.reloadData()
                    }
                }
            }
        }
        r.child("users").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    let cs = child as! DataSnapshot
                    let user = cs.childSnapshot(forPath: "name").value as! String
                    if cs.childSnapshot(forPath: "speed").childSnapshot(forPath: "alltime").childSnapshot(forPath: "spe").exists() {
                        let spe = cs.childSnapshot(forPath: "speed").childSnapshot(forPath: "alltime").childSnapshot(forPath: "spe").value as! Int
                        let loc = cs.childSnapshot(forPath: "speed").childSnapshot(forPath: "alltime").childSnapshot(forPath: "loc").value as! String
                        allleaderboardList.append((cs.key as! String, spe, loc, user))
                        allleaderboardList = allleaderboardList.sorted { $0.1 > $1.1 }
                        for i in 0...allleaderboardList.count - 1{
                            if allleaderboardList[i].0 == USERID {
                                self.allUserRank = i + 1
                            }
                        }
                        self.leaderboardView.reloadData()
                    }
                }
            }
        }
        r_user.child("name").observe(.value) { (snapshot) in
            self.userTextField.text = snapshot.value as! String
        }
        r_user.child("vehicle").observe(.value) { (snapshot) in
            self.vehicleTextField.text = snapshot.value as! String
        }
        r_user.child("speed").child(currDate).child("spe").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.userTopSpeed.text = "Top Speed: \(snapshot.value as! Int)"
            }
        }
    }
    
    @IBAction func timeSelected(_ sender: Any) {
        if timeSelector.selectedSegmentIndex == 0 {
            formatter.dateFormat = "dd-MM-yyyy"
            let currDate = formatter.string(from: date)
            r_user.child("speed").child(currDate).child("spe").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    self.userTopSpeed.text = "Top Speed: \(snapshot.value as! Int)"
                    self.userRank.text = "Rank: \(self.dailyUserRank)"
                }
            }
            leaderboardView.reloadData()

        }else {
            r_user.child("speed").child("alltime").child("spe").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    self.userTopSpeed.text = "Top Speed: \(snapshot.value as! Int)"
                    self.userRank.text = "Rank: \(self.allUserRank)"
                }
            }
            leaderboardView.reloadData()
        }
    }
    @IBAction func zoneSelected(_ sender: Any) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        r_user.child("name").setValue(userTextField.text)
        r_user.child("vehicle").setValue(vehicleTextField.text)
        return true
    }
}
