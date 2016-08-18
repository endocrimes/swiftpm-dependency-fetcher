
import JSON

class ServerDataSource {
    
    let local: DB
    let server: CrossServerFetcher
    
    init(local: DB, server: CrossServerFetcher) {
        self.local = local
        self.server = server
    }
    
    func getPackage(name: String, tag: Tag) throws -> Package {
        do {
            return try local.getPackage(name: name, tag: tag)
        } catch ServerError.cacheMiss {
            //fetch and cache
            let package = try server.getPackage(name: name, tag: tag)
            try local.savePackage(package: package, name: name, tag: tag)
            return package
        }
    }
    
    func getTags(name: String) throws -> [Tag] {
        var info: ([Tag], String)? = nil
        do {
            info = try local.getTags(name: name)
        } catch ServerError.cacheMiss { }
        
        //ensure no new data on server
        switch try server.getTags(name: name, etag: info?.1) {
        case .notModified:
            return info!.0
        case .newData(let data):
            try local.saveTags(tags: data.0, name: name, etag: data.1)
            return data.0
        }
    }
    
}
