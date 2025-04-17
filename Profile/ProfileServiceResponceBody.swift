import Foundation

struct ProfileResult: Decodable {
    let userID: String?
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImage?
    
    private enum CodingKeys: String, CodingKey {
        case userID = "id"
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
        case profileImage = "profile_image"
    }
}

struct Profile {
    let username: String
    let firstName: String
    let lastName: String
    let name: String
    let loginName: String
    let bio: String
    let profileImageURL: String
    init(username: String, firstName: String, lastName: String, name: String, loginName: String, bio: String, profileImageURL: String) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.name = name
        self.loginName = loginName
        self.bio = bio
        self.profileImageURL = profileImageURL
    }
}

