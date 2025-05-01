import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var usernameInStorage = OAuth2TokenStorage().username
    private let profileViewController = ProfileViewController()
    private var authToken = OAuth2TokenStorage().token
    private(set) var profile: Profile?
    private init() {}
    
    func fetchProfile(_ authToken: String?, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let authToken = authToken else {
            return
        }
        guard let request = makeProfileRequest(authToken: authToken) else {
            print("func fetchProfile: Request failed")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let session = URLSession.shared
        
        let task = session.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
            switch result {
            case .success(let data):
                switch ProfileService().decodeProfile(data) {
                case .success(let response):
                    self?.usernameInStorage = response.username ?? ""
                    let result = ProfileService().convertStruct(profile: response)
                    self?.profile = result
                    print("USERNAME IN STORAGE:", self?.usernameInStorage ?? "USERNAME DIDN't SAVED")
                    ProfileImageService.shared.fetchProfileImageURL(authToken: authToken, username: self?.usernameInStorage) { _ in }
                    completion(.success(result))
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
    
    private func convertStruct (profile: ProfileResult) -> Profile {
        Profile(
            username: profile.username ?? "",
            firstName: profile.firstName ?? "",
            lastName: profile.lastName ?? "",
            name: "\(String(describing: profile.firstName)) \(String(describing: profile.lastName))",
            loginName: "@\(profile.username ?? "")",
            bio: profile.bio ?? "",
            profileImageURL: profile.profileImage?.medium ?? ""
        )
    }
    
    private func decodeProfile(_ data: Data)  -> Result<ProfileResult, Error>  {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ProfileResult.self, from: data)
            return .success(decodedData)
        } catch {
            print("-->UNABLE TO PARSE JSON<--")
            return .failure(error)
        }
    }
    
    private func makeProfileRequest(authToken: String?) -> URLRequest? {
        let url = URL(string: "https://api.unsplash.com/me")
        var request = URLRequest(url: url!)
        if let authToken = authToken {
            request.httpMethod = "GET"
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
