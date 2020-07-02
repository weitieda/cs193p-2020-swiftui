//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Tieda Wei on 2020-06-15.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Identifiable, Hashable, Equatable {
    
    static let palette = "🥳👍🏼💪🏼🦞"
    
    @Published private(set) var backgroundImage: UIImage?
    @Published private var emojiArt: EmojiArt
    
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero
    
    private var autosaveCancellable: AnyCancellable?
    private var fetchImageCancellable: AnyCancellable?
    
    let id: UUID
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    var backgroundUrl: URL? {
        get { emojiArt.backgroundURL }
        set { emojiArt.backgroundURL = newValue?.imageURL; fetchBackgroundImageData() }
    }
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultsKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink { emojiArt in
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
    }
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        guard let url = self.emojiArt.backgroundURL else { return }
        fetchImageCancellable?.cancel()
        fetchImageCancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .map {data, response in UIImage(data: data)}
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .assign(to: \.backgroundImage, on: self)
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
