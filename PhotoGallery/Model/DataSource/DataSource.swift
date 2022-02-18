import Foundation

protocol DataSourceProtocol {
    var localStorage: LocalDataSourceProtocol { get }
    var remoteDataSource: RemoteDataSourceProtocol { get }
    func getPhotos(by searchQuery: String, completion: @escaping (Result<[Photo], Error>) -> ())
}

class DataSource: DataSourceProtocol {
    
    let localStorage: LocalDataSourceProtocol
    let remoteDataSource: RemoteDataSourceProtocol
    let userDefaults: UserDefaults
    
    init(
        localStorage: LocalDataSourceProtocol,
        remoteDataSource: RemoteDataSourceProtocol,
        userDefaults: UserDefaults
    ) {
        self.localStorage = localStorage
        self.remoteDataSource = remoteDataSource
        self.userDefaults = userDefaults
    }
    
    func getPhotos(
        by searchQuery: String = "",
        completion: @escaping (Result<[Photo], Error>) -> ()
    ) {
        if userDefaults.bool(forKey: K.UserDefaultsKeys.hasPhotosCached) && searchQuery.isBlank {
            remoteDataSource.stopAllPendingNetworkRequests()
            localStorage.fetchCachedPhotos { result in
                completion(result)
                print("Has got result from local")
            }
        } else {
            remoteDataSource.fetchPhotos(by: searchQuery) { [weak self] result in
                switch result {
                case .success(let photos):
                    completion(.success(photos))
                    self?.userDefaults.set(false ,forKey: K.UserDefaultsKeys.hasPhotosCached)
                    if searchQuery.isBlank {
                        self?.localStorage.cachePhotos(photos: Array(photos[0...K.photosAmountDataToSaveInCache]))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
                print("Has got result from remote")
            }
        }
    }
    
    
}
