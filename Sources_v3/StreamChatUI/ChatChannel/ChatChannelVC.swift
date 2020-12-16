//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import StreamChat
import UIKit

open class ChatChannelVC<ExtraData: ExtraDataTypes>: ChatVC<ExtraData> {
    // MARK: - Properties
    
    public var controller: _ChatChannelController<ExtraData>!

    public private(set) lazy var messageInputAccessoryViewController: MessageComposerInputAccessoryViewController<ExtraData> = {
        let inputAccessoryVC = MessageComposerInputAccessoryViewController<ExtraData>()
        
        // `inputAccessoryViewController` is part of `_UIKeyboardWindowScene` so we need to manually pass
        // tintColor down that `inputAccessoryViewController` view hierarchy.
        inputAccessoryVC.view.tintColor = view.tintColor
        inputAccessoryVC.suggestionsPresenter = self
        
        return inputAccessoryVC
    }()

    public private(set) lazy var suggestionsViewController: MessageComposerSuggestionsViewController<ExtraData> = {
        uiConfig.messageComposer.suggestionsViewController.init()
    }()

    public private(set) lazy var collectionViewLayout: ChatChannelCollectionViewLayout = uiConfig
        .messageList
        .collectionLayout
        .init()
    public private(set) lazy var collectionView: UICollectionView = {
        let collection = uiConfig.messageList.collectionView.init(layout: collectionViewLayout)
        collection.register(
            СhatIncomingMessageCollectionViewCell<ExtraData>.self,
            forCellWithReuseIdentifier: СhatIncomingMessageCollectionViewCell<ExtraData>.reuseId
        )
        collection.register(
            СhatOutgoingMessageCollectionViewCell<ExtraData>.self,
            forCellWithReuseIdentifier: СhatOutgoingMessageCollectionViewCell<ExtraData>.reuseId
        )
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        
        return collection
    }()

    private var navbarListener: ChatChannelNavigationBarListener<ExtraData>?

    public private(set) lazy var router = uiConfig.navigation.channelDetailRouter.init(rootViewController: self)
    
    // MARK: - Life Cycle
    
    override open func setUp() {
        super.setUp()

        channelController.setDelegate(self)
        channelController.synchronize()
    }

    override func makeNavbarListener(
        _ handler: @escaping (ChatChannelNavigationBarListener<ExtraData>.NavbarData) -> Void
    ) -> ChatChannelNavigationBarListener<ExtraData>? {
        guard let channel = channelController.channel else { return nil }
        let navbarListener = ChatChannelNavigationBarListener.make(for: channel.cid, in: channelController.client)
        navbarListener.onDataChange = handler
        return navbarListener
    }

    override public func defaultAppearance() {
        super.defaultAppearance()

        guard let channel = channelController.channel else { return }

        let avatar = ChatChannelAvatarView<ExtraData>()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.heightAnchor.constraint(equalToConstant: 32).isActive = true
        avatar.channelAndUserId = (channel, channelController.client.currentUserId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatar)
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - ChatMessageListVCDataSource

    override public func numberOfMessagesInChatMessageListVC(_ vc: ChatMessageListVC<ExtraData>) -> Int {
        channelController.messages.count
    }

    override public func chatMessageListVC(_ vc: ChatMessageListVC<ExtraData>, messageAt index: Int) -> _ChatMessage<ExtraData> {
        channelController.messages[index]
    }

    override public func loadMoreMessagesForChatMessageListVC(_ vc: ChatMessageListVC<ExtraData>) {
        channelController.loadNextMessages()
    }

    override public func chatMessageListVC(
        _ vc: ChatMessageListVC<ExtraData>,
        replyMessageFor message: _ChatMessage<ExtraData>,
        at index: Int
    ) -> _ChatMessage<ExtraData>? {
        guard let parentMessageId = message.parentMessageId else { return nil }
        let messageController = channelController.client.messageController(
            cid: channelController.cid!,
            messageId: parentMessageId
        )
        if let parentMessage = messageController.message {
            return parentMessage
        }
        messageController.synchronize { [weak self, messageController] _ in
            guard let self = self, let parentMessage = messageController.message else { return }
            self.channelController(
                self.channelController,
                didUpdateMessages: [.update(parentMessage, index: IndexPath(item: index, section: 0))]
            )
        }
        return nil
    }

    override public func chatMessageListVC(
        _ vc: ChatMessageListVC<ExtraData>,
        controllerFor message: _ChatMessage<ExtraData>
    ) -> _ChatMessageController<ExtraData> {
        channelController.client.messageController(
            cid: channelController.cid!,
            messageId: message.id
        )
    }

    // MARK: - ChatMessageListVCDelegate

    override public func chatMessageListVC(
        _ vc: ChatMessageListVC<ExtraData>,
        didTapOnRepliesFor message: _ChatMessage<ExtraData>
    ) {
        router.showThreadDetail(for: message, within: channelController)
    }
}

// MARK: - _ChatChannelControllerDelegate

extension ChatChannelVC: _ChatChannelControllerDelegate {
    public func channelController(
        _ channelController: _ChatChannelController<ExtraData>,
        didUpdateMessages changes: [ListChange<_ChatMessage<ExtraData>>]
    ) {
        messageList.updateMessages(with: changes)
    }
}

// MARK: - SuggestionsPresenter

extension ChatChannelVC: SuggestionsViewControllerPresenter {
    public func presentSuggestions(with configuration: SuggestionsConfiguration) {
        suggestionsViewController.configuration = configuration
        let array = Array(controller.channel!.cachedMembers)
        suggestionsViewController.chatMembers = array as! [SuggestionItem]
        addChild(suggestionsViewController)
        view.addSubview(suggestionsViewController.view)
        suggestionsViewController.didMove(toParent: parent)
        suggestionsViewController.bottomAnchorView = messageInputAccessoryViewController.composerView
    }

    public func dismissSuggestionsViewController() {
        suggestionsViewController.removeFromParent()
        suggestionsViewController.view.removeFromSuperview()
    }
}
