import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
}

struct photoPackResponse: Decodable {
    let urls: photoPackURL
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let welcomeDescription: String?
    let isLiked: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case urls = "urls"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
    }
}

struct photoPackURL: Decodable {
    let small: String
    let thumbImage: String
    let largeImage: String
    
    private enum CodingKeys: String, CodingKey {
        case small = "small"
        case thumbImage = "thumb"
        case largeImage = "full"
    }
}
