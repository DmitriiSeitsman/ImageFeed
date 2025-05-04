import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case codeError
}

extension URLSession {
    
    func exit () {
            let alertController = UIAlertController(title: "Превышен лимит запросов (код: 403)", message: "Выйдем на время?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { _ in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }))
            UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true)
            return
    }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else if 300 <= statusCode {
                    DispatchQueue.main.async {
                        if statusCode == 403 {
                            print("Превышен лимит запросов на Unsplash. Статус код: \(statusCode)")
                            self.exit()
                            return
                        } else {
                            return
                        }
                    }
                    print("Unsplash server returned status code \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error {
                print("Failed to perform URLRequest with error: \(error)", error.localizedDescription)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("Fail of URLSession")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}

