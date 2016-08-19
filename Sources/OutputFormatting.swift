
enum OutputFormat: String {
    case json //default
    case png
    case dot
    case d3json
    case d3
    //TODO: plain text with ascii arrows?
}

import HTTP
import JSON
import Foundation

extension OutputFormat {
    
    func format(graph: DependencyGraph) throws -> Response {
        
        switch self {
            
        case .json:
            return try JSON(node: graph.makeNode()).makeResponse()
            
        case .dot:
            let dot = graph.asDOT()
            let response = dot.makeResponse()
            response.headers["Content-Type"] = "text/vnd.graphviz"
            return response
            
        case .png:
            let gv = graph.asDOT()
            guard let data = gv.data(using: .utf8) else {
                throw ServerError.dataConversion
            }
            let results = try Task.run(["dot", "-T", "png"], data: data)
            let png = Image(data: results.stdout)
            return try png.makeResponse()
            
        case .d3json:
            let d3 = try graph.asD3()
            return d3.makeResponse()
            
        case .d3: fatalError()
        }
    }
}
