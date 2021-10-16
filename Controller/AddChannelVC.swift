//
//  AddChannelVC.swift
//  Smack

import UIKit

class AddChannelVC: UIViewController {

    @IBOutlet weak var channelNameTxt: UITextField!
    @IBOutlet weak var descriptionTxt: UITextField!
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @IBAction func closeModalPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func closedModalPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createChannelBtnPressed(_ sender: Any) {
        guard let channelName = channelNameTxt.text, channelNameTxt.text != "" else {return}
        guard let channelDescription = descriptionTxt.text, descriptionTxt.text != "" else {return}
        SocketService.instance.addChannel(channelName: channelName, channelDescription: channelDescription) { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setupView(){
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(AddChannelVC.closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
        
        channelNameTxt.attributedPlaceholder = NSAttributedString(string: "Channel name", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])
        descriptionTxt.attributedPlaceholder = NSAttributedString(string: "Channel description", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])

    }
    
    @objc func closeTap(_ recognizer: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }

}
