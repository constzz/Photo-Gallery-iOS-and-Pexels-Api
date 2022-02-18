import Foundation

enum JSONError: Error {
    case decodingError
}

class NetworkDataFetcher {
    private let networkSevice: NetworkService
    private let jsonDecoder: JSONDecoder
    
    init(networkService: NetworkService, jsonDecoder: JSONDecoder) {
        self.networkSevice = networkService
        self.jsonDecoder = jsonDecoder
    }
    
    func fetchImages(searchQuery: String? = nil, completion: @escaping (Result<[Photo], Error>) -> Void) {
        try? networkSevice.request(searchQuery: searchQuery) { [weak self] result in
            if let photosData = try? self?.jsonDecoder.decode(
                PhotosData.self,
                from: result.get())
            {
                completion(.success(Array(photosData.photos)))
            } else {
                completion(.failure(JSONError.decodingError))
            }
        }
    }
}

