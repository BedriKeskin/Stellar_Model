//
//  About.swift
//  Stellar Model
//
//  Created by Bedri Keskin on 1/19/20.
//  Copyright © 2020 Bedri Keskin. All rights reserved.
//

import UIKit
import MessageUI
import Amplitude_iOS
import StoreKit

class Info: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var tvText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let text = NSMutableAttributedString(string: "In astrophysics, a polytrope refers to a solution of the Lane–Emden equation in which the pressure depends upon the density in the form\n")
        let image = NSTextAttachment()
        image.image = UIImage(named: "LaneEmden.png")
        image.bounds = CGRect(x: 100, y: 0, width: 110, height: 23)
        let image1String = NSAttributedString(attachment: image)
        text.append(image1String)
        text.append(NSAttributedString(string: "\nwhere P is pressure, ρ is density and K is a constant of proportionality. The constant n is known as the polytropic index; note however that the polytropic index has an alternative definition as with n as the exponent. This relation need not be interpreted as an equation of state, which states P as a function of both ρ and T (the temperature); however in the particular case described by the polytrope equation there are other additional relations between these three quantities, which together determine the equation. Thus, this is simply a relation that expresses an assumption about the change of pressure with radius in terms of the change of density with radius, yielding a solution to the Lane–Emden equation. "))
        
        let linkText = NSMutableAttributedString(string: "Read more from Wikipedia...", attributes: [NSAttributedString.Key.link: URL(string: "https://en.wikipedia.org/wiki/Polytrope")!])
        text.append(linkText)

        tvText.attributedText = text
        tvText.isUserInteractionEnabled = true
        tvText.isSelectable = true
        tvText.isEditable = false
        
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance()?.disableIdfaTracking()
        Amplitude.instance().initializeApiKey("9656f73c8990e6e6190f50c6e6cce7a5")
    }
    
    @IBAction func btShareAppClick(_ sender: Any) {
        Amplitude.instance().logEvent("btShareAppClick")
            let textToShare = "Check out Stellar Model app"
            if let myWebsite = URL(string: "http://itunes.apple.com/app/id1496421896") {
                let objectsToShare = [textToShare, myWebsite] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = sender as? UIView
                self.present(activityVC, animated: true, completion: nil)
            }
    }
    
    @IBAction func btRateAppClick(_ sender: Any) {
        Amplitude.instance().logEvent("btRateAppClick")
        if #available(iOS 10.3, *) {SKStoreReviewController.requestReview()}
            else if let url = URL(string: "itms-apps://itunes.apple.com/app/id1496421896") {
               if #available(iOS 10, *) {UIApplication.shared.open(url, options: [:], completionHandler: nil)}
                else {UIApplication.shared.openURL(url)}
           }
    }
    
    @IBAction func btReverseLookupClick(_ sender: Any) {
        Amplitude.instance().logEvent("btReverseLookupClick")
        UIApplication.shared.open(NSURL(string: "https://itunes.apple.com/app/id1482011745")! as URL, options: [:], completionHandler: nil)
        Amplitude.instance().logEvent("open_ReverseLookupLink")
    }
    
    @IBAction func btBedriClick(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["bedri.keskin@gmail.com"])
            mail.setSubject("About Stellar Model IOS App")
            mail.setMessageBody("\r\n\r\n\r\n\r\n\r\n--------------------------\r\nApp Version: \(AMPDeviceInfo.init().appVersion as String)\r\nDevice Version: \(AMPDeviceInfo.init().osVersion as String)\r\nDevice Type: \(AMPDeviceInfo.init().model as String)\r\nDevice ID: \(Amplitude.instance().deviceId as String)", isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            UIApplication.shared.open(URL(string: "bedri.keskin@gmail.com")!)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    @IBAction func btAnkaraUniclick(_ sender: Any) {
        if let url = NSURL(string: "https://en.ankara.edu.tr"){
            UIApplication.shared.open(url as URL, options: [:])
        }
    }
    
    @IBAction func btAstronomyClick(_ sender: Any) {
        if let url = NSURL(string: "http://fenbilimleri.ankara.edu.tr/en/astronomy-and-space-sciences/"){
            UIApplication.shared.open(url as URL, options: [:])
        }
    }
}

