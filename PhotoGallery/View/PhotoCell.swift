import UIKit
import SDWebImage

class PhotoCell: UICollectionViewCell {
    //MARK: Constants
    static let reuseId = "PhotoCell"
    
    //MARK: Properties
    var photo: Photo! {
        didSet {
            if let photoUrl = photo.src?.medium,
               let url = URL(string: photoUrl) {
                photoImageView.sd_setImage(with: url, completed: {_, error,_,_ in
                        if let error = error {
                            print("Sd web image error for PhotoCell:" + error.localizedDescription)
                            return
                        }
                    })
            } else {
                print("Image url is nil for photo:\(String(describing: photo))")
            }
        }
    }
    
    lazy var photoImageView: UIImageView = makePhotoImageView()

    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Overrides
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
    }
    
    //MARK: Methods
    private func setupImageView() {
        addSubview(photoImageView)
        photoImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func makePhotoImageView(url: URL? = nil) -> UIImageView {
        let imageView =  UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }
}

