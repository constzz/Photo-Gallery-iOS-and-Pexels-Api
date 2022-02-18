import Foundation

protocol RemoteDataSourceProtocol {
    func fetchPhotos(by searchQuery: String, completion: @escaping (Result<[Photo], Error>) -> Void)
    func stopAllPendingNetworkRequests()
}

class RemoteDataSource: RemoteDataSourceProtocol {
    
    ///The delay for network requests
    private let requestDelay = 0.5
    
    let networkDataFetcher: NetworkDataFetcher
    private var networkTimer: Timer?
    
    init(networkDataFetcher: NetworkDataFetcher) {
        self.networkDataFetcher = networkDataFetcher
    }
    
    func fetchPhotos(by searchQuery: String =  "", completion: @escaping (Result<[Photo], Error>) -> Void) {
        stopAllPendingNetworkRequests()
        networkTimer = Timer.scheduledTimer(
            withTimeInterval: requestDelay,
            repeats: false,
            block: { [weak self] _ in
            self?.networkDataFetcher.fetchImages(searchQuery: searchQuery, completion: { result in
                   completion(result)
            })
        })
    }
    
    func stopAllPendingNetworkRequests() {
        networkTimer?.invalidate()
    }
    
}


