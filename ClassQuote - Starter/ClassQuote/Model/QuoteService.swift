//
//  QuoteService.swift
//  ClassQuote
//
//  Created by Déborah Suon on 14/10/2021.
//  Copyright © 2021 OpenClassrooms. All rights reserved.
//

import Foundation


import Foundation

class QuoteService {
    private static let quoteUrl = URL(string: "https://api.forismatic.com/api/1.0/")!
    private static let pictureUrl = URL(string: "https://source.unsplash.com/random/1000x1000")!
    private var task: URLSessionDataTask?
    static var shared = QuoteService()
    private init() {}
    

    func getQuote(callback: @escaping (Bool, Quote?) -> Void) {
        let request = QuoteService.createQuoteRequest()
        let session = URLSession(configuration: .default)

        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
            if let data = data, error == nil {
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    if let responseJSON = try? JSONDecoder().decode([String: String].self, from: data),
                        let text = responseJSON["quoteText"],
                        let author = responseJSON["quoteAuthor"] {
                        self.getImage { (data) in
                            if let data = data {
                                let quote = Quote(text: text, author: author, imageData: data)
                                callback(true, quote)
                            } else {
                                callback(false, nil)
                            }
                        }
                    } else {
                        callback(false, nil)
                    }
                } else {
                    callback(false, nil)
                }
            } else {
                callback(false, nil)
            }
        }
        }
        task?.resume()
    }

    private static func createQuoteRequest() -> URLRequest {
        var request = URLRequest(url: quoteUrl)
        request.httpMethod = "POST"

        let body = "method=getQuote&lang=en&format=json"
        request.httpBody = body.data(using: .utf8)

        return request
    }

    func getImage(completionHandler: @escaping ((Data?) -> Void)) {
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: QuoteService.pictureUrl) { (data, response, error) in
            DispatchQueue.main.async {
            if let data = data, error == nil {
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    completionHandler(data)
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        }
        }
        task?.resume()
    }
}
