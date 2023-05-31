//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI
import AVKit

struct FeedbackView: View {
    var cf:ContextFlow?
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @State private var messageRow: FeedbackButtonView?
    
    @State private var messages:[FeedbackButtonView] = []

    @EnvironmentObject var appState: AppState
    @State private var isFullFeedback: Bool = false
    @State private var fullFeedbackText: String = ""
    let coloredNavAppearance = UINavigationBarAppearance()
//    init(vm: ViewModel,GoToHome:Binding<Bool>){
//        self.vm = vm
//
//        coloredNavAppearance.configureWithOpaqueBackground()
//        coloredNavAppearance.backgroundColor = UIColor.white
//        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
//        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
//        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
//        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
//        _GoToHome = GoToHome
//    }
    
    
    var body: some View {
            chatListView
                .navigationTitle("피드백")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action:{
                    //path = []
                    appState.rootViewId = UUID()
                },label: {
                    Text("< 홈으로")
                }))
                .onAppear{
                    vm.api.temperature = 0
                    for message in vm.messages  {
                        let m = message.copy(messageRow: message)
                        self.messages.append(FeedbackButtonView(message: m))
                        self.messages.append(FeedbackButtonView(message: m,isAssistant: true))
                    }
                }
        if(cf?.dialogType == ContextFlow.DialogType.real)
        {
            Button(action:{
                isFullFeedback = true
            },label:{
//                Text("면접 전체 피드백")
//                    .font(.custom("Arial", size: 25))
//                    .foregroundColor(Color.black)
            }).buttonStyle(PlainButtonStyle())
                .frame(height:80)
                .sheet(isPresented: $isFullFeedback, content: {
                    ScrollView{
                        VStack{
                            if(fullFeedbackText == ""){
                                DotLoadingView().frame(width: 90, height: 45)
                                    .padding(.bottom,50)
                                    .padding(.top,250)
                                Text("분석중입니다")
                                    .frame(width:340,alignment: .center)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("잠시만 기다려주세요")
                                    .frame(width:340,alignment: .center)
                                Text("답변이 잘려보이거나 너무 오래 기다리는 경우,")
                                    .frame(width:340,alignment: .center)
                                Text("화면을 내린 후 다시 로드해주시기 바랍니다.")
                                    .frame(width:340,alignment: .center)
                            }
                            else{
                                Text("면접 전체 피드백")
                                    .font(.custom("Arial-BoldMT", size: 35))
                                    .foregroundColor(Color.black)
                                    .padding(.bottom,20)
                                Text(fullFeedbackText)
                                    .frame(width:340)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }.padding(.top, 20)
                    }.task{
                        do{
                            var prompt = """
    전체 대화에 대해 피드백을 제공해줘야 한다.
    피드백은 반드시 각각의 질문에 답변하는 형식이 아닌, 모든 조건을 만족하는 하나의 지문으로 완성하라.
    피드백 이외의 불필요한 문장은 삭제하여 글자수를 최소화 해야한다. 해당 문장에 대한 요약이나 해당 문장 전체를 언급하는 것을 최대한 자제하여 글자수를 최소화하라.
    피드백은 최대 500글자 이하로 작성되어야만한다.
    하나의 지문은 아래의 조건을 모두 만족해야만 한다.
    1. 면접대상자의 답변 내용을 참고하여 면접 대상자에 대한 인상을 간략하게 설명한다.
    2. \(cf?.jobCategory!)직무에 대해 (1.)설명에서의 인상이 어떠한 영향을 미칠 수 있는지 설명한다. 이후 그 영향에 대한 조언도 함께하라
    3. 면접대상자의 답변을 참고하여 \(cf?.jobCategory!)직무에서 어떠한 부분에서 아쉬운지 설명하라. 그리고 아쉬운 부분을 해결하기 위한 방법에 대해서도 설명하라.
    4. 면접대상자의 답변을 참고하여 100점이 가장 모범적인 답변이라고 하였을때 (2.)과 (3.)에서의 평가를 근거로 하여 해당 문장이 몇점정도의 답변인지 객관적으로 0점부터 100점사이의 점수를 측정하여 이를 제공해야한다.
    예시:
    면접대상자님의 인상은 ???, ???이라는 인상을 받았습니다. 이러한 특징은 ??? 직무에서 ??? 업무능력에서 ???한 능력에 ???한 영향을 미칠 수 있습니다. 그러므로 면접대상자님께서는 ??? 하는것이 좋다고 생각합니다.
    
    하지만 면접대상자님께서 ???의 답변을 보아 ???한 부분이 아쉽다고 생각합니다. 이러한 부분은 ??? 직무에서 ???하기때문에 이러한 부분은 개선할 필요가 있습니다. ???한 방법으로 답변하거나 혹은 ???한 활동을 하는것도 좋아보입니다.
    
    면접대상자님의 답변을 참고하여 제가 면접대상자님께 점수를 드린다면 100점 만점에 ???점입니다.
    """
                            vm.api.changePrompt(text: prompt)
                            fullFeedbackText = try await vm.api.getFeedback(
                                    text:
"""
면접 전체에 대해 피드백 해줘
""")
                        }
                        catch{
                            print(error.localizedDescription)
                        }
                    }
                })
                .frame(width:500,height:100)
                .background(Color.white)
                .shadow(radius:10,x:1,y:0)
                .overlay{
                    Text("면접 전체 피드백")
                        .font(.custom("Arial", size: 25))
                        .foregroundColor(Color.black)
                }
                
                
        }
        Button(action:{
            
        },label:{
            
        }).hidden()
    }
    
    var chatListView: some View {
        ScrollView{
            ForEach(self.messages) { message in
                Button(action: {
                    messageRow = message
                }, label:{
                    message
                }).buttonStyle(PlainButtonStyle())
            }.sheet(item: $messageRow){message in
                feedbackSheetView(message:message, vm:vm, cf:cf!)
            }
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static let vm = ViewModel(api:ChatGPTAPI())

    static var previews: some View {
        VStack{
            FeedbackView(
                cf:ContextFlow(
                    dialogType: ContextFlow.DialogType.real,
                    selectedQuestion: "본인의역량",
                    jobCategory:"게임개발",
                    coverLetterAnswer: "저는 아주 끈기있는 게임 개발자 입니다. 기술적인 문제가 발생하였을때, 저는 이를 해결하기위해 밤을 새서라도 이것에 대해 해결하며, 자료를 찾기 위해 영어를 공부하여 공인인증 영어 시험인 토익에서 910점이라는 높은 점수를 기록하였습니다."),
                vm:vm)
            .onAppear{
                vm.api.historyList = [
                    Message(role: "system",
                            content:
                            """
                            면접관처럼 행동하고, 가능한 한 간단하게 말하고, 무조건 한 가지 질문만 하라.
                            직무와 관련되지 않은 질문은 지양하라. 압박 면접 분위기를 조성하라.
                            다음은 지원자에 대한 정보이다.이를 참고하여 면접을 진행하라.
                            1. 지원자가 지원한 직무 분야는 게임 개발이다.
                            2. 다음은 지원자가 제출한 자기소개서 문항과 그에 대한 답변이다.
                            문항 :본인의 역량,
                            답변 : 저는 아주 끈기있는 게임 개발자 입니다. 기술적인 문제가 발생하였을때, 저는 이를 해결하기위해 밤을 새서라도 이것에 대해 해결하며, 자료를 찾기 위해 영어를 공부하여 공인인증 영어 시험인 토익에서 910점이라는 높은 점수를 기록하였습니다.
                            """),
                    Message(role: "user",
                            content:
                                "너는 지금부터 면접관이고 나는 지원자야. 실제 면접처럼 하나씩만 질문해줘."),
                    Message(
                        role: "assistant",
                        content: "안녕하세요, 지원자님. 자기소개를 부탁드립니다."),
                    Message(
                        role: "user",
                        content: "안녕하십니까 허현준입니다."),
                    Message(
                        role: "assistant",
                        content: "안녕하세요, 허현준님. 자신이 개발한 게임 중에서 가장 자신 있는 작품이 어떤 것인지 말씀해주시겠어요?"),
                    Message(
                        role: "user",
                        content:
                            "아직 개발중에 있는 프로젝트이지만, 현재 가제 “백룸 크롤러”라는 게임을 개발하고있습니다. 탑다운 뷰의 미스테리 공포 로그라이크 장르의 게임인데요, 여기에서 저는 몬스터, 캐릭터조작, 및 장비 등 게임 시스템 전반의 개발을 맡고 있으며, 현재 광주광역시의 인디스타즈라는 인디게임 지원 프로그램의 도움을 받으며 개발중에 있습니다."),
                    Message(
                        role: "assistant",
                        content: "현재 개발 중인 게임에서 가장 큰 어려움은 무엇인가요? 그리고 그 어려움을 어떻게 극복하려고 하고 있나요?"),
                    Message(
                        role: "user",
                        content:
                            "현재 이 프로젝트에서는 탑다운엔진이라는 다소 규모가 큰 에셋을 프로젝트에 활용중에 있습니다. 하지만 직접 작성한 코드가 아니다 보니, 클래스간의 상속관계 그리고 각 클래스의 역할에 대해 파악하는데 어려움을 겪고있습니다. 저는 이를 해결하기 위해 에셋 개발자의 공식 홈페이지의 자료를 번역하여 정리해 저장하고있으며 클래스간의 관계를 팀에서 사용중인 노션에 공유하고 있습니다."),
                    Message(
                        role: "assistant",
                        content:
                            "팀 프로젝트에서 협업하는 과정에서 가장 중요하다고 생각하는 점은 무엇인가요? 그리고 그것을 실천하기 위해 어떤 노력을 하고 있나요?"),
                    Message(
                        role: "user",
                        content: "저는 협업은 같은 목표를 향해 함께하는 것이라고 생각하여 이를 위해 목표하는 바를 공유하는 의사소통이 가장 중요하다고 생각합니다. 저희팀은 팀원간의 소통을 위해 노션을 사용중인데요, 팀원 중 노션 사용에 익숙하지 않은 팀원들이 존재했고 또한 같이 사용하는 공간에서 어떠한 작업흐름을 가지고 작업을 수행해야할지 고민하였습니다. 그래서 제가 가장 사용하는데 익숙한 게시판형태를 기본으로 하여 간반보드와 적절히 활용하여 직관적인 UI를 구현하였고 각 문서별로 템플릿을 작성하여 문서를 규격화하였습니다."),
                    Message(
                        role: "assistant",
                        content: "허현준님께서는 개발자로서 기술적인 역량을 강조하셨습니다. 그러나 게임 개발에 있어서 인간적인 측면도 중요합니다. 팀 내에서 갈등이 발생했을 때, 그것을 어떻게 해결하시나요?"),
                    Message(
                        role: "user",
                        content: "저또한 인간적인 측면이 중요하다는데에 동의하는 바입니다. 하지만, 팀 내에서의 갈등 또한 원인이 있기 마련이기에, 저는 그 원인을 먼저 파악하고자 하는 것이 우선이라고 생각합니다. 현재 해결이 가능한 문제의 원인의 경우 그것을 먼저 해결하려고 노력하고, 불가능한 경우에 상황설명과 원인에 대해서 먼저 설명한 후 상호간의 협의를 이끌어내려고 합니다."),
                    Message(
                        role: "assistant",
                        content:
                            "허현준님께서는 게임 개발 분야에서 가장 관심 있는 기술이 무엇인가요? 그리고 그 기술을 활용하여 어떤 게임을 개발하고 싶은가요?"),
                    Message(
                        role: "user",
                        content:
                            "저는 모션캡처나 이미지 분석등의 작업물 생성에 도움을 주는 기술에 관심이 있습니다. 현재 사회에서 뜨겁게 이슈가 되는 생성형 인공지능 또한 이러한 범주에 해당하는데요, 기존에 아트팀에서 모델링이나 애니메이션의 작업을 그저 배우가 한번 연기함으로써 약간의 수정작업만 진행하면 기존의 애니메이션이나 모델보다 훨씬 빠른 속도로 게임개발을 진행할 수 있게 됐으며, 대표적으로는 원신이라는 게임이 있습니다. 저는 이러한 기술들을 활용하여 조금 작은 규모의 팀으로 영화와 같은 현실감있는 게임을 개발해보고 싶습니다."),
                    Message(
                        role: "assistant",
                        content: "허현준님께서는 게임 개발 분야에서 가장 어려운 부분은 무엇이라고 생각하시나요? 그리고 그 부분을 극복하기 위해 어떤 노력을 하고 계신가요?"),
                    Message(
                        role: "user",
                        content: "저는 시간적인 문제가 가장 어려웠습니다. 팀의 규모가 작다는 문제점도 있지만, 기본적으로 게임은 작업량이 많은 종류의 프로그램이기 때문에 오랜 기간의 개발을 해야합니다. 저는 이를 해결하기위해 이미 구현된 에셋이 있을 경우 구입에 돈을 아끼지 않을 뿐만아니라, 이를 프로젝트에 적용하기 위해 빠른시간에 에셋의 구조를 파악하려는 연습을 합니다. 저는 이를 위해 평소에 깃허브에서의 다양한 프로젝트의 프로그램의 데이터흐름, 클래스 구조등을 그림을 그려 시각화하는 연습을 하고 있으며 현재 약 50개정도의 프로젝트를 분석하였습니다."),
//                    Message(
//                        role: "assistant",
//                        content:
//                            "허현준님께서는 게임 개발 분야에서 가장 중요한 기술이 무엇인지 생각하시나요? 그리고 그 기술을 활용한 게임 개발 경험이 있으신가요?"),
//                    Message(
//                        role: "user",
//                        content: "저는 앞선 답변들과 같은 맥락에서 기술을 활용할 수 있는 기술이 필요하다고 생각합니다. 새로운 기술이 나왔을때, 최근에는 특히나 더,  이것을 본인의 프로젝트에 적용할 수 있는 능력이 필요하다고 생각합니다. 저는 기존의 프로젝트에서 효과음이나 메인 테마곡이 필요하여 작곡 AI인 AIVA를 활용하여 기존의 프로젝트에 적용했던 경험이 있습니다. 여기서 저는 AI에게 명확하게 원하는 응답을 받을 수 있도록 질의를 생성하는 기술을 익혔습니다."),
                    Message(
                        role: "assistant",
                        content: "허현준님께서는 게임 개발 분야에서 가장 성장할 수 있는 부분은 무엇이라고 생각하시나요? 그리고 그 부분을 개발자로서 어떻게 발전시키려고 노력하고 계신가요?"),
                    Message(
                        role: "user",
                        content: "질문에 대해 잘 이해하지 못하여 조금 더 구체적인 설명이 필요한 것 같습니다. 제가 성장할 수 있는 부분에 대해서인가요? 혹은 게임개발이라는 분야가 성장 할 수 있는 부분에 대해서 여쭈어보시는건가요?"),
                    Message(
                        role: "assistant",
                        content: "죄송합니다. 제가 미흡한 질문을 드렸습니다. 제가 물은 것은 게임 개발 분야에서 허현준님께서 가장 성장할 수 있는 부분은 무엇이라고 생각하시는지, 그리고 그 부분을 개발자로서 어떻게 발전시키려고 노력하고 계신지에 대한 것이었습니다."),
                    Message(
                        role: "user",
                        content: "저는 게임개발은 객체간의 상호작용을 가장 신경써야하는 분야라고 생각합니다. 때문에 저는 객체지향 프로그래밍에 있어 조금더 효율적인 객체화를 추구할 수 있으며, 많은 알고리즘을 활용한 상호작용에 대해 성장할 수 있다고 생각합니다. 저는 이를 위해 게임에 적용가능한 알고리즘을 온라인 저지 사이트에서 연습하고 있으며 또한 앞서 말씀드린것처럼 약 50개의 프로그램의 객체들을 분석하였습니다."),
                    Message(
                        role: "system",
                        content: "이전 답변에서 추가 질문이 꼭 필요하다고 판단하면 추가적인 질문을 하고, 그렇지 않다면 적절한 주제의 새로운 질문을 하라. 만약 새로운 질문을 한다면 지원 직무 관련 지식에 대한 질문을 하라.")
                ]
                vm.reloadHistory()
            }
        }
    }
}

struct feedbackSheetView: View{
    var message: FeedbackButtonView
    var vm: ViewModel
    @State var player: AVAudioPlayer!
    let cf: ContextFlow
    @State private var text:String = ""
    
    var body: some View{
        ScrollView{
            message
                .padding(.bottom, 20)
                .padding(.top, 20)
            if(cf.dialogType == ContextFlow.DialogType.english){
                Button(action:{
                    Task{
                        await TTS.shared.getSpeech(from : message.text, lang: "eng"){result in
                            do{
                                var data = try Data(contentsOf: result)
                                if((self.player != nil && !self.player.isPlaying) ||
                                   (self.player == nil)) {
                                    
                                    try self.player = AVAudioPlayer(data:data)
                                    self.player.play()
                                }
                            }
                            catch{
                                print(error.localizedDescription)
                            }
                        }
                    }
                }, label:{
                    Text("다시 듣기\n\n")
                })
            }
            if(text == "")
            {
                VStack{
                    DotLoadingView()
                        .frame(width: 90, height: 45)
                        .padding(.bottom,20)
                        .padding(.top, 30)
                    Text("분석중입니다")
                        .frame(width:340,alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("잠시만 기다려주세요")
                        .frame(width:340,alignment: .center)
                    Text("답변이 잘려보이거나 너무 오래 기다리는 경우,")
                        .frame(width:340,alignment: .center)
                    Text("화면을 내린 후 다시 로드해주시기 바랍니다.")
                        .frame(width:340,alignment: .center)
                }
            }else{
                Text("피드백")
                    .font(.custom("Arial-BoldMT", size: 35))
                    .foregroundColor(Color.black)
                    .padding(.bottom,20)
                Text(text)
                    .frame(width:340)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }.task{
            do{
                var prompt = ""
                
                if(cf.dialogType == ContextFlow.DialogType.real){
                    prompt = """
이제부턴 면접에 대해 피드백을 제공해줘야 한다.
피드백은 반드시 각각의 질문에 답변하는 형식이 아닌, 모든 조건을 만족하는 하나의 지문으로 완성하라.
피드백 이외의 불필요한 문장은 삭제하여 글자수를 최소화 해야한다. 해당 문장에 대한 요약이나 해당 문장 전체를 언급하는 것을 최대한 자제하여 글자수를 최소화하라.
피드백은 최대 500글자 이하로 작성되어야만한다.
하나의 지문은 아래의 조건을 모두 만족해야만 한다.
피드백이 필요한 문장은 이하 해당 문장으로 칭한다.
1. 피드백은 \(cf.jobCategory!)직무에 알맞아야 한다.
"""
                    if(message.isAssistant){
                        prompt +=
"""
2. 피드백은 해당 문장이 어떠한 의도의 질문인지 그 의도에 대한 해설을 포함해야한다.
3. 피드백은 해당 문장에 대한 적절한 답변에는 어떤 내용이 표현되야 하는지를 포함해야한다.
4. 피드백은 (3.)에서 설명한 내용이 적절하게 표현되도록 해당 질문에 대한 모범 답변을 최대한 간략하게 제시하라.
예시: 해당 질문은 ??? 직무의 ??? 부분에 대해 평가하기 위한 질문입니다. 이 질문의 의도로는 ???, ??? 등의 항목을 면접 대상자에게서 살펴보기 위한 것으로, 이에 대해 ???에 대해 중점적으로 답변하는 것이 좋습니다. 만약 답변을 한다면 "???"과 같이 답변하는 것이 좋은 질문입니다.
"""
                    }else{
                        prompt +=
"""
2. 피드백은 오로지 해당 문장에 대해서만 답변해야한다. 예외적으로 (5.)의 조건을 만족시키기 위한 경우와 해당 문장 이전의 답변에 대해서만 예외적으로 문맥을 고려하라.
3. 피드백은 해당 문장이 자기소개서등의 문장이아니라, "면접"이라는 상황에서 적절했는지에 대한 객관적인 평가를 제시해야한다. 면접상황에서 적절했는지를 평가하기 위한 요소로는 답변의 길이, 이전 답변들과의 일관성, \(cf.jobCategory!)직무와의 연관성, \(cf.jobCategory!)직무에 대한 열정, 논리적인 전개의 정도, 질문에 대한 이해도 등이다. 특히 \(cf.jobCategory!)직무와의 연관성과 열정 그리고 답변의 길이의 적절성은 중요한 평가사항이다
4. (3.)의 말미에는 100점이 가장 모범적인 답변이라고 하였을때 (3.)에서의 평가를 근거로 하여 해당 문장이 몇점정도의 답변인지 객관적으로 0점부터 100점사이의 점수를 측정하여 이를 제공해야한다.
5. 피드백은 해당 문장에 대한 평가 이후, 최대한 간략한 해당 문장의 모범적인 답변을 포함하라. 만약 면접대상자의 답변 중, 참고할만한 내용이 있으면 참고하라.
예시: 해당 답변은 ??? 직무의 ???질문에 대한 ???한 답변으로 보입니다. ???질문은 ???한 의도를 파악하기 위한 질문으로 이에 대해 ???의 답변은 ???하다고 평가할 수 있습니다. 특히 ???직무에서 이러한 답변은 ???하다고 평가될 수 있으므로 ???합니다. 제가 이 답변에 대한 점수를 준다면 100점 만점에 ???점이라고 생각되는 답변입니다. 100점이 아닌 이유로는, ???이라는 점이 더 보완된다면 더욱 좋은 평가를 받을 수 있습니다. 만약 제가 면접대상자님의 답변을 기반으로 수정한다면 "???"으로 수정할 것입니다.
"""
                    }
                } else if(cf.dialogType == ContextFlow.DialogType.english)
                {
                    prompt = """
이제부턴 대화에 대해 피드백을 제공해줘야 한다.
피드백은 반드시 각각의 질문에 답변하는 형식이 아닌, 모든 조건을 만족하는 하나의 지문으로 완성하라.
피드백 이외의 불필요한 문장은 삭제하여 글자수를 최소화 해야한다. 해당 문장에 대한 요약이나 해당 문장 전체를 언급하는 것을 최대한 자제하여 글자수를 최소화하라.
피드백은 최대 500글자 이하로 작성되어야만한다.
하나의 지문은 아래의 조건을 모두 만족해야만 한다.
피드백이 필요한 문장은 이하 해당 문장으로 칭한다.
1. 문장 전체에 대한 해석을 한국어로 작성하라.
2. 영어 회화를 배우는 입장에서 유용하다고 생각되는 단어에 대해 해당 문장의 부분과 단어의 뜻을 작성하라.
3. 영어 회화를 배우는 입장에서 유용하다고 생각되는 숙어 혹은 관용어 구문 대해 해당 문장의 부분과 숙어 혹은 관용어 구문의 뜻을 작성하라.
예시:
해석: "???"
유용한 단어 :
영 ??? / 한 ???
영 ??? / 한 ???
...
유용한 숙어 혹은 관용어 :
영 ??? / 한 ???
영 ??? / 한 ???
...
"""
                } else if(cf.dialogType == ContextFlow.DialogType.single)
                {
                    prompt = """
이제부턴 대화에 대해 피드백을 제공해줘야 한다.
피드백은 반드시 각각의 질문에 답변하는 형식이 아닌, 모든 조건을 만족하는 하나의 지문으로 완성하라.
피드백 이외의 불필요한 문장은 삭제하여 글자수를 최소화 해야한다. 해당 문장에 대한 요약이나 해당 문장 전체를 언급하는 것을 최대한 자제하여 글자수를 최소화하라.
피드백은 최대 500글자 이하로 작성되어야만한다.
하나의 지문은 아래의 조건을 모두 만족해야만 한다.
피드백이 필요한 문장은 이하 해당 문장으로 칭한다.
"""
                    if(message.isAssistant)
                    {
                        prompt += """
1. 피드백은 해당 문장이 어떠한 의도의 질문인지 그 의도에 대한 해설을 포함해야한다.
2. 피드백은 해당 문장에 대한 적절한 답변에는 어떤 내용이 표현되야 하는지를 포함해야한다.
3. 피드백은 (2.)에서 설명한 내용이 적절하게 표현되도록 해당 질문에 대한 모범 답변을 최대한 간략하게 제시하라.
예시: 해당 질문은 ??? 부분에 대해 평가하기 위한 질문입니다. 이 질문의 의도로는 ???, ??? 등의 항목을 면접 대상자에게서 살펴보기 위한 것으로, 이에 대해 ???에 대해 중점적으로 답변하는 것이 좋습니다. 만약 답변을 한다면 "???"과 같이 답변하는 것이 좋은 질문입니다.
"""
                    }else
                    {
                        prompt += """
1. 피드백은 오로지 해당 문장에 대해서만 답변해야한다. 예외적으로 (5.)의 조건을 만족시키기 위한 경우와 해당 문장 이전의 답변에 대해서만 예외적으로 문맥을 고려하라.
2. "면접"이라는 상황에서 적절했는지에 대한 객관적인 평가를 제시해야한다. 면접상황에서 적절했는지를 평가하기 위한 요소로는 답변의 길이, 이전 답변들과의 일관성, 직무에 대한 열정, 논리적인 전개의 정도, 질문에 대한 이해도 등이다. 특히 답변의 길이의 적절성은 중요한 평가사항이다
3. (2.)의 말미에는 100점이 가장 모범적인 답변이라고 하였을때 (3.)에서의 평가를 근거로 하여 해당 문장이 몇점정도의 답변인지 객관적으로 0점부터 100점사이의 점수를 측정하여 이를 제공해야한다.
4. 피드백은 해당 문장에 대한 평가 이후, 최대한 간략한 해당 문장의 모범적인 답변을 포함하라. 만약 면접대상자의 답변 중, 참고할만한 내용이 있으면 참고하라.
예시: 해당 답변은 ???질문에 대한 ???한 답변으로 보입니다. ???질문은 ???한 의도를 파악하기 위한 질문으로 이에 대해 ???의 답변은 ???하다고 평가할 수 있습니다. 특히 ???직무에서 이러한 답변은 ???하다고 평가될 수 있으므로 ???합니다. 만약 제가 이 답변에 대한 점수를 줄 수 있다면 100점 만점에 ???점이라고 생각되는 답변입니다. 100점이 아닌 이유로는, ???이라는 점이 더 보완된다면 더욱 좋은 평가를 받을 수 있습니다. 만약 제가 면접대상자님의 답변을 기반으로 수정한다면 "???"으로 수정할 것입니다.
"""
                    }
                }
                
                vm.api.changePrompt(text: prompt)
                
                text = try await vm.api.getFeedback(
text: """
면접 상황중 아래의 문장 대해 피드백 해줘
\(message.text)
"""
                )
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}

struct FeedbackButtonView: View, Identifiable{
    var id = UUID()
    var isIgnore : Bool = false
    var text: String
    var image: String
    var responseError:String?
    var isAssistant:Bool = false
    
    init(message:MessageRow, isAssistant:Bool=false){
        self.isAssistant = isAssistant
        if(isAssistant){
            if(message.responseText == ""){
                self.isIgnore = true
            }
            self.text = message.responseText!
            self.image = message.responseImage
            if(message.responseError != nil){
                self.responseError = message.responseError!
            }
        }else{
            self.text = message.sendText
            self.image = message.sendImage
            self.isIgnore = message.isIgnore
        }
    }
    
    var body: some View{
        if(!isIgnore){
            VStack{
                HStack(alignment: .top, spacing:24) {
                        Image(image).resizable()
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading) {
                            if !text.isEmpty {
                                Text(text)
                                    .frame(width:300,alignment: .leading)
                                    .textSelection(.enabled)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            if let error = responseError {
                                Text("Error: \(error)")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    HStack{
                        Rectangle().size(width:50, height:1).foregroundColor(Color(hex: "#7B7B7B"))
                    }.frame(width: 50, height:1)
                }
        }
    }
}


