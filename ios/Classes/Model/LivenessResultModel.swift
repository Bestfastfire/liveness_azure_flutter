class LivenessResultModel: Codable{
    var livenessStatus: String?
    var failureReason: String?
    var verificationStatus: String?
    var confidence: Float?
    var resultId: String?
    var digest: String?
    var faceUID: String?
    
    init(livenessStatus: String?,
         failureReason: String?,
         verificationStatus: String?,
         confidence: Float?,
         resultId: String?,
         digest: String?,
         faceUID: String?) {
        
        self.livenessStatus = livenessStatus
        self.failureReason = failureReason
        self.verificationStatus = verificationStatus
        self.confidence = confidence
        self.resultId = resultId
        self.digest = digest
        self.faceUID = faceUID
    }
}
