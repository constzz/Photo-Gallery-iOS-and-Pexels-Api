import UIKit
import RealmSwift

typealias DatabaseQueue = dispatch_queue_serial_t

class DependencyProvider {
    private static var jsonDecoder: JSONDecoder {
        return JSONDecoder()
    }
    private static var userDefaults: UserDefaults {
        return UserDefaults()
    }
    private static let databaseQueue =  DispatchQueue(label: "database") as! DatabaseQueue
    private static var realm: Realm {
        databaseQueue.sync {
            return try! Realm()
        }
    }
    
    //MARK: Network
    private static var networkService: NetworkService {
        return NetworkService()
    }
    private static var networkDataFetcher: NetworkDataFetcher {
        return NetworkDataFetcher(networkService: self.networkService, jsonDecoder: self.jsonDecoder)
    }
    //MARK: Data Sources
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
    //MARK: ViewModels
    private static var photosViewModel: PhotosViewModel {
        return PhotosViewModel(dataSource: self.dataSource)
    }
    //MARK: Views
    static var photosViewController: UINavigationController {
        return UINavigationController(rootViewController: PhotosCollectionViewController(photosViewModel: photosViewModel))
    }
    
}
