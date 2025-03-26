import UIKit

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

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    let oauth2TokenStorage = OAuth2TokenStorage()
    var OAuthToken: String?
    
    init() {}
    
    static func decode(from data: Data) -> Result<OAuthTokenResponseBody, Error> {
        
        let decoder = JSONDecoder()
        do {
            print("INFO:", String(data: data, encoding: .utf8) ?? "NOT POSSIBLE")
            let decodedData = try decoder.decode(OAuthTokenResponseBody.self, from: data)
            return .success(decodedData)
        } catch {
            print("-->UNABLE TO PARSE JSON<--")
            return .failure(error)
        }
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<Data, Error>) -> Void) {
        guard let request = makeRequest(code: code) else {
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            guard let data = data else { return }
            switch OAuth2Service.decode(from: data) {
            case .success(let response):
                print ("SUCCESS, ACCESS TOKEN: ---> \(response.accessToken)")
                self.oauth2TokenStorage.token = response.accessToken
                print("Actual TOKEN in storage:", self.oauth2TokenStorage.token)
                handler(.success(data))
            case .failure(let error):
                handler(.failure(error))
            }
            handler(.success(data))
        }
        task .resume()
    }
    
    func makeRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else { return nil }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
