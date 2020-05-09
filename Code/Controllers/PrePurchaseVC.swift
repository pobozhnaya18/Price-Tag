//
//  PrePurchaseVC.swift
//  barCodes
//

import UIKit
import CoreData
import M13Checkbox

class PrePurchaseVC: UIViewController {
    
    @IBOutlet weak var outletView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var prePurchaseTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var effect: UIVisualEffect!
    var preItems: [PreItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        outletView.layer.cornerRadius = 5
        visualEffectView.isHidden = true
        self.hideKeyboardWhenTappedAround() 
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.fetch { (complete) in
            if complete{
                if preItems.count >= 1 {
                    // welcomeUser(toWelcome: true)
                }else{
                    //welcomeUser(toWelcome: false)
                }
                tableView.reloadData(
                    with: .simple(duration: 0.75, direction: .rotation3D(type: .captainMarvel),
                                  constantDelay: 0))
            }
        }
        animateOut()
    }
    override func viewDidDisappear(_ animated: Bool) {
        animateOut()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        self.tableView.isHidden = true
        animateIn()
    }
    @IBAction func dismissPopUp(_ sender: Any) {
        if(self.prePurchaseTextField.text != ""){
            self.save(){ (complete) in
                if complete {
                    print("saved")
                }
            }
        }
        self.fetch { (complete) in
            if complete{
                tableView.reloadData()
            }
        }
        self.tableView.isHidden = false
        animateOut()
    }
    func animateIn(){
        visualEffectView.isHidden = false
        self.view.addSubview(outletView)
        outletView.center = self.view.center
        outletView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        outletView.alpha = 0
        UIView.animate(withDuration: 0.4){
            self.visualEffectView.effect = self.effect
            self.outletView.alpha = 1
            self.outletView.transform = CGAffineTransform.identity
        }
    }
    func animateOut(){
        UIView.animate(withDuration: 0.3, animations:  {
            self.outletView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.outletView.alpha = 0
            self.visualEffectView.effect = nil
            self.visualEffectView.isHidden = true
        }) {(success:Bool) in
                self.outletView.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   

}

extension PrePurchaseVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "preItemCell") as? PreItemCell else
        { return UITableViewCell() }
        let item = preItems[indexPath.row]
        cell.configureCell(titleOfProduct: item.productName!)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            deleteRecord(itemToDelete: self.preItems[indexPath.row])
            self.preItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }
    func fetch(completion: (_ complete:Bool) -> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PreItem")
        do{
            preItems =  try managedContext.fetch(fetchRequest) as! [PreItem]
            completion(true)
        }catch{
            completion(false)
        }
    }
    
    func save(completion: (_ finished: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let item = PreItem(context: managedContext)
        item.productName = self.prePurchaseTextField.text
        do{
            try managedContext.save()
            completion(true)
            print("saved")
        }catch{
            print("error")
            completion(false)
        }
    }
    
    func deleteRecord(itemToDelete: PreItem) -> Void {
        let moc = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PreItem")
        
        let result = try? moc.fetch(fetchRequest)
        let resultData = result as! [PreItem]
        
        for object in resultData {
            if (object == itemToDelete){
                moc.delete(object)
            }
        }
        
        do {
            try moc.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
}
