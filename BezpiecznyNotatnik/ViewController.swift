import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var passwordInput: UITextField!
    let locksmith = Locksmith.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func savePassword(sender: UIButton){
        let password = passwordInput.text!
        let result = locksmith.encryptPassword(password: password)
        if(!result){
            let alert = UIAlertController(title: "Zbyt krótkie hasło!", message: "Hasło ma mniej niż 8 znaków. Wprowadź dłuższe hasło.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default ,handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        //switch to message storyboard after setting keychain
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        
        present(vc, animated: true, completion: nil)
    }
}

