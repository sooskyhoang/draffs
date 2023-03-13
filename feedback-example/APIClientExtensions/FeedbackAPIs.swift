//
//  ChatGPTFeedback.swift
//  chatGPT2
//
//  Created by nguyen van hoang on 10/03/2023.
//

import Alamofire
import SVProgressHUD

extension APIClient {
    
    static func sendFeedback(yourEmail : String, feedBack : String, uploadFiles: [UploadFile] = [],  completion: @escaping (ResponseModel<ChatFeedbackData>?) -> Void) {
        
        var params = Parameters()
        params["project_id"] = 10
        params["device_id"] = KeychainManager.shared.getDeviceIdentifier()
        params["device_name"] = UIDevice.current.name
        params["device_model"] = UIDevice.modelName
        params["software_version"] = UIDevice.current.systemVersion
        params["user_name"] = ""
        params["user_email"] = yourEmail
        params["problem_description"] = feedBack
        
        var attachments: [UploadAttachment] = []
        if !uploadFiles.isEmpty {
            attachments.append(UploadAttachment(param: "attachment", files: uploadFiles))
        }
        
        let router = UploadRouter(baseURL: AppManager.shared.feedbackBaseURL, path: "api/createFeedback", parameters: params, attachments: attachments)
        
        SVProgressHUD.show()
        
        upload(router: router, classType: ResponseModel<ChatFeedbackData>.self) { result in
            SVProgressHUD.dismiss()
            
            switch result {
            case .failure(let errorMessage):
                print(errorMessage)
            case .success(let data):
                completion(data)
            }
        }
    }
}

