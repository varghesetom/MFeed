//
//  SearchBar.swift
//  musicSharing
//

import SwiftUI


struct SearchBarView: View {
    @State var text = ""
    @State var isEditing = false
    var TDManager: TestDataManager
    
    init(_ manager: TestDataManager) {
        self.TDManager = manager
    }
    
    var body: some View {
        var filtered_users = [User]()
        if !text.isEmpty {
            if let retrieved_users = self.TDManager.getAllUsers() {
                filtered_users = retrieved_users.filter({$0.name.contains(text)})
            }
        }

        return NavigationView {
            VStack {
                HStack {
                    TextField("Search peeps...", text: $text)
                        .padding()
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                if isEditing {
                                    Button(action: {
                                        self.text = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")  // x out the query
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            self.isEditing = true
                        }
                    if isEditing {
                        Button(action: {
                            self.isEditing = false
                            self.text = ""
                        }) {
                            Text("Cancel")
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                    }
                }
                .padding()
                List {
                    ForEach(filtered_users, id: \.self) { user in
                        NavigationLink(destination: ProfileView(userProfile: ProfileViewModel(self.TDManager, user))) {
                            Text(user.name)
                        }
                    }
                                    
                }
            }
            .navigationBarTitle("Search")
        }
            
    }
}

