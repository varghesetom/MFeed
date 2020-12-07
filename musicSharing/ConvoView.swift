//
//  ConvoView.swift
//  musicSharing
//
//  Created by Varghese Thomas on 07/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import SwiftUI

struct ConvoView: View {
    var manager: TestDataManager
    var songInstEnt: SongInstanceEntity
    @Binding var dismiss: Bool
    @State var offset = CGFloat.zero
    @State var showActionSheet = false
    
    var body: some View {
        ZStack {
            Color.yellow.edgesIgnoringSafeArea(.all)
            ScrollView(.vertical) {
                HStack{
                    Text("Conversation")
                        .font(.system(size: 35, weight: .bold, design: .default))
                        .padding(.leading, 20)
                        .allowsTightening(true)
                    Spacer()
                    Button("Add Comment") {
                        self.showActionSheet.toggle()
                    }
                    .actionSheet(isPresented: self.$showActionSheet) {
                        ActionSheet(
                            title: Text("Actions"),
                            message: Text("Available actions"),
                            buttons: [
                                .cancel { print(self.showActionSheet)},
                                .default(Text("Action")) {
                                    print("actioned")
                                },
                                .destructive(Text("Delete")) {
                                    print("deleted")
                                }
                            ]
                            )
                    }
                    .padding()
                    Button("Back") { self.dismiss.toggle() }.padding()
                }.padding(.bottom).padding(.top)
                VStack {
                    MusicTweet(self.manager, songInstEnt: self.songInstEnt, Alignment.center)
                    Spacer()
                    ForEach(1..<55) { index in
                        HStack {
                            Text("Hello").foregroundColor(Color.white)
                            Text("\(index)")
                        }
                    }
                    Spacer()
                    Spacer()
                }.background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                                       value: -$0.frame(in: .named("convo")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) {
                    self.offset = $0
                }
            }.coordinateSpace(name: "convo")
        }
    }
}

class ConvoViewModel {
    var manager: TestDataManager
    var songInstEnt: SongInstanceEntity
    var toggleGreatComment = false
    var toggleInterestingComment = false
    var toggleLoveComment = false
    
    init(_ manager: TestDataManager, _ songInstEnt: SongInstanceEntity) {
        self.manager = manager
        self.songInstEnt = songInstEnt
    }
    
    func addComment(_ commentType: CommentType) {
    
    }
    
    func getAllCommentsForSongInstance() {
        
    }
}


struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> Value) {
        value += nextValue()
    }
}

//.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, alignment: Alignment.center)
//.background(Color.yellow)

//NavigationView {
//           ZStack {
//               Color.yellow.edgesIgnoringSafeArea(.all)
//
//           }
//           .background(Color.orange).edgesIgnoringSafeArea(.all)
//           .navigationBarTitle("Conversation")
//           .navigationBarItems(trailing: Button("Back") {
//
//           })
//       }
