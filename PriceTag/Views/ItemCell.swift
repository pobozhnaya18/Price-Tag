//
//  ItemCell.swift
//  barCodes
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var titleOfProductLabel: UILabel!
    @IBOutlet weak var centsTitle: UILabel!
    func configureCell(titleOfProduct: String,price: String, cents: String ){
        var str = price + "." + cents + "p"
        titleOfProductLabel.text = titleOfProduct
        centsTitle.text = str
    }
}
