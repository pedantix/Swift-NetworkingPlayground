//: WIP: - A Factory for simplifiing the construction of URL Request

import UIKit


import Foundation

enum MyServer {
  case service1, service2
}

enum HttpMethod: String {
  case post = "POST"
  case get = "GET"
  case delete = "DELETE"
  case patch = "PATCH"
}

struct UrlRequestFactory<T: Encodable> {
  struct RequestComponents {
    let method: HttpMethod
    let server: MyServer
    let path: String
    let payload: T?
    let params: [URLQueryItem]?

    init(method: HttpMethod, server: MyServer, path: String, payload: T? = nil, params: [URLQueryItem]? = nil) {
      self.method = method
      self.server = server
      self.path = path
      self.payload = payload
      self.params = params
    }
  }

  static func getRequest(for requestCompoents: RequestComponents) -> URLRequest? {
    let urlString = "\(getServerAddress(requestCompoents.server))/\(requestCompoents.path)"
    guard let urlComponents = NSURLComponents(string: urlString) else { return nil }
    urlComponents.queryItems = requestCompoents.params
    guard let url = urlComponents.url else { return nil }

    var request = URLRequest(url: url)
    request.httpMethod = requestCompoents.method.rawValue

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Setup Tokens and headers here

    if let payload = requestCompoents.payload {
      request.httpBody = try? MyCoders.shared.encoder.encode(payload)
    }

    return request
  }

  private static func getServerAddress(_ server: MyServer) -> String {
    switch server {
    case .service1:
      return "https://example.com/json"
    case .service2:
      return "https://example1.com/json"
    }
  }
}

// Things I will probably have in the app
struct MyCoders {
  static let shared = MyCoders()
  var decoder = JSONDecoder()
  var encoder = JSONEncoder()
}

let comps = UrlRequestFactory<[String: Codable]>.RequestComponents(method: .get,
                                                                   server: .service1,
                                                                   path: "myPath",
                                                                   payload: nil,
                                                                   params: nil)

guard let req = UrlRequestFactory.getRequest(for: comps) else { fatalError() }

print("oh my goodness \(req)")

