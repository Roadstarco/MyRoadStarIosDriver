//
//  EarningVC.swift
//  RoadStarRider
//
//  Created by Faizan Ali  on 2021/6/7.
//  Copyright © 2021 Faizan Ali . All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SDWebImage

class EarningVC: BaseViewController, Storyboarded {
    
    @IBOutlet weak var theTableView: UITableView!
    @IBOutlet weak var lblEarning: UILabel!
    
    
    var internationalJobs: [EarningHistoryInternationalJob] = [EarningHistoryInternationalJob]()
    var earning: EarningResponse? = nil
    
    override func setupUI() {

        self.reloadTheView()
        registerXibs()
        self.getHistory()
    }
    
    func registerXibs() {
        
        let nib = UINib.init(nibName: "EarningCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "EarningCell")
    }
    
    func reloadTheView() {
        
        if let e = self.earning {
            lblEarning.text = "$\(e.internationalRidesRevenue ?? 0).0"
            
        }
    }
    
    func getHistory() {
        
        let pi = ProgressIndicator.show(message: "loading...")
        self.getHistory { (msg, success) in
            self.getEarnings { (msg, success) in
                Run.onMain {
                    pi.close()
                    self.theTableView.reloadData()
                    self.reloadTheView()
                }
            }
        }
    }
}


extension EarningVC {
    
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
                block(nil, true)
            }
        }
    }
    
    func getEarnings(block: @escaping (String?, Bool)-> Void){

        TheRoute.summary.send(EarningResponse.self, data: nil, multipleData: nil) { (progress) in
            print(progress)
        } then: { (results) in
            switch results {
            case .failure(let error):
                print(error)
                block(error.localizedDescription, false)
                
                
            case .success(let data ):
                print(data)
                self.earning = data
                block(nil, true)
            }
        }
    }
}


extension EarningVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return internationalJobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EarningCell") as! EarningCell
        
        cell.setUp(history: self.internationalJobs[indexPath.row])
        
        return cell
        
    }
    
    
    
}
