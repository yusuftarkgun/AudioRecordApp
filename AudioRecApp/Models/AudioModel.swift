//
//  AudioModel.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 8.12.2024.
//

import Firebase
import UIKit
import FirebaseFirestore

struct AudioModel: Codable {
    let summary: String?
    let speech: String?
    let audioDownloadURL: String?
    let updatedAt: Date?
    let id: String?


    enum CodingKeys: String, CodingKey {
        case summary
        case speech
        case audioDownloadURL
        case updatedAt
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        speech = try container.decodeIfPresent(String.self, forKey: .speech)
        audioDownloadURL = try container.decodeIfPresent(String.self, forKey: .audioDownloadURL)
        id = try container.decodeIfPresent(String.self, forKey: .id)

        if let timestamp = try container.decodeIfPresent(Timestamp.self, forKey: .updatedAt) {
            updatedAt = timestamp.dateValue()
        } else {
            updatedAt = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(summary, forKey: .summary)
        try container.encode(speech, forKey: .speech)
        try container.encode(audioDownloadURL, forKey: .audioDownloadURL)

        if let updatedAt = updatedAt {
            let timestamp = Timestamp(date: updatedAt)
            try container.encode(timestamp, forKey: .updatedAt)
        }
    }
}
