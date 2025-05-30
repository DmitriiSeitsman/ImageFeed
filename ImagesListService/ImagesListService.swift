import UIKit

protocol ImagesListServiceProtocol {
    var task: URLSessionTask? { get set }
    var photosFull: [Photo] { get set }
    
    func fetchPhotosNextPage(handler: @escaping (Result<[photoPackResponse], Error>) -> Void)
    func convertPhotosStruct(response: photoPackResponse) -> Photo
    func changeLike(photoId: String, isLike: Bool, _ handler: @escaping (Result<[Photo], Error>) -> Void)
    func clearData()
}

final class ImagesListService: ImagesListServiceProtocol {
    var task: URLSessionTask?
    var photosFull: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private let tokenInStorage = OAuth2TokenStorage.shared.token
    private let usernameInStorage = OAuth2TokenStorage.shared.username
    private var lastLoadedPage: Int = 1
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    func clearData() {
        photosFull.removeAll()
        lastLoadedPage = 1
    }
    
    func fetchPhotosNextPage(handler: @escaping (Swift.Result<[photoPackResponse], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil, let request = makePhotosRequest() else {
            print(">>> UNABLE TO CREATE REQUEST <<<")
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        let task = session.data(for: request) {[weak self] result in
            switch result {
            case .success(let data):
                //print("DATA IS HERE:--->>>>", String(data: data, encoding: .utf8) ?? "NO DATA during PHOTOS REQUEST")
                switch self?.decodePhotos(data) {
                case .success(let response):
                    
                    self?.incrementLastPage()
                    print(">>>>> SUCCESSFULLY DECODED PHOTOS RESPONSE, COUNT OF ARRAY IS: \(response.count) <<<<<")
                    handler(.success(response))
                    
                case .failure(let error):
                    print("func fetchPhotosNextPage error: \(String(describing: error))")
                    handler(.failure(error))
                case .none:
                    print("SELF IS NIL")
                }
            case .failure(let error):
                print("func fetchPhotosNextPage error: \(String(describing: error))")
                handler(.failure(error))
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
    
    func changeLike(photoId: String, isLike: Bool, _ handler: @escaping (Result<[Photo], Error>) -> Void) {
        guard task == nil else {
            print("TASK IS ACTIVE")
            task?.cancel()
            return
        }
        
        let request: URLRequest?
        if isLike {
            request = likeOn(authToken: tokenInStorage, photoId: photoId)
        } else {
            request = likeOff(authToken: tokenInStorage, photoId: photoId)
        }
        
        guard let finalRequest = request else {
            print(">>> UNABLE TO MAKE LIKE REQUEST <<<")
            return
        }
        
        let session = URLSession.shared
        let task = session.data(for: finalRequest) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.changePhotoInArray(photoId: photoId)
                    handler(.success(self?.photosFull ?? []))
                case .failure(let error):
                    print("ERROR AFTER REQUEST")
                    handler(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
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
    
    private func changePhotoInArray(photoId: String) {
        if let index = self.photosFull.firstIndex(where: { $0.id == photoId }) {
            
            let photo = self.photosFull[index]
            
            let newPhoto: [Photo] = [Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                thumbImageURL: photo.thumbImageURL,
                largeImageURL: photo.largeImageURL,
                isLiked: !photo.isLiked
            )]
            
            self.photosFull.remove(at: index)
            self.photosFull.insert(contentsOf: newPhoto, at: index)
            print("OLD LIKE STATUS: /","ID:", photo.id, "/ PROPERTY:", photo.isLiked)
            print("NEW LIKE STATUS: /","ID:",self.photosFull[index].id, "/ PROPERTY:", self.photosFull[index].isLiked)
        }
        return
    }
    
    private func incrementLastPage() {
        lastLoadedPage += 1
        return
    }
    
    private func makePhotosRequest() -> URLRequest? {
        guard let token = tokenInStorage else { return nil }
        print("TOKEN", token as Any)
        print("Last page is:", lastLoadedPage)
        var components = URLComponents(string: Constants.defaultIBaseURLString + "/photos")
        components?.queryItems = [URLQueryItem(name: "page", value: String(lastLoadedPage))]
        
        guard let url = components?.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("REQUEST:", request.description)
        
        return request
    }
    
    private func likeOn(authToken: String?, photoId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")
        else { return nil }
        var request = URLRequest(url: url)
        if let authToken = authToken {
            request.httpMethod = "POST"
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func likeOff(authToken: String?, photoId: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")
        else { return nil }
        var request = URLRequest(url: url)
        if let authToken = authToken {
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
}

