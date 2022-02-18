import UIKit

class PhotoPreviewProvider: UIViewController {
    
    private let imageUrl: URL
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    var image: UIImage?
    
    init(imageUrl: URL) {
        self.imageUrl = imageUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupAutolayout()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews(){
        view.addSubview(imageView)
        view.addSubview(activityIndicator)
    }
    
    private func setupAutolayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSubviews() {
        activityIndicator.startAnimating()
        imageView.sd_setImage(with: imageUrl, completed: { [weak self] downloadedImage, error,_,_ in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self?.activityIndicator.stopAnimating()
                self?.image = downloadedImage
            }
        )
    }
}

