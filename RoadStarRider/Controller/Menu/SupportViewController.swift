//
//  SupportViewController.swift
//  RoadStar Customer
//
//  Created by Roamer on 21/07/2020.
//  Copyright © 2020 Osama Azmat Khan. All rights reserved.
//

import UIKit

class SupportViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var theTableView: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtView: UITextView!
    var currentUserMessages: [String] = [String]()
    var otherUserMessages: [String] = [String]()

    var messages: [String] = [String]()
    
    override func setupUI() {
        registerXib()
        messages = ["Hy", "Hello Sir How are you?"]
    }
    
    override func setupTheme() {
        super.setupTheme()
    }
    
    func registerXib() {
        
        let nib = UINib.init(nibName: OtherUserMessageCell.nibName, bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: OtherUserMessageCell.nibName)
        
        let nib1 = UINib.init(nibName: CurrentUserMessageCell.nibName, bundle: nil)
        theTableView.register(nib1, forCellReuseIdentifier: CurrentUserMessageCell.nibName)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherUserMessageCell.nibName, for: indexPath) as! OtherUserMessageCell
            cell.setUI(text: messages[indexPath.row])
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrentUserMessageCell.nibName, for: indexPath) as! CurrentUserMessageCell
        cell.setUI(text: messages[indexPath.row])
        
        return cell
    }


    @IBAction func btnSendMessage(_ sender: Any) {
        
        messages.append(txtView.text)
        theTableView.reloadData()
        txtView.text = nil
    }
}
