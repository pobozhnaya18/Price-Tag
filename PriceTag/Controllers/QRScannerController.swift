//
//  QRScannerController.swift
//  QRCodeReader
//

import UIKit
import AVFoundation
import SwiftHTTP
import CoreData
import Foundation

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class QRScannerController: UIViewController{
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet var topbar: UIView!
    
    @IBOutlet weak var doNotPushButton: UIButton!
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var price: String = ""
    var cents: String = ""
    var titleOfProduct: String = ""
    var threshold: Double?
    var items: [Item] = []
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      ]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        let captureDevice = AVCaptureDevice.default(for: .video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            print(error)
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        captureSession.startRunning()
        view.bringSubview(toFront: topbar)
        view.bringSubview(toFront: doNotPushButton)
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(Threshold.shared.getThreshold())
        self.threshold = Double(lroundf(Float(Threshold.shared.getThreshold())))
        print(self.threshold!)
        self.fetch { (complete) in
            if complete {
                checkForThreshold()
            }
        }
    }

    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        captureSession.stopRunning()
        HTTP.GET("https://e-dostavka.by/search/?searchtext=\(decodedURL)") { response in
            if let err = response.error {
            print("error: \(err.localizedDescription)")
            return
            }
            guard var result = response.description as? String else{
                return
            }
            self.getPrice(response: result)
        }
    }
    
    @IBAction func deleteAllPressed(_ sender: Any) {
        
        deleteAll()
    }
    
    
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                launchApp(decodedURL: metadataObj.stringValue!)
            }
        }
    }
    
    func save(completion: (_ finished: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let item = Item(context: managedContext)
        item.productName = self.titleOfProduct
        item.price = self.price
        item.cents = self.cents
        do{
            try managedContext.save()
            completion(true)
            print("saved")
        }catch{
            print("error")
            completion(false)
        }
    }
    
    func getPrice(response: String) {
        let result = Array(response.characters)
        let result2 = Array(response.characters)
        for i in 136000...result.count-1 {
            if (result[i] == "c" && result[i+1] == "l" && result[i+2] == "a" && result[i+3] == "s" && result[i+4] == "s" && result[i+5] == "=" &&  result[i+7] == "p" && result[i+8] == "r" && result[i+13] == ">"){
                price.append(result[i+14])
                if(result[i+15] != "<"){
                    price.append(result[i+15])
                }
                if(result[i+16] != "<" && result[i+16] != "b"){
                    price.append(result[i+16])
                }
            }
        }
        for j in 136000...result2.count-1 {
            if (result2[j] == "c" && result2[j+1] == "e" && result2[j+2] == "n" && result2[j+3] == "t" && result2[j+5] == ">"  ){
                self.cents.append(result2[j+6])
                if(result2[j+7] != "<"){
                    self.cents.append(result2[j+7])
                }
            }
        }
        
        for j in 136000...result2.count-1 {
            if (result2[j] == "." && result2[j+2] == " " && result2[j+3] == "t" && result2[j+4] == "i" && result2[j+5] == "t"  ){
                self.titleOfProduct.append(result2[j+9])
                for i in 1...100{
                    if(result2[j+9+i] != "/"){
                        self.titleOfProduct.append(result[j+i+9])
                    }else{
                        break
                    }
                }
            }
        }
        let alertPrompt = UIAlertController(title: "\(self.titleOfProduct)", message: "Price : \(self.price) р, \(self.cents) коп. ", preferredStyle: .actionSheet)
        
        
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.save { (complete) in
                if complete {
                    print("saved")
                }
            }
            self.price = ""
            self.cents = ""
            self.titleOfProduct = ""
            self.fetch { (complete) in
                if complete {
                    if (Int(self.threshold!) > Int(self.checkForThreshold())) {
                        self.captureSession.startRunning()
                    } else {
                        if(self.threshold != 1.0){
                            let outOfAlert = UIAlertController(title: "PriceTag", message: "Out of threshold", preferredStyle: UIAlertControllerStyle.alert)
                            outOfAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    self.captureSession.startRunning()
                                    
                                case .cancel:
                                    print("cancel")
                                    
                                case .destructive:
                                    print("destructive")
                                    
                                    
                                }}))
                            self.present(outOfAlert, animated: true, completion: nil)
                        }else{
                            self.captureSession.startRunning()
                        }
                    }
                }
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            self.price = ""
            self.cents = ""
            self.titleOfProduct = ""
            self.captureSession.startRunning()
        })
        if(self.price != "" && self.cents != ""){
            alertPrompt.addAction(confirmAction)
            alertPrompt.addAction(cancelAction)
            present(alertPrompt, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "PriceTag", message: "Can't find 😔", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    self.captureSession.startRunning()
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
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
    
    
    func checkForThreshold() -> Double {
        var basket: Double = 0
        for item in items {
            var str = "0." + item.cents!
            basket += Double(item.price!)! + Double(str)!
        }
        if(basket != 0) {
            var str = String(basket) + "p"
            DispatchQueue.main.async {
                self.totalPriceLabel.text = str
            }
            
        }else{
            DispatchQueue.main.async {
                self.totalPriceLabel.text = "0,0p"
            }
        }
        return basket
    }
    
    func deleteAll() {
        
        let alertPrompt = UIAlertController(title: "PriceTag", message: "Хотите завершить покупки?", preferredStyle: .alert)
        self.captureSession.stopRunning()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            self.captureSession.startRunning()
        })
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.deletePreItemRecords()
            self.deleteItemRecords()
            self.captureSession.startRunning()
        })
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        present(alertPrompt, animated: true, completion: nil)
        
        self.viewWillAppear(false)
        
    }
    
    func deletePreItemRecords() -> Void {
        let moc = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PreItem")
        
        let result = try? moc.fetch(fetchRequest)
        let resultData = result as! [PreItem]
        
        for object in resultData {
                moc.delete(object)
        }
        do {
            try moc.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    func deleteItemRecords() -> Void {
        let moc = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        let result = try? moc.fetch(fetchRequest)
        let resultData = result as! [Item]
        
        for object in resultData {
                moc.delete(object)
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
