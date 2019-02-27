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

class RPSAppLinkedViewController: UIViewController {
    init(call: RPSCall) {
        assert(call != .none, "Invalid parameter not satisfying: call != .none")

        super.init()

        self.call = call
modalTransitionStyle = .crossDissolve
    }

    private var call: RPSCall?
    @IBOutlet private weak var callImageView: UIImageView!
    @IBOutlet private weak var playButton: UIButton!

// MARK: - Lifecycle

// MARK: - Methods
    @IBAction func play(_ sender: Any) {
        dismiss(animated: true)
    }

// MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        playButton.layer.cornerRadius = 8.0
        playButton.layer.borderWidth = 4.0
        playButton.layer.borderColor = playButton.titleLabel?.textColor.cgColor

        var callImage: UIImage? = nil
        switch call {
            case .paper?:
                callImage = UIImage(named: "right-paper-128.png")
            case .rock?:
                callImage = UIImage(named: "right-rock-128.png")
            case .scissors?:
                callImage = UIImage(named: "right-scissors-128.png")
            default:
                break
        }

        callImageView.image = callImage
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}