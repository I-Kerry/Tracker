
import Foundation

enum ApiForMertica {    
    static let apiKey = "33181269-9be0-4315-8923-1a4ffc4feb89"
}

enum EmojiArray {
    static let emojiArray = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
}

enum MainScreenEvent: String {
    case open
    case close
    case click
}

enum Screen: String {
    case main
    case additional
}

enum Item: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}
