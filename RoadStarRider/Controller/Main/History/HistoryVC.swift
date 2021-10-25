//
//  HistoryVC.swift
//  RoadStarRider
//
//  Created by Faizan Ali  on 2021/6/8.
//  Copyright © 2021 Faizan Ali . All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SDWebImage

class HistoryVC: BaseViewController, Storyboarded {
    
    @IBOutlet weak var theTableView: UITableView!
    
    
    var internationalJobs: [EarningHistoryInternationalJob] = [EarningHistoryInternationalJob]()
    var localJobs: [LocalJob] = [LocalJob]()
    
    override func setupUI() {

        registerXibs()
        self.getHistory()
    }
    
    func registerXibs() {
        
        let nib = UINib.init(nibName: "HistoryCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "HistoryCell")
    }
    
    func getHistory() {
        
        let pi = ProgressIndicator.show(message: "loading...")
        self.getHistory { (msg, success) in
                Run.onMain {
                    pi.close()
                    self.theTableView.reloadData()
                }
        }
    }
}


extension HistoryVC {
    
    func getHistory(block: @escaping (String?, Bool)-> Void){
        
        TheRoute.history.send(EarningHistoryResponse.self, data: nil, multipleData: nil) { (progress) in
            print(progress)
        } then: { (results) in
            
            switch results {
            case .failure(let error):
                print(error)
                block(error.localizedDescription, false)
                
                
            case .success(let data ):
                print(data)
                if let theData = data.internationalJobs {
                    
                    
                    self.internationalJobs = theData
                }
                if let local = data.localJobs {
                    self.localJobs = local
                }
                block(nil, true)
            }
        }
    }
}


extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return internationalJobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryCell
        
        let history = self.internationalJobs[indexPath.row]
        
        let date = history.createdAt ?? ""
        let id = history.bookingID ?? ""
        let earning = history.tripAmount ?? 0
        let to = history.tripto ?? ""
        let from = history.tripfrom ?? ""
        
        cell.setUp(date: date, id: id, earning: String(earning), to: to, from: from)
        
//        let history = self.localJobs[indexPath.row]
        
        return cell
        
    }
    
    
    
}
