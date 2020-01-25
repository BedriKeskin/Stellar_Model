//
//  PrivacyPolicy.swift
//  Stellar Model
//
//  Created by Bedri Keskin on 1/25/20.
//  Copyright © 2020 Bedri Keskin. All rights reserved.
//

import UIKit

class PrivacyPolicy: UIViewController {
    
    @IBOutlet weak var tvPrivacy: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tvPrivacy.setContentOffset(CGPoint.zero, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func btXClick(_ sender: Any) {
        //performSegueToReturnBack()
        self.dismiss(animated: true, completion: nil)

    }
}
