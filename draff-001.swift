@objc func updateNetworkLog(notification: NSNotification) {
        if let response = notification.userInfo?["response"] as? URLResponse {
            DispatchQueue.main.async {
                // Edit for logging video url
                if !self.resposes.contains(response) {
                    if response.mimeType == "application/vnd.apple.mpegurl" ||
                    response.mimeType == "application/x-mpegurl" ||
                    (response.mimeType?.contains("video/") ?? false) {
                        print("xxx: \(String(describing: response.mimeType)) \(String(describing: response.url?.absoluteString))")
//                        self.resposes.append(response)
//                        self.tableView.reloadData()
                    }
                }
                
                // Origin
                self.resposes.append(response)
                self.tableView.reloadData()
            }
        }
    }
