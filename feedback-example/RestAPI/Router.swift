
import Alamofire

struct Router: URLRequestConvertible {
    let baseURL: String
    let path: String
    let httpMethod: HTTPMethod
    let parameters: Parameters?
    var setUrlParams: Bool = false
    
    func asURLRequest() throws -> URLRequest {
        var urlRequest: URLRequest?
        let url = URL(string: "\(baseURL)/\(path)")!
        urlRequest = URLRequest(url: url)
        
        urlRequest!.httpMethod = httpMethod.rawValue
        urlRequest!.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let params = parameters {
            if (httpMethod == .get || httpMethod == .delete || setUrlParams == true),
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                let percentEncodedQuery = params.map({ "\($0)=\($1)" }).joined(separator: "&")
                urlComponents.percentEncodedQuery = percentEncodedQuery.replacingOccurrences(of: " ", with: "%20")
                urlRequest?.url = urlComponents.url
            } else {
                let bodyData = try JSONSerialization.data(withJSONObject: params, options: [])
                urlRequest!.httpBody = bodyData
            }
        }
        return urlRequest!
    }
}

struct UploadRouter: URLConvertible {
    let baseURL: String
    let path: String
    let parameters: Parameters?
    let attachments: [UploadAttachment]
    
    func asURL() throws -> URL {
        let url = URL(string: "\(baseURL)/\(path)")!
        return url
    }
}

enum MediaType: String {
    case image = "image/jpeg"
    case video = "video/mp4"
    case audio = "audio/mpeg"
}

struct UploadFile {
    var data: Data
    var type: MediaType
    var fileName: String
}

struct UploadAttachment {
    let param: String
    let files: [UploadFile]
}


