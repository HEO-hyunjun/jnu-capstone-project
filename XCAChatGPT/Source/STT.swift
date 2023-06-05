import Foundation
import Alamofire
//(1) 라이브러리 추가

class STT {
    
    static let shared = STT()
//(2)싱글통 객체를 선언해서 앱 어디에서든지 접근가능하도록 한다
    private init() {}
    
    func getText(data:Data, lang:String, completion: @escaping(Any)->Void)
    {
        var url=APIConstants.getSTTURL
        if(lang=="eng"){url+="/eng"}
        //HTTP Headers : 요청 헤더
        let header : HTTPHeaders = ["Content-Type" : "multipart/form-data"]
        
        AF.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(data, withName: "file", fileName: "file.m4a", mimeType: "audio/mpeg")
        }, to: url, method: .post, headers: header).response{ response in
                let responseString = String(data: response.data ?? Data(), encoding: .utf8)
                //print("\(responseString!)")
                completion(responseString ?? "없는데용?!@!@")
            
        }
    }
        
    
}
