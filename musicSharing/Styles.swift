

import SwiftUI

struct GenreSeekingStyle: ButtonStyle {
    
    @State var selectedColor: LinearGradient
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .foregroundColor(.black)
            .background(RoundedRectangle(cornerRadius: 10).fill(selectedColor))
            .compositingGroup()
            .shadow(color: .blue, radius: 20)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .scaleEffect(configuration.isPressed ? 1.2 : 1.0)
            .cornerRadius(5)
            .scaledToFit()
    }
}

struct TweetButtonBackground: ButtonStyle {
    @State private var firstGradientColor = Color.orange
    @State private var secondGradientColor = Color.red
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(5)
            .compositingGroup()
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .scaledToFit()
    }
}

struct FollowRequestStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .padding()
            .background(Color.accentColor)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .scaleEffect(configuration.isPressed ? 1.2 : 1.0)
            .cornerRadius(8)
    }
}

