//
//  AuthService.swift
//  Smack

import Foundation
import Alamofire
import SwiftyJSON

class AuthService {
    static let instance = AuthService()
    
    let defaults = UserDefaults.standard
    
    var isLoggedIn : Bool {
        get {
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    
    var authToken: String {
        get {
            return defaults.value(forKey: TOKEN_KEY) as! String
        }
        set {
            defaults.set(newValue, forKey: TOKEN_KEY)
        }
    }
    
    var userEmail: String {
        get {
            return defaults.value(forKey: USER_EMAIL) as! String
        }
        set {
            defaults.set(newValue, forKey: USER_EMAIL)
        }
    }
    
    
    func registerUser(email : String, password: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let body: [String : String] = [
            "email": lowerCaseEmail,
            "password": password
        ]
        AF.request(URL_REGISTER, method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: HEADER).responseString { (response) in
            if response.error == nil {
                completion(true)
            }else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
    }
    
    func loginUser(email : String, password: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let body: [String : String] = [
            "email": lowerCaseEmail,
            "password": password
        ]
        AF.request(URL_LOGIN, method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: HEADER).responseJSON { (response) in
            if response.error == nil {
                guard let data = response.data else {return}
                let json = try! JSON(data: data)
                print(json)
                self.userEmail = json["user"].stringValue
                self.authToken = json["token"].stringValue
                self.isLoggedIn = true
                completion(true)
            }else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
    }
    
    func createUser(name: String, email: String, avatarName: String, avatarColor: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let body: [String : String] = [
            "name": name,
            "email": lowerCaseEmail,
            "avatarName": avatarName,
            "avatarColor": avatarColor
        ]
        
        AF.request(URL_ADD_USER, method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.error == nil {
                guard let data = response.data else {return}
                self.setUserInfo(data: data)
                completion(true)
            }else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
    }
    
    func findUserByEmail(completion : @escaping CompletionHandler){
        let parameters: [String : String]? = nil
        AF.request("\(URL_USER_BY_EMAIL)\(userEmail)", method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: BEARER_HEADER).responseJSON { (response) in
            print("\(URL_USER_BY_EMAIL)\(self.userEmail)")
            if response.error == nil {
                guard let data = response.data else {return}
                self.setUserInfo(data: data)
                completion(true)
            }else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
    }
    
    func setUserInfo(data: Data) {
        let json = try! JSON(data: data)
        print(json)
        let id = json["_id"].stringValue
        let avatarColor = json["avatarColor"].stringValue
        let avatarName = json["avatarName"].stringValue
        let email = json["email"].stringValue
        let name = json["name"].stringValue
        UserDataService.instance.setUserData(id: id, avatarColor: avatarColor, avatarName: avatarName, email: email, name: name)
    }
}
