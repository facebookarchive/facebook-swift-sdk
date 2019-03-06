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

@testable import FacebookCore
import XCTest

class GraphRequestSerializerTests: XCTestCase {

  private var startingParameters: [String: AnyHashable] = ["Foo": "Bar"]

  func testPreprocessingParametersWithDebugParameterNone() {
    let fakeSettings = FakeSettings(graphApiDebugParameter: .none)
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    let processedParameters = serializer.preProcess(startingParameters)

    XCTAssertEqual(
      startingParameters,
      processedParameters,
      "Preprocessing parameters should not add additional parameters unless settings have a non-none debug parameter"
    )
  }

  func testPreprocessingParametersWithDebugParameterInfo() {
    let fakeSettings = FakeSettings(graphApiDebugParameter: .info)
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    let processedParameters = serializer.preProcess(startingParameters)
    var expectedParameters = startingParameters
    expectedParameters.updateValue(
      GraphApiDebugParameter.info.rawValue,
      forKey: GraphRequestSerializer.Keys.debug.rawValue
    )

    XCTAssertEqual(
      expectedParameters,
      processedParameters,
      "Preprocessing parameters should add additional parameters when settings has a debug parameter of info"
    )
  }

  func testPreprocessingParametersWithDebugParameterWarning() {
    let fakeSettings = FakeSettings(graphApiDebugParameter: .warning)
    let serializer = GraphRequestSerializer(settings: fakeSettings)

    let processedParameters = serializer.preProcess(startingParameters)
    var expectedParameters = startingParameters
    expectedParameters.updateValue(
      GraphApiDebugParameter.warning.rawValue,
      forKey: GraphRequestSerializer.Keys.debug.rawValue
    )

    XCTAssertEqual(
      expectedParameters,
      processedParameters,
      "Preprocessing parameters should add additional parameters when settings has a debug parameter of warning"
    )
  }

}
