import UIKit
import Foundation

class ViewController {
    static let shared = ViewController()

    var myButton: UIButton!
    
    //
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //    }
    
    
    var question: [String] = []
    func questionList(category:String) async->[String]{
        await getQuestion(from:category){ret in
            self.question=ret
        }
        return question
    }
    // 서버 통신 코드를 실제로 뷰 컨트롤러에서 호출해서 사용하는 부분입니다.
    //    func getQuestion() -> [String] {
    //        var ret: [String] = []
    //        // 각각의 텍스트 필드의 있는 값을 받아옵니다.
    ////        guard let name = nameTextField.text else { return }
    ////        guard let email = emailTextField.text else { return }
    ////        guard let password = passwordTextField.text else { return }
    //
    //        // 서버 통신 서비스 코드를 싱글톤 변수를 통해서 접근하고 있네요.
    //        // 호출 후에 받은 응답을 가지고, 적절한 처리를 해주고 있습니다.
    //        GetQuestion.shared.getQuestion(
    //            ) { response in
    //            switch response {
    //            case .success(let data):
    //                guard let data = data as? QuestionResponse else { return }
    //                for questionData in data.question {
    //                       print(questionData.question)
    //                    ret.append(questionData.question)
    //                   }
    //            case .requestErr(let err):
    //                print(err)
    //            case .pathErr:
    //                print("pathErr")
    //            case .serverErr:
    //                print("serverErr")
    //            case .networkFail:
    //                print("networkFail")
    //            }
    //
    //        }
    //        return ret
    //    }
    //
    func getQuestion(from category:String,completion: @escaping ([String]) -> Void)async {
        var ret: [String] = []
        
        GetQuestion.shared.getQuestion(from:category) { response in
            switch response {
            case .success(let data):
                guard let data = data as? QuestionResponse else {
                    completion(ret) // Return the populated `ret` array
                    return
                }
                for questionData in data.question {
//                    print(questionData.question)
                    ret.append(questionData.question)
                }
                completion(ret) // Return the populated `ret` array
            case .requestErr(let err):
                print(err)
                completion(ret) // Return the empty `ret` array
            case .pathErr:
                print("pathErr")
                completion(ret) // Return the empty `ret` array
            case .serverErr:
                print("serverErr")
                completion(ret) // Return the empty `ret` array
            case .networkFail:
                print("networkFail")
                completion(ret) // Return the empty `ret` array
            }
        }
    }
    
    
    // 알림창을 띄우는 함수입니다.
    //    func alert(message: String) {
    //        let alertVC = UIAlertController(title: message, message: nil, preferredStyle: .alert)
    //        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
    //        alertVC.addAction(okAction)
    //        present(alertVC, animated: true)
    //    }
    
}
