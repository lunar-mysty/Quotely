//
//  ContentView.swift
//  Quotely
//
//  Created by Leo Ross on 5/30/24.
//

import SwiftUI
import Foundation
import Combine

struct Quote: Codable {
    let _id: String
    let content: String
    let author: String
    let tags: [String]
    let authorSlug: String
    let length: Int
    let dateAdded: String
    let dateModified: String
}

class QuoteFetcher: ObservableObject {
    @AppStorage("quote") private var quote: String = ""
    @AppStorage("author") private var author: String = ""
    @AppStorage("quoteType") private var quoteType: Int = 1
    @State private var quoteTag: String = ""

    private var cancellable: AnyCancellable?

    func fetchQuote() {
        if quoteType == 1 {
            quoteTag = "inspirational"
        } else if quoteType == 2 {
            quoteTag = "age"
        } else if quoteType == 3 {
            quoteTag = "art"
        } else if quoteType == 4 {
            quoteTag = "attitude"
        } else if quoteType == 5 {
            quoteTag = "courage"
        } else if quoteType == 6 {
            quoteTag = "education"
        } else if quoteType == 7 {
            quoteTag = "equality"
        } else if quoteType == 8 {
            quoteTag = "faith"
        } else if quoteType == 9 {
            quoteTag = "family"
        } else if quoteType == 10 {
            quoteTag = "friendship"
        } else if quoteType == 11 {
            quoteTag = "funny"
        } else if quoteType == 12 {
            quoteTag = "future"
        } else if quoteType == 13 {
            quoteTag = "happiness"
        } else if quoteType == 14 {
            quoteTag = "success"
        }
        guard let url = URL(string: "https://api.quotable.io/quotes/random?tags=\(quoteTag)") else {
            print("Invalid URL")
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Quote].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching quote: \(error)")
                }
            }, receiveValue: { [weak self] quotes in
                if let firstQuote = quotes.first {
                    self?.quote = firstQuote.content
                    self?.author = firstQuote.author
                }
            })
    }
}

func loadArray() -> [String] {
    @AppStorage("favoritesArray") var favoritesArrayData: Data = Data()
    if let array = try? JSONDecoder().decode([String].self, from: favoritesArrayData ) {
        return array
    }
    return []
}

func appendArray(_ newElements: [String]) {
    @AppStorage("favoritesArray") var favoritesArrayData: Data = Data()
    var currentArray = loadArray()
    currentArray.append(contentsOf: newElements)
    if let data = try? JSONEncoder().encode(currentArray) {
        favoritesArrayData = data
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            TabView() {
                HomeView().tabItem {
                    Label("Home", systemImage: "house")
                }
                SettingsView().tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                FavoritesView().tabItem {
                    Label("Favorites", systemImage: "star")
                }
            }
        }
    }
}

struct HomeView: View {
    @State private var showInfoBubble = false
    @AppStorage("favoritesArray") private var favoritesArrayData: Data = Data()
    @AppStorage("largerFont") private var largerFont: Bool = false
    @AppStorage("quote") private var quote: String = ""
    @AppStorage("author") private var author: String = ""
    @StateObject private var quoteFetcher = QuoteFetcher()
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if largerFont {
                        Text("\"\(quote)\"").font(.largeTitle).multilineTextAlignment(.center).padding()
                    } else {
                        Text("\"\(quote)\"").font(.title).multilineTextAlignment(.center).padding()
                    }
                    Text("- \(author)").multilineTextAlignment(.center).padding([.leading, .bottom, .trailing])
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ShareLink(item: "\"\(quote)\" - \(author)")
                        {
                            Label("Share Quote", systemImage: "square.and.arrow.up")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { // Favorite Quote
                            appendArray([quote, "- \(author)"])
                            withAnimation {
                                showInfoBubble = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showInfoBubble = false
                                }
                            }
                        }) {
                            Label("Favorite Quote", systemImage: "star")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("New Quote", systemImage: "arrow.clockwise") {
                            quoteFetcher.fetchQuote()
                        }
                    }
                }
                if showInfoBubble {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Added Quote to Favorites")
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .padding(.bottom, 25)
                                .shadow(radius: 20)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            quoteFetcher.fetchQuote()
        }
    }
}

struct SettingsView: View {
    @AppStorage("largerFont") private var largerFont: Bool = false
    @AppStorage("quoteType") private var quoteType: Int = 1
    var body: some View {
        NavigationStack {
            Form {
                Picker(selection: $quoteType, label: Text("Quote Type")) {
                    Text("Inspirational").tag(1)
                    Text("Age").tag(2)
                    Text("Art").tag(3)
                    Text("Attitude").tag(4)
                    Text("Courage").tag(5)
                    Text("Education").tag(6)
                    Text("Equality").tag(7)
                    Text("Faith").tag(8)
                    Text("Family").tag(9)
                    Text("Friendship").tag(10)
                    Text("Funny").tag(11)
                    Text("Future").tag(12)
                    Text("Happiness").tag(13)
                    Text("Success").tag(14)
                }
                Toggle(isOn: $largerFont) {
                    Text("Larger Quote Font")
                }
                NavigationLink(destination: NotificationSettingsView()) {
                    Text("Notifications")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct NotificationSettingsView: View {
    @AppStorage("notifs") private var notifs: Bool = false
    var body: some View {
        NavigationStack {
            Form {
                Toggle(isOn: $notifs) {
                    Text("Show Notifications")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Notifications")
        }
    }
}

struct FavoritesView: View {
    @State private var favoritesArray: [String] = []
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<favoritesArray.count/2, id: \.self) { index in
                    LazyVStack {
                        Text("\"\(favoritesArray[index * 2])\"")
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            
                        Text(favoritesArray[index * 2 + 1])
                            .multilineTextAlignment(.center)
                            .padding(1.0)
                            
                        ShareLink(item: "\"\(favoritesArray[index * 2])\" \(favoritesArray[index * 2 + 1])") {
                            Label("Share Quote", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                .onDelete(perform: deleteItem)
            }
            .navigationTitle("Favorites")
            .onAppear {
                favoritesArray = loadArray()
            }
        }
    }
    func saveArray(_ array: [String]) {
        if let data = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(data, forKey: "favoritesArray")
        }
    }
    func deleteItem(at offsets: IndexSet) {
        @AppStorage("favoritesArray") var favoritesArrayData: Data = Data()
        offsets.forEach { index in
            let realIndex = index * 2
            favoritesArray.remove(at: realIndex)
            if realIndex < favoritesArray.count {
                favoritesArray.remove(at: realIndex)
            }
        }
        saveArray(favoritesArray)
    }
}

#Preview {
    ContentView()
}
