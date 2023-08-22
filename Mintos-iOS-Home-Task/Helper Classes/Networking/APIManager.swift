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
            
//            do {
//                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
//                completion(.success(decodedResponse))
//            } catch let error {
//                print(error)
//                if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? T {
//                    completion(.success(jsonData))
//                } else {
//                    completion(.failure(APIError.decodingError))
//                }
//                completion(.failure(APIError.decodingError))
//            }
            
            
            
            
            
            
            do {
                let jsonData = """
                {
                  "response": {
                    "paymentDetails": "Investor ID: 54361338",
                    "items": [
                      {
                        "bank": "Acme Bank",
                        "swift": "ACMEUS33",
                        "currency": "EUR",
                        "beneficiaryName": "AS Mintos Marketplace",
                        "beneficiaryBankAddress": "10 Rue de la Paix, 75002 Paris, France",
                        "iban": "GB29NWBK60161331926819"
                      },
                      {
                        "bank": "City Bank",
                        "swift": "eqweqweqwe",
                        "currency": "USD",
                        "beneficiaryName": "AS Mintos Marketplace",
                        "beneficiaryBankAddress": "123 Main Street, New York, NY, USA",
                        "iban": "US12345678901234567890"
                      },
                {
                        "bank": "City Bank",
                        "swift": "CITdasdsadasdIUS33",
                        "currency": "USD",
                        "beneficiaryName": "AS Mintos Marketplace",
                        "beneficiaryBankAddress": "123 Main Street, New York, NY, USA",
                        "iban": "US12345678901234567890"
                      },
                                      {
                                        "bank": "City Bank",
                                        "swift": "CITIUS33",
                                        "currency": "USD",
                                        "beneficiaryName": "AS Mintos Marketplace",
                                        "beneficiaryBankAddress": "123 Main Street, New York, NY, USA",
                                        "iban": "4324234234234"
                                      },
                      {
                        "bank": "EuroBank Poland",
                        "swift": "EURBPLPW",
                        "currency": "PLN",
                        "beneficiaryName": "AS Mintos Marketplace",
                        "beneficiaryBankAddress": "567 Maple Avenue, Warsaw, Poland",
                        "iban": "PL87654321098765432109"
                      }
                    ]
                  }
                }
                """.data(using: .utf8)!
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: jsonData)
                completion(.success(response))
            } catch {
                print("Error decoding JSON: \(error)")
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
