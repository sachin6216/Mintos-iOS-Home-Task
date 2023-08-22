//
//  PaymentTableViewCell.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 18/08/2023.
//

import UIKit

// Protocol to handle button actions in PaymentTableViewCell
protocol PaymentTableViewCellDelegate: AnyObject {
    func paymentCellDidCopyBankDetails(at indexPath: IndexPath?)
}
class PaymentTableViewCell: UITableViewCell {
    // Outlets for various cell elements

// paymentCell
    @IBOutlet weak var bgLineView: UIView!
    @IBOutlet weak var btnCopyValue: UIButton!
    @IBOutlet weak var lblCellValue: UILabel!
    @IBOutlet weak var lblCellTitle: UILabel!
    // paymentBank
    @IBOutlet weak var lblBankName: UILabel!

    // Delegate to handle button action
    weak var delegate: PaymentTableViewCellDelegate?
    
    // IndexPath to identify the cell's position
    var cellIndexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Action triggered when the copy button is tapped
    @IBAction func btnBankDetailCopy(_ sender: UIButton) {
        // Notify the delegate about the button tap along with the cell's IndexPath
        delegate?.paymentCellDidCopyBankDetails(at: cellIndexPath)
    }
    
}
