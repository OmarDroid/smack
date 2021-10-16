//
//  MessageService.swift
//  Smack

import Foundation
import Alamofire
import SwiftyJSON

class MessageService {
    static let instance = MessageService()
    
    var channels = [Channel]()
    var messages = [Message]()
    var selectedChannel: Channel?
    var unreadChannelMessages = [String]()
  
    func findAllChannels(completion : @escaping CompletionHandler){
        let parameters: [String : String]? = nil
        AF.request(URL_GET_CHANNELS, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.error == nil {
                guard let data = response.data else {return}
                if let json = try! JSON(data: data).array {
                    for item in json {
                        let channelName = item["name"].stringValue
                        let channelDescription = item["description"].stringValue
                        let channelId = item["_id"].stringValue
                        let channel = Channel(channelTitle: channelName, channelDescription: channelDescription, channelId: channelId)
                        self.channels.append(channel)
                    }
                    NotificationCenter.default.post(name: NOTIF_CHANNELS_LOADED, object: nil)
                    completion(true)
                }
            }else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
    }
    
    func findAllMessagesForChannel(channelId: String, completion: @escaping CompletionHandler) {
        let parameters: [String : String]? = nil
        AF.request("\(URL_GET_MESSAGES)\(channelId)", method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.error == nil {
                self.clearMessages()
                guard let data = response.data else {return}
                if let json = try! JSON(data: data).array {
                    for item in json {
                        let messageBody = item["messageBody"].stringValue
                        let channelId = item["channelId"].stringValue
                        let id = item["_id"].stringValue
                        let userName = item["userName"].stringValue
                        let userAvatar = item["userAvatar"].stringValue
                        let userAvatarColor = item["userAvatarColor"].stringValue
                        let timeStamp = item["timeStamp"].stringValue
                        let message = Message(message: messageBody, userName: userName, channelId: channelId, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
                        self.messages.append(message)
                    }
                    //NotificationCenter.default.post(name: NOTIF_CHANNELS_LOADED, object: nil)
                    print("messages-------------", self.messages)
                    completion(true)
                }
            }else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
    }
    
    
    func clearMessages(){
        messages.removeAll()
    }
    
    func clearChannels() {
        channels.removeAll()
    }
}
