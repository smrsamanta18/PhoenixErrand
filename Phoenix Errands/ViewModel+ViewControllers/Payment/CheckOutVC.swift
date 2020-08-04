//
//  CheckOutVC.swift
//  Phoenix Errands
//
//  Created by Shyam Future Tech on 25/09/19.
//  Copyright © 2019 Shyam Future Tech. All rights reserved.
//

import UIKit
import Braintree
import Stripe
import MaterialComponents.MaterialCards
import Localize_Swift

class CheckOutVC: BaseViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var cardListCollectionView: UICollectionView!
    @IBOutlet weak var txtExpDate: UITextField!
    @IBOutlet weak var txtCvvNumber: UITextField!
    @IBOutlet weak var txtCardNumber: UITextField!
    var clientToken : String?
    var nonce:String?
    var strstripeCode : String?
    var proposalID : Int = 0
    lazy var viewModel: PaymentVM = {
        return PaymentVM()
    }()
    
    lazy var viewProfileModel: ProfileVM = {
        return ProfileVM()
    }()
    
    var PaymentDetails = PaymentModel()
    let card = MDCCard()
    
    var userCardList : [UserCardList]?
    var isExistingCardPay = false
    var isExistingToken : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeViewModel()
        //self.acceptProposal()
        setText()
        txtCardNumber.keyboardType = .numberPad
        txtCvvNumber.keyboardType = .numberPad
        txtExpDate.delegate = self
        txtCardNumber.delegate = self
        
        
//        let defaults = UserDefaults.standard
//        let myarray = defaults.array(forKey: "CardDetails")  as? [UserCardList]
//        userCardList = myarray
        self.cardListCollectionView.register(UINib(nibName: "CardListCell", bundle: Bundle.main), forCellWithReuseIdentifier:  "CardListCell")
        self.cardListCollectionView.delegate = self
        self.cardListCollectionView.dataSource = self

        getProfileDetailsview()
        initializeViewProfileModel()
    }
    
    func getProfileDetailsview(){
        viewProfileModel.getProfileDetailsToAPIService()
    }
    
    func setText(){
        
       // UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
             statusBar.backgroundColor = UIColor.clear
             UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
             UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
        }
        if Localize.currentLanguage() == "en"{
            headerView.lblHeaderTitle.text = "Wallet"//"Card Details"
            txtCardNumber.placeholder = "Card Number"
            lblTitle.text = "Use this card for your payment on Phoenix Errands"
        }else{
            headerView.lblHeaderTitle.text = "Wallet"//"Détails de la carte"
            txtCardNumber.placeholder = "Numéro de carte"
            lblTitle.text = "Utilisez cette carte pour votre paiement sur Phoenix Errands"
        }
        headerView.imgProfileIcon.isHidden = false
        headerView.menuButtonOutlet.isHidden = false
        headerView.imgViewMenu.isHidden = false
        headerView.menuButtonOutlet.tag = 1
        headerView.imgViewMenu.image = UIImage(named:"whiteback")
        headerView.notificationValueView.isHidden = true
        headerView.imgProfileIcon.isHidden = true
    }
    
    
    @IBAction func btnOkTapped(_ sender: Any){
        //callStripeViewControllerMethod()
        isExistingToken = nil
        isExistingCardPay = false
        if txtCardNumber.text == "" {
            self.showAlertWithSingleButton(title: commonAlertTitle, message:"Please enter valid card number", okButtonText: okText, completion: nil)
        }else if txtExpDate.text == "" {
            
            self.showAlertWithSingleButton(title: commonAlertTitle, message:"Please enter expiry date", okButtonText: okText, completion: nil)
            
        }else if txtCvvNumber.text == "" {
            
            self.showAlertWithSingleButton(title: commonAlertTitle, message:"Please enter valid CVV number", okButtonText: okText, completion: nil)
            
        }else{
            self.acceptProposal()
        }
    }
    
    @IBAction func scanCardTapped(_ sender: Any)
    {
        let vc = UIStoryboard.init(name: "Profile", bundle: Bundle.main).instantiateViewController(withIdentifier: "ScannCardVC") as? ScannCardVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func acceptProposal(){
        let obj = AcceptProposalParam()
        obj.proposal_id = proposalID
        viewModel.sendAcceptProposalToAPIService(user: obj)
    }
    
    func postPaymentDetails(stripeToken : String){
        let obj = AcceptProposalParam()
        obj.stripeToken = stripeToken
        obj.contactid = Int(PaymentDetails.id!)
        viewModel.sendPaymentDetailsToAPIService(user: obj)
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
                if (self?.viewModel.PaymentDetails.status) == 200 {
                    self!.PaymentDetails = (self?.viewModel.PaymentDetails)!
                    if self!.isExistingCardPay == true{
                        self!.postPaymentDetails(stripeToken: self!.isExistingToken!)
                    }else{
                        self!.callStripeViewControllerMethod()
                    }
                    
                }else{
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message:(self?.viewModel.PaymentDetails.message)!, okButtonText: okText, completion: nil)
                }
            }
        }
        
        viewModel.refreshPaymentViewClosure = {[weak self]() in
            DispatchQueue.main.async {
                if (self?.viewModel.PaymentDetails.status) == 200 {
                    
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message:alertPaymentSucessMessage, okButtonText: okText, completion: {
                        let vc = UIStoryboard.init(name: "Activity", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyORderVC") as? MyORderVC
                        vc!.tagID = 3
                        self!.navigationController?.pushViewController(vc!, animated: true)
                    })
                }else{
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message:(self?.viewModel.PaymentDetails.message)!, okButtonText: okText, completion: nil)
                }
            }
        }
        
        viewModel.refreshDeleteViewClosure = {[weak self]() in
            DispatchQueue.main.async {
                if (self?.viewModel.deleteCardModel.status) == 200 {
                    
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message:(self?.viewModel.deleteCardModel.message)!, okButtonText: okText, completion: {
                        self?.getProfileDetailsview()
                    })
                }else{
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message:(self?.viewModel.deleteCardModel.message)!, okButtonText: okText, completion: nil)
                }
            }
        }
    }
    
    
    func initializeViewProfileModel() {
        
        viewProfileModel.showAlertClosure = {[weak self]() in
            DispatchQueue.main.async {
                if let message = self?.viewProfileModel.alertMessage {
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message: message, okButtonText: okText, completion: nil)
                }
            }
        }
        
        viewProfileModel.updateLoadingStatus = {[weak self]() in
            DispatchQueue.main.async {
                
                let isLoading = self?.viewProfileModel.isLoading ?? false
                if isLoading {
                    self?.addLoaderView()
                } else {
                    self?.removeLoaderView()
                }
            }
        }
        
        viewProfileModel.refreshViewClosure = {[weak self]() in
            DispatchQueue.main.async {
                
                if (self?.viewProfileModel.profileDetails.status) == 200 {
                    
                    self!.userCardList = self?.viewProfileModel.profileDetails.ProfileDetails!.userCardList
                    self!.cardListCollectionView.reloadData()
                    
                }
                else{
                    self?.showAlertWithSingleButton(title: commonAlertTitle, message: (self?.viewProfileModel.profileDetails.message)!, okButtonText: okText, completion: nil)
                }
            }
        }
    }
    
    
    func callStripeViewControllerMethod()
    {
        
        let cardNumber = txtCardNumber.text
        let newString = cardNumber!.replacingOccurrences(of: "-", with: "")
        print("newString==>\(newString)")
        let expdate = txtExpDate.text
        let expNewValue = expdate!.components(separatedBy: "/")
        let expMonth    = expNewValue[0]
        let expYear = expNewValue[1]
        
        let cardParams = STPCardParams()
        cardParams.number = newString //"4242424242424242"//myPaymentCardTextField.cardNumberShyam2018
        //myPaymentCardTextField.expirationMonth
        cardParams.expYear = UInt(expYear)!//2019//myPaymentCardTextField.expirationYear
        cardParams.expMonth = UInt(expMonth)!
        cardParams.cvc = txtCvvNumber.text//myPaymentCardTextField.cvc
        STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
            guard let token = token else {
                return
            }
            print(token)
            self.postPaymentDetails(stripeToken: token.tokenId)
        }
    }
}

