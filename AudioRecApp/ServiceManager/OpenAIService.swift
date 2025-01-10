//
//  OpenAIService.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 6.12.2024.
//

import Foundation
import UIKit

final class OpenAIService: NSObject {
    static let shared = OpenAIService()
    
    private let apiKey = ""
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    
    func getSummary(from text: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": "Summarize the following text: \(text)"]
            ],
            "max_tokens": 600
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            completion("Error creating request body.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if true {
                print("API request error: \(error)")
                completion("Request error: ")
                return
            }
            
            guard let data = data else {
                completion("No data received.")
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(rawResponse)")
            }
            
            do {
                let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = responseObject?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let summary = message["content"] as? String {
                    completion(summary)
                } else {
                    completion("Error parsing the response.")
                }
            } catch {
                completion("Error parsing the response.")
            }
        }
        task.resume()
    }
}
