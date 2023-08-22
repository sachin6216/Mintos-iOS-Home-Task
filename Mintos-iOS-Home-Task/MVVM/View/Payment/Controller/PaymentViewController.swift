//
//  PaymentViewController.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 18/08/2023.
//

import UIKit
import Combine


class PaymentViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var bgCurrecnyIconView: UIView!
    @IBOutlet weak var bgInvestorView: UIView!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var lblCurrencyValue: UILabel!
    @IBOutlet weak var btnSortCurrency: UIButton!
    @IBOutlet weak var lblBankTransfer: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblInvestorTitle: UILabel!
    @IBOutlet weak var lblInvestorValue: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    // MARK: - Variables
    private var viewModel = PaymentViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribers()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setUITheme()
        self.viewModel.getBankAccountAPI()
    }
    // MARK: - IBOutlets Action
    @IBAction func btnCopyInvestor(_ sender: UIButton) {
        if let investorId = viewModel.model.investorId {
            UIPasteboard.general.string = investorId
            self.showalertview(messagestring: "TEXTHASBEENCOPIEDSUCCESSFULLY".localized)
        }
    }
    
    @IBAction func btnSortCurrency(_ sender: UIButton) {
        
        if #available(iOS 14.0, *) {
            self.btnSortCurrency.showsMenuAsPrimaryAction = true
            self.btnSortCurrency.menu = self.showMenu()
        } else {
            self.showActionSheet(sender: sender)
        }
        
    }
    // MARK: - Extra Method
    /// Perform initial UI setup.
    private func setUITheme() {
        self.tableView.tableFooterView = UIView()
        
        self.bgCurrecnyIconView.layer.cornerRadius = self.bgCurrecnyIconView.frame.height / 2
        self.bgInvestorView.layer.cornerRadius = 10
        self.tableView.layer.cornerRadius = 10
        
        // Localize
        self.lblCurrency.text = "CURRENCY".localized
        self.lblBankTransfer.text = "BANKTRANSFER".localized
        self.lblSubTitle.text = "TRANSFERMONEYFROMYOURBANK".localized
        self.lblInvestorTitle.text = "ADDTHISINFORMATIONTOPAYMENT".localized
        
    }
    
    /// Show an action sheet for sorting currencies.
    /// - Parameter sender: The button triggering the action sheet.
    private func showActionSheet(sender: UIButton) {
        let alertController = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        // Create UIAlertAction instances from the option titles and add them to the alertController
        self.viewModel.model.currencyList.forEach { title in
            let action = UIAlertAction(title: title, style: .default) { _ in
                self.lblCurrencyValue.text = title
                self.viewModel.model.selectedCurrency = title
                self.sortBankAccount()
                
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Create and return a UIMenu for sorting currencies.
    private func showMenu() -> UIMenu {
        // Create an array of UIAction instances from the option titles
        let actions = self.viewModel.model.currencyList.map { title in
            UIAction(title: title) { action in
                self.lblCurrencyValue.text = title
                self.viewModel.model.selectedCurrency = title
                self.sortBankAccount()
                
            }
        }
        
        return UIMenu(title: "Menu", children: actions)
    }
    
    /// Sorts and updates the bank details list for the selected currency.
    ///
    /// This function retrieves the bank accounts for the selected currency from the view model,
    /// transforms the data into a list of tuples containing relevant details, and updates the
    /// view model's `bankDetailsList` property. The table view is then reloaded to reflect the changes.
    ///
    /// - Complexity: The time complexity of this function is O(n), where 'n' is the number of bank
    /// accounts in the selected currency's bank account array. The dominant factor is the enumeration
    /// through the bank account array. Other operations, such as creating tuples and reloading the
    /// table view, are constant time. This time complexity is suitable for most practical scenarios.
    ///
    private func sortBankAccount() {
        // Retrieve the bank accounts for the selected currency from the view model
        guard let bankAccount = viewModel.model.bankAccountsByCurrency[viewModel.model.selectedCurrency] else {
            return
        }
        
        // Transform the bank account data into a list of tuples
        let bankDetailsList = bankAccount.enumerated().map { (section, item) in
            return (
                currencySection: section,
                bankAccounts: [
                    ("BANKNAME".localized, item.bank ?? ""),
                    ("BENEFICIARYBANKACCOUNT".localized, item.iban ?? ""),
                    ("BIICODE".localized, item.swift ?? ""),
                    ("BENEFICIARYNAEM".localized, item.beneficiaryName ?? ""),
                    ("BENEFICIARYBANKADDRESS".localized, item.beneficiaryBankAddress ?? "")
                ]
            )
        }
        
        // Update the view model's bank details list and reload the table view
        viewModel.model.bankDetailsList = bankDetailsList
        tableView.reloadData()
    }
    private func updateBankAccountDetails() {
        print("msg")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let bankDetailsResponse = self.viewModel.model.bankDetalisResponse {
                self.extractInvestorId(from: bankDetailsResponse.paymentDetails)
            } else {
                print("No bank details response.")
            }
            
            if let firstItem = self.viewModel.model.bankDetalisResponse?.items?.first {
                self.updateCurrencyInfo(with: firstItem)
            }
            
            self.sortBankAccount()
            self.tableView.reloadData()
        }
    }

    private func extractInvestorId(from paymentDetails: String?) {
        guard let paymentDetails = paymentDetails else {
            print("Payment details are nil.")
            return
        }
        
        if let numbersRange = paymentDetails.range(of: "\\d+", options: .regularExpression) {
            let extractedNumbers = paymentDetails[numbersRange]
            self.viewModel.model.investorId = "\(extractedNumbers)"
            self.lblInvestorValue.text = "\(extractedNumbers) - Investor"
        } else {
            print("No numbers found in the string.")
        }
    }

    private func updateCurrencyInfo(with item: Item) {
        self.lblCurrencyValue.text = item.currency
        self.viewModel.model.selectedCurrency = item.currency ?? ""
    }

    
    // MARK: - APIs
    /// Set up subscribers for observing ViewModel events.
    func subscribers() {
        self.viewModel.bankAccountSubject.sink { [weak self] _ in
            self?.updateBankAccountDetails()
        }.store(in: &subscriptions)
        self.viewModel.errorPublisher.sink { msg in
            print(msg)
        }.store(in: &subscriptions)
    }
    
}
// MARK: - Extensions
extension PaymentViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.model.bankAccountsByCurrency[self.viewModel.model.selectedCurrency]?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.model.bankDetailsList[section].bankAccounts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PaymentTableViewCell
        let bankAccount = self.viewModel.model.bankDetailsList[indexPath.section].bankAccounts[indexPath.row]
        
        if bankAccount.title == "BANKNAME".localized {
            guard let bankCell = tableView.dequeueReusableCell(withIdentifier: "paymentBank", for: indexPath) as? PaymentTableViewCell else { return UITableViewCell() }
            cell = bankCell
            
            cell.lblBankName.text = bankAccount.value
            
        } else {
            guard let paymentCell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as? PaymentTableViewCell else { return UITableViewCell() }
            cell = paymentCell
            
            cell.lblCellTitle.text = bankAccount.title
            cell.lblCellValue.text = bankAccount.value
            cell.bgLineView.isHidden = (self.viewModel.model.bankDetailsList[indexPath.section].bankAccounts.count - 1) == indexPath.row
            cell.cellIndexPath = indexPath
            cell.delegate = self
        }
        return cell
    }
}
extension PaymentViewController: PaymentTableViewCellDelegate {
    func paymentCellDidCopyBankDetails(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            UIPasteboard.general.string = self.viewModel.model.bankDetailsList[indexPath.section].bankAccounts[indexPath.row].value
            self.showalertview(messagestring: "TEXTHASBEENCOPIEDSUCCESSFULLY".localized)
        }
    }
}
