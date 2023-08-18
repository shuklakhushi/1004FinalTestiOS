//
//  Songs.swift
//  MDEV1004-FinalTestiOS
//
//  Created by Khushi Shukla on 2023-08-18.
//

import Foundation

struct Songs: Codable {
    var documentID: String?
    var songID: Int
    var title: String
    var album: String
    var artist: String
    var composer: String
    var duration: String
    var genre: String
    var label: String
    var rating: Double
    var releaseDate: String
    var trackNumber: Int
    var youtubeLink: String
}
