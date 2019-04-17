//  Converted to Swift 4 by Swiftify v4.2.38216 - https://objectivec2swift.com/
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

import FBSDKCoreKit
import FBSDKShareKit
import Foundation
import UIKit

private let kTaggedPlaceID = "110843418940484"

class FBSDKShareAPIIntegrationTests: FBSDKIntegrationTestCase, FBSDKSharingDelegate, FBSDKVideoUploaderDelegate {
    private var fileHandle: FileHandle?

    var shareCallback: ((_ results: [AnyHashable : Any]?, _ error: Error?, _ isCancel: Bool) -> Void)?
    var uploadCallback: ((_ results: [AnyHashable : Any]?, _ error: Error?) -> Void)?

// MARK: - FBSDKSharingDelegate
    func sharer(_ sharer: FBSDKSharing?, didCompleteWithResults results: [AnyHashable : Any]?) {
        if shareCallback != nil {
            shareCallback?(results, nil, false)
            shareCallback = nil
        }
    }

    func sharer(_ sharer: FBSDKSharing?) throws {
        if shareCallback != nil {
            shareCallback?(nil, error, false)
            shareCallback = nil
        }
    }

    func sharerDidCancel(_ sharer: FBSDKSharing?) {
        if shareCallback != nil {
            shareCallback?(nil, nil, true)
            shareCallback = nil
        }
    }

// MARK: - FBSDKVideoUploaderDelegate
    func videoChunkData(for videoUploader: FBSDKVideoUploader?, startOffset: Int, endOffset: Int) -> Data? {
        let chunkSize: Int = endOffset - startOffset
        fileHandle?.seek(toFileOffset: UInt64(startOffset))
        let videoChunkData = fileHandle?.readData(ofLength: chunkSize)
        if videoChunkData == nil || (videoChunkData?.count ?? 0) != chunkSize {
            assert(videoChunkData == nil || (videoChunkData?.count ?? 0) != chunkSize, "fail to get video chunk")
            return nil
        }
        return videoChunkData
    }

    func videoUploader(_ videoUploader: FBSDKVideoUploader?, didCompleteWithResults results: [AnyHashable : Any]?) {
        var results = results
        if uploadCallback != nil {
            uploadCallback?(results, nil)
            uploadCallback = nil
        }
    }

    func videoUploader(_ videoUploader: FBSDKVideoUploader?) throws {
        if uploadCallback != nil {
            uploadCallback?(nil, error)
            uploadCallback = nil
        }
    }

// MARK: - Test OpenGraph
    func testOpenGraph() {
        let testUsers = createTwoFriendedTestUsers()
        let one = testUsers?[0] as? FBSDKAccessToken
        let tagParameters = taggableFriendsOfTestUser(one)
        let tag = tagParameters?["tag"] as? String
        let taggedName = tagParameters?["taggedName"] as? String
        // now do the share
        let content = FBSDKShareOpenGraphContent()
        content.action = FBSDKShareOpenGraphAction(type: "facebooksdktests:run", objectURL: URL(string: "http://samples.ogp.me/414221795280789"), key: "test")
        content.peopleIDs = [tag]
        content.previewPropertyName = "test"

        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var postID: String? = nil
        shareCallback = { results, error, isCancel in
            if let error = error {
                assert(error == nil, "share failed :\(error)")
            }
            assert(!isCancel, "share cancelled")
            postID = results?["postId"] as? String
            blocker?.signal()
        }
        FBSDKShareAPI.share(with: content, delegate: self)
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "share didn't complete")
        XCTAssertNotNil(postID)

        //now fetch and verify the share.
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        FBSDKGraphRequest(graphPath: postID, parameters: [
        "fields": "id,tags.limit(1){name},place.limit(1){id}"
    ]).start(completionHandler: { connection, result, error in
            XCTAssertNil(error)
            XCTAssertEqual(postID, result?["id"])
            XCTAssertEqual(taggedName, result?["tags"][0]["name"])
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 20), "couldn't fetch verify post.")
    }

