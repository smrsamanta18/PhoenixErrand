//
//  MyOrderCell.swift
//  Phoenix Errands
//
//  Created by Shyam Future Tech on 30/09/19.
//  Copyright © 2019 Shyam Future Tech. All rights reserved.
//

import UIKit
import Localize_Swift
protocol MyOrderMarkasCompleteProtocol {
    func acceptProposal(indexPath : Int)
    func goToContactDetails(indexPath : Int)
}
class MyOrderCell: UITableViewCell {

    @IBOutlet weak var contactBtnOutlet: UIButton!
    @IBOutlet weak var btnMaskasComplete: UIButton!
    @IBOutlet weak var lblServiceName: UILabel!
    @IBOutlet weak var imgProviderImg: UIImageView!
    @IBOutlet weak var lblProviderName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var providerStatus: UILabel!
    @IBOutlet weak var lblProposalDate: UILabel!
    @IBOutlet weak var lblPaymentStatus: UILabel!
    var myOrderMarkasCompleteDelegate : MyOrderMarkasCompleteProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if Localize.currentLanguage() == "en" {
           contactBtnOutlet.setTitle("Contact Information", for: .normal)
        }else{
            contactBtnOutlet.setTitle("Informations de contact", for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnMarkComplete(_ sender: Any) {
        myOrderMarkasCompleteDelegate?.acceptProposal(indexPath: (sender as AnyObject).tag)
    }
    
    @IBAction func btnContactDetailsAction(_ sender: Any) {
        myOrderMarkasCompleteDelegate?.goToContactDetails(indexPath: (sender as AnyObject).tag)
    }
    
    
    func initializeCellDetails(cellDic : MyOrderList) {
        
        if cellDic.status == 1
        {
            if Localize.currentLanguage() == "en" {
               btnMaskasComplete.setTitle("Completed", for: .normal)
            }else{
                btnMaskasComplete.setTitle("Terminé", for: .normal)
            }
        }
        else{
            if Localize.currentLanguage() == "en" {
               btnMaskasComplete.setTitle("Mark as complete", for: .normal)
            }else{
                btnMaskasComplete.setTitle("Marquer comme terminé", for: .normal)
            }
        }
        
        
        if let serviceName = cellDic.serviceName {
            if Localize.currentLanguage() == "en" {
               self.lblServiceName.text = "Service Name : " + serviceName
            }else{
                self.lblServiceName.text = "Nom du service : " + serviceName
            }
        }else{
            if Localize.currentLanguage() == "en" {
               self.lblServiceName.text = "Service Name : "
            }else{
                self.lblServiceName.text = "Nom du service : "
            }
        }
        
        if let userFirstName = cellDic.userFirstName {
            if Localize.currentLanguage() == "en" {
               self.lblProviderName.text = "Provider Name :" + userFirstName
            }else{
                self.lblProviderName.text = "Nom du fournisseur : " + userFirstName
            }
        }else{
            if Localize.currentLanguage() == "en" {
               self.lblProviderName.text = "Provider Name : "
            }else{
                self.lblProviderName.text = "Nom du fournisseur : "
            }
        }
        
        if let cost = cellDic.cost {
            if Localize.currentLanguage() == "en" {
               self.lblPrice.text = "Service Price : \(priceType(type: cellDic.type ?? ""))" + cost
            }else{
                self.lblPrice.text = "Prix ​​du service : \(priceType(type: cellDic.type ?? ""))" + cost
            }
            
        }else{
            if Localize.currentLanguage() == "en" {
               self.lblPrice.text = "Service Price : "
            }else{
                self.lblPrice.text = "Prix ​​du service : "
            }
        }
        
        if let status = cellDic.status {
            if Localize.currentLanguage() == "en" {
               self.providerStatus.text = "Status : Active"
            }else{
                self.providerStatus.text = "Statut : Actif"
            }
        }else{
            if Localize.currentLanguage() == "en" {
               self.providerStatus.text = "Status :"
            }else{
                self.providerStatus.text = "Statut :"
            }
        }
        
        if let created_at = cellDic.created_at {
            if Localize.currentLanguage() == "en" {
               self.lblProposalDate.text = "Date : " + created_at
            }else{
                self.lblProposalDate.text = "Date : " + created_at
            }
            
        }
        
        if let payment_status = cellDic.payment_status {
            if payment_status == 1 {
                if Localize.currentLanguage() == "en" {
                    self.lblPaymentStatus.text = "Payment Status :  Done"
                }else{
                     self.lblPaymentStatus.text = "Statut de paiement :  Terminé"
                }
            }else{
                if Localize.currentLanguage() == "en" {
                    self.lblPaymentStatus.text = "Payment Status : Pending"
                }else{
                     self.lblPaymentStatus.text = "Statut de paiement : En attente"
                }
            }
        }else{
            if Localize.currentLanguage() == "en" {
                self.lblPaymentStatus.text = "Payment Status :"
            }else{
                 self.lblPaymentStatus.text = "Statut de paiement :"
            }
        }
    }
    func priceType(type : String) -> String{
        if type == "1"{
            return "$"
        }else if type == "2"{
            return "€"
        }else if type == "3"{
            return "£"
        }
        else{
            return ""
        }
    }
}
