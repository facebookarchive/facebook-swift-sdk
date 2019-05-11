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

import UIKit

class Button: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)

    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  func configure(
    withHighlightColor highlightColor: UIColor = Color.defaultButtonBackgroundHighlighted
    ) {
    let image: UIImage? = {
      let pointSize = UIFont.systemFont(ofSize: 14).pointSize
      let size = CGSize(width: pointSize, height: pointSize)
      let logo = Logo().image(size: size)
      return logo?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }()

    setImage(image, for: .normal)
    backgroundColor = Color.defaultButtonBackground

    setImage(
      backgroundImage(
        with: highlightColor,
        cornerRadius: 3
      ),
      for: .highlighted
    )
  }

  func setBackgroundColor(_ color: UIColor, for state: State) {
    let image = backgroundImage(with: color, cornerRadius: 3)

    setBackgroundImage(image, for: state)
  }

  private func backgroundImage(
    with color: UIColor
    ) -> UIImage? {
    let cornerRadius = 3
    let length = 1.0 + 2 * cornerRadius
    let size = CGSize(width: length, height: length)
    let insets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
    let image = ButtonBackground(cornerRadius: cornerRadius).image(size: size, color: color)

    return image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
  }
}
