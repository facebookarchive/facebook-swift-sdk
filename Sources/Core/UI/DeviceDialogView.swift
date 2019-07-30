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

protocol DeviceDialogViewDelegate: AnyObject {
  func didCancel(dialogView: DeviceDialogView)
}

// swiftlint:disable:next type_body_length
class DeviceDialogView: UIView {
  private let logoColor = UIColor(red: 66, green: 103, blue: 178)

  weak var delegate: DeviceDialogViewDelegate?

  var confirmationCode: String? {
    didSet {
      guard oldValue != confirmationCode else {
        return
      }
      switch confirmationCode {
      case nil:
        confirmationCodeLabel.text = ""
        confirmationCodeLabel.isHidden = true
        qrImageView.isHidden = true
        activityIndicatorView.startAnimating()

      case let code?:
        activityIndicatorView.stopAnimating()
        confirmationCodeLabel.text = code
        confirmationCodeLabel.isHidden = false
        qrImageView.isHidden = false
        qrImageView.image = buildQRCode(withAuthorizationCode: code)
      }
    }
  }

  lazy var qrImageView: UIImageView = {
    let qrCodeImage = buildQRCode(withAuthorizationCode: nil)
    let view = UIImageView(image: qrCodeImage)
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var dialogView: UIView = {
    let dialogView = UIView()
    dialogView.layer.cornerRadius = 3
    dialogView.translatesAutoresizingMaskIntoConstraints = false
    dialogView.clipsToBounds = true
    dialogView.backgroundColor = .white

    return dialogView
  }()

  private lazy var dialogHeaderView: UIView = {
    let dialogHeaderView = UIView()
    dialogHeaderView.translatesAutoresizingMaskIntoConstraints = false
    dialogHeaderView.backgroundColor = UIColor(red: UInt8(226), green: 231, blue: 235, alpha: 0.85)

    return dialogHeaderView
  }()

  private lazy var imageView: UIImageView = {
    let imageSize = CGSize(width: LayoutConstants.logoSize, height: LayoutConstants.logoSize)
    let logo = Logo().image(size: imageSize, color: logoColor)
    let image = logo.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    let imageView = UIImageView(image: image)
    imageView.translatesAutoresizingMaskIntoConstraints = false

    return imageView
  }()

  private lazy var activityIndicatorView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .whiteLarge)
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var confirmationCodeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = logoColor
    label.font = UIFont.systemFont(ofSize: LayoutConstants.confirmationCodeFontSize, weight: .light)
    label.textAlignment = .center
    label.sizeToFit()

