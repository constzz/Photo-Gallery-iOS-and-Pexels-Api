import Foundation
import RealmSwift

protocol LocalDataSourceProtocol {
    func fetchCachedPhotos(completion: @escaping (Result<[Photo], Error>) -> Void)
    func cachePhotos(photos: [Photo])
}

class LocalDataSource: LocalDataSourceProtocol {
    let databaseQueue: DatabaseQueue
    let userDefaults: UserDefaults
    
    init(databaseQueue: DatabaseQueue, userDefaults: UserDefaults) {
        self.databaseQueue = databaseQueue
        self.userDefaults = userDefaults
    }
    
    func cachePhotos(photos: [Photo]) {
        databaseQueue.sync {
            do {
                let realm = try Realm()
                if realm.isInWriteTransaction {
                    realm.cancelWrite()
                }
                try realm.write({
                    realm.deleteAll()
                    for photo in photos {
                        photo.isDataCached = true
                        realm.add(photo)
                    }
                })
                self.userDefaults.set(true, forKey: K.UserDefaultsKeys.hasPhotosCached)
                print("Photos are cached")
            } catch {
                print("Error trying to cache photos: \(error)")
                self.userDefaults.set(false, forKey: K.UserDefaultsKeys.hasPhotosCached)
            }
        }
    }
    
    func fetchCachedPhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        databaseQueue.sync {
            do {
                let realm = try Realm()
                if realm.isInWriteTransaction {
                    realm.cancelWrite()
                }
                completion(.success(Array(realm.objects(Photo.self))))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    
}
