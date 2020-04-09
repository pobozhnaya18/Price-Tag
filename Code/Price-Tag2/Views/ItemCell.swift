//
//  ItemCell.swift
//  barCodes
//


import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var titleOfProductLabel: UILabel!
    @IBOutlet weak var priceTitle: UILabel!
    @IBOutlet weak var centsTitle: UILabel!
    func configureCell(titleOfProduct: String,price: String, cents: String ){
        titleOfProductLabel.text = titleOfProduct
        priceTitle.text = price
        centsTitle.text = cents
    }
}
