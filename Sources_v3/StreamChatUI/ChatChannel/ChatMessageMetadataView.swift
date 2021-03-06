//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

open class ChatMessageMetadataView<ExtraData: ExtraDataTypes>: View, UIConfigProvider {
    public var message: _ChatMessageGroupPart<ExtraData>? {
        didSet { updateContentIfNeeded() }
    }
    
    // MARK: - Subviews

    public private(set) lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = UIStackView.spacingUseSystem
        return stack.withoutAutoresizingMaskConstraints
    }()

    public private(set) lazy var currentUserVisabilityIndicator = uiConfig
        .messageList
        .messageContentSubviews
        .onlyVisibleForCurrentUserIndicator
        .init()
        .withoutAutoresizingMaskConstraints

    public private(set) lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout).bold
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    // MARK: - Overrides

    override public func defaultAppearance() {
        let color = uiConfig.colorPalette.messageTimestampText
        currentUserVisabilityIndicator.textLabel.textColor = color
        currentUserVisabilityIndicator.imageView.tintColor = color
        timestampLabel.textColor = color
    }

    override open func setUpLayout() {
        stack.addArrangedSubview(currentUserVisabilityIndicator)
        stack.addArrangedSubview(timestampLabel)
        embed(stack)
    }

    override open func updateContent() {
        timestampLabel.text = message?.createdAt.getFormattedDate(format: "hh:mm a")
        currentUserVisabilityIndicator.isVisible = message?.onlyVisibleForCurrentUser ?? false
    }
}

open class ChatMessageOnlyVisibleForCurrentUserIndicator: View {
    // MARK: - Subviews

    public private(set) lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = UIStackView.spacingUseSystem
        return stack.withoutAutoresizingMaskConstraints
    }()

    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView.withoutAutoresizingMaskConstraints
    }()

    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout).bold
        label.adjustsFontForContentSizeCategory = true
        return label.withoutAutoresizingMaskConstraints
    }()

    // MARK: - Overrides

    override public func defaultAppearance() {
        imageView.image = UIImage(named: "eye", in: .streamChatUI)
        textLabel.text = L10n.Message.onlyVisibleToYou
    }

    override open func setUpLayout() {
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(textLabel)
        embed(stack)

        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
    }
}

private extension _ChatMessageGroupPart {
    var onlyVisibleForCurrentUser: Bool {
        guard message.isSentByCurrentUser else {
            return false
        }

        return message.deletedAt != nil || message.type == .ephemeral
    }
}
