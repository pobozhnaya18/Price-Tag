//
//  RootViewController.swift
// Price-Tag

import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDataSource {

    lazy var viewControllerList: [UIViewController] = {
        let sb = UIStoryboard(name: "Main",bundle: nil)
        
        let vc3 = sb.instantiateViewController(withIdentifier: "PrePurchaseVC")
        let vc1 = sb.instantiateViewController(withIdentifier: "ItemsVC")
        let vc2 = sb.instantiateViewController(withIdentifier: "QRScannerVC")
        
        return [vc3,vc1,vc2]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        if let firstViewController = viewControllerList.first {
            
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.index(of: viewController) else { return nil }
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else {return nil}
        guard viewControllerList.count > previousIndex else {return nil}
        return viewControllerList[previousIndex]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else { return nil}
        
        let nextIndex = vcIndex + 1
        guard viewControllerList.count != nextIndex else {return nil}
        guard viewControllerList.count > nextIndex else {return nil}
        return viewControllerList[nextIndex]
    }

}
