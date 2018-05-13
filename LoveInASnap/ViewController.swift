

import UIKit
import Alamofire
import TesseractOCR

class ViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var findTextField: UITextField!
  @IBOutlet weak var replaceTextField: UITextField!
  @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  
  @IBOutlet weak var _email: UITextField!
  @IBOutlet weak var _password: UITextField!
  @IBOutlet weak var _loginButton: UIButton!
  @IBOutlet weak var _register: UIButton!
  
  
  
  @IBAction func openSignin(_ sender: Any) {
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as UIViewController
    self.present(nextViewController, animated:true, completion:nil)
  }
  
  
  @IBAction func openRegister(_ sender: Any) {
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "registerVC") as UIViewController
    self.present(nextViewController, animated:true, completion:nil)
  }
  
  @IBAction func openForget(_ sender: Any) {
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "forgetVC") as UIViewController
    self.present(nextViewController, animated:true, completion:nil)  }
  
  @IBAction func loginAction(_ sender: Any) {
    
    if(_loginButton.titleLabel?.text == "LOG OUT")
    {
      let preferences = UserDefaults.standard
      preferences.removeObject(forKey: "session")
      
      //LoginToDo()
      return
      
    }
    
    let email = _email.text
    let password = _password.text
    
    if(email == "" || password == "")
    {
      alertview()
      return
    }
    
    DoLogin(email!, password!)
    
  }
  
  func DoLogin(_ eml:String, _ psw:String)
  {
    let url = URL(string:"http://www.")
    let session = URLSession.shared
    
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = "POST"
    
    let paramToSend = "username=" + eml + "&password=" + psw
    request.httpBody = paramToSend.data(using: String.Encoding.utf8)
    
    let task = session.dataTask(with: request as URLRequest, completionHandler: {
      (data, response, error) in
      
      guard let _:Data = data else
      {
        
        return
      }
      
      let json:Any?
      
      do
      {
        json = try JSONSerialization.jsonObject(with: data!, options:[])
        
      }
      catch{
        return
      }
      
      guard let server_response = json as? NSDictionary else
      {
        return
      }
      
      if let data_block = server_response["data"] as? NSDictionary
      {
        
        if let session_data = data_block["session"] as? String
        {
          
          let preference = UserDefaults.standard
          preference.set(session_data, forKey: "session")
          
          DispatchQueue.main.async (
            execute:self.LoginDone
          
          )
          
        }
      }
    })
  task.resume()
  }
  
  
  func alertview1()
  {
    
    let loginController = UIAlertController(title: "Wrong Credentials", message: "Your details are wrong, kindly check them and try again", preferredStyle: UIAlertControllerStyle.alert)
    
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    
    loginController.addAction(cancelAction)
    
    present(loginController, animated: true, completion: nil)
    
  }
  
  
  func alertview()
  {
    
    let loginController = UIAlertController(title: "Empty Credentials", message: "Kindly check details and try again", preferredStyle: UIAlertControllerStyle.alert)
    
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    
    loginController.addAction(cancelAction)
    
    present(loginController, animated: true, completion: nil)
    
  }
  
  func LoginDone()
  {
    _email.isEnabled = false
    _password.isEnabled = false
    //_loginButton.setTitle("LOG OUT", for: .normal)
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "snapVC") as UIViewController
    self.present(nextViewController, animated:true, completion:nil)  }
  
  
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0{
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y != 0{
        self.view.frame.origin.y += keyboardSize.height
      }
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
  
    let preference = UserDefaults.standard
    if(preference.object(forKey: "session") != nil)
    {
     LoginDone()
    }
    else{
      //LoginToDo()
      return   }
  }

  // IBAction methods
  @IBAction func backgroundTapped(_ sender: Any) {
    view.endEditing(true)
  }
  
  @IBAction func textFieldEndOnExit(_ sender: Any) {
    view.endEditing(true)
  }
  
  @IBAction func takePhoto(_ sender: Any) {
    view.endEditing(true)
    presentImagePicker()
  }
  
  @IBAction func swapText(_ sender: Any) {
    view.endEditing(true)

    guard let text = textView.text,
      let findText = findTextField.text,
      let replaceText = replaceTextField.text else {
        return
    }

    textView.text = text.replacingOccurrences(of: findText, with: replaceText)
    findTextField.text = nil
    replaceTextField.text = nil
  }
  
  @IBAction func sharePoem(_ sender: Any) {
    if textView.text.isEmpty {
      return
    }
    let activityViewController = UIActivityViewController(activityItems:
      [textView.text], applicationActivities: nil)
    let excludeActivities:[UIActivityType] = [
      .assignToContact,
      .saveToCameraRoll,
      .addToReadingList,
      .postToFlickr,
      .postToVimeo]
    activityViewController.excludedActivityTypes = excludeActivities
    present(activityViewController, animated: true)
  }

  // Tesseract Image Recognition
  func performImageRecognition(_ image: UIImage) {

    if let tesseract = G8Tesseract(language: "eng+fra") {
      tesseract.engineMode = .tesseractCubeCombined
      tesseract.pageSegmentationMode = .auto
      tesseract.image = image.g8_blackAndWhite()
      tesseract.recognize()
      textView.text = tesseract.recognizedText
    }
    activityIndicator.stopAnimating()
  }
  
  // The following methods handle the keyboard resignation/
  // move the view so that the first responders aren't hidden
  func moveViewUp() {
    if topMarginConstraint.constant != 0 {
      return
    }
    topMarginConstraint.constant -= 135
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  func moveViewDown() {
    if topMarginConstraint.constant == 0 {
      return
    }
    topMarginConstraint.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    moveViewUp()
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    moveViewDown()
  }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
  func presentImagePicker() {

    let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image",
                                                   message: nil, preferredStyle: .actionSheet)
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let cameraButton = UIAlertAction(title: "Take Photo",
                                       style: .default) { (alert) -> Void in
                                        let imagePicker = UIImagePickerController()
                                        imagePicker.delegate = self
                                        imagePicker.sourceType = .camera
                                        self.present(imagePicker, animated: true)
      }
      imagePickerActionSheet.addAction(cameraButton)
    }
    
    let libraryButton = UIAlertAction(title: "Choose Existing",
                                      style: .default) { (alert) -> Void in
                                        let imagePicker = UIImagePickerController()
                                        imagePicker.delegate = self
                                        imagePicker.sourceType = .photoLibrary
                                        self.present(imagePicker, animated: true)
    }
    imagePickerActionSheet.addAction(libraryButton)

    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
    imagePickerActionSheet.addAction(cancelButton)

    present(imagePickerActionSheet, animated: true)
  }

  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
      let scaledImage = selectedPhoto.scaleImage(640) {
      
      activityIndicator.startAnimating()

      dismiss(animated: true, completion: {
        self.performImageRecognition(scaledImage)
      })
    }
  }
}

// MARK: - UIImage extension
extension UIImage {
  func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
    
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    
    if size.width > size.height {
      let scaleFactor = size.height / size.width
      scaledSize.height = scaledSize.width * scaleFactor
    } else {
      let scaleFactor = size.width / size.height
      scaledSize.width = scaledSize.height * scaleFactor
    }
    
    UIGraphicsBeginImageContext(scaledSize)
    draw(in: CGRect(origin: .zero, size: scaledSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }
}
