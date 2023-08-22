//
//  APIManager.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 18/08/2023.
//

import Foundation
class APIManager {
    private var session: URLSession!
    private var dataTask: URLSessionDataTask?
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    
    var method: HTTPMethod
    var path: String
    
    init<T: TargetType>(targetData: T) {
        self.method = targetData.method
        self.path = targetData.path
        
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration)
        print("method:-\(self.method.rawValue)\n URL: \(ApisURL.baseURl + targetData.path)")
    }
    
    func executeRequest<T>(completion: @escaping (Result<T, Error>) -> Void) where T: Codable {
        
        guard let url = buildURL() else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        
        
        dataTask = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            let receviedData = String(data: data, encoding: .utf8) ?? ""
            print("recevied data: \(receviedData)")
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("\n Status code: \(String(describing: statusCode))")
                
                if !(200...299).contains(statusCode) {
                    completion(.failure(APIError.statusCodeError(statusCode)))
                    return
                }
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch let error {
                print(error)
                if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? T {
                    completion(.success(jsonData))
                } else {
                    completion(.failure(APIError.decodingError))
                }
                completion(.failure(APIError.decodingError))
            }
        }
        
        dataTask?.resume()
        
    }
    
    private func buildURL() -> URL? {
        var urlComponents = URLComponents(string: ApisURL.baseURl)
        urlComponents?.path = self.path
        return urlComponents?.url
    }
}
enum APIError: Error {
    case invalidURL
    case serializationError
    case noData
    case decodingError
    case statusCodeError(Int) // New case to handle status code errors
    case errorMsg(String)
    var errorMessage: String? {
        switch self {
        case .errorMsg(let message):
            return message
        default:
            return nil
        }
    }
}

protocol TargetType {
    
    var path: String { get }
    var method: HTTPMethod { get }
}
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    // Add more if needed
}
