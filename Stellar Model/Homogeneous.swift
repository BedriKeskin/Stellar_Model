//
//  Homogeneous.swift
//  Stellar Model
//
//  Created by Bedri Keskin on 2/3/20.
//  Copyright © 2020 Bedri Keskin. All rights reserved.
//

import UIKit
import Foundation
import Amplitude_iOS

class Homogeneous: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var tfMass: UITextField!
    @IBOutlet weak var tblHomogen: UITableView!
    @IBOutlet weak var aiActIndic: UIActivityIndicatorView!
    @IBOutlet weak var lblIterCount: UILabel!
    @IBOutlet weak var lblCentPress: UILabel!
    @IBOutlet weak var lblCentDens: UILabel!
    @IBOutlet weak var lblxfit: UILabel!
    @IBOutlet weak var lblffit: UILabel!
    @IBOutlet weak var lblhfit: UILabel!
    @IBOutlet weak var lblDistUnit: UILabel!
    @IBOutlet weak var lblMass: UILabel!
    @IBOutlet weak var lblRadius: UILabel!
    @IBOutlet weak var lblLumino: UILabel!
    @IBOutlet weak var lblEffTemp: UILabel!
    @IBOutlet weak var btExpResults: UIButton!
    
    let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Homogeneous Stellar Model.csv")!
    
    var mass:Double = 2.5 //mass
    
    let g = 6.673e-8
    let a = 7.56464e-15
    let rgas = 8.314e7
    let xx = 0.7
    let yy = 0.27
    let zz = 0.03
    let mu = 0.618238
    let M0 = 2e33 //Msun
    let R0 = 6.96e10 //Rsun
    let L0 = 3.83e33 //Lsun
    
    var i:Int = 0
    let arraysize = 1764347 // n=4.999 ve h=0.01 için
    var x:[Double] = []
    var f:[Double] = []
    var h:[Double] = []
    var m:[Double] = []
    var p:[Double] = []
    var t:[Double] = []
    var d:[Double] = []
    var r:[Double] = []
    var ee:[Double] = []
    var l:[Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tfMass.delegate = self
        tblHomogen.delegate = self
        tblHomogen.dataSource = self
        tblHomogen.rowHeight = 20.0
        
        x = Array(repeating: 0, count: arraysize)
        f = Array(repeating: 0, count: arraysize)
        h = Array(repeating: 0, count: arraysize)
        m = Array(repeating: 0, count: arraysize)
        p = Array(repeating: 0, count: arraysize)
        t = Array(repeating: 0, count: arraysize)
        d = Array(repeating: 0, count: arraysize)
        r = Array(repeating: 0, count: arraysize)
        ee = Array(repeating: 0, count: arraysize)
        l = Array(repeating: 0, count: arraysize)
        
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance()?.disableIdfaTracking()
        Amplitude.instance().initializeApiKey("9656f73c8990e6e6190f50c6e6cce7a5")
    }
    
    @IBAction func btCalculateClick(_ sender: Any) {
        Amplitude.instance().logEvent("btCalculateclickHomogen")
        //   fatalError()  // Force a test crash FirebaseCrashlytics
        aiActIndic.isHidden = false
        aiActIndic.startAnimating()
        self.view.addSubview(aiActIndic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {//Act Ind'ın butona bastıktan hemen sonra donmesi için bütün kodun bunun içinde olması lazım
            if let xxx = Double(self.tfMass.text!), xxx > 0 {
                self.mass = xxx
            } else {
                self.tfMass.text = ""
                self.tfMass.becomeFirstResponder()
                self.aiActIndic.stopAnimating()
                return
            }
            
            let w = log10(self.mass)
            var mt:Double = 0 //final mass
            var rad:Double = 0 //final radius
            var logteff:Double = 0 //

            // central values of temperature and density
            let tc = pow(10, 7.23937 + 0.2724354 * w - 0.0401771 * w * w)
            var dc = pow(10, 2.27899 - 1.658707 * w + 0.29329095 * w * w)
            
            // compute the value of the fitmass :
            var ffit:Double
            if self.mass < 4 { ffit = 9.0}
            else if self.mass < 10 { ffit = 19.58794 - 17.58794 * w }
            else { ffit = 2.0}
            
            var xfit:Double = 0 //
            var hfit:Double = 0 //
            
            // compute other central quantities
            let pgc = self.rgas * dc * tc / self.mu
            let prc = 1 / 3.0 * self.a * pow(tc, 4)
            var ptc = pgc + prc
            let betac = pgc / ptc
            let beta = 1 - 2 / 3.0 * (1 - betac)
            let fb = (8 - 6 * beta) / (32 - 24 * beta - 3 * pow(beta, 2))
            var n = (1 - fb) / fb
            var rn = sqrt((n + 1) * ptc / 4.0 / Double.pi / self.g / dc / dc)
            let eec = self.e(d: dc, t: tc)
            
            self.x[self.i] = 0
            self.f[self.i] = 1
            self.h[self.i] = 0
            self.t[self.i] = tc
            self.ee[self.i] = eec
            self.l[self.i] = 0
            (self.p[self.i], self.d[self.i], self.m[self.i], self.r[self.i]) = self.poly(n: n, x: self.x[self.i], f: self.f[self.i], h: self.h[self.i], pc: ptc, dc: dc, rn: rn);
            
            // compute and show first step
            self.i=1
            var dx = 0.1
            self.x[self.i] = dx
            self.f[self.i] = 1 - 1 / 6.0 * pow(dx, 2) + n / 120.0 * pow(dx, 4)
            self.h[self.i] = -1 / 3.0 * dx + n / 30.0 * pow(dx, 3)
            (self.p[self.i], self.d[self.i], self.m[self.i], self.r[self.i]) = self.poly(n: n, x: self.x[self.i], f: self.f[self.i], h: self.h[self.i], pc: ptc, dc: dc, rn: rn)
            self.t[self.i] = self.temp(mu: self.mu, p: self.p[self.i], d: self.d[self.i]);
            self.ee[self.i] = self.e(d: self.d[self.i], t: self.t[self.i]);
            let dr = dx * rn;
            self.l[self.i] = 4 / 3.0 * Double.pi * dc * eec * pow(dr, 3);
            
            // Start of main cycle
            var surface = 0
            self.i = 2
            
            for zone in 1...2 {  // zone = 1 during convective region = 2 during radiative region
                var stp = 0
                while stp != 1 {
                    let flast = self.f[self.i-1] // Save previous value of polytrope variable in flast
                    let x12 = self.x[self.i-1] + 0.5 * dx
                    let f12 = self.f[self.i-1] + 0.5 * dx * self.h[self.i-1]
                    
                    // check whether f12 is still positive
                    if f12 > 0 {
                        let h12 = self.h[self.i-1] + 0.5 * dx * (-pow(self.f[self.i-1], n) - 2 * self.h[self.i-1] / self.x[self.i-1])
                        let p12 = ptc * pow(f12, n + 1)
                        let d12 = dc * pow(f12, n)
                        let t12 = self.temp(mu: self.mu, p: p12, d: d12)
                        var ee12:Double = 0
                        // compute energy production when in convective zone
                        if zone == 1 { ee12 = self.e(d: d12, t: t12) }
                        
                        self.x[self.i] = self.x[self.i-1] + dx
                        self.f[self.i] = self.f[self.i-1] + dx * h12
                        // check whether f is still positive
                        if self.f[self.i] > 0 {
                            let xxx = (-pow(f12, n) - 2 * h12 / x12)
                            self.h[self.i] = self.h[self.i-1] + dx * xxx
                            self.p[self.i] = ptc * pow(self.f[self.i], n + 1)
                            self.d[self.i] = dc * pow(self.f[self.i], n)
                            self.m[self.i] = -4 * Double.pi * dc * pow(rn, 3) * pow(self.x[self.i], 2) * self.h[self.i]
                            self.r[self.i] = rn * self.x[self.i]
                            self.t[self.i] = self.temp(mu: self.mu, p: self.p[self.i], d: self.d[self.i])
                            
                            // compute new value of luminosity when in convective zone
                            if zone == 1 {
                                self.l[self.i] = self.l[self.i-1] + 4 * Double.pi * d12 * dx * ee12 * pow(rn, 3) * pow(x12, 2)
                            } else {
                                self.l[self.i] = self.l[self.i-1]
                            }
                            // compute energy production for new state when in convective
                            // zone. In radiative zone, ee is put to 1, so that log(ee) becomes 0
                            if zone == 1 {
                                self.ee[self.i] = self.e(d: self.d[self.i], t: self.t[self.i])
                            } else {
                                self.ee[self.i] = 1
                            }
                        } else {
                            surface = 1 // surface has been reached}
                        }
                    } else {
                        surface = 1 // surface has been reached}
                    }
                    // check if in convective zone
                    if zone == 1 {
                        let test = 1.339944e9 * self.p[self.i] / self.m[self.i] * self.l[self.i] / pow(self.t[self.i], 4) / fb
                        // check if boundary of convective zone is reached
                        if test < 1 {
                            // compute fitting parameters
                            self.f[self.i] = ffit
                            ptc = self.p[self.i] / pow(ffit, 4)
                            dc = self.d[self.i] / pow(ffit, 3)
                            rn = sqrt(ptc / Double.pi / self.g / pow(dc, 2))
                            self.x[self.i] = self.r[self.i] / rn
                            self.h[self.i] = -self.m[self.i] / 4.0 / Double.pi / dc / pow(rn, 3) / pow(self.x[self.i], 2)
                            n = 3.0
                            dx = 0.04
                            stp = 1
                            surface = 0
                            xfit = self.x[self.i]
                            hfit = self.h[self.i]
                            
                            self.lblCentPress.text = " " + String(format:"%.2e", ptc)
                            self.lblCentDens.text = " " + String(format:"%.4f", dc)
                            self.lblxfit.text = " " + String(format:"%.9f", xfit)
                            self.lblffit.text = " " + String(format:"%.9f", ffit)
                            self.lblhfit.text = " " + String(format:"%.9f", hfit)
                            self.lblDistUnit.text = " " + String(format:"%.2e", rn)
                        }
                    } else {
                        dx = 1.1 * dx
                        // check if surface is reached
                        if surface == 1 {
                            // compute exact location of surface and surface data
                            stp = 1
                            self.i=self.i-1
                            let xs = self.x[self.i] - flast / self.h[self.i]
                            mt = self.m[self.i] + 0.5 * Double.pi * self.d[self.i] * pow(rn, 3) * pow(self.x[self.i] + xs, 2)
                            rad = self.r[self.i] + rn * (xs - self.x[self.i])
                            logteff = 3.7613 + 0.25 * log10(self.l[self.i] / self.L0) - 0.5 * log10(rad / self.R0)
                            
                            self.lblMass.text = " " + String(format:"%.4f", mt/self.M0)
                            self.lblRadius.text = " " + String(format:"%.4f", rad/self.R0)
                            self.lblLumino.text = " " + String(format:"%.4f", log10(self.l[self.i] / self.L0))
                            self.lblEffTemp.text = " " + String(format:"%.4f", logteff)
                        }
                    }
                    self.i = self.i + 1
                }
            }
            self.i=self.i-1//garip bir şekilde fazladan 1 iterasyon yapıyor sebebini anlamadım -1 o yüzden
            self.lblIterCount.text = " " + String(format:"%i", self.i)
            self.tblHomogen.reloadData()
            
            // sonuçları dosyaya kaydetme
            var csvText = "Homogeneous Stellar Model\n\n--Initial Values--\nMass (M0):,\(self.mass)\n\n--Iterations--\ni,Mr/Mo,log(p),log(T),log(d),r/r0,log(E),log(L),X(n),F(n),H(n)\n"
            
            for n in 0...self.i {
                let newLine = "\(n),\(self.m[n]/self.M0),\(log10(self.p[n])),\(log10(self.t[n])),\(log10(self.d[n])),\(self.r[n]/self.R0),\(log10(self.ee[n])),\(log10(self.l[n]/self.L0)),\(self.x[n]),\(self.f[n]),\(self.h[n])\n"
                csvText.append(contentsOf: newLine)
            }
            let results = "\n--Results--\nIteration Count (i):,\(self.i)\nCentral Pressure (Pc) (dyn/cm2):,\(ptc)\nCentral Density (⍴c) (gr/cm3):,\(dc)\nxfit:,\(xfit)\nffit:,\(ffit)\nhfit:,\(hfit)\nDistance Unit (rn):,\(rn)\nMass (M0):,\(mt/self.M0)\nRadius (R0):,\(rad/self.R0)\nLuminosity (log(L/L0)):,\(log10(self.l[self.i] / self.L0))\nEff. Temp.(log):,\(logteff)"
            csvText.append(contentsOf: results)
            
            do {
                try csvText.write(to: self.path, atomically: true, encoding: String.Encoding.utf8)
                self.btExpResults.isHidden = false
            } catch {self.btExpResults.isHidden = true}
            
            self.aiActIndic.stopAnimating()
        } //DispatchQueue.main.asyncAfter sonu
    }
    // computes the energy production for given density d and temperature t
    func e(d: Double, t: Double) -> Double {
        let tt = exp(1 / 3.0 * log(t / 1e9));
        let p1 = 1 + tt * ( 0.133 + tt * (1.09 + tt * 0.938));
        let p2 = 1 + tt * (0.027 + tt * (-0.788 + tt * (-0.149 + tt * (0.261 + tt * 0.127))));
        let e1 = 23760.0 / pow(tt, 2) * p1 * exp(-3.38 / tt);
        let e2 = 8.6665e25 / pow(tt, 2) * p2 * exp(-15.228 / tt - pow(tt, 6) / 9.5481);
        let xx = 0.7;
        return d * (pow(xx, 2) * e1 + 0.02 * xx * e2);
    }
    // computes pressure, density, mass and distance to the centre starting from the polytrope results (x, f and h) and parameters n, pc and dc
    func poly(n: Double, x: Double, f: Double, h: Double, pc: Double, dc: Double, rn: Double) -> (Double, Double, Double, Double) {
        let p = pc * pow(f, n + 1);
        let d = dc * pow(f, n);
        let mr = -4 * Double.pi * dc * pow(rn, 3) * pow(x, 2) * h;
        let r = rn * x;
        return (p, d, mr, r)
    }
    // solves the equation of state to compute the temperature from the pressure, density and mean molecular weight
    func temp(mu: Double, p: Double, d: Double) -> Double {
        let rgas = 8.314e7;
        let a = 7.56464e-15;
        var tt = mu * p / rgas / d;
        for _ in 1...11 {
            tt = mu / rgas / d * (p - 1 / 3.0 * a * pow(tt, 4))
        }
        return tt
    }
    
    @IBAction func btExpResultsClick(_ sender: Any) {//sonuçları export etme
        Amplitude.instance().logEvent("btExpResultsClickHomogen")
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = sender as? UIView
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return i+1 // i saymaya 0'dan başladığı için satır sayısı 1 fazla olacaktı ama zaten fazladan 1 iterasyon yapıyor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellHomogen", for: indexPath) as? HomogenCell
        if i > 0 { // i=0 ise tabloda hiçbir şey göstermesin
            cell?.lbli.text = String(indexPath.row)
            cell?.lblMrMo.text = String(format:"%.4f", m[indexPath.row]/M0)
            cell?.lbllogp.text = String(format:"%.3f", log10(p[indexPath.row]))
            cell?.lbllogT.text = String(format:"%.2f", log10(t[indexPath.row]))
            cell?.lbllogd.text = String(format:"%.2f", log10(d[indexPath.row]))
            cell?.lblrr0.text = String(format:"%.4f", r[indexPath.row]/R0)
            cell?.lbllogE.text = String(format:"%.2f", log10(ee[indexPath.row]))
            cell?.lbllogL.text = String(format:"%.3f", log10(l[indexPath.row]/L0))
            cell?.lblx.text = String(format:"%.3f", x[indexPath.row])
            cell?.lblf.text = String(format:"%.3f", f[indexPath.row])
            cell?.lblh.text = String(format:"%.2f", h[indexPath.row])}
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