    return label
  }()

  // swiftlint:disable:next closure_body_length
  private lazy var instructionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    let localizedFormatString = NSLocalizedString(
      "DeviceLogin.LogInPrompt",
      tableName: "FacebookSDK",
      bundle: LocalizedStringHelper.localizedStringsBundle,
      value: "Visit %@ and enter your code.",
      comment: "The format string for device login instructions"
    )
    let deviceLoginURLString = "facebook.com/device"
    let instructionString = String.localizedStringWithFormat(localizedFormatString, deviceLoginURLString)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = 1.1
    let attributedString = NSMutableAttributedString(
      string: instructionString,
      attributes: [
        NSAttributedString.Key.paragraphStyle: paragraphStyle
      ]
    )
    guard let range = instructionString.range(of: deviceLoginURLString) else {
      return UILabel()
    }
    attributedString.addAttribute(
      NSAttributedString.Key.font,
      value: UIFont.systemFont(ofSize: LayoutConstants.instructionFontSize, weight: .medium),
      range: NSRange(range, in: deviceLoginURLString)
    )
    label.font = UIFont.systemFont(ofSize: LayoutConstants.instructionFontSize, weight: .light)
    label.attributedText = attributedString
    label.numberOfLines = 0
    label.textAlignment = NSTextAlignment.center
    label.sizeToFit()
    label.textColor = UIColor(white: LayoutConstants.fontColorValue, alpha: 1.0)

    return label
  }()

  private lazy var buttonContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }()

  private lazy var cancelButton: UIButton = {
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 4
    button.translatesAutoresizingMaskIntoConstraints = false
    let localizedTitle = NSLocalizedString(
      "LoginButton.CancelLogout",
      tableName: "FacebookSDK",
      bundle: LocalizedStringHelper.localizedStringsBundle,
      value: "Cancel",
      comment: "The label for the FBSDKLoginButton action sheet to cancel logging out"
    )
    button.setTitle(localizedTitle, for: .normal)
    button.titleLabel?.font = instructionLabel.font
    button.setTitleColor(
      UIColor(white: LayoutConstants.fontColorValue, alpha: 1),
      for: .normal
    )

    button.addTarget(self, action: #selector(cancelButtonTapped), for: .primaryActionTriggered)

    return button
  }()

  // MARK: - Overrides

  override init(frame: CGRect) {
    super.init(frame: frame)

    buildView()
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  // MARK: - Actions

  @objc
  func cancelButtonTapped() {
    delegate?.didCancel(dialogView: self)
  }

  // MARK: - Layout & Configuration

  // swiftlint:disable:next function_body_length
  func buildView() {
    addSubview(dialogView)
    NSLayoutConstraint.activate(
      [
        dialogView.centerXAnchor.constraint(equalTo: centerXAnchor),
        dialogView.centerYAnchor.constraint(equalTo: centerYAnchor),
        dialogView.widthAnchor.constraint(equalToConstant: LayoutConstants.width),
        dialogView.heightAnchor.constraint(equalToConstant: LayoutConstants.height)
      ]
    )

    dialogView.addSubview(dialogHeaderView)
    NSLayoutConstraint.activate(
      [
        dialogHeaderView.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
        dialogHeaderView.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
        dialogHeaderView.heightAnchor.constraint(equalToConstant: LayoutConstants.dialogHeaderViewHeight),
        dialogHeaderView.topAnchor.constraint(equalTo: dialogView.topAnchor)
      ]
    )

    dialogHeaderView.addSubview(imageView)
    NSLayoutConstraint.activate(
      [
        imageView.widthAnchor.constraint(equalToConstant: LayoutConstants.logoSize),
        imageView.heightAnchor.constraint(equalToConstant: LayoutConstants.logoSize),
        imageView.topAnchor.constraint(equalTo: dialogHeaderView.topAnchor, constant: LayoutConstants.logoMargin),
        imageView.leadingAnchor.constraint(
          equalTo: dialogHeaderView.leadingAnchor,
          constant: LayoutConstants.logoMargin
        )
      ]
    )

    dialogHeaderView.addSubview(activityIndicatorView)
    NSLayoutConstraint.activate(
      [
        activityIndicatorView.centerXAnchor.constraint(equalTo: dialogHeaderView.centerXAnchor),
        activityIndicatorView.centerYAnchor.constraint(equalTo: dialogHeaderView.centerYAnchor),
        activityIndicatorView.widthAnchor.constraint(equalToConstant: LayoutConstants.confirmationCodeFontSize),
        activityIndicatorView.heightAnchor.constraint(equalToConstant: LayoutConstants.confirmationCodeFontSize)
      ]
    )
    activityIndicatorView.startAnimating()

    dialogHeaderView.addSubview(confirmationCodeLabel)
    NSLayoutConstraint.activate(
      [
        confirmationCodeLabel.centerXAnchor.constraint(equalTo: dialogHeaderView.centerXAnchor),
        confirmationCodeLabel.centerYAnchor.constraint(equalTo: dialogHeaderView.centerYAnchor)
      ]
    )

    confirmationCodeLabel.isHidden = true

    dialogView.addSubview(qrImageView)

    NSLayoutConstraint.activate(
      [
        qrImageView.topAnchor.constraint(
          equalTo: dialogHeaderView.bottomAnchor,
          constant: LayoutConstants.qrCodeMargin
        ),
        qrImageView.bottomAnchor.constraint(
          equalTo: qrImageView.topAnchor,
          constant: LayoutConstants.qrCodeSize
        ),
        qrImageView.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor, constant: LayoutConstants.qrCodeMargin),
        qrImageView.trailingAnchor.constraint(equalTo: qrImageView.leadingAnchor, constant: LayoutConstants.qrCodeSize)
      ]
    )

    dialogView.addSubview(instructionLabel)
    NSLayoutConstraint.activate(
      [
        instructionLabel.topAnchor.constraint(
          equalTo: dialogHeaderView.bottomAnchor,
          constant: LayoutConstants.verticalSpaceBetweenHeaderViewAndInstructionLabel
        ),
        instructionLabel.leadingAnchor.constraint(
          equalTo: qrImageView.trailingAnchor,
          constant: LayoutConstants.qrCodeMargin
        ),
        dialogView.trailingAnchor.constraint(
          equalTo: instructionLabel.trailingAnchor,
          constant: LayoutConstants.instructionTextHorizontalMargin
        )
      ]
    )

    dialogView.addSubview(buttonContainerView)
    NSLayoutConstraint.activate(
      [
        buttonContainerView.centerXAnchor.constraint(
          equalTo: dialogView.centerXAnchor
        ),
        buttonContainerView.heightAnchor.constraint(
          equalToConstant: LayoutConstants.buttonContainerHeight
        ),
        buttonContainerView.leadingAnchor.constraint(
          equalTo: dialogView.leadingAnchor,
          constant: LayoutConstants.buttonContainerMargin
        ),
        dialogView.trailingAnchor.constraint(
          equalTo: buttonContainerView.trailingAnchor,
          constant: LayoutConstants.buttonContainerMargin
        ),
        dialogView.bottomAnchor.constraint(
          equalTo: buttonContainerView.bottomAnchor,
          constant: LayoutConstants.verticalSpaceBetweenCancelButtonAndButtomAnchor
        )
      ]
    )

    buttonContainerView.addSubview(cancelButton)
    NSLayoutConstraint.activate(
      [
        cancelButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
        cancelButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
        cancelButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
        cancelButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
      ]
    )
  }

  private func buildQRCode(withAuthorizationCode authorizationCode: String?) -> UIImage {
    let authorizationURI = "https://facebook.com/device?user_code=\(authorizationCode ?? "")&qr=1"

    let qrCodeData = authorizationURI.data(using: .isoLatin1)

    guard let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator") else {
      return UIImage()
    }

    qrCodeFilter.setValue(qrCodeData, forKey: "inputMessage")
    qrCodeFilter.setValue("M", forKey: "inputCorrectionLevel")

    guard let qrCodeImage = qrCodeFilter.outputImage else {
      return UIImage()
    }

    let qrImageSize = qrCodeImage.extent.integral
    let qrOutputSize = CGSize(width: 200, height: 200)

    let scaleTransform = CGAffineTransform(
      scaleX: qrOutputSize.width / qrImageSize.width,
      y: qrOutputSize.height / qrImageSize.height
    )
    let resizedImage = qrCodeImage.transformed(by: scaleTransform)

    return UIImage(ciImage: resizedImage)
  }

  private enum LayoutConstants {
    static let buttonContainerHeight: CGFloat = 100
    static let buttonContainerMargin: CGFloat = 400
    static let width: CGFloat = 1080
    static let height: CGFloat = 820
    static let verticalSpaceBetweenHeaderViewAndInstructionLabel: CGFloat = 102
    static let verticalSpaceBetweenCancelButtonAndButtomAnchor: CGFloat = 117
    static let dialogHeaderViewHeight: CGFloat = 309
    static let logoSize: CGFloat = 44
    static let logoMargin: CGFloat = 30
    static let instructionTextHorizontalMargin: CGFloat = 151
    static let confirmationCodeFontSize: CGFloat = 108
    static let fontColorValue: CGFloat = 119.0 / 255.0
    static let instructionFontSize: CGFloat = 36
    static let qrCodeMargin: CGFloat = 50
    static let qrCodeSize: CGFloat = 200
  }
}
