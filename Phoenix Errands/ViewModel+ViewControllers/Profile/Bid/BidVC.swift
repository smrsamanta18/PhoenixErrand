//
//  BidVC.swift
//  Phoenix Errands
//
//  Created by Raghav Beriwala on 10/09/19.
//  Copyright © 2019 Shyam Future Tech. All rights reserved.
//

import UIKit
import Localize_Swift
class BidVC: UIViewController
{
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var lblCurrency : UILabel!
    var requestid: Int?
    lazy var viewModel: BidVM = {
        return BidVM()
    }()
    var biddetails = BidModel()
    @IBOutlet weak var btnSubmitOutlet: UIButton!
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var amountSign = ["Dollar($)","Euro(€)","Pound(£)"]
    var SelectSign = "",updateTextFieldAmount = ""
    var valueType = Int()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        txtAmount.delegate = self
        initializeViewModel()
        if Localize.currentLanguage() == "en" {
            lblHeaderTitle.text = "Bid"
            btnSubmitOutlet.setTitle("SEND", for: .normal)
            txtAmount.placeholder = "Amount"
        }else{
            txtAmount.placeholder = "Montante"
            lblHeaderTitle.text = "offre"
            btnSubmitOutlet.setTitle("Envoyer", for: .normal)
        }
        lblCurrency.text = "$"
        valueType = 1
        txtAmount.keyboardType = .numberPad
    }
    
    func initializeViewModel() {
        
        viewModel.showAlertClosure = {[weak self]() in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message: message, okButtonText: okText, completion: nil)
                }
            }
        }
        viewModel.updateLoadingStatus = {[weak self]() in
            DispatchQueue.main.async {
                
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.addLoaderView()
                } else {
                    self?.removeLoaderView()
                }
            }
        }
        
        viewModel.refreshViewClosure = {[weak self]() in
            DispatchQueue.main.async {
                
                if  (self?.viewModel.bidService.status) == 200
                {
                    self!.biddetails = (self?.viewModel.bidService)!
                    
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message: (self?.viewModel.bidService.message)!, okButtonText: okText, completion: {
                        self?.navigationController?.popViewController(animated: true)
                    })
                    
                    
                }else{
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message: (self?.viewModel.bidService.message)!, okButtonText: okText, completion: nil)
                }
            }
        }
    }
    @IBAction func btnBackTapped(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDropDownAction(_ sender : UIButton){
        txtAmount.endEditing(true)
        picker = UIPickerView.init()
        picker.delegate = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
    }
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        lblCurrency.text = SelectSign
    }
    @IBAction func btnSubmitTapped(_ sender: Any)
    {
        let bidParams = BidParams()
        if requestid != nil
        {
            bidParams.servicerequestid = requestid
        }
        else{
             
        }
        if SelectSign != ""{
            if self.txtAmount.text != "" {
                bidParams.proposalamount = Int(updateTextFieldAmount)
                bidParams.type = valueType
                viewModel.getBidServicesToAPIService(user: bidParams)
            }else{
                self.showAlertWithSingleButton(title: commonAlertTitle, message: "Please enter proposal amount", okButtonText: okText, completion: nil)
            }
        }else{
            self.showAlertWithSingleButton(title: commonAlertTitle, message: "Please select currency first", okButtonText: okText, completion: nil)
        }
    }
}
extension BidVC : UITextFieldDelegate{
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let txtAfterUpdate = textField.text! as NSString
        let updateText = txtAfterUpdate.replacingCharacters(in: range, with: string) as String
        print("Updated TextField:: \(updateText)")
        updateTextFieldAmount = updateText
        return true
    }
    
}
extension BidVC : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return amountSign.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return amountSign[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(amountSign[row])
        switch  amountSign[row]{
        case "Euro(€)":
            SelectSign = "€"
            valueType = 2
        case "Pound(£)":
            SelectSign = "£"
            valueType = 3
        default:
            SelectSign = "$"
            valueType = 1
        }
        
    }
}
