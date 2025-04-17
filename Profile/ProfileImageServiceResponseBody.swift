import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage?
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let small: String?
    let medium: String?
    let large: String?
    
    private enum CodingKeys: String, CodingKey {
        case small = "small"
        case medium = "medium"
        case large = "large"
    }
}
