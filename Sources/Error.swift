
enum ServerError: Error {
    case missingQuery
    case nonexistentRepo(String)
    case noData
    case unparsablePackageContents
    case convertFailed
    case failedTags
    case dependencyGraphCannotBeSatisfied(Versions, [Tag])
    case dependencyGraphConflict(Dependency, String)
    case locationHeaderMissing
    case invalidVersion(String)
}

