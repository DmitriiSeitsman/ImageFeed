import Foundation

struct OAuthTokenResponseBody : Decodable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    let scope: String
    let createdAt: Date?
    let userID: Int
    let username: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope = "scope"
        case createdAt = "created_at"
        case userID = "user_id"
        case username = "username"
    }
}
