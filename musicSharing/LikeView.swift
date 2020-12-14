//
//  LikeView.swift
//  musicSharing
//
//

import SwiftUI

struct LikeView: View {
    
    @State var numLikes: Int
    
    var body: some View {
        Heart()
            .overlay(LikeNumberText(numLikes: numLikes))
            .scaleEffect(0.25)
    }
}


struct LikeNumberText: View {
    
    @State var numLikes: Int
    
    var body: some View {
        VStack(alignment: .center) {
            Text("\(numLikes)")
                .font(.system(size: 75, weight: .bold, design: .rounded))
                .allowsHitTesting(true)
                .minimumScaleFactor(0.5)
                .foregroundColor(Color(.red))
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
                .foregroundColor(.white)
                .cornerRadius(5)
            Circle()
                .frame(width: HeartDimensions.width, height: HeartDimensions.height, alignment: .center)
                .foregroundColor(.white)
                .padding(.top, -HeartDimensions.height)
            Circle()
                .frame(width: HeartDimensions.width, height: HeartDimensions.height, alignment: .center)
                .foregroundColor(.white)
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
