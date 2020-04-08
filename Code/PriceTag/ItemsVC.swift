//
//  ItemsVC.swift
//  Price-Tag


import UIKit
import CoreData

class ItemsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var items:[Item] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        
        // Do any additional setup after loading the view.
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
        return UITableViewCell()
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else { return UITableViewCell() }
//        let goal  = goals[indexPath.row]
//
//        cell.configureCell(description: goal.goalDescription!, type: GoalType(rawValue: goal.goalType!)!, goalProgressAmount: Int(goal.goalProgress))
        //return cell
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
