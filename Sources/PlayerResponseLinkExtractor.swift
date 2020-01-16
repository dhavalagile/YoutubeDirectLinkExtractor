import Foundation

enum PlayerResponseLinkExtractor {

    private enum Error: LocalizedError {
        case badDataFormat
        case responseTypeError
        case missingStreamingData
        case missingAdaptiveFormats

        var errorDescription: String? {
            switch self {
            case .badDataFormat:
                return "Unable to convert response to UTF8 data"
            case .responseTypeError:
                return "Unable to parse player response"
            case .missingStreamingData:
                return "Unable to parse streaming data"
            case .missingAdaptiveFormats:
                return "Unable to parse adaptive formats"
            }
        }
    }

    private enum Key {
        static let streamingData = "streamingData"
        static let adaptiveFormats = "adaptiveFormats"
        static let quality = "quality"
        static let url = "url"
    }

    // Return type to match VideoInfo rawInfo
    static func extractLinks(from playerResponse: String) throws -> [[String: String]] {
        guard let data = playerResponse.data(using: .utf8) else { throw Error.badDataFormat }
        guard let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { throw Error.responseTypeError }
        guard let streamingData = object[Key.streamingData] as? [String: Any] else { throw Error.missingStreamingData }
        guard let adaptiveFormats = streamingData[Key.adaptiveFormats] as? [[String: Any]] else { throw Error.missingAdaptiveFormats }
        return adaptiveFormats.compactMap { format -> [String: String]? in
            guard let quality = format[Key.quality] as? String, let url = format[Key.url] as? String else { return nil }
            return [
                Key.quality: quality,
                Key.url: url
            ]
        }
    }
}
