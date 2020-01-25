//
//  Polytropes.swift
//  Stellar Model
//
//  Created by Bedri Keskin on 1/19/20.
//  Copyright © 2020 Bedri Keskin. All rights reserved.
//

import UIKit
import Foundation
import Amplitude_iOS

class Polytropes: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var tfpolitIndex: UITextField!
    @IBOutlet weak var tfStepSize: UITextField!
    @IBOutlet weak var tfMass: UITextField!
    @IBOutlet weak var tfRadius: UITextField!
    @IBOutlet weak var btCalculate: UIButton!
    @IBOutlet weak var aiActIndic: UIActivityIndicatorView!
    @IBOutlet weak var tblPolytropes: UITableView!
    @IBOutlet weak var lblIterCount: UILabel!
    @IBOutlet weak var lblCentPress: UILabel!
    @IBOutlet weak var lblCentDens: UILabel!
    @IBOutlet weak var lblMassParam: UILabel!
    @IBOutlet weak var lblDistUnit: UILabel!
    @IBOutlet weak var lblxFinal: UILabel!
    @IBOutlet weak var lbl_x2h: UILabel!
    @IBOutlet weak var lblAverDens: UILabel!
    
    var n:Double = 1.5 // polytrope index
    var dr:Double = 0.05 // stepsize
    var mass:Double = 2.5 //mass
    var rad:Double = 1.68 // radius
    
    var i:Int = 0
    let arraysize = 3700 //it is enough. for stepsize=0.001 iteration counts to 3653
    var x:[Double] = []
    var f:[Double] = []
    var h:[Double] = []
    var p:[Double] = []
    var d:[Double] = []
    var m:[Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tfpolitIndex.delegate = self
        tfStepSize.delegate = self
        tfMass.delegate = self
        tfRadius.delegate = self
        tblPolytropes.delegate = self
        tblPolytropes.dataSource = self
        tblPolytropes.rowHeight = 20.0

        x = Array(repeating: 0, count: arraysize)
        f = Array(repeating: 0, count: arraysize)
        h = Array(repeating: 0, count: arraysize)
        p = Array(repeating: 0, count: arraysize)
        d = Array(repeating: 0, count: arraysize)
        m = Array(repeating: 0, count: arraysize)
        
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance()?.disableIdfaTracking()
        Amplitude.instance().initializeApiKey("9656f73c8990e6e6190f50c6e6cce7a5")
    }
    
    @IBAction func btCalculateclick(_ sender: Any) {
        Amplitude.instance().logEvent("btCalculateclick")

        if let xxx = Double(tfpolitIndex.text!), xxx >= 0, xxx < 5 {
            n = xxx
        } else {
            tfpolitIndex.text = ""
            tfpolitIndex.becomeFirstResponder()
            return
        }
        if let xxx = Double(tfStepSize.text!), xxx >= 0.001, xxx <= 0.1 {
            dr = xxx
        } else {
            tfStepSize.text = ""
            tfStepSize.becomeFirstResponder()
            return
        }
        if let xxx = Double(tfMass.text!), xxx > 0 {
            mass = xxx
        } else {
            tfMass.text = ""
            tfMass.becomeFirstResponder()
            return
        }
        if let xxx = Double(tfRadius.text!), xxx > 0 {
            rad = xxx
        } else {
            tfRadius.text = ""
            tfRadius.becomeFirstResponder()
            return
        }

        //print('  i   x = r/rn       f           h        log(P/Pc)   log(d/dC)     l*mr')
        x[i] = 0
        f[i] = 1
        h[i] = 0
        p[i] = pow(f[i], n + 1)
        d[i] = pow(f[i], n)
        m[i] = -x[i] * x[i] * h[i]
        
        // compute first step
        i = 1
        x[i]=dr
        f[i] = 1.0 - pow(x[i], 2) / 6.0 + pow(x[i], 4) * n / 120.0
        h[i] = -x[i] / 3.0 + pow(x[i], 3) * n / 30.0
        p[i] = pow(f[i], n + 1)
        d[i] = pow(f[i], n)
        m[i] = -x[i] * x[i] * h[i]

        // initialize main cycle

        var verder:Double = 1
        var x12:[Double] = Array(repeating: 0, count: arraysize)
        var f12:[Double] = Array(repeating: 0, count: arraysize)
        var h12:[Double] = Array(repeating: 0, count: arraysize)

        while verder > 0 {
             x12[i] = x[i] + 0.5 * dr
             f12[i] = f[i] + 0.5 * dr * h[i]
            
            // check whether f12 (= F at half step) is till positive
            if f12[i] > 0 {
                h12[i] = h[i] + 0.5 * dr * (-pow(f[i], n) - 2 * h[i] / x[i])
                x[i+1] = x[i] + dr
                f[i+1] = f[i] + dr * h12[i]
                
                // check whether f1 ( = F at new state) is still positive
                if f[i+1] > 0 {
                    h[i+1] = h[i] + dr * (-pow(f12[i], n) - 2 * h12[i] / x12[i])
                    
                    // compute pressure, density and mass
                    p[i+1] = pow(f[i+1], n + 1)
                    d[i+1] = pow(f[i+1], n)
                    m[i+1] = -x[i+1] * x[i+1] * h[i+1]
                    i = i + 1
                }else {
                    // this else is reached if f1 was negative
                    verder=0}
            } else {verder=0}
        }

        tblPolytropes.reloadData()

        lblIterCount.text = " " + String(format:"%i", i)
        // compute general characteristics and surface data
        let xm = x[i] - f[i] / h[i]  // x-final
        lblxFinal.text = " " + String(format:"%.4f", xm)
        let hm = h[i] + (xm - x[i]) * (-pow(f[i], n) - 2 * h[i] / x[i])
        lbl_x2h.text = " " + String(format:"%.4f", -xm*xm*hm)
      //  let fm = 0
        let pc = 9.048e14 * mass * mass / (n + 1) / hm / hm / pow(rad, 4) //central pressure (Pc)
        lblCentPress.text = " " + String(format:"%.2e", pc)
        let dm = 1.42 * mass / pow(rad, 3) //average density (dm)
        lblAverDens.text = " " + String(format:"%.4f", dm)
        let dc = -dm * xm / 3.0 / hm //central density (dc)
        lblCentDens.text = " " + String(format:"%.4f", dc)
        let lmr = -xm * xm * hm / mass //mass parameter (L)
        lblMassParam.text = " " + String(format:"%.4f", lmr)
        let rn = rad / xm //distance unit (rn)
        lblDistUnit.text = " " + String(format:"%.4f", rn)
        
        aiActIndic.hidesWhenStopped = true
        aiActIndic.isHidden = false
        aiActIndic.startAnimating()
        self.view.addSubview(aiActIndic)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.aiActIndic.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return i+1 // i saymaya 0'dan başladığı için satır sayısı 1 fazla olacak
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellPolytropes", for: indexPath) as? PolytropesCell
        if i > 0 { // i=0 ise tabloda hiçbir şey göstermesin
        cell?.lbli.text = String(indexPath.row)
        cell?.lblx.text = String(format:"%.3f", x[indexPath.row])
        cell?.lblf.text = String(format:"%.5f", f[indexPath.row])
        cell?.lblh.text = String(format:"%.5f", h[indexPath.row])
        cell?.lbllogPoPc.text = String(format:"%.4f", log10(p[indexPath.row]))
        cell?.lbllogdodc.text = String(format:"%.4f", log10(d[indexPath.row]))
        cell?.lbllmr.text = String(format:"%.4f", m[indexPath.row])}
        return cell!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        if let regex = try? NSRegularExpression(pattern: "^[0-9]*((\\.|,)[0-9]{0,3})?$", options: .caseInsensitive) {
            return regex.numberOfMatches(in: newText, options: .reportProgress, range: NSRange(location: 0, length: (newText as NSString).length)) > 0
        }
        return false
        }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
