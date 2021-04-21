//
//  ApiViewController.swift
//  FinanceApp
//
//  Created by Elena Nazarova on 15.04.2021.
//

import UIKit
import Alamofire
import SwiftyJSON
public var nowDate = Date()

class ApiViewController: UIViewController {
    //currencyscoop
    

   //"https://api.nomics.com/v1/
    
//    let endpoint_ = "convert"
    
    
    let dateFormatter = DateFormatter()
    let utcISODateFormatter = ISO8601DateFormatter()
    let ISO8601Formatter = ISO8601DateFormatter()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    // currency labels
    @IBOutlet weak var usd: UILabel!
    @IBOutlet weak var eur: UILabel!
    @IBOutlet weak var jpy: UILabel!
    @IBOutlet weak var gbp: UILabel!
    @IBOutlet weak var chf: UILabel!
    @IBOutlet weak var cad: UILabel!
    
    @IBOutlet weak var btc: UILabel!
    @IBOutlet weak var eth: UILabel!
    @IBOutlet weak var ltc: UILabel!
    @IBOutlet weak var xlm: UILabel!
    @IBOutlet weak var dot: UILabel!
    @IBOutlet weak var xrp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchRates()
        fetchCrypto()
    }
    
    func fetchRates() {
        let apiKey = "24e5830a39d7446448c5ce14133d5e54"
        let endpoint = "latest"
        let baseURL = "https://api.currencyscoop.com/v1/"
        
        let labels = [usd,eur,jpy,gbp,chf,cad]
        let bases = ["USD","EUR","JPY","GBP","CHF","CAD"]
        let symbols = "RUB"
        
        for i in 0..<bases.count {
            let url = baseURL+endpoint+"?api_key="+apiKey+"&base="+bases[i]+"&symbols="+symbols
            let request = AF.request(url, method: .get)
            request.responseJSON { [self] (response) in
                if let data = response.data {
                    if let jsonData = try? JSON(data: data) {
                        labels[i]?.text = String(jsonData["response"]["rates"]["RUB"].doubleValue.formattedWithSeparator) + " rub"
                        let utcDate = utcISODateFormatter.date(from: jsonData["response"]["date"].string!)
                        nowDate = utcDate ?? Date()
                        
                        dateFormatter.dateFormat = "d MMMM, yyyy, E" // 14 April, 2021, Thu
                        dateLabel.text = dateFormatter.string(from: utcDate!)
                        
                        dateFormatter.dateFormat = "HH:mm" // 15:20:40
                        timeLabel.text = dateFormatter.string(from: utcDate!)
                    }
                }
            }
        }
    }
    
    func fetchCrypto() {
        let baseURL = "https://rest.coinapi.io/v1/"
        let endpoint = "exchangerate/"
        let apiKey = "2F914509-A68C-4ABD-B915-6322841B26BF"
    
        let labels = [btc,eth,ltc,xlm,dot,xrp]
        let from = ["BTC","ETH","LTC","XLM","DOT","XRP"]
        let to = "RUB"
        
        for i in 0..<from.count {
            let url = baseURL+endpoint+from[i]+"/"+to+"?apikey="+apiKey
            let request = AF.request(url, method: .get)
            request.responseJSON { (response) in
                if let data = response.data {
                    if let jsonData = try? JSON(data: data) {
                        print(jsonData)
                        labels[i]?.text = String(jsonData["rate"].doubleValue.formattedWithSeparator) + " rub"
                    }
                }
            }
        }
    }
    

}
