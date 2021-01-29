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
    @EnvironmentObject var mtModel: MusicTweetViewModel
    @ObservedObject var convoModel: ConvoViewModel
    
    
    init(_ manager: TestDataManager, _ songInstEnt: SongInstanceEntity, dismiss: Binding<Bool>) {
        self.manager = manager
        self.songInstEnt = songInstEnt
        self._dismiss = dismiss
        self.convoModel = ConvoViewModel(self.manager, self.songInstEnt)
    }
    
    var body: some View {
        ZStack {
            Color.yellow.edgesIgnoringSafeArea(.all)
            ScrollView(.vertical) {
                HStack{
                    Text("Conversation")
                        .font(.system(size: 25, weight: .bold, design: .default))
                        .padding(.leading, 20)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Button("Add Comment") {
                        self.showActionSheet.toggle()
                    }
                    .actionSheet(isPresented: self.$showActionSheet) {
                        ActionSheet(
                            title: Text("Comments"),
                            message: Text("Add a comment!"),
                            buttons: [
                                .cancel { print(self.showActionSheet)},
                                .default(Text(EnhancedComment.greatSong)) {
                                    self.convoModel.addCommentBasedOnActionType(EnhancedComment.greatSong)
                                    self.convoModel.getAllCommentsForSongInstance()
                                },
                                .default(Text(EnhancedComment.interestingSong)) {
                                    self.convoModel.addCommentBasedOnActionType(EnhancedComment.interestingSong)
                                    self.convoModel.getAllCommentsForSongInstance()
                                },
                                .default(Text(EnhancedComment.loveSong)) {
                                    self.convoModel.addCommentBasedOnActionType(EnhancedComment.loveSong)
                                    self.convoModel.getAllCommentsForSongInstance()
                                }
                            ]
                        )
                    }
                    .padding()
                    Button("Back") {
                        self.dismiss.toggle()
                        self.convoModel.getAllCommentsForSongInstance() // update again in case user keeps entering the same conversation from the MusicTweet "Convo" button
                    }.padding()
                }.padding(.bottom).padding(.top)
                VStack {
                    MusicTweet(MusicTweetViewModel(self.mtModel.TDManager, self.mtModel.songInstEnt))
                    Spacer()
                    ForEach(self.convoModel.comments, id: \.self ) { comment in
                            HStack {
                                Image("\(comment.user.avatar!)")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 80, alignment: .center)
                                    .padding(.leading, 20)
                                VStack(alignment: .leading) {
                                    Text("\(comment.user.name)")
                                        .font(.system(size: 25, weight: .light, design: .serif ))
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                    Text("\(self.convoModel.getEnhancedCommentFromCommentType(comment.comment))")
                                }
                            }
                            .frame(width: 300, height: 100, alignment: .center)
                            .padding()
                            .cornerRadius(3)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 2))
                            .background(Color("comment"))
                            .shadow(color: Color(UIColor.secondarySystemBackground), radius: 5, x: 1, y: 1)
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
        }.onAppear {
            self.convoModel.getAllCommentsForSongInstance()
        }
    }
}

struct EnhancedComment {
    static let greatSong = "Great song!"
    static let interestingSong = "Interesting..."
    static let loveSong = "Love it!"
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> Value) {
        value += nextValue()
    }
}

