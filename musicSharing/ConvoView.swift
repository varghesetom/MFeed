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
    @State private var offset = CGFloat.zero
    
    var body: some View {
//        GeometryReader { geometry in
        ZStack {
            Color.yellow.edgesIgnoringSafeArea(.all)
            ScrollView(.vertical) {
                HStack{
                    Text("Conversation").font(.largeTitle).padding(.leading, 20)
                    Spacer()
                    Button("Back") {}
                }.padding(.bottom)
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
                                       value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) {
                    self.offset = $0   // needed offset to shift back image
                }
            }.coordinateSpace(name: "scroll")
            .navigationBarTitle("Conversation")
            .navigationBarItems(trailing: Button("Back") {
            })
        }
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
