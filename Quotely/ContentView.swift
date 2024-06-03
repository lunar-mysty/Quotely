//
//  ContentView.swift
//  Quotely
//
//  Created by Leo Ross on 5/30/24.
//

import SwiftUI
import Foundation
import Combine
import PhotosUI

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
    @AppStorage("customFontColor") private var customFontColor: Bool = false
    @AppStorage("quote") private var quote: String = ""
    @AppStorage("author") private var author: String = ""
    @AppStorage("fontColorR") private var fontColorR: Double = 1.0
    @AppStorage("fontColorG") private var fontColorG: Double = 0.0
    @AppStorage("fontColorB") private var fontColorB: Double = 0.0
    @StateObject private var quoteFetcher = QuoteFetcher()
    @State private var offset = CGSize.zero
    @State private var screenWidth = UIScreen.main.bounds.width
    @State private var screenHeight = UIScreen.main.bounds.height

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if largerFont {
                        if customFontColor {
                            Text("\"\(quote)\"")
                                .font(.largeTitle)
                                .foregroundColor(Color(red: fontColorR, green: fontColorG, blue: fontColorB, opacity: 1.0))
                                .multilineTextAlignment(.center)
                                .padding()
                                .offset(x: offset.width, y: offset.height)
                                .animation(.easeInOut(duration: 0.5), value: offset)
                        } else {
                            Text("\"\(quote)\"")
                                .font(.largeTitle)
                                .multilineTextAlignment(.center)
                                .padding()
                                .offset(x: offset.width, y: offset.height)
                                .animation(.easeInOut(duration: 0.5), value: offset)
                        }
                    } else {
                        if customFontColor {
                            Text("\"\(quote)\"")
                                .font(.title)
                                .foregroundColor(Color(red: fontColorR, green: fontColorG, blue: fontColorB, opacity: 1.0))
                                .multilineTextAlignment(.center)
                                .padding()
                                .offset(x: offset.width, y: offset.height)
                                .animation(.easeInOut(duration: 0.5), value: offset)
                        } else {
                            Text("\"\(quote)\"")
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding()
                                .offset(x: offset.width, y: offset.height)
                                .animation(.easeInOut(duration: 0.5), value: offset)
                        }
                    }
                    if customFontColor {
                        Text("- \(author)")
                            .foregroundColor(Color(red: fontColorR, green: fontColorG, blue: fontColorB, opacity: 1.0))
                            .multilineTextAlignment(.center)
                            .padding([.leading, .bottom, .trailing])
                            .offset(x: offset.width, y: offset.height)
                            .animation(.easeInOut(duration: 0.5), value: offset)
                    } else {
                        Text("- \(author)")
                            .multilineTextAlignment(.center)
                            .padding([.leading, .bottom, .trailing])
                            .offset(x: offset.width, y: offset.height)
                            .animation(.easeInOut(duration: 0.5), value: offset)
                    }
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
                                .shadow(radius: 10)
                            Spacer()
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        let flingDirection = CGSize(width: gesture.translation.width * 4, height: gesture.translation.height * 4)
                        offset = flingDirection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            offset = .zero
                            quoteFetcher.fetchQuote()
                        }
                    }
            )
        }
        .onAppear {
            quoteFetcher.fetchQuote()
        }
    }
}

struct SettingsView: View {
    @AppStorage("largerFont") private var largerFont: Bool = false
    @AppStorage("quoteType") private var quoteType: Int = 1
    @AppStorage("customFontColor") private var customFontColor: Bool = false
    @AppStorage("fontColorR") private var fontColorR: Double = 1.0
    @AppStorage("fontColorG") private var fontColorG: Double = 0.0
    @AppStorage("fontColorB") private var fontColorB: Double = 0.0
    @State private var fontColorSel: Color = .red
    @State private var isColorPickerPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                } header: {
                    Text("General")
                }
                Section {
                    Toggle(isOn: $customFontColor) {
                        Text("Custom Quote Font Color")
                    }
                    if customFontColor {
                        ColorPicker("Quote Font Color", selection: $fontColorSel)
                            .onChange(of: fontColorSel) { newColor in
                                assignRGBValues(from: newColor)
                            }
                    }
                } header: {
                    Text("Appearance")
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            loadStoredColor()
        }
    }
    
    private func assignRGBValues(from color: Color) {
        if let cgColor = color.cgColor, let components = cgColor.components, components.count >= 3 {
            fontColorR = Double(components[0])
            fontColorG = Double(components[1])
            fontColorB = Double(components[2])
        }
    }
    
    private func loadStoredColor() {
        fontColorSel = Color(red: fontColorR, green: fontColorG, blue: fontColorB)
    }
}

struct FavoritesView: View {
    @State private var favoritesArray: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                if favoritesArray.isEmpty {
                    Text("No favorites yet!")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
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
                }
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
