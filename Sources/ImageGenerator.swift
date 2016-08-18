import Foundation
import Tasks
import HTTP

struct Image {
    let data: Data
    let mimeType: String = "image/png"
}

extension Image: ResponseRepresentable {
    func makeResponse() throws -> Response {
        return Response(headers: ["Content-Type":mimeType], body: data)
    }
}

func loadImage(path: String) throws -> Image {
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    return Image(data: data)
}
