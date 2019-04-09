//
//  Graph.swift
//  FacebookCore
//
//  Created by Joe Susnick on 4/8/19.
//  Copyright © 2019 Facebook Inc. All rights reserved.
//

import Foundation

struct SampleError: Error {}

struct RemoteUser: Decodable {
  let identifier: Graph.RemoteObjectIdentifier
  let full_name: String
}

enum UserSource {
  struct User {
    let name: String
  }

  enum UserBuilder {
    static func build(from remoteUser: RemoteUser) throws -> User {
      throw SampleError()
    }
  }

  // @async
  static func getUser(completionHandler: (Result<User, Error>) -> Void) {
    Graph.getObject(ofType: RemoteUser.self, identifiedBy: "some-id") { fetchResult in
      let result: Result<User, Error>

      defer {
        completionHandler(result)
      }

      switch fetchResult {
      case .success(let remoteUser):
        do {
          let user = try UserBuilder.build(from: remoteUser)
          result = .success(user)
        } catch {
          result = .failure(error)
        }

      case .failure(let error):
        result = .failure(error)
      }
    }
  }
}

public enum Graph {
  typealias DecodableRemoteType = Decodable
  typealias RemoteObjectIdentifier = String

  // Really looks differently
  enum ApiError: String, Decodable, Error {
    case unauthenticated
    case unauthorized
  }

  // @async
  static func getObject<RemoteType: Decodable>(
    ofType remoteType: RemoteType.Type,
    identifiedBy identifier: RemoteObjectIdentifier,
    completionHandler: (Result<RemoteType, Error>) -> Void
    ) {
    fetchObject(identifiedBy: identifier) { fetchResult in
      let result: Result<RemoteType, Error>
      defer { completionHandler(result) }

      switch fetchResult {
      case .success(let data):
        result = convertFetchDataToObjectResult(data: data, remoteType: remoteType)

      case .failure(let error):
        result = .failure(error)
      }
    }
  }

  private static func convertFetchDataToObjectResult<RemoteType: Decodable>(
    data: Data,
    remoteType: RemoteType.Type
    ) -> Result<RemoteType, Error> {
    if let apiError = try? Parser.parse(data: data, for: ApiError.self) {
      return .failure(apiError)
    } else {
      do {
        let object = try Parser.parse(data: data, for: remoteType)
        return .success(object)
      } catch {
        return .failure(error)
      }
    }
  }

  // @async
  // sourcery: exposeInternal
  internal static func fetchObject(
    identifiedBy identifier: RemoteObjectIdentifier,
    completionHandler: (Result<Data, Error>) -> Void
    ) {
    // Probably do token refreshing at this level, token stuff should stay close to the server.

    // create URL, run task, etc. - either data retrieved or networking failure
    completionHandler(.failure(SampleError()))
  }
}

public enum Parser {
  public static func parse<RemoteType: Decodable>(data: Data, for remoteType: RemoteType.Type) throws -> RemoteType {
    return try JSONDecoder().decode(remoteType, from: data)
  }

  // sourcery: exposeInternal
  static func getSomeData() -> Data {
    return Data()
  }

  static func doNotExposeGetSomeData() -> Data {
    return Data()
  }
}

extension Parser: ObjCBridgeable {}
extension Graph: ObjCBridgeable {}
