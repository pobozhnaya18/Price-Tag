//
//  ItemsVC.swift
//  barCodes
//


import UIKit
import CoreData
import fluid_slider


class ItemsVC: UIViewController {
    
    @IBOutlet weak var arrowButton: UIButton!
    var borshViewHeight = 70
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var treshHoldSlider: Slider!
    @IBOutlet weak var borshView: UIView!
    let arrowDownImage = UIImage(named: "arrowDown.png")
    let arrowUpImage = UIImage(named: "arrowUp.png")
    
    var items:[Item] = []
    
    override func viewDidLoad() {
        
       arrowButton.setImage(UIImage(named: "caret-down")?.withRenderingMode(.automatic), for: .normal)
        borshView.frame.size.height = CGFloat(borshViewHeight)
        tableView?.delegate = self
        tableView?.dataSource = self
        let labelTextAttributes: [NSAttributedStringKey : Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.white]

        treshHoldSlider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 0
            let string = formatter.string(from: (fraction * 100) as NSNumber) ?? ""
            return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.black])
        }
        treshHoldSlider.setMinimumLabelAttributedText(NSAttributedString(string: "1", attributes: labelTextAttributes))
        treshHoldSlider.setMaximumLabelAttributedText(NSAttributedString(string: "100", attributes: labelTextAttributes))

        //treshHoldSlider.fraction = 0.5
        treshHoldSlider.shadowOffset = CGSize(width: 0, height: 10)
        treshHoldSlider.shadowBlur = 5
        treshHoldSlider.shadowColor = UIColor(white: 0, alpha: 0.1)
        treshHoldSlider.contentViewColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        treshHoldSlider.valueViewColor = .white
        treshHoldSlider.didBeginTracking = { void in
           // print(self.treshHoldSlider.description)
        }
        treshHoldSlider.didEndTracking = { void in
           // print(self.treshHoldSlider.description)
            print(self.treshHoldSlider.fraction.description)
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func expandButtonPressed(_ sender: Any) {
        if(borshView.frame.size.height == 70){
            arrowButton.setImage(UIImage(named: "caret-arrow-up")?.withRenderingMode(.automatic), for: .normal)
            tableView.expandTableView(isViewExpanded: false)
            borshView.expandView()
        }else{
            arrowButton.setImage(UIImage(named: "caret-down")?.withRenderingMode(.automatic), for: .normal)
            tableView.expandTableView(isViewExpanded: true)
            borshView.expandView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetch { (complete) in
            if complete{
                tableView.reloadData()
            }
        }
    }
    
}

extension ItemsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as? ItemCell else
        { return UITableViewCell() }
        let item = items[indexPath.row]
        cell.configureCell(titleOfProduct: item.productName!, price: item.price!, cents: item.cents!)
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75.0
    }
}

extension ItemsVC {
    func fetch(completion: (_ complete:Bool) -> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do{
            items =  try managedContext.fetch(fetchRequest) as! [Item]
            completion(true)
        }catch{
            completion(false)
        }
    }
}
