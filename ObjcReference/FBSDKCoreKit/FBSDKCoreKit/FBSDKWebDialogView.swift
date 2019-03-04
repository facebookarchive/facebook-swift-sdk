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

import UIKit

class FBSDKWebDialogView: UIView, UIWebViewDelegate {
    private var closeButton: UIButton?
    private var loadingView: UIActivityIndicatorView?
    private var webView: UIWebView?

    weak var delegate: FBSDKWebDialogViewDelegate?

    func load(_ URL: URL?) {
        loadingView?.startAnimating()
        if let URL = URL {
            webView?.loadRequest(URLRequest(url: URL))
        }
    }

    func stopLoading() {
        webView?.stopLoading()
    }

// MARK: - Object Lifecycle
    override init(frame: CGRect) {
        //if super.init(frame: frame)
        backgroundColor = UIColor.clear
        isOpaque = false

        webView = UIWebView(frame: CGRect.zero)
        webView?.delegate = self
        if let webView = webView {
            addSubview(webView)
        }

        closeButton = UIButton(type: .custom)
        let closeImage: UIImage? = FBSDKCloseIcon().image(at: CGSize(width: 29.0, height: 29.0))
        closeButton?.setImage(closeImage, for: .normal)
        closeButton?.setTitleColor(UIColor(red: 167.0 / 255.0, green: 184.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0), for: .normal)
        closeButton?.setTitleColor(UIColor.white, for: .highlighted)
        closeButton?.showsTouchWhenHighlighted = true
        closeButton?.sizeToFit()
        if let closeButton = closeButton {
            addSubview(closeButton)
        }
        closeButton?.addTarget(self, action: #selector(FBSDKWebDialogView._close(_:)), for: .touchUpInside)

        loadingView = UIActivityIndicatorView(style: .whiteLarge)
        loadingView?.color = UIColor.gray
        if let loadingView = loadingView {
            webView?.addSubview(loadingView)
        }
    }

    deinit {
        webView?.delegate = nil
    }

// MARK: - Public Methods

// MARK: - Layout
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        backgroundColor?.setFill()
        context?.fill(bounds)
        UIColor.black.setStroke()
        context?.setLineWidth(1.0 / layer.contentsScale)
        context?.stroke(webView?.frame)
        context?.restoreGState()
        super.draw(rect)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var bounds: CGRect = self.bounds
        if UI_USER_INTERFACE_IDIOM() == .pad {
            let horizontalInset: CGFloat = bounds.width * 0.2
            let verticalInset: CGFloat = bounds.height * 0.2
            let iPadInsets = UIEdgeInsets(top: Float(verticalInset), left: Float(horizontalInset), bottom: Float(verticalInset), right: Float(horizontalInset))
            bounds = UIEdgeInsetsInsetRect(bounds, iPadInsets)
        }
        let webViewInsets = UIEdgeInsets(top: Float(FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH), left: Float(FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH), bottom: Float(FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH), right: Float(FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH))
        webView?.frame = UIEdgeInsetsInsetRect(bounds, webViewInsets).integral()

        let webViewBounds: CGRect? = webView?.bounds
        loadingView?.center = CGPoint(x: webViewBounds?.midX, y: webViewBounds?.midY)

        if webViewBounds?.height == 0.0 {
            closeButton?.alpha = 0.0
        } else {
            closeButton?.alpha = 1.0
            var closeButtonFrame: CGRect? = closeButton?.bounds
            closeButtonFrame?.origin = bounds.origin
            closeButton?.frame = closeButtonFrame?.integral()
        }
    }

// MARK: - Actions
    @objc func _close(_ sender: Any?) {
        delegate?.webDialogViewDidCancel(self)
    }

// MARK: - UIWebViewDelegate
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        loadingView?.stopAnimating()

        // 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
        // NSURLErrorCancelled == "Operation could not be completed", note NSURLErrorCancelled occurs when the user clicks
        // away before the page has completely loaded, if we find cases where we want this to result in dialog failure
        // (usually this just means quick-user), then we should add something more robust here to account for differences in
        // application needs
        if !(((((error as NSError).domain) == NSURLErrorDomain) && (error as NSError).code == NSURLErrorCancelled) || ((((error as NSError).domain) == "WebKitErrorDomain") && (error as NSError).code == 102)) {
            try? delegate?.webDialogView(self)
        }
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let URL: URL? = request.url

        if (URL?.scheme == "fbconnect") {
            var parameters = FBSDKUtility.dictionary(withQueryString: URL?.query)
            for (k, v) in FBSDKUtility.dictionary(withQueryString: URL?.fragment) { parameters[k] = v }
            if URL?.resourceSpecifier?.hasPrefix("//cancel") ?? false {
                let errorCode = FBSDKTypeUtility.integerValue(parameters["error_code"])
                if errorCode != 0 {
                    let errorMessage = FBSDKTypeUtility.stringValue(parameters["error_msg"])
                    let error = Error.fbError(withCode: errorCode, message: errorMessage)
                    try? delegate?.webDialogView(self)
                } else {
                    delegate?.webDialogViewDidCancel(self)
                }
            } else {
                delegate?.webDialogView(self, didCompleteWithResults: parameters)
            }
            return false
        } else if navigationType == .linkClicked {
            if let URL = request.url {
                UIApplication.shared.openURL(URL)
            }
            return false
        } else {
            return true
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingView?.stopAnimating()
        delegate?.webDialogViewDidFinishLoad(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol FBSDKWebDialogViewDelegate: NSObjectProtocol {
    func webDialogView(_ webDialogView: FBSDKWebDialogView?, didCompleteWithResults results: [AnyHashable : Any]?)
    func webDialogView(_ webDialogView: FBSDKWebDialogView?) throws
    func webDialogViewDidCancel(_ webDialogView: FBSDKWebDialogView?)
    func webDialogViewDidFinishLoad(_ webDialogView: FBSDKWebDialogView?)
}

let FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH = 10.0