extension CheckOutVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtExpDate
        {
            if string == "" {
                return true
            }
            
            let currentText = txtExpDate.text! as NSString
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            
            txtExpDate.text = updatedText
            let numberOfCharacters = updatedText.count
            if numberOfCharacters == 2 {
                txtExpDate.text?.append("/")
            }
            return false
        }
        if textField == txtCardNumber
        {
            let replacementStringIsLegal = string.rangeOfCharacter(from: NSCharacterSet(charactersIn: "0123456789").inverted) == nil
            
            if !replacementStringIsLegal
            {
                return false
            }
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: NSCharacterSet(charactersIn: "0123456789").inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 16 && !hasLeadingOne) || length > 19
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 16) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.append("1 ")
                index += 1
            }
            if length - index > 4
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@-", prefix)
                index += 4
            }
            
            if length - index > 4
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@-", prefix)
                index += 4
            }
            if length - index > 4
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@-", prefix)
                index += 4
            }
            
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            print("remainder==>\(remainder)")
            print("formattedString==>\(formattedString)")
            print("textField.text==>\(textField.text)")
            return false
        }
        else
        {
            return true
        }
    }
    
    func cardInActiveActive(index : Int){
     
        let alertController = UIAlertController(title: commonAlertTitle, message: "You want to delete?".localized(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            self.deleteCardDetails(cardId: self.userCardList![index].id!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func deleteCardDetails(cardId : String){
        let param = DeleteCardParam()
        param.card_id = cardId
        viewModel.deleteCardDetailsToAPIService(user: param)
    }
}

extension CheckOutVC : UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout , cardActiveInActiveDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)-> Int {
        if userCardList != nil  && userCardList!.count > 0 {
            return userCardList!.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardListCell", for: indexPath as IndexPath) as! CardListCell
        cell.delegate = self
        cell.initializeCellDetails(cellDic: userCardList![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat = 264
        let height: CGFloat = 120
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isExistingToken = userCardList![indexPath.row].id!
        isExistingCardPay = true
        self.acceptProposal()
    }
}
