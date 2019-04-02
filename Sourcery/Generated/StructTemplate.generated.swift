// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



  @objc(FBSDKAccessTokenStruct)
  class _ObjCAccessTokenStruct: NSObject {
    private(set) var accessTokenStruct: AccessTokenStruct

    // Initializer to be used from Swift
    init(accessTokenStruct: AccessTokenStruct) {
      self.accessTokenStruct = accessTokenStruct
    }


    // Forwarding property for native types
    var identifier: String
    {
        get {
            return self.accessTokenStruct.identifier
        }
    }

    // Forwarding property for native types
    var code: Int
    {
        get {
            return self.accessTokenStruct.code
        }
    }
  }
