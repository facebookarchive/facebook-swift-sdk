// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/**
 A service used to fetch and store `Gatekeeper`'s associated with a particular
 application identifier
 */
public class GatekeeperService {
  private(set) var gatekeepers: [String: [Gatekeeper]] = [:]
  private(set) var graphConnectionProvider: GraphConnectionProviding
  private(set) var logger: Logging
  private(set) var store: GatekeeperStore
  private(set) var accessTokenProvider: AccessTokenProviding
  private(set) var settings: SettingsManaging
  private let oneHourInSeconds = TimeInterval(60 * 60)
  private var isLoading: Bool = false

  var isRequeryFinishedForAppStart: Bool = false

  var timestamp: Date?

  init(
    graphConnectionProvider: GraphConnectionProviding = GraphConnectionProvider(),
    logger: Logging = Logger(),
    store: GatekeeperStore = GatekeeperStore(),
    accessTokenProvider: AccessTokenProviding = AccessTokenWallet.shared,
    settings: SettingsManaging = Settings.shared
    ) {
    self.graphConnectionProvider = graphConnectionProvider
    self.logger = logger
    self.store = store
    self.accessTokenProvider = accessTokenProvider
    self.settings = settings
  }

  var isTimestampValid: Bool {
    guard let timestamp = timestamp else {
      return false
    }

    return timestamp.timeIntervalSince(Date()) < oneHourInSeconds
  }

  var isGatekeeperValid: Bool {
    return isRequeryFinishedForAppStart && isTimestampValid
  }

  var loadGatekeepersRequest: GraphRequest? {
    // TODO: Add timeout of 4.0 to this graph request

    let parameters = [
      "fields": "gatekeepers",
      "format": "json",
      "include_headers": "false",
      "platform": "ios",
      "sdk": "ios",
      "sdk_version": settings.sdkVersion
    ]

    guard let appIdentifier = settings.appIdentifier else {
      return nil
    }

    return GraphRequest(
      graphPath: .gatekeepers(appIdentifier: appIdentifier),
      parameters: parameters,
      flags: GraphRequest.Flags.doNotInvalidateTokenOnError
        .union(GraphRequest.Flags.disableErrorRecovery)
    )
  }

  /**
   Returns whether a `Gatekeeper` with a given name and application identifier exists
   and is enabled.

   - Parameter name: The name of the gatekeeper to retrieve
   - Parameter appIdentifier: The identifier that was used to fetch the
   `Gatekeeper` being retrieved, defaults to the app identifier stored in `Settings`

   - Returns: false if a) a `Gatekeeper` cannot be found under the given app identifier and name
   or b) the `Gatekeeper` is found but is not enabled
   */
  public func isGatekeeperEnabled(
    name: String,
    appIdentifier: String? = nil
    ) -> Bool {
    guard let gatekeeper = gatekeeper(name, forAppIdentifier: appIdentifier) else {
      return false
    }

    return gatekeeper.isEnabled
  }

  /**
   Attempts to retrieve a `Gatekeeper` with a given name and application identifier

   - Parameter name: The name of the gatekeeper to retrieve
   - Parameter appIdentifier: The identifier that was used to fetch the
   `Gatekeeper` being retrieved, defaults to the app identifier stored in `Settings`

   - Returns: a `Gatekeeper` if one is stored under the given app identifier and name
   */
  public func gatekeeper(
    _ name: String,
    forAppIdentifier appIdentifier: String? = nil
    ) -> Gatekeeper? {
    guard let identifier = appIdentifier ?? settings.appIdentifier else {
      return nil
    }

    return gatekeepers[identifier]?.first {
      $0.name == name
    }
  }

  /**
   Loads gatekeepers for a particular application identifier

   Will search `UserDefaults` first and caches the retrieved results locally
   if they are available.

   Values cached in `UserDefaults` are keyed to be associated with the
   application identifier that was used to fetch them.

   Values will be fetched from the server if it is the first time they are
   requested for an application identifier or if they are out of date
   (they expire within one hour)
   */
  public func loadGatekeepers() {
    guard let appIdentifier = settings.appIdentifier,
      let request = loadGatekeepersRequest
      else {
        logger.log(.developerErrors, "Missing app identifier. Please add one in Settings.")
        return
    }

    self.gatekeepers[appIdentifier] = store.cachedGatekeepers

    // Ensure it's valid for the current app identifier or that the store has data for the current app identifier
    guard !isGatekeeperValid || !store.hasDataForCurrentAppIdentifier,
      !isLoading
      else {
        return
    }

    isLoading = true

    _ = graphConnectionProvider
      .graphRequestConnection()
      .getObject(
        RemoteGatekeeperList.self,
        for: request
      ) { [weak self] result in
        guard let self = self else {
          return
        }

        self.isLoading = false
        self.isRequeryFinishedForAppStart = true

        switch result {
        case let .failure(error):
          self.logger.log(.networkRequests, error.localizedDescription)

        case let .success(remote):
          let list = GatekeeperListBuilder.build(from: remote)

          self.timestamp = Date()
          self.gatekeepers.updateValue(list, forKey: appIdentifier)
          self.store.cache(list)
        }
      }
  }
}
