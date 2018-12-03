import UIKit

class MessageViewController: UIViewController {

    
    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var changePasswordInput: UITextField!

    
    let locksmith = Locksmith.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let messageHash = keychain.getData("message")
        
        if messageHash != nil {
            let message: String? = locksmith.decryptMessage(message: messageHash!)
            if message != nil {
                messageLabel.text = message
            }
            else{
                let alert = UIAlertController(title: "Błąd!", message: "Nie udało się odczytać wiadomości!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default ,handler: nil))
                present(alert, animated: true)
            }
        }
    }
    
    
    @IBAction func saveMessage(sender: UIButton){
        let message = messageInput.text!
        if(!locksmith.encryptMessage(message: message, key: "message")){
            let alert = UIAlertController(title: "Błąd!", message: "Nie udało się zapisać wiadomości!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default ,handler: nil))
            present(alert, animated: true)
            return
        }
        
        messageInput.text = ""
        messageLabel.text = message
    }
    
    @IBAction func changePassword(sender: UIButton){
        let alertController = UIAlertController(title: "Zmiana hasła", message: "Podaj nowe hasło", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let password = alertController.textFields?[0].text
            
            let result = self.locksmith.encryptPassword(password: password!)
            
            if(!result){
                let alert = UIAlertController(title: "Zbyt krótkie hasło!", message: "Hasło ma mniej niż 8 znaków. Wprowadź dłuższe hasło.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default ,handler: nil))
                self.present(alert, animated: true)

                return
            }
            
            self.locksmith.encryptMessage(message: self.messageLabel.text!, key: "message")
            
            let alert = UIAlertController(title: "Sukces", message: "Hasło zostało zmienione!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default ,handler: nil))
            self.present(alert, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Anuluj", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Podaj hasło"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        }
    
    
    
//    @IBAction func changePassword(sender: UIButton){
//        let password = changePasswordInput.text!
//        let result = locksmith.encryptPassword(password: password)
//
//        if(!result.success){
//            let alert = UIAlertController(title: "Zbyt krótkie hasło!", message: "Hasło ma mniej niż 8 znaków. Wprowadź dłuższe hasło.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default ,handler: nil))
//            self.present(alert, animated: true)
//
//            return
//        }
//
//        let alert = UIAlertController(title: "Sukces", message: "Hasło zostało zmienione!", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default ,handler: nil))
//        self.present(alert, animated: true)
//    }
    }
