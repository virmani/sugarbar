//
//  BloodSugarFetcher.swift
//  sugarbar
//
//  Created by Ashish Virmani on 7/18/15.
//  Copyright (c) 2015 Ashish Virmani. All rights reserved.
//

import SwiftyJSON
import SwiftHTTP

class BloodSugarFetcher {
    var nighscoutDomain: String
    var httpProtocol: String

    let STATUS = "status"
    let NOW = "now"
    let BGS = "bgs"
    let SGV = "sgv"
    let DIRECTION = "direction"
    let TIME = "datetime"
    let MIN_BG: Double = 20
    

    init(domain: String) {
        //TODO: check to make sure that this is nightscout domain
        nighscoutDomain = domain
        httpProtocol = "http"
    }
    
    func refreshBloodSugar(successClosure: (String, String) -> ()) {
        var request = HTTPTask()
        var pebbleUrl = httpProtocol + "://" + nighscoutDomain + "/pebble"
        request.GET(pebbleUrl, parameters: ["a": "a"], completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                println("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            if let data = response.responseObject as? NSData {
                let json = JSON(data: data)
                
                var bloodSugar = "NC"
                if(self.isValueComputable(json)) {
                    if let bs = json[self.BGS][0][self.SGV].string{
                        bloodSugar = bs
                    }
                }
                
                var trendArrow = "~"
                if let trendDesc = json[self.BGS][0][self.DIRECTION].string{
                    trendArrow = self.trendArrow(trendDesc)
                }
                
                successClosure(bloodSugar, trendArrow)
            }
        })
    }
    
    private func isValueComputable(json: JSON) -> Bool {
        var isComputable = true;
        if let sgv = json[self.BGS][0][self.SGV].string{
            isComputable = isComputable && (sgv.toInt() != nil)
        } else {
            isComputable = isComputable && false
        }
        
        return isComputable
    }
    
    private func trendArrow(str: String) -> String {
        var arrow = "?"
        switch str {
        case "Flat":
            arrow = "→"
        case "FortyFiveDown":
            arrow = "↘"
        case "FortyFiveUp":
            arrow = "↗"
        case "SingleUp":
            arrow = "↑"
        case "SingleDown":
            arrow = "↓"
        case "DoubleUp":
            arrow = "↑↑"
        case "DoubleDown":
            arrow = "↓↓"
        case "NOT COMPUTABLE":
            arrow = "NC"
        default:
            arrow = "?"
        }

        return arrow
    }
}