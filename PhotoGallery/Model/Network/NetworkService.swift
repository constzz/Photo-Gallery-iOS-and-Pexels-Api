import Foundation

enum NetworkSeviceError: Error {
    case baseUrlMalformed
    case urlMalformed
    case badResponseStatusCode(Int)
}

class NetworkService {
    
    func request(searchQuery: String? = nil, completion: @escaping (Result<Data, Error>) -> Void) throws {
        let parameters = prepareParameters(searchQuery: searchQuery)
        let url = try formUrl(with: parameters, searchQuery: searchQuery)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = prepareHeader()
        request.httpMethod = "GET"
        resumeDataTask(urlRequest: request) { (result) in
            completion(result)
        }
    }
    
    private func prepareHeader() -> [String: String] {
        var headers = [String: String]()
        headers["Authorization"] = K.apiKey
        return headers
    }
    
    private func prepareParameters(searchQuery: String? = nil) -> [String:String] {
        var parameters = [String: String]()
        parameters["page"] = String(1)
        parameters["per_page"] = String(K.photosInResponseAmount)
        return parameters
    }

    private func formUrl(with parameters: [String: String]? = nil, searchQuery: String? = nil) throws -> URL {
        guard var urlComponents = URLComponents(
            //Showing curated photos if there is no search query
            string: searchQuery.isNilOrEmpty
                        ? K.photoBaseUrlCurated
                        : K.photoBaseUrlForSearch
        ) else {
            throw NetworkSeviceError.baseUrlMalformed
        }
        urlComponents.queryItems = []
        if searchQuery.isNotNilOrBlank {
            urlComponents.queryItems?.append(URLQueryItem(
                name: "query",
                value: searchQuery)
            )
        }
        if let parameters = parameters {
            urlComponents.queryItems?.append(contentsOf:
                parameters.map { (URLQueryItem(name: $0, value: $1)) }
            )
        }
        guard let url = urlComponents.url else {
            throw NetworkSeviceError.urlMalformed
        }
        return url
    }
    
    private func resumeDataTask(urlRequest: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            }
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               let data = data {
                completionHandler(.success(data))
            }
        }
        task.resume()
    }
}



//Using new async API to simplify code
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension NetworkService {

    func request(searchQuery: String? = nil) async throws -> Data {
        let parameters = prepareParameters(searchQuery: searchQuery)
        let url = try formUrl(with: parameters, searchQuery: searchQuery)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = prepareHeader()
        request.httpMethod = "GET"
        return try await resumeDataTask(urlRequest: request)
    }

    private func resumeDataTask(urlRequest: URLRequest) async throws -> Data {
        let (data,response) = try await URLSession.shared.data(for: urlRequest, delegate: nil)
        if let statusCode = (response as? HTTPURLResponse)?.statusCode,
              statusCode != 200 {
            throw NetworkSeviceError.badResponseStatusCode(statusCode)
        }
        return data
    }

}
