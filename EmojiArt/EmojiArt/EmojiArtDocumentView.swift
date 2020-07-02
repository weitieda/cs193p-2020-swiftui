//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Tieda Wei on 2020-06-15.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    private let defaultEmojiSize: CGFloat = 40
    
    @ObservedObject var document: EmojiArtDocument
    @State private var chosenPalette: String
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var isLoading: Bool { document.backgroundImage == nil && document.backgroundUrl != nil }
    private var zoomScale: CGFloat { document.steadyStateZoomScale * gestureZoomScale }
    private var panOffset: CGSize { (document.steadyStatePanOffset + gesturePanOffset) * zoomScale }
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: self.defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
            }
            
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    ).gesture(self.doubleTapToZoom(in: geometry.size))
                    
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text).font(animatableWithSize: emoji.fontSize * self.zoomScale).position(self.position(for: emoji, in: geometry.size))
                        }
                    }
                }
                .clipped()
                .gesture(self.panGesture()) // pan gesture has to come first?
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage) { self.zoomToFit($0, in: geometry.size) }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    // SwiftUI bug (as of 13.4)? the location is supposed to be in our coordinate system
                    // however, the y coordinate appears to be in the global coordinate system
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != self.document.backgroundUrl {
                        self.confirmBackgroundPaste = true
                    } else {
                        self.explainBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard")
                        .imageScale(.large)
                        .alert(isPresented: self.$explainBackgroundPaste) {
                            return Alert(
                                title: Text("Paste Background"),
                                message: Text("Copy the URL of an image to the clip board and touch this button to make it the background of your document."),
                                dismissButton: .default(Text("OK"))
                            )
                    }
                }))
            }
        }.alert(isPresented: self.$confirmBackgroundPaste) {
            Alert(
                title: Text("Paste Background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                primaryButton: .default(Text("OK")) {
                    self.document.backgroundUrl = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, inOutGestureState, transaction in
                inOutGestureState = latestGestureScale
            }
            .onEnded { (finalGestureScale) in
                self.document.steadyStateZoomScale = finalGestureScale
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.height > 0, image.size.width > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStatePanOffset = .zero
            self.document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + self.panOffset.width, y: location.y + self.panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundUrl = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
}

