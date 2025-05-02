import UIKit
import Kingfisher

final class ProfileImageService {
    
    private(set) var avatarURL: String?
    private var usernameInStorage = OAuth2TokenStorage.shared.username
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private init() {}
    
    
    func fetchProfileImageURL(authToken: String?, username: String?, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let authToken = authToken,
              let username = username  else {
            return
        }
        
        guard let request = makeImageRequest(authToken: authToken, username: username) else {
            print("func fetchProfileImageURL: Request failed")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let session = URLSession.shared
        let task = session.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    switch ProfileImageService.shared.decodeImage(data) {
                    case .success(let response):
                        guard let profileImage = response.profileImage else { return }
                        self.avatarURL = profileImage.medium
                        let profileImageURL = self.avatarURL as Any
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": profileImageURL])
                        completion(.success(String(describing: self.avatarURL)))
                    case .failure(let error):
                        print("func fetchProfile error: \(String(describing: error))")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("func fetchProfile error: \(String(describing: error))")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task .resume()
    }
    
    private func decodeImage(_ data: Data)  -> Result<UserResult, Error>  {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(UserResult.self, from: data)
            return .success(decodedData)
        } catch {
            print("-->UNABLE TO PARSE IMAGE FROM JSON<--")
            return .failure(error)
        }
    }
    
    private func makeImageRequest(authToken: String?, username: String?) -> URLRequest? {
        let url = URL(string: "https://api.unsplash.com/users/\(username ?? "no username in storage")")
        var request = URLRequest(url: url!)
        if let authToken = authToken {
            request.httpMethod = "GET"
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
