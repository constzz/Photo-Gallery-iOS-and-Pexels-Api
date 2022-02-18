import Foundation

class PhotosViewModel {
    
    let dataSource: DataSourceProtocol
        
    var photos = Observable(Array<Photo>())
    var error = Observable<Error?>(nil)
    var searchQuery = Observable<String>("") 
        
    init(dataSource: DataSourceProtocol) {
        self.dataSource = dataSource
        searchQuery.observe(on: self) { searchQuery in
            self.fetchImages(bySearchQuery: searchQuery)
        }
    }
    
    deinit {
        searchQuery.remove(observer: self)
    }
        
    private func fetchImages(bySearchQuery searchQuery: String) {
        dataSource.getPhotos(by: searchQuery) { result in
            switch result {
            case .success(let photos):
                self.photos.value = photos
            case .failure(let error):
                self.error.value = error
            }
        }
    }
}

