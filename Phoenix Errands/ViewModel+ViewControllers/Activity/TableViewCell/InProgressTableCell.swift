//
//  InProgressTableCell.swift
//  Phoenix Errands
//
//  Created by Raghav Beriwala on 06/09/19.
//  Copyright © 2019 Shyam Future Tech. All rights reserved.
//

import UIKit
import Localize_Swift
protocol cancelRequestDelegates {
    func cancelRequest(indexPathValue : Int)
    func detailsRequest(indexPathValue : Int)
}

class InProgressTableCell: UITableViewCell {

    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var activeView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblServiceDescribtion: UILabel!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var cancelRequestBtnOutlet: UIButton!
    var cancelDelegate : cancelRequestDelegates?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Localize.currentLanguage() == "en" {
            detailsButton.setTitle("Details", for: .normal)
        }else{
            detailsButton.setTitle("détails", for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initializeCellDetails(cellDic : ServiceList)
    {
        if cellDic.is_active == "1" {
            activeView.isHidden = true
        }else{
            activeView.isHidden = false
        }
        lblServiceName.text = cellDic.serviceName
        lblServiceDescribtion.text = cellDic.serviceDescription
        //let dateTime = dateFormate(date: cellDic.created_at!)
        lblDate.text = cellDic.created_at //dateTime
    }
    
    func dateFormate(date : String) -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMM,yyyy hh:mm"
        
        let date: NSDate? = (dateFormatterGet.date(from: date)! as NSDate)
        print(dateFormatterPrint.string(from: date! as Date))
        
        return dateFormatterPrint.string(from: date! as Date)
    }
    
    @IBAction func cancelRequestBtn(_ sender: Any) {
        cancelDelegate?.cancelRequest(indexPathValue: (sender as AnyObject).tag)
    }
    
    @IBAction func detailsButtonAction(_ sender: Any) {
        cancelDelegate?.detailsRequest(indexPathValue: (sender as AnyObject).tag)
    }
}
