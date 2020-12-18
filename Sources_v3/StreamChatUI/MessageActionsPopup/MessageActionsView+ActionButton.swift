//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import UIKit

extension MessageActionsView {
    open class ActionButton: Button, UIConfigProvider {
        public var actionItem: ChatMessageActionItem? {
            didSet { updateContentIfNeeded() }
        }

        // MARK: Overrides

        override open func defaultAppearance() {
            backgroundColor = uiConfig.colorPalette.generalBackground
            titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline).bold
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            contentHorizontalAlignment = .left
        }

        override open func setUp() {
            super.setUp()
            
            addTarget(self, action: #selector(touchUpInsideHandler(_:)), for: .touchUpInside)
        }
        
        override open func updateContent() {
            guard let name = actionItem?.name else {
                setImage(nil, for: .normal)
                setTitle(nil, for: .normal)
                return
            }

            setImage(
                uiConfig.messageList.messageActionsSubviews.actionIcons[name],
                for: .normal
            )
            imageView?.tintColor = uiConfig.colorPalette.messageActionIconTints[name] ??
                uiConfig.colorPalette.messageActionIconDefaultTint

            setTitle(
                uiConfig.messageList.messageActionsSubviews.actionTitles[name],
                for: .normal
            )
            setTitleColor(
                uiConfig.colorPalette.messageActionTitleColors[name] ??
                    uiConfig.colorPalette.messageActionTitleDefaultColor,
                for: .normal
            )
        }

        // MARK: Actions
        
        @objc open func touchUpInsideHandler(_ sender: Any) {
            actionItem?.action()
        }
    }
}
