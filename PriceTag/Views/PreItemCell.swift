//
//  PreItemCell.swift
//  barCodes
//

import UIKit
import M13Checkbox

class PreItemCell: UITableViewCell {
    @IBOutlet weak var checkBox: M13Checkbox!
    var state = "unchecked"
    @IBOutlet weak var titleOfProduct: UILabel!
    func configureCell(titleOfProduct: String){
        self.titleOfProduct.text = titleOfProduct
        if(self.state == "unchecked"){
            self.checkBox.checkState = .unchecked
        }else{
            self.checkBox.checkState = .checked
        }
    }

    @IBAction func checkPressed(_ sender: Any) {
        self.state = "checked"
    }
}
