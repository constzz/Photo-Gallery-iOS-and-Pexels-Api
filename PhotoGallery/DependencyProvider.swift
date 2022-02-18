import UIKit
import RealmSwift

typealias DatabaseQueue = dispatch_queue_serial_t

class DependencyProvider {
    static var jsonDecoder: JSONDecoder {
        return JSONDecoder()
    }
    private static var userDefaults: UserDefaults {
        return UserDefaults()
    }
    private static var networkService: NetworkService {
        return NetworkService()
    }
    private static let databaseQueue: DatabaseQueue = DispatchQueue(label: "database") as! DatabaseQueue
    private static var networkDataFetcher: NetworkDataFetcher {
        return NetworkDataFetcher(networkService: self.networkService, jsonDecoder: self.jsonDecoder)
    }
    private static var localDataSource: LocalDataSourceProtocol {
        return LocalDataSource(databaseQueue: self.databaseQueue, userDefaults: self.userDefaults)
    }
    private static var remoteDataSource: RemoteDataSourceProtocol {
        return RemoteDataSource(networkDataFetcher: networkDataFetcher)
    }
    private static var dataSource: DataSourceProtocol {
        return DataSource(
            localStorage: self.localDataSource,
            remoteDataSource: self.remoteDataSource,
            userDefaults: self.userDefaults
        )
    }
    private static var photosViewModel: PhotosViewModel {
        return PhotosViewModel(dataSource: self.dataSource)
    }
    
    static var photosViewController: UINavigationController {
        return UINavigationController(rootViewController: PhotosCollectionViewController(photosViewModel: photosViewModel))
    }
    
}
