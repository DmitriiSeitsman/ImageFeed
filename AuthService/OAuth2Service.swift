import UIKit

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
    
    func fetchOAuthToken(code: String, handler: @escaping (Swift.Result<String, Error>) -> Void) {
        guard let request = makeRequest(code: code) else {
            return
        }
        let session = URLSession.shared
        let task = session.data(for: request) {result in switch result {
            case .success(let data):
            switch OAuth2Service.decode(from: data) {
            case .success(let response):
                print ("SUCCESS, ACCESS TOKEN: ---> \(response.accessToken)")
                self.oauth2TokenStorage.token = response.accessToken
                print("Actual TOKEN in storage:", self.oauth2TokenStorage.token)
                handler(.success(response.accessToken))
            case .failure(let error):
                print("error: \(String(describing: error))")
                handler(.failure(error))
            }
            case .failure(let error):
            print("error: \(String(describing: error))")
                handler(.failure(error))
            }
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
