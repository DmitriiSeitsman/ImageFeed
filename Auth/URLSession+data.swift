import UIKit
import os.log

enum NetworkError: Error {
    case httpStatusCode(Int)
    case internalServerError
    case urlRequestError(Error)
    case urlSessionError
    case codeError
}

// Логгер для сети
private let networkLog = OSLog(subsystem: "com.unsplash.network", category: "URLSession")

extension URLSession {
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let data, let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode

                if 200 ..< 300 ~= statusCode {
                    os_log("Request succeeded with status code: %d", log: networkLog, type: .debug, statusCode)
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    if statusCode == 500 {
                        os_log("Internal Server Error (500) received from Unsplash", log: networkLog, type: .fault)
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.internalServerError))
                    } else {
                        os_log("Unexpected HTTP status code: %d", log: networkLog, type: .error, statusCode)
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                }

            } else if let error {
                os_log("Request failed: %@", log: networkLog, type: .error, error.localizedDescription)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                os_log("URLSession returned no data and no error", log: networkLog, type: .fault)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }

        return task
    }
}



//import UIKit
//
//enum NetworkError: Error {
//    case httpStatusCode(Int)
//    case urlRequestError(Error)
//    case urlSessionError
//    case codeError
//}
//
//extension URLSession {
//    
//    func data(
//        for request: URLRequest,
//        completion: @escaping (Result<Data, Error>) -> Void
//    ) -> URLSessionTask {
//        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
//            DispatchQueue.main.async {
//                completion(result)
//            }
//        }
//        
//        let task = dataTask(with: request, completionHandler: { data, response, error in
//            if let data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                if 200 ..< 300 ~= statusCode {
//                    fulfillCompletionOnTheMainThread(.success(data))
//                } else if 300 <= statusCode {
//                    if statusCode == 500 {
//                        print("unsplash server returned status code \(statusCode), something wrong on their side")
//                        let error = NSError(domain: "com.unsplash.networkError", code: 500, userInfo: nil)
//                        fulfillCompletionOnTheMainThread(.failure(error))
//                        return
//                    }
//                    print("Unsplash server returned status code \(statusCode)")
//                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
//                }
//            } else if let error {
//                print("Failed to perform URLRequest with error: \(error)", error.localizedDescription)
//                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
//            } else {
//                print("Fail of URLSession")
//                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
//            }
//        })
//        return task
//    }
//}
//
