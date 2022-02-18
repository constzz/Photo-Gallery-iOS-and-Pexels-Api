import UIKit
import CollectionViewWaterfallLayout
import Toast

class PhotosCollectionViewController: UICollectionViewController {
    
    //MARK: ColletionView Constants
    private let itemsInRow = 3
    
    //MARK: Properties
    private var photosViewModel: PhotosViewModel
    private var photos: Array<Photo>? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: Initializers
    init(photosViewModel: PhotosViewModel) {
        self.photosViewModel = photosViewModel
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    deinit {
        photosViewModel.error.remove(observer: self)
        photosViewModel.photos.remove(observer: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
        setupSearchBar()
        setupBinding()
    }
    
    //MARK: Methods
    private func setupBinding() {
        photosViewModel.photos.observe(on: self) { [weak self] photos in
            self?.photos = photos
        }
        photosViewModel.error.observe(on: self) { [weak self] error in
            if let error = error {
                self?.view.makeToast("Unable to load photos. Please try again later.")
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: UI Setup funcitons
extension PhotosCollectionViewController {
    private func setupNavigationBar() {
        let label = UILabel()
        label.text = "Pexels Photos API"
        
        navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
        
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupCollectionView() {
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseId)
    }

}

//MARK: UISearchBarDelegate
extension PhotosCollectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        photosViewModel.searchQuery.value = searchText
    }
}

//MARK: UICollectionViewDelegate, CollectionViewDataSource
extension PhotosCollectionViewController: CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.width / CGFloat(itemsInRow) - CGFloat(10)
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        
        guard let selectedPhoto = photos?[indexPath.row],
            selectedPhoto.isDataCached == false else {
                return nil
            }
        
        func shareImage(image: UIImage?) {
            guard let image = image else {
                print("Image in conetext menu is nil. Nothing to share.")
                return
            }
            let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(ac, animated: true)
        }
        
        func saveImage(image: UIImage?) {
            guard let image = image else {
                print("Image in conetext menu is nil. Nothing to save.")
                return
            }
            ImageSaver().writeToPhotoAlbum(image: image)
        }
        
        var url: String?

        url = selectedPhoto.src?.original
        
        guard let url = url else {
            return nil
        }
 
        let photoPreviewProvider = PhotoPreviewProvider(imageUrl: URL(string: url)!)
        
        func photoPreview() -> UIViewController {
            return photoPreviewProvider
        }
        
        let shareButton = UIAction(
            title: "Share",
            image: UIImage(systemName: "square.and.arrow.up"),
            identifier: nil,
            discoverabilityTitle: nil,
            state: (photoPreviewProvider.image == nil) ? .off : .on
        ) { _ in
            shareImage(image: photoPreviewProvider.image)
        }
        
        let saveButton = UIAction(
            title: "Save to gallery",
            image: UIImage(systemName: "square.and.arrow.down"),
            identifier: nil,
            discoverabilityTitle: nil,
            state: (photoPreviewProvider.image == nil) ? .off : .on
        ) { _ in
            saveImage(image: photoPreviewProvider.image)
        }
        
        let configuration = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: photoPreview,
            actionProvider: { (_: [UIMenuElement]) -> UIMenu in
                return UIMenu(
                    title: "",
                    subtitle: nil,
                    image: nil,
                    identifier: .share,
                    options: .displayInline,
                    children: [shareButton, saveButton]
                )
            }
        )
        
        return configuration
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as! PhotoCell
        cell.photo = photos?[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
}
