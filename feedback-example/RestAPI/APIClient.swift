
import Alamofire

public enum ServerResponse<T: Codable> {
    case success(T)
    case failure(String)
}

class APIClient: NSObject {
    static func request<T: Codable>(router: Router, classType: T.Type, completion: @escaping (ServerResponse<T>) -> Void) {
        
        AF.request(router).validate(statusCode: 200..<300).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decode = JSONDecoder()
                    let result = try decode.decode(classType, from: data)
                    
                    completion(.success(result))
                } catch {
                    completion(.failure("Json Decode Error"))
                }
            case let .failure(error):
                completion(.failure(error.localizedDescription))
            }
        }
        
    }
    
    static func upload<T: Codable>(router: UploadRouter, classType: T.Type, completion: @escaping (ServerResponse<T>) -> Void) {
        
        AF.upload(multipartFormData: { multipartFormData in
            if let params = router.parameters {
                for (key, value) in params {
                    if let stringValue = value as? String {
                        multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                    }
                    
                    if let stringValue = value as? Int {
                        multipartFormData.append("\(stringValue)".data(using: .utf8)!, withName: key)
                    }
                    
                    if let stringValue = value as? Double {
                        multipartFormData.append("\(stringValue)".data(using: .utf8)!, withName: key)
                    }
                }
            }
            
            for attachment in router.attachments {
                for file in attachment.files {
                    multipartFormData.append(file.data, withName: attachment.param , fileName: file.fileName, mimeType: file.type.rawValue)
                }
            }
            
        }, to: router).validate(statusCode: 200..<300).responseData(completionHandler: { response in
            switch response.result {
            case .success(let data):
                do {
                    let decode = JSONDecoder()
                    let result = try decode.decode(classType, from: data)
                    
                    completion(.success(result))
                } catch {
                    completion(.failure("Json Decode Error"))
                }
            case let .failure(error):
                completion(.failure(error.localizedDescription))
            }
        })
    }
}


