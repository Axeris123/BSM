import UIKit
import KeychainSwift
import CryptoSwift
import LocalAuthentication

let keychain = KeychainSwift()

class Locksmith{
    var aes: AES?
    var message: String?
    
    private static var sharedLocksmith: Locksmith = {
        return Locksmith()
    }()
    
    class func getInstance() -> Locksmith {
        return sharedLocksmith
    }
    
    func encryptPassword(password: String) -> Bool {
        if password.count < 8 {
            return false
        }
        
        let salt = self.generateSalt(length: 8)
        let passwordToHash: Array<UInt8> = Array(password.utf8)
        let saltToHash: Array<UInt8> = Array(salt.utf8)
        
        do{
            let key = try PKCS5.PBKDF2(password: passwordToHash, salt: saltToHash, iterations: 4096, variant: .sha256).calculate()
            
            //32bitowy wektor inicjalizacyjny == AES256
            let iv: Array<UInt8> = AES.randomIV(32)
            
            let aes = try AES(key: key, blockMode: GCM(iv: iv, mode: .combined))
            self.aes = aes
            
            let encryptedPassword = try aes.encrypt(passwordToHash)
            
            keychain.set(salt, forKey: "salt")
            keychain.set(Data(iv), forKey: "iv")
            keychain.set(Data(encryptedPassword), forKey: "password")
            
            return true
        }
        catch{
            return false
        }
    }
    
    
    func generateSalt(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func decryptMessage(message: Data) -> String? {
        do{
            let decryptedMessage = try self.aes!.decrypt(message.bytes)
            let plainMessage = String(bytes: decryptedMessage, encoding: .utf8)
            
            return plainMessage
        }
        catch{
            return nil
        }
    }
    
    func encryptMessage(message: String, key: String) -> Bool {
        do {
            let encryptedMessage = try aes!.encrypt(Array(message.utf8))
            keychain.set(Data(encryptedMessage), forKey: key)
            
            return true
        }
        catch {
            return false
        }
    }
    
    func login(password: String) -> Bool{
        let hashedPassword = keychain.getData("password")
        let salt = keychain.get("salt")
        let iv: Array<UInt8> = keychain.getData("iv")!.bytes
        
        let passwordToHash: Array<UInt8> = Array(password.utf8)
        let saltToHash: Array<UInt8> = Array(salt!.utf8)
        
        do{
            
            let key = try PKCS5.PBKDF2(password: passwordToHash, salt: saltToHash, iterations: 4096, variant: .sha256).calculate()
            
            let aes = try AES(key: key, blockMode: GCM(iv: iv, mode: .combined))
            
            let encryptedPassword = try aes.encrypt(passwordToHash)
            
            if(encryptedPassword != hashedPassword!.bytes){
                return false
            }
            
            if(!faceIDAuth()){
                return false
            }
     
            self.aes = aes
            return true
        }
        catch{
            return false
        }
        
    }
    
    func faceIDAuth() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        let localAuthenticationContext = LAContext()
        let reasonString = "To access the secure data"
        
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var result: Bool = false
        var authError: NSError?
  
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in

                result = success ? true : false
                semaphore.signal()
            }
        } else {
            result = false
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return result
    }
    
    
}
