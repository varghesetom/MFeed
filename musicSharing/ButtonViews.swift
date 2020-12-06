//
//  StyleViews.swift
//  musicSharing
//
//  Created by Varghese Thomas on 06/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import SwiftUI

struct GenreSeekingButton: View {
    @State var genre: String
    @State var didSelectGenre = false
    @State private var chosenGenre = LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing)
    @State private var unselected = LinearGradient(gradient: Gradient(colors: [ Color.white, Color.gray]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        Button(action: {
            self.didSelectGenre.toggle()
        }) {
            Text("\(genre)")
                .padding(2)
                .font(.subheadline)
                .allowsTightening(true)
        }
        .buttonStyle(didSelectGenre ? GenreSeekingStyle(selectedColor: chosenGenre) : GenreSeekingStyle(selectedColor: unselected))
    }
}

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

