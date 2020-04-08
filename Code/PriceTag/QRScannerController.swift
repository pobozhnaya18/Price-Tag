//
//  QRScannerController.swift
//  QRCodeReader
//

import UIKit
import AVFoundation
import SwiftHTTP
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class QRScannerController: UIViewController {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var price: String = ""
    var cents: String = ""
    var titleOfProduct: String = ""
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

        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        let captureDevice = AVCaptureDevice.default(for: .video)!
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: topbar)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods

    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        captureSession.stopRunning()
        HTTP.GET("https://e-dostavka.by/search/?searchtext=\(decodedURL)") { response in
            if let err = response.error {
            print("error: \(err.localizedDescription)")
            return //also notify app of failure as needed
            }
            guard var result = response.description as? String else{
                return
            }
            self.getPrice(response: result)
            //print("data is: \(response.data)") access the response of the data with response.data
        }
    }

}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                launchApp(decodedURL: metadataObj.stringValue!)
                messageLabel.text = metadataObj.stringValue
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
            self.captureSession.startRunning()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (action) -> Void in
            self.price = ""
            self.cents = ""
            self.titleOfProduct = ""
            self.captureSession.startRunning()
        })
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        present(alertPrompt, animated: true, completion: nil)
    }
}


