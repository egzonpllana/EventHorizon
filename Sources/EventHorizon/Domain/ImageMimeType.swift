import Foundation

public enum ImageMimeType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case bmp = "image/bmp"
    case tiff = "image/tiff"
    case svg = "image/svg+xml"
    
    /// Returns the corresponding MIME type string for the image format.
    public var asString: String {
        return self.rawValue
    }
}