// MARK: - Test Share Link
    func testShareLink() {
        let testUsers = createTwoFriendedTestUsers()
        let one = testUsers?[0] as? FBSDKAccessToken
        let tagParameters = taggableFriendsOfTestUser(one)
        let tag = tagParameters?["tag"] as? String
        let taggedName = tagParameters?["taggedName"] as? String
        // now do the share
        let content = FBSDKShareLinkContent()
        content.contentURL = URL(string: "http://liveshows.disney.com/")
        content.peopleIDs = [tag]
        content.placesFieldKey.placeID = kTaggedPlaceID

        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var postID: String? = nil
        shareCallback = { results, error, isCancel in
            if let error = error {
                assert(error == nil, "share failed :\(error)")
            }
            assert(!isCancel, "share cancelled")
            postID = results?["postId"] as? String
            blocker?.signal()
        }
        FBSDKShareAPI.share(with: content, delegate: self)
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "share didn't complete")
        XCTAssertNotNil(postID)

        //now fetch and verify the share.
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        FBSDKGraphRequest(graphPath: postID, parameters: [
        "fields": "id,with_tags.limit(1){name}, place.limit(1){id}"
    ]).start(completionHandler: { connection, result, error in
            XCTAssertNil(error)
            XCTAssertEqual(postID, result?["id"])
            XCTAssertEqual(taggedName, result?["with_tags"]["data"][0]["name"])
            XCTAssertEqual(kTaggedPlaceID, result?["place"]["id"])
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 200), "couldn't fetch verify post.")
    }

    func testShareLinkTokenOverride() {
        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var tokenWithPublish: FBSDKAccessToken?
        var tokenWithEmail: FBSDKAccessToken?
        testUsersManager.requestTestAccountTokens(withArraysOfPermissions: [
        Set<AnyHashable>(["publish_actions"]),
        Set<AnyHashable>(["email"])
    ], createIfNotFound: true, completionHandler: { tokens, error in
            tokenWithPublish = tokens?[0] as? FBSDKAccessToken
            tokenWithEmail = tokens?[1] as? FBSDKAccessToken
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 8), "failed to fetch two test users for testing")
        XCTAssertFalse((tokenWithPublish?.userID == tokenWithEmail?.userID), "failed to fetch two distinct users for testing")

        // set current token to email token.
        FBSDKAccessToken.setCurrent(tokenWithEmail)

        let content = FBSDKShareLinkContent()
        content.contentURL = URL(string: "http://www.yahoo.com/")

        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        var postID: String? = nil
        shareCallback = { results, error, isCancel in
            if let error = error {
                assert(error == nil, "share failed :\(error)")
            }
            assert(!isCancel, "share cancelled")
            postID = results?["postId"] as? String
            blocker?.signal()
        }
        // but send as the other token
        let sharer = FBSDKShareAPI.withContent(content, delegate: self)
        sharer.accessToken = tokenWithPublish
        sharer.share()

        XCTAssertTrue(blocker?.wait(withTimeout: 5), "share didn't complete")
        XCTAssertNotNil(postID)

        //now fetch and verify the share.
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        FBSDKGraphRequest(graphPath: postID, parameters: [
        "fields": "id,from"
    ], tokenString: tokenWithPublish?.tokenString, version: nil, httpMethod: "GET").start(completionHandler: { connection, result, error in
            XCTAssertNil(error)
            XCTAssertEqual(postID, result?["id"])
            XCTAssertEqual(tokenWithPublish?.userID, result?["from"]["id"])
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 10), "couldn't fetch verify post.")
    }

// MARK: - Test Share Photo
    func testSharePhoto() {
        let testUsers = createTwoFriendedTestUsers()
        let one = testUsers?[0] as? FBSDKAccessToken
        let tagParameters = taggableFriendsOfTestUser(one)
        let tag = tagParameters?["tag"] as? String
        let taggedName = tagParameters?["taggedName"] as? String
        // now do the share
        FBSDKAccessToken.setCurrent(one)
        let content = FBSDKSharePhotoContent()
        content.placesFieldKey.photos = [
        FBSDKSharePhoto(image: UIImage(named: "hack.png"), userGenerated: true)
    ]
        content.peopleIDs = [tag]
        content.placesFieldKey.placeID = kTaggedPlaceID

        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var postID: String? = nil
        shareCallback = { results, error, isCancel in
            if let error = error {
                assert(error == nil, "share failed :\(error)")
            }
            assert(!isCancel, "share cancelled")
            postID = results?["postId"] as? String
            blocker?.signal()
        }
        FBSDKShareAPI.share(with: content, delegate: self)
        XCTAssertTrue(blocker?.wait(withTimeout: 10), "share didn't complete")
        XCTAssertNotNil(postID)

        //now fetch and verify the share.
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)

        // Note in order to verify tags on a photo, we have to get the photo
        // object id from the post id, rather than simply checking the with_tags
        // of the post. This is because the photo can go in an album which
        // doesn't have the same tags.
        // So we build a batch request to get object_id and then et the tags and place off that.
        let batch = FBSDKGraphRequestConnection()
        let getPhotoIDRequest = FBSDKGraphRequest(graphPath: postID, parameters: [
            "fields": "object_id"
        ]) as? FBSDKGraphRequest

        let handler = { connection, result, error in
            } as? FBSDKGraphRequestBlock

        batch.add(getPhotoIDRequest, completionHandler: handler, batchEntryName: "get-id")
        let getTagsToVerifyRequest = FBSDKGraphRequest(graphPath: "{result=get-id:$.object_id}", parameters: [
            "fields": "id,tags.limit(1){name}, place.limit(1){id}"
        ]) as? FBSDKGraphRequest
        batch.add(getTagsToVerifyRequest, completionHandler: { connection, result, error in
            XCTAssertNil(error)
            XCTAssertEqual(taggedName, result?["tags"]["data"][0]["name"])
            XCTAssertEqual(kTaggedPlaceID, result?["place"]["id"])
            blocker?.signal()
        })
        batch.start()
        XCTAssertTrue(blocker?.wait(withTimeout: 30), "couldn't fetch verify post.")
    }

