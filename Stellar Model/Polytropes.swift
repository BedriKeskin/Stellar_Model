//
//  Polytropes.swift
//  Stellar Model
//
//  Created by Bedri Keskin on 1/19/20.
//  Copyright © 2020 Bedri Keskin. All rights reserved.
//
// Bedri Keskin
// bedri.keskin@gmail.com
// PhD Student
// Ankara University, Turkiye
// Astronomy and Space Science
// SWIFT reinterpretation of Python code of "Astrophysics with a PC"
// "Chapter 7 - Polytropes"
// https://github.com/cdacos/astrophysics_with_a_pc/blob/master/python/ch07_polytropes.py

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
    @IBOutlet weak var btExpResults: UIButton!
    
    let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Polytropic Stellar Model.csv")!

    var n:Double = 1.5 // polytrope index
    var dr:Double = 0.05 // stepsize
    var mass:Double = 2.5 //mass
    var rad:Double = 1.68 // radius
    
    var i:Int = 0
    let arraysize = 1764347 // n=4.999 ve h=0.01 için
    var x:[Double] = []
    var f:[Double] = []
    var h:[Double] = []
    var p:[Double] = []
    var d:[Double] = []
    var m:[Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        aiActIndic.hidesWhenStopped = true
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
        Amplitude.instance().logEvent("btCalculateclickPoly")
     //   fatalError()  // Force a test crash FirebaseCrashlytics
        
        aiActIndic.isHidden = false
        aiActIndic.startAnimating()
        self.view.addSubview(aiActIndic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {//aiActIndic'ın butona bastıktan hemen sonra dönmesi için bütün kodun bunun içinde olması lazım
                
        if let xxx = Double(self.tfpolitIndex.text!), xxx >= 0, xxx <= 4.999 {
                    self.n = xxx
        } else {
            self.tfpolitIndex.text = ""
            self.tfpolitIndex.becomeFirstResponder()
            self.aiActIndic.stopAnimating()
            return
        }
        if let xxx = Double(self.tfStepSize.text!), xxx >= 0.01, xxx <= 0.1 {
                    self.dr = xxx
        } else {
            self.tfStepSize.text = ""
            self.tfStepSize.becomeFirstResponder()
            self.aiActIndic.stopAnimating()
            return
        }
        if let xxx = Double(self.tfMass.text!), xxx > 0 {
                    self.mass = xxx
        } else {
            self.tfMass.text = ""
            self.tfMass.becomeFirstResponder()
            self.aiActIndic.stopAnimating()
            return
        }
        if let xxx = Double(self.tfRadius.text!), xxx > 0 {
                    self.rad = xxx
        } else {
            self.tfRadius.text = ""
            self.tfRadius.becomeFirstResponder()
            self.aiActIndic.stopAnimating()
            return
        }

        //print('  i   x = r/rn       f           h        log(P/Pc)   log(d/dC)     l*mr')
                self.x[self.i] = 0
                self.f[self.i] = 1
                self.h[self.i] = 0
                self.p[self.i] = pow(self.f[self.i], self.n + 1)
                self.d[self.i] = pow(self.f[self.i], self.n)
                self.m[self.i] = -self.x[self.i] * self.x[self.i] * self.h[self.i]
        
        // first step
                self.i = 1
                self.x[self.i]=self.dr
                self.f[self.i] = 1.0 - pow(self.x[self.i], 2) / 6.0 + pow(self.x[self.i], 4) * self.n / 120.0
                self.h[self.i] = -self.x[self.i] / 3.0 + pow(self.x[self.i], 3) * self.n / 30.0
                self.p[self.i] = pow(self.f[self.i], self.n + 1)
                self.d[self.i] = pow(self.f[self.i], self.n)
                self.m[self.i] = -self.x[self.i] * self.x[self.i] * self.h[self.i]

        // main cycle
        var iter:Double = 1
                var x12:[Double] = Array(repeating: 0, count: self.arraysize)
                var f12:[Double] = Array(repeating: 0, count: self.arraysize)
                var h12:[Double] = Array(repeating: 0, count: self.arraysize)

        while iter > 0 {
            x12[self.i] = self.x[self.i] + 0.5 * self.dr
            f12[self.i] = self.f[self.i] + 0.5 * self.dr * self.h[self.i]
            
            // check whether f12 (= F at half step) is till positive
            if f12[self.i] > 0 {
                h12[self.i] = self.h[self.i] + 0.5 * self.dr * (-pow(self.f[self.i], self.n) - 2 * self.h[self.i] / self.x[self.i])
                self.x[self.i+1] = self.x[self.i] + self.dr
                self.f[self.i+1] = self.f[self.i] + self.dr * h12[self.i]
                
                // check whether f1 ( = F at new state) is still positive
                if self.f[self.i+1] > 0 {
                    self.h[self.i+1] = self.h[self.i] + self.dr * (-pow(f12[self.i], self.n) - 2 * h12[self.i] / x12[self.i])
                    
                    // compute pressure, density and mass
                    self.p[self.i+1] = pow(self.f[self.i+1], self.n + 1)
                    self.d[self.i+1] = pow(self.f[self.i+1], self.n)
                    self.m[self.i+1] = -self.x[self.i+1] * self.x[self.i+1] * self.h[self.i+1]
                    self.i = self.i + 1
                }else {
                    // this else is reached if f1 was negative
                    iter=0}
            } else {iter=0}
        }

                self.tblPolytropes.reloadData()

                self.lblIterCount.text = " " + String(format:"%i", self.i)
        // compute general characteristics and surface data
                let xm = self.x[self.i] - self.f[self.i] / self.h[self.i]  // x-final
                self.lblxFinal.text = " " + String(format:"%.4f", xm)
                let hm = self.h[self.i] + (xm - self.x[self.i]) * (-pow(self.f[self.i], self.n) - 2 * self.h[self.i] / self.x[self.i])
                self.lbl_x2h.text = " " + String(format:"%.4f", -xm*xm*hm)
      //  let fm = 0
                let pc = 9.048e14 * self.mass * self.mass / (self.n + 1) / hm / hm / pow(self.rad, 4) //central pressure (Pc)
                self.lblCentPress.text = " " + String(format:"%.2e", pc)
                let dm = 1.42 * self.mass / pow(self.rad, 3) //average density (dm)
                self.lblAverDens.text = " " + String(format:"%.4f", dm)
        let dc = -dm * xm / 3.0 / hm //central density (dc)
                self.lblCentDens.text = " " + String(format:"%.4f", dc)
                let lmr = -xm * xm * hm / self.mass //mass parameter (L)
                self.lblMassParam.text = " " + String(format:"%.4f", lmr)
                let rn = self.rad / xm //distance unit (rn)
                self.lblDistUnit.text = " " + String(format:"%.4f", rn)

        // sonuçları dosyaya kaydetme
                var csvText = "Polytropic Stellar Model\n\n--Initial Values--\nPolytrope Index (n):,\(self.n)\nStep Size (h):,\(self.dr)\nMass (M0):,\(self.mass)\nRadius (R0):,\(self.rad)\n\n--Iterations--\ni,X(n),F(n),H(n),log(P/Pc),log(⍴/⍴c),LM(r)\n"
        
                for n in 0...self.i {
                    let newLine = "\(n),\(self.x[n]),\(self.f[n]),\(self.h[n]),\(log10(self.p[n])),\(log10(self.d[n])),\(self.m[n])\n"
            csvText.append(contentsOf: newLine)
        }
                let results = "\n--Results--\nIteration Count (i):,\(self.i)\nCentral Pressure (Pc) (dyn/cm2):,\(pc)\nAverage Density (⍴m) (gr/cm3):,\(dm)\nCentral Density (⍴c) (gr/cm3):,\(dc)\nMass Parameter (L):,\(lmr)\nDistance Unit (rn):,\(rn)\nx (final):,\(xm)\n-x2*h (final):,\(-xm*xm*hm)"
        csvText.append(contentsOf: results)
        
        do {
            try csvText.write(to: self.path, atomically: true, encoding: String.Encoding.utf8)
            self.btExpResults.isHidden = false
        } catch {self.btExpResults.isHidden = true}
        
      self.aiActIndic.stopAnimating()
     } //DispatchQueue.main.asyncAfter sonu
    }
    
    @IBAction func btExpResultsClick(_ sender: Any) {//sonuçları export etme
        Amplitude.instance().logEvent("btExpResultsClickPoly")
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = sender as? UIView
        present(vc, animated: true, completion: nil)
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
    //textfieldların noktadan sonra 3 hane olması
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
