import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    var task: URLSessionTask?
    var photosFull: [Photo] = []
    private let tokenInStorage = OAuth2TokenStorage().token
    private var lastLoadedPage = 1
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    func fetchPhotosNextPage(handler: @escaping (Swift.Result<[photoPackResponse], Error>) -> Void) {
        
        guard task == nil, let request = makePhotosRequest() else {
            print(">>> UNABLE TO CREATE REQUEST <<<")
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        let task = session.data(for: request) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    //print("DATA IS HERE:--->>>>", String(data: data, encoding: .utf8) ?? "NO DATA during PHOTOS REQUEST")
                    switch ImagesListService().decodePhotos(data) {
                    case .success(let response):
                        print(">>>>> SUCCESSFULLY DECODED PHOTOS RESPONSE, COUNT OF ARRAY IS: \(response.count) <<<<<")
                        self?.lastLoadedPage += 1
                        handler(.success(response))
                    case .failure(let error):
                        print("func fetchPhotosNextPage error: \(String(describing: error))")
                        handler(.failure(error))
                    }
                case .failure(let error):
                    print("func fetchPhotosNextPage error: \(String(describing: error))")
                    handler(.failure(error))
                }
            }
            self?.task = nil
        }
        self.task = task
        task .resume()
    }
    
    func convertPhotosStruct (response: photoPackResponse) -> Photo {
        let date: Date? = dateFormatter.date(from: response.createdAt)
        return Photo(
            id: response.id,
            size: CGSize(width: response.width, height: response.height),
            createdAt: date,
            welcomeDescription: response.welcomeDescription ?? "No description",
            thumbImageURL: response.urls.thumbImage,
            largeImageURL: response.urls.largeImage,
            isLiked: response.isLiked
        )
    }
    
    private func decodePhotos(_ data: Data)  -> Result<[photoPackResponse], Error>  {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([photoPackResponse].self, from: data)
            return .success(decodedData)
        } catch {
            print("-->UNABLE TO PARSE IMAGE FROM JSON<--")
            return .failure(error)
        }
    }
    
    private func makePhotosRequest() -> URLRequest? {
        guard let username = ProfileService.shared.profile?.username else { return nil }
        var components = URLComponents(string: Constants.defaultIBaseURLString + "/users/\(username)" + "/photos")
        components?.queryItems = [URLQueryItem(name: "page", value: String(lastLoadedPage))]
        
        guard let url = components?.url, let token = tokenInStorage else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
}
