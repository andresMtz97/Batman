//
//  DataManager.swift
//  Batman
//
//  Created by DISMOV on 15/06/24.
//

import Foundation
import CoreLocation

class DataManager: NSObject {
    let baseUrl = "http://janzelaznog.com/DDAM/iOS/"
    
    func getLocations(completion: @escaping ([CLLocationCoordinate2D]?) -> Void) {
        let urlStr = baseUrl + "BatmanLocations.json"
        
        if let url = URL(string: urlStr) {
            let request = URLRequest(url: url)
            let sessionConf = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: sessionConf)
            let task = session.dataTask(with: request) { data, response, error in
                if error == nil {
                    do{
                        let array = try JSONSerialization.jsonObject(with: data!) as! [[String : Double]]
                        var coordArray = [CLLocationCoordinate2D]()
                        for item in array {
                            let coord = CLLocationCoordinate2D(latitude: item["latitud"] ?? 0.0, longitude: item["longitud"] ?? 0.00)
                            coordArray.append(coord)
                        }
                        completion(coordArray)
                    } catch {
                        print("no se pudo convertir el json a coordenadas")
                        completion(nil)
                    }
                }
                
            }
            
            task.resume()
        }
    }
}
