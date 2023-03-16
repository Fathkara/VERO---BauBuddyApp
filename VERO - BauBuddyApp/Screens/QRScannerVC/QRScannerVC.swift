//
//  QRScannerVC.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 16.03.2023.
//

import UIKit
import AVFoundation
import SnapKit

protocol QRScannnerProtocol {
    var delegate: QRScannnerDelegate? { get set}
    func searchTextOR(text: String)
}

protocol QRScannnerDelegate {
    func handleQROutPut(text: String)
}

class QRScannnerVC: UIViewController, QRScannnerProtocol {
    var captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var qrCodeFrame = UIView()
    var qrScannnerProtocol: QRScannnerProtocol?
    var delegate: QRScannnerDelegate?
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        startQRScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession.isRunning == false) {
            DispatchQueue(label: "qr").async {
                self.captureSession.startRunning()

            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    private func startQRScanner() {
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer!)
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
            
        } catch {
            print(error)
        }
        configureQRFrame()
        
    }
    private func configureQRFrame() {
        qrCodeFrame.layer.borderColor = UIColor.green.cgColor
        qrCodeFrame.layer.borderWidth = 2.0
        view.addSubview(qrCodeFrame)
        view.bringSubviewToFront(qrCodeFrame)
        qrCodeFrame.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
       
   }
}

extension QRScannnerVC : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrame.frame = .zero
            print("No code found.")
            return
        }
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.searchTextOR(text: stringValue)

        }
        if metadataObject.type == .qr {
            
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
            qrCodeFrame.frame = barCodeObject!.bounds
           
            
            if metadataObject.stringValue != nil {
            }
            print("Code value is == \(String(describing: metadataObject.stringValue))")
        }
    }
    
    func searchTextOR(text: String) {
        delegate?.handleQROutPut(text: text)
        self.navigationController?.popToRootViewController(animated: true)
    }

}

