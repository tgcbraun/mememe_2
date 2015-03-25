//
//  ViewController.swift
//  Meme Me 0.1
//
//  Created by Thiago Graça Couto Braun on 3/23/15.
//  Copyright (c) 2015 GCBraun. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    //Outlets and variables
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var memesButton: UIBarButtonItem!
    
  
    var imagePicker = UIImagePickerController()
    var memedImage : UIImage!
    
    @IBOutlet weak var textTop: UITextField!
    @IBOutlet weak var textBottom: UITextField!
    
    //Meme text attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -2.0
    ]
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)

        //Button and text alignment Setup
        textTop.textAlignment = NSTextAlignment.Center
        textBottom.textAlignment = NSTextAlignment.Center
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if there are Memes stored to enable the Memes Button
        if (UIApplication.sharedApplication().delegate as AppDelegate).memes.count > 0 {
            memesButton.enabled = true
        }
        
       //Button setup according to conditions
        shareButton.enabled = false
        pickButton.enabled = true
        cameraButton.enabled = true
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable    (UIImagePickerControllerSourceType.Camera)
        
        //Text setup
        textTop.delegate = self
        textTop.defaultTextAttributes = memeTextAttributes
        
        textBottom.delegate = self
        textBottom.defaultTextAttributes = memeTextAttributes
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Unsubscribes from keyboard notifications
        self.unsubscribeFromKeyboardNotifications()
    }

    //Called when Pick button is pressed
    @IBAction func pickImage(sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            //Image view scaling code
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleWidth
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
        
    }
    
    //Called when Camera button is pressed
    @IBAction func takePicture(sender: UIBarButtonItem) {
        
               
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    //Called when Share button is pressed
    @IBAction func shareMeme(sender: AnyObject) {
     
     self.unsubscribeFromKeyboardNotifications()
     generateMemedImage()
        
        var imageArray : [UIImage] = [memedImage]
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:Array!, error:NSError!) in
            
            //Saves the meme and enables meme collection button if share activity is completed
            if completed {
                    self.save()
                    self.dismissViewControllerAnimated(true, completion: {});
                    //Enables MemesButton after sucessfully competing Sharing Activity
                    self.memesButton.enabled = true
                     return
                
            }
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })

        imageView.image = image
        pickButton.enabled = false
        cameraButton.enabled = false
        shareButton.enabled = true
        
    }
    
  
    
    func textFieldDidBeginEditing(textField: UITextField!) {    //delegate method
        if textField == textTop {
            
            //Make sure that there are no keyboard notifications. Not needed for top textfield.
            
            self.unsubscribeFromKeyboardNotifications()
            
        } else if textField == textBottom {
            
            //When the bottom text is selected, first unsubscribe to keyboard notifications to avoid duplicity and, right after that, call method to move view to open up space for keyboard. Right after that,
            
            self.unsubscribeFromKeyboardNotifications()
            self.subscribeToKeyboardNotifications()
            
        }
   
    }
   
    //Method thar closed keybord upon pressing return.
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
         self.view.endEditing(true)
        return false
    }
    
    //Avoids rotation of the screen.
    override func shouldAutorotate() -> Bool {
                return false;
        
    }
    
    //Indicates proper orientation
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }
    
    //Method to subscribe to Keyboard notificatios
    func subscribeToKeyboardNotifications() {
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Method to unsubscribe to Keyboard notificatios
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    //Keyboard adjustment
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    //Keyboard adjustment
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    //Keyboard height calculator
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //Generate meme. Called by Share button.
    func generateMemedImage() -> UIImage
    {
        // Render view to an image
        self.navigationController?.navigationBar.hidden = true
        toolBar.hidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        memedImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navigationController?.navigationBar.hidden = false
        toolBar.hidden = false
        
        return memedImage
    }
    
    //Saves the meme. Called after share activity is completed.
    func save() {
        //Creates the meme
        var meme = Meme(text1: textTop.text!, text2: textBottom.text!, image:
            imageView.image!, memedImage: memedImage)
        (UIApplication.sharedApplication().delegate as AppDelegate).memes.append(meme)
    
    }
    
}

