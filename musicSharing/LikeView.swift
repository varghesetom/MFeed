//
//  LikeView.swift
//  musicSharing
//
//

import SwiftUI

class LikeViewModel: ObservableObject {
    var manager: TestDataManager
    var songInstEnt: SongInstanceEntity
    @Published var numLikes = 0
    
    init(_ manager: TestDataManager, _ songInstEnt: SongInstanceEntity) {
        self.manager = manager
        self.songInstEnt = songInstEnt
    }
    
    func getLikes() {
        numLikes = self.manager.getLikesForSongInstID(songInstID: songInstEnt.instance_id! )
    }
}

struct LikeView: View {
    
    @State var numLikes: Int
    
    var body: some View {
        Heart()
            .overlay(NumberText(numLikes: numLikes))
            .scaleEffect(0.1)
    }
}


struct NumberText: View {
    
    @State var numLikes: Int
    
    var body: some View {
        VStack(alignment: .center) {
            Text("\(numLikes)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .allowsHitTesting(true)
                .minimumScaleFactor(0.5)
                .foregroundColor(Color("heartNum"))
                .shadow(color: Color(UIColor.systemBackground), radius: 10, x: 1, y: 2)
        }
            .padding(.bottom, 25)
    }
}

struct Heart: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: HeartDimensions.width, height: HeartDimensions.height, alignment: .center)
                .foregroundColor(.blue)
                .cornerRadius(5)
            Circle()
                .frame(width: HeartDimensions.width, height: HeartDimensions.height, alignment: .center)
                .foregroundColor(.blue)
                .padding(.top, -HeartDimensions.height)
            Circle()
                .frame(width: HeartDimensions.width, height: HeartDimensions.height, alignment: .center)
                .foregroundColor(.blue)
                .padding(.trailing, -HeartDimensions.width)
        }.rotationEffect(Angle(degrees: -45))
    }
}

struct HeartDimensions {
    static let width: CGFloat = 100
    static let height: CGFloat = 100
}

//struct LikeView_Previews: PreviewProvider {
//    static var previews: some View {
//        LikeView()
//    }
//}
