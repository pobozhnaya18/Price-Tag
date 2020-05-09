//
//  PageMenuVC.swift
//  barCodes
//
//  Created by NG on 3/24/18.
//  Copyright © 2018 NG. All rights reserved.
//

import UIKit
import PageMenu

class PageMenuVC: UIViewController {
    var pageMenu : CAPSPageMenu?
    
    var controllerArray : [UIViewController] = []
    var controller : UIViewController = UIViewController(nibName: "QRScannerController", bundle: nil)
    var parameters: [CAPSPageMenuOption] = [
        .menuItemSeparatorWidth(4.3),
        .useMenuLikeSegmentedControl(true),
        .menuItemSeparatorPercentageHeight(0.1)
    ]
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPageMenu()
        self.view.addSubview(pageMenu!.view)
        
    }
    func setupPageMenu() {
        let colors = [UIColor.black, UIColor.blue]
        let controllers = colors.map { (color: UIColor) -> UIViewController in
            let controller = QRCodeViewController()
            //controller.view.backgroundColor = color
            return controller
        }
       self.pageMenu = CAPSPageMenu(viewControllers: controllers, in: self, with: dummyConfiguration(), usingStoryboards: true)
    }
    
    func dummyConfiguration() -> CAPSPageMenuConfiguration {
        let configuration = CAPSPageMenuConfiguration()
        return configuration
    }

}
