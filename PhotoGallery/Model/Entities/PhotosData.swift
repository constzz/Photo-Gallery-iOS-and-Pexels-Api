import Foundation
import RealmSwift

// MARK: - PhotosData
class PhotosData: Codable {
    var page: Int
    var perPage: Int
    var photos: [Photo]
    var totalResults: Int
    var nextPage: String

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case photos
        case totalResults = "total_results"
        case nextPage = "next_page"
    }
}

// MARK: - Photo
class Photo: Object, Codable {
    var id: Int
    var width: Int
    var height: Int
    var url: String
    var photographer: String
    var photographerURL: String
    var photographerID: Int
    var avgColor: String
    @Persisted var src: Src?
    var liked: Bool
    var alt: String
    var isDataCached: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer
        case photographerURL = "photographer_url"
        case photographerID = "photographer_id"
        case avgColor = "avg_color"
        case src, liked, alt
    }
}

// MARK: - Src
class Src: Object, Codable {
    @Persisted var original: String
    var large2X: String
    var large: String
    @Persisted var medium: String
    var small: String
    var portrait: String
    var landscape: String
    var tiny: String

    enum CodingKeys: String, CodingKey {
        case original
        case large2X = "large2x"
        case large, medium, small, portrait, landscape, tiny
    }
}
