//
//  GinCapturerViewController.swift
//  gin-reader
//
//  Created by Fernando Rocha Silva on 4/1/16.
//  Copyright © 2016 Fernando Rocha Silva. All rights reserved.
//

import UIKit

class GinCapturerViewController: UIViewController, UINavigationControllerDelegate {
    
    var employeesArray = NSMutableArray()
    
    var activityIndicator:UIActivityIndicatorView!
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeesArray.count
    }
    
    //populates the tableview cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "CellIdentifier", forIndexPath: indexPath)
        
        cell.textLabel!.text = employeesArray[indexPath.row] as? String
        
        return cell
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract()
        
        tesseract.language = "eng"
        tesseract.engineMode = .TesseractOnly
       
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0

        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        
        
        let gin = self.captureGin(tesseract.recognizedText)
        let ginNumber: Int? = Int(gin)
        if ginNumber != nil {
            employeesArray.addObject(gin)
            table.reloadData()
        }
        else {
            print("Not Valid Integer \(gin)")
        }

        table.reloadData()

        removeActivityIndicator()
    }
    
    // Activity Indicator methods
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    func captureGin(tesseractText: String) -> String {
        let needle: Character = "0"
        
        if let idx = tesseractText.characters.indexOf(needle) {
            print(tesseractText[idx..<idx.advancedBy(8)])
            return tesseractText[idx..<idx.advancedBy(8)]
        }
        
        return ""
    }
    
}
extension GinCapturerViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
        
        addActivityIndicator()
        
        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(scaledImage)
        })
    }
}



