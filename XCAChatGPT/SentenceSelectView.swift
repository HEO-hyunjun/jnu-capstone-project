//
//  SentenceSelectView.swift
//  XCAChatGPT
//
//  Created by 허현준 on 2023/05/04.
//

import SwiftUI

struct SentenceSelectView: View {
    
    var title: String
    @State private var sentences=[""]
    let cf:ContextFlow
    
    var real_category=["웹 개발", "IOS 개발", "안드로이드 개발", "게임 개발", "서버 개발","통신엔지니어", "웹 퍼블리셔", "클라우드 엔지니어" ,"전자 엔지니어"," 기계 엔지니어", "전기 엔지니어", "제조, 생산", "물류, 무역", "의료", "PM", "데이터 분석", "금융", "기획", "회계", "경영", "마케팅", "디자인", "영업", "미디어", "교육", "법률", "건설", "복지"]
    var coverletterQuestion=["지원동기", "입사 후 포부", "성장배경", "성격 및 장단점", "위기 극복 사례", "주도적으로 업무를 수행한 사례", "사회경험", "직무를 선택한 이유", "본인의 역량"]
    var dialogue=["“솔로로 지낸 지 좀 오래됐거든요” \n\n- 남녀 소개팅 대화 -","“여기 어때?”\n\n- 휴가 여행지 결정하기 - ","“지금 어디서 뭐하는거야?”\n\n- 부모 자식 간에 오고가는 대화- ","“난 아무거나 상관없어”\n\n- 저녁 메뉴 정하기 - ","“늘 먹던걸로 주세요”\n\n- 식당에서 주문하기 -","“나랑 친구할래..?”\n\n- 새학기 친구 사귀기 -","“죽기전에 이건 꼭 봐!”\n\n- 영화 관련 대화 -","“너 돈관리 어떻게 해?”\n\n- 재테크 관련 대화 -","“난 숨쉬기 운동 좋아해”\n\n- 운동 관련 대화 -","“나 진짜 헤어질거야”\n\n- 연애 문제 고민 들어주기 -"]
    var body: some View {
        NavigationStack{
            VStack{
                VStack{
                }.frame(width:400,height: 180)
                    .padding(.top,10)
                    .background(Color.white)
                    .shadow(radius:5,x:1,y:5)
                    .overlay{
                        VStack{
                            HStack{
                                Text(title+"\n")
                                    .font(.custom("Arial-BoldMT", size: 32)).foregroundColor(Color(hex: "#7B7B7B")) +
                                Text("선택해주세요")
                                    .font(.custom("Arial", size: 32)).foregroundColor(Color(hex: "#7B7B7B"))
                                Spacer()
                            }.frame(width: 250.0, height: 100.0).padding(.top,10)
                        }
                    }
                
                
                ScrollView{
                    VStack{
                        //단일질문 ->
                        if(cf.dialogType == ContextFlow.DialogType.single){
                            ForEach(sentences,id: \.self){text in
                                NavigationLink(destination:LazyView(
                                    MicChatView(
                                        cf:cf.setSelectedQuestion(question:text),
                                        vm: ViewModel(api: ChatGPTAPI())
                                        ))){
                                    SentenceButtonView(text: text)
                                }
                            }
                        }else if(cf.dialogType == ContextFlow.DialogType.real
                                 && cf.jobCategory == nil){
                            //실전면접 -> 카테고리
                            ForEach(real_category,id: \.self){text in
                                NavigationLink(
                                    destination:LazyView(
                                    SentenceSelectView(
                                        title:"자기소개서 질문을",
                                        cf:cf.setJobCategory(jobCategory: text )))){
                                    SentenceButtonView(text: text)
                                }
                            }
                        }else if(cf.dialogType == ContextFlow.DialogType.real
                                 && cf.jobCategory != nil){
                            //실전면접 -> 카테고리 -> 자소서질문 -> 자소서
                            ForEach(coverletterQuestion,id: \.self){text in
                                NavigationLink(
                                    destination:LazyView(
                                        CoverletterView(
                                            cf:cf.setCoverLetterQuestion(question: text)))){
                                    SentenceButtonView(text: text)
                                }
                            }
                        }
                        else if(cf.dialogType == ContextFlow.DialogType.english){
                            //영어회화
                            ForEach(dialogue,id: \.self){text in
                                NavigationLink(
                                    destination:LazyView(
                                        MicChatView(
                                            cf:cf.setDialogueCase(dialogueCase: text),
                                            vm: ViewModel(api: ChatGPTAPI())
                                        ))){
                                    SentenceButtonView(text: text)
                                }
                            }
                        }
                        else{
                            //그외
                            ForEach(sentences,id: \.self){text in
                                NavigationLink(destination:HomeView()){
                                    SentenceButtonView(text: text)
                                }
                            }
                        }
                        
                    }
                    }.frame(width:350).padding(.top,10)
                
                }
            }.task {
                if(cf.questionCategory == ContextFlow.QuestionCategory.creativity){
                    await questionList(category:"creativity")
                }else if(cf.questionCategory == ContextFlow.QuestionCategory.personality){
                    await questionList(category:"personality")
                }else if(cf.questionCategory == ContextFlow.QuestionCategory.social){
                    await questionList(category:"social")
                }else if(cf.questionCategory == ContextFlow.QuestionCategory.job){
                    await questionList(category:"suitability")
                }
            }
    }
    
    func questionList(category:String) async{
        await ViewController.shared.getQuestion(from:category){ret in
            self.sentences=ret
        }
    }
}

//struct SentenceSelectView_Previews: PreviewProvider {
//    @Binding var gotohome:Bool
//    static var previews: some View {
//        SentenceSelectView(title:"창의질문", cf: ContextFlow(dialogType:ContextFlow.DialogType.real,questionCategory:ContextFlow.QuestionCategory.creativity),path:$path)
//    }
//}

struct NavigationSentenceView: View {
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            TokenizerView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
