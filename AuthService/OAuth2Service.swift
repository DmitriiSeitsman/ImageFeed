import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    static let shared = OAuth2Service()
    let oauth2TokenStorage = OAuth2TokenStorage()
    var OAuthToken: String?
    
    init() {}
    
    static func decode(from data: Data) -> Result<OAuthTokenResponseBody, Error> {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(OAuthTokenResponseBody.self, from: data)
            return .success(decodedData)
        } catch {
            print("-->UNABLE TO PARSE JSON<--")
            return .failure(error)
        }
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Swift.Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print(">>> CODE IS THE SAME AS THE LAST ONE <<<")
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        guard let request = makeRequest(code: code) else {
            print(">>> UNABLE TO CREATE REQUEST <<<")
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        let session = URLSession.shared
        let task = session.data(for: request) {result in DispatchQueue.main.async {
            switch result {
            case .success(let data):
                switch OAuth2Service.decode(from: data) {
                case .success(let response):
                    self.oauth2TokenStorage.token = response.accessToken
                    print("""
>>> TOKEN SAVED <<<
\(String(describing: self.oauth2TokenStorage.token))
""")
                    handler(.success(response.accessToken))
                case .failure(let error):
                    print("56 func fetchOAuthToken error: \(String(describing: error))")
                    handler(.failure(error))
                }
            case .failure(let error):
                print("60 func fetchOAuthToken error: \(String(describing: error))")
                handler(.failure(error))
            }
        }
        }
        self.task = task
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
        ) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