// MARK: - Test Share Video
    func testShareVideo() {
        let testUsers = createTwoFriendedTestUsers()
        let one = testUsers?[0] as? FBSDKAccessToken
        let tagParameters = taggableFriendsOfTestUser(one)
        let tag = tagParameters?["tag"] as? String
        // now do the share
        FBSDKAccessToken.setCurrent(one)
        let content = FBSDKShareVideoContent()
        let bundleURL: URL? = Bundle.main.url(forResource: "videoviewdemo", withExtension: "mp4")
        content.video = FBSDKShareVideo(videoURL: bundleURL)
        content.peopleIDs = [tag]

        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        shareCallback = { results, error, isCancel in
            assert(results == nil, "VideoContent should not allow peopleIDs")
            assert(error != nil, "VideoContent should not allow peopleIDs.")
            blocker?.signal()
        }
        FBSDKShareAPI.share(with: content, delegate: self)
        XCTAssertTrue(blocker?.wait(withTimeout: 10), "share didn't complete")
    }

    func testVideoUploader() {
        let token: FBSDKAccessToken? = getTokenWithPermissions(["publish_actions"])
        FBSDKAccessToken.setCurrent(token)
        var dictionary: [AnyHashable : Any] = [:]
        let bundleURL: URL? = Bundle.main.url(forResource: "videoviewdemo", withExtension: "mp4")
        //test on file URL
        let blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        if let bundleURL = bundleURL {
            fileHandle = try? FileHandle(forReadingFrom: bundleURL)
        }
        assert(fileHandle != nil, "Fail to get file handler")
        let videoUploader = FBSDKVideoUploader(videoName: bundleURL?.lastPathComponent, videoSize: Int(UInt(fileHandle?.seekToEndOfFile() ?? 0)), parameters: dictionary, delegate: self) as? FBSDKVideoUploader
        uploadCallback = { results, error in
            if let error = error {
                assert(error == nil, "upload failed :\(error)")
            }
            assert(results?["success"] != nil, "upload fail")
            blocker?.signal()
        }
        videoUploader?.start()
        XCTAssertTrue(blocker?.wait(withTimeout: 20), "upload didn't complete")
    }

// MARK: - Help Method
    func createTwoFriendedTestUsers() -> [Any]? {
        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        var one: FBSDKAccessToken? = nil
        var two: FBSDKAccessToken? = nil
        let userManager: FBSDKTestUsersManager? = testUsersManager
        // get two users.
        userManager?.requestTestAccountTokens(withArraysOfPermissions: [
        Set<AnyHashable>(["user_friends", "publish_actions", "user_posts"]),
        Set<AnyHashable>(["user_friends"])
    ], createIfNotFound: true, completionHandler: { tokens, error in
            XCTAssertNil(error)
            one = tokens?[0] as? FBSDKAccessToken
            two = tokens?[1] as? FBSDKAccessToken
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 15), "couldn't get 2 test users")

        // make them friends
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        userManager?.makeFriends(withFirst: one, second: two, callback: { error in
            XCTAssertNil(error)
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "couldn't make friends between:\n%@\n%@", one?.tokenString, two?.tokenString)
        return [one, two]
    }

    func taggableFriendsOfTestUser(_ testUser: FBSDKAccessToken?) -> [AnyHashable : Any]? {
        FBSDKAccessToken.setCurrent(testUser)
        var tag: String? = nil
        var taggedName: String? = nil
        var blocker = FBSDKTestBlocker(expectedSignalCount: 1) as? FBSDKTestBlocker
        blocker = FBSDKTestBlocker(expectedSignalCount: 1)
        FBSDKGraphRequest(graphPath: "me/taggable_friends?limit=1", parameters: [
        "fields": "id,name"
    ]).start(completionHandler: { connection, result, error in
            XCTAssertNil(error)
            tag = result?["data"][0]["id"] as? String
            // grab the name for later verification. unfortunately we can't just compare to
            // two.userID since there may already be (other) friends for this test users.
            taggedName = result?["data"][0]["name"] as? String
            blocker?.signal()
        })
        XCTAssertTrue(blocker?.wait(withTimeout: 5), "couldn't fetch taggable friends")
        XCTAssertNotNil(tag)
        XCTAssertNotNil(taggedName)
        return [
        "tag": tag ?? 0,
        "taggedName": taggedName ?? 0
    ]
    }
}