//
//  EditViewController.swift
//  Text me
//
//  Created by 서정 on 2021/01/18.
//

import UIKit
import Vision

class EditViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet var detailTitle: UITextField!
    @IBOutlet var mainTextView: UITextView!
    @IBOutlet var subTextView: UITextView!
    @IBOutlet var refImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var memo: MemoVO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTextView.layer.cornerRadius = 10
        subTextView.layer.cornerRadius = 10
        refImage.layer.cornerRadius = 5
        
        detailTitle.text = memo?.titleText
        mainTextView.text = memo?.mainText
        refImage.image = memo?.refImage
        
        startAnimating()
        setupVisionTextRecognizeImage(image: (memo?.refImage)!)
        
        
        mainTextView.delegate = self
        mainTextView.isEditable = false
        mainTextView.dataDetectorTypes = .link
        
        makeDoneAtToolbar()
        
    }
    
    private func makeDoneAtToolbar() {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissMyKeyboard))
        
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        self.detailTitle.inputAccessoryView = toolbar
        self.mainTextView.inputAccessoryView = toolbar
        self.subTextView.inputAccessoryView = toolbar
    }
    
    @objc func dismissMyKeyboard() {
        view.endEditing(true)

    }
    
    private func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    private func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    var request = VNRecognizeTextRequest()
    private func setupVisionTextRecognizeImage(image: UIImage?) {
        var textString = ""
        
        request = VNRecognizeTextRequest(completionHandler: {(request, Error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                fatalError("Received Invalid Observation")
            }
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    print("No candidate")
                    continue
                }
                textString += "\n\(topCandidate.string)"
                DispatchQueue.main.async {
                    self.stopAnimating()
                    self.mainTextView.text = textString
                }
            }
            
        })
        
        //add some properties
        request.customWords = ["custom"]
        request.minimumTextHeight = 0.03125
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        //creating request handler
         
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = image?.cgImage else {
                fatalError("Missing image Scan")
            }
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try? handle.perform(requests)
        }
    }
    
    
    
}
