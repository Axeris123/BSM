import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var inputPassword: UITextField!
    
    var hashedPassword: Data? = nil
    let locksmith = Locksmith.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(sender: UIButton){
        let password = inputPassword.text!
        if(!locksmith.login(password: password)){
            let alert = UIAlertController(title: "Błąd!", message: "Złe hasło!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default ,handler: nil))
            present(alert, animated: true)
            
            return
        }
        
        
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        
        present(vc, animated: true, completion: nil)
    }
    

}
