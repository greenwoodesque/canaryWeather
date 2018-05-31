//
//  WebServices.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/26/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import Foundation

let API_KEY = "9bc30c86ac4193c9cb8b0e4886e48027"

let forecastEndpointBase = "https://api.darksky.net/forecast/\(API_KEY)/"
let forecastEndpointExclusions = "exclude=currently,minutely,hourly,alerts,flags"

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

final class Webservice {
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { data, _, _ in
            let result = data.flatMap(resource.parse)
            completion(result)
            }.resume()
    }
}


