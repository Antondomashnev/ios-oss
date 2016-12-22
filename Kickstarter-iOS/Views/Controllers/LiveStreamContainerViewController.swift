//swiftlint:disable file_length
import KsApi
import Library
import Prelude
import ReactiveCocoa
import Result
import UIKit
import KsLive

//swiftlint:disable type_body_length
internal final class LiveStreamContainerViewController: UIViewController {

  @IBOutlet private weak var availableForLabel: UILabel!
  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarLabel: UILabel!
  @IBOutlet private weak var creatorAvatarLiveDotImageView: UIImageView!
  @IBOutlet private weak var detailsContainerStackView: UIStackView!
  @IBOutlet private weak var detailsLoadingActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var detailsStackView: UIStackView!
  @IBOutlet private weak var liveStreamParagraphLabel: UILabel!
  @IBOutlet private weak var liveStreamTitleLabel: UILabel!
  @IBOutlet private weak var loaderActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var loaderButton: UIButton!
  @IBOutlet private weak var loaderContainerStackView: UIStackView!
  @IBOutlet private weak var loaderLabel: UILabel!
  @IBOutlet private weak var loaderStackView: UIStackView!
  @IBOutlet private weak var loaderView: UIView!
  @IBOutlet private weak var loaderViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var numberWatchingButton: UIButton!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var subscribeActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var subscribeButton: UIButton!
  @IBOutlet private weak var subscribeLabel: UILabel!
  @IBOutlet private weak var subscribeStackView: UIStackView!
  @IBOutlet private weak var titleDetailsSeparator: UIView!
  @IBOutlet private weak var titleStackView: UIStackView!
  @IBOutlet private weak var titleStackViewHeightConstraint: NSLayoutConstraint!

  private let eventDetailsViewModel: LiveStreamEventDetailsViewModelType = LiveStreamEventDetailsViewModel()
  private var liveStreamViewController: LiveStreamViewController?
  private let shareViewModel: ShareViewModelType = ShareViewModel()
  private let viewModel: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  internal static func configuredWith(project project: Project, event: LiveStreamEvent?)
    -> LiveStreamContainerViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerViewController)
      vc.viewModel.inputs.configureWith(project: project, event: event)
      vc.eventDetailsViewModel.inputs.configureWith(project: project, event: event)

      if event == nil {
        vc.eventDetailsViewModel.inputs.fetchLiveStreamEvent()
      }

      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .whiteColor()
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(LiveStreamContainerViewController.close(_:)))

    self.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

    self.navBarTitleStackViewBackgroundView.addSubview(self.navBarTitleStackView)
    self.navBarTitleStackView.addArrangedSubview(self.navBarLiveDotImageView)
    self.navBarTitleStackView.addArrangedSubview(self.navBarTitleLabel)

    self.navBarTitleStackView.leadingAnchor.constraintEqualToAnchor(
      self.navBarTitleStackViewBackgroundView.leadingAnchor).active = true
    self.navBarTitleStackView.topAnchor.constraintEqualToAnchor(
      self.navBarTitleStackViewBackgroundView.topAnchor).active = true
    self.navBarTitleStackView.trailingAnchor.constraintEqualToAnchor(
      self.navBarTitleStackViewBackgroundView.trailingAnchor).active = true
    self.navBarTitleStackView.bottomAnchor.constraintEqualToAnchor(
      self.navBarTitleStackViewBackgroundView.bottomAnchor).active = true

    self.navigationItem.titleView = navBarTitleStackViewBackgroundView

    self.viewModel.inputs.viewDidLoad()
    self.eventDetailsViewModel.inputs.viewDidLoad()
  }

  //swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill

    self.loaderContainerStackView
      |> UIStackView.lens.axis .~ .Horizontal
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.distribution .~ .Fill

    self.loaderStackView
      |> UIStackView.lens.axis .~ .Vertical
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.distribution .~ .FillEqually

    self.loaderView
      |> UIView.lens.backgroundColor .~ UIColor.hex(0x353535)

    self.loaderActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .White
      |> UIActivityIndicatorView.lens.animating .~ true

    self.loaderLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .whiteColor()

    self.loaderButton
      |> UIButton.lens.hidden .~ true

    self.titleStackViewHeightConstraint.constant = Styles.grid(14)

    self.titleStackView
      |> UIStackView.lens.axis .~ .Horizontal
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.distribution .~ .Fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))

    self.availableForLabel
      |> UILabel.lens.font .~ UIFont.ksr_footnote(size: 11).italicized
      |> UILabel.lens.textColor .~ .whiteColor()

    self.titleDetailsSeparator
      |> UIView.lens.backgroundColor .~ UIColor.whiteColor().colorWithAlphaComponent(0.2)

    self.detailsStackView
      |> UIStackView.lens.axis .~ .Vertical
      |> UIStackView.lens.distribution .~ .Fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.subscribeStackView
      |> UIStackView.lens.axis .~ .Horizontal
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.distribution .~ .Fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~ .init(
        top: 0,
        left: Styles.grid(4),
        bottom: Styles.grid(4),
        right: Styles.grid(4))

    self.creatorAvatarLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.font .~ .ksr_footnote()

    self.creatorAvatarImageView
      |> UIImageView.lens.layer.masksToBounds .~ true

    self.numberWatchingButton
      |> baseButtonStyle
      |> UIButton.lens.titleColor(forState: .Normal) .~ .whiteColor()
      |> UIButton.lens.backgroundColor .~ UIColor.whiteColor().colorWithAlphaComponent(0.1)
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(left: -Styles.grid(2))
      |> UIButton.lens.image(forState: .Normal) .~ UIImage(named: "eye")
      |> UIButton.lens.tintColor .~ self.subscribeButton.currentTitleColor
      |> UIButton.lens.titleLabel.font .~ UIFont.ksr_headline(size: 12)
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.title(forState: .Normal) .~ String(0)

    self.numberWatchingButton.semanticContentAttribute = .ForceLeftToRight

    self.liveStreamTitleLabel
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.font .~ .ksr_headline(size: 18)
      |> UILabel.lens.textColor .~ .whiteColor()

    self.liveStreamParagraphLabel
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UILabel.lens.textColor .~ .whiteColor()

    self.subscribeLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13)
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.textColor .~ .whiteColor()

    self.subscribeActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .White
      |> UIActivityIndicatorView.lens.animating .~ true

    self.subscribeButton
      |> whiteBorderContainerButtonStyle
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(right: -Styles.grid(1))
      |> UIButton.lens.tintColor .~ self.subscribeButton.currentTitleColor
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 10.0, leftRight: Styles.grid(2))

    self.subscribeButton.semanticContentAttribute = .ForceRightToLeft

    self.detailsLoadingActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .White
      |> UIActivityIndicatorView.lens.animating .~ true

    self.navBarTitleStackViewBackgroundView
      |> UIView.lens.layer.cornerRadius .~ 2
      |> UIView.lens.layer.masksToBounds .~ true
      |> UIView.lens.backgroundColor .~ UIColor.blackColor().colorWithAlphaComponent(0.5)

    self.navBarTitleStackView
      |> UIStackView.lens.axis .~ .Horizontal
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.distribution .~ .Fill
      |> UIStackView.lens.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))

    self.navBarLiveDotImageView
      |> UIImageView.lens.image .~ UIImage(named: "live_dot")
      |> UIImageView.lens.contentMode .~ .ScaleAspectFit
      |> UIImageView.lens.contentHuggingPriorityForAxis(.Horizontal) .~ UILayoutPriorityDefaultHigh

    self.navBarTitleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.textAlignment .~ .Center
  }
  //swiftlint:enable function_body_length

  //swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.createAndConfigureLiveStreamViewController
      .observeForUI()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        let (_, event) = $0

        _self.addChildLiveStreamViewController(LiveStreamViewController(event: event, delegate: _self))
    }

    self.viewModel.outputs.showVideoView
      .map(negate)
      .observeForUI()
      .observeNext { [weak self] in
      self?.liveStreamViewController?.view.hidden = $0
    }

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(next: { [weak self] image in self?.projectImageView.image = nil })
      .observeNext { [weak self] in self?.projectImageView.af_setImageWithURL($0) }

    self.loaderLabel.rac.text = self.viewModel.outputs.loaderText

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.eventDetailsViewModel.outputs.retrieveEventInfo
      .observeNext { [weak self] in
        KsLiveApp.retrieveEvent($0, uid: AppEnvironment.current.currentUser?.id).startWithResult {
          switch $0 {
          case .Success(let event):
            self?.viewModel.inputs.setLiveStreamEvent(event: event)
            self?.eventDetailsViewModel.inputs.setLiveStreamEvent(event: event)
          case .Failure(let error):
            print(error)
          }
        }
    }

    self.creatorAvatarLabel.rac.attributedText = self.eventDetailsViewModel.outputs.introText

    self.eventDetailsViewModel.outputs.creatorAvatarUrl
      .observeForUI()
      .on(next: { [weak self] image in self?.creatorAvatarImageView.image = nil })
      .observeNext { [weak self] in self?.creatorAvatarImageView.af_setImageWithURL($0) }

    let isLive: Signal<Bool, NoError> = self.viewModel.outputs.liveStreamState
      .observeForUI()
      .map {
      if case .live = $0 { return true }

      return false
    }

    let isReplay: Signal<Bool, NoError> = self.viewModel.outputs.liveStreamState
      .observeForUI()
      .map {
        if case .replay = $0 { return true }

        return false
    }

    self.navBarLiveDotImageView.rac.hidden = isLive.map(negate)
    self.creatorAvatarLiveDotImageView.rac.hidden = isLive.map(negate)
    self.numberWatchingButton.rac.hidden = isLive.map(negate)
    self.availableForLabel.rac.hidden = isReplay.map(negate)

    self.navBarTitleLabel.rac.text = self.viewModel.outputs.titleViewText

    self.liveStreamTitleLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamTitle
    self.liveStreamParagraphLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamParagraph
    self.subscribeLabel.rac.text = self.eventDetailsViewModel.outputs.subscribeLabelText
    self.subscribeButton.rac.title = self.eventDetailsViewModel.outputs.subscribeButtonText
    self.numberWatchingButton.rac.title = self.eventDetailsViewModel.outputs.numberOfPeopleWatchingText
    self.shareBarButtonItem.rac.enabled = self.eventDetailsViewModel.outputs.configureSharing.mapConst(true)

    self.eventDetailsViewModel.outputs.configureSharing.observeNext { [weak self] in
      self?.shareViewModel.inputs.configureWith(shareContext: ShareContext.liveStream($0, $1))
    }

    self.eventDetailsViewModel.outputs.subscribeButtonImage
      .observeForUI()
      .observeNext { [weak self] in
        self?.subscribeButton.setImage($0, forState: .Normal)
    }

    self.availableForLabel.rac.text = self.eventDetailsViewModel.outputs.availableForText

    self.detailsLoadingActivityIndicatorView.rac.hidden = self.eventDetailsViewModel.outputs
      .showActivityIndicator
      .map(negate)

    self.detailsContainerStackView.rac.hidden = self.eventDetailsViewModel.outputs.showActivityIndicator

    self.subscribeActivityIndicatorView.rac.hidden = self.eventDetailsViewModel.outputs
      .showSubscribeButtonActivityIndicator
      .map(negate)

    self.subscribeButton.rac.hidden = self.eventDetailsViewModel.outputs
      .showSubscribeButtonActivityIndicator

    self.eventDetailsViewModel.outputs.toggleSubscribe
      .observeNext { [weak self] in
        guard let userId = AppEnvironment.current.currentUser?.id else { return }
        KsLiveApp.subscribe($0.0, uid: userId, subscribe: $0.1).startWithResult {
          switch $0 {
          case .Success(let result):
            self?.eventDetailsViewModel.inputs.setSubcribed(subscribed: result)
          case .Failure(let error):
            print(error)
          }
        }
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showShareSheet($0) }
  }
  //swiftlint:enable function_body_length

  internal override func prefersStatusBarHidden() -> Bool {
    return true
  }

  internal override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.loaderView.layer
      |> CALayer.lens.masksToBounds .~ false
      |> CALayer.lens.shadowColor .~ UIColor.blackColor().CGColor
      |> CALayer.lens.shadowOffset .~ CGSize(width: 0, height: 5)
      |> CALayer.lens.shadowOpacity .~ Float(0.5)

    self.loaderView.layer.shadowPath = UIBezierPath(rect: self.loaderView.bounds).CGPath
    self.numberWatchingButton.layer.cornerRadius = self.numberWatchingButton.frame.size.height / 2
    self.subscribeButton.layer.cornerRadius = self.subscribeButton.frame.size.height / 2
    self.creatorAvatarImageView.layer.cornerRadius = self.creatorAvatarImageView.frame.size.width / 2

    let titleSize = self.navBarTitleLabel.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max))
    self.navBarTitleStackViewBackgroundView.frame = CGRect(
      origin:self.navBarTitleStackViewBackgroundView.frame.origin,
      size: CGSize(width: Styles.grid(4) + titleSize.width, height: Styles.grid(5))
    )

    self.loaderViewHeightConstraint.constant = self.videoFrame(self.isLandscape()).height

    if let view = self.liveStreamViewController?.view {
      self.layoutLiveStreamView(view)
    }
  }

  internal override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator
    coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    coordinator.animateAlongsideTransition({ (context) in
      if let view = self.liveStreamViewController?.view { self.layoutLiveStreamView(view) }
      }, completion: { _ in
        self.navigationController?.setNavigationBarHidden(self.isLandscape(), animated: true)
    })
  }

  private func addChildLiveStreamViewController(controller: LiveStreamViewController) {
    self.liveStreamViewController = controller
    controller.view.hidden = true
    self.addChildViewController(controller)
    controller.didMoveToParentViewController(self)
    self.view.addSubview(controller.view)
  }

  private func layoutLiveStreamView(view: UIView) {
    view.frame = self.videoFrame(self.isLandscape())
  }

  private func isLandscape() -> Bool {
    return UIApplication.sharedApplication().statusBarOrientation != .Portrait
  }

  private func videoFrame(landscape: Bool) -> CGRect {
    return CGRect(x: 0, y: 0,
                  width: self.view.bounds.size.width,
                  height: self.view.bounds.size.height * (landscape ? 1 : 0.4))
  }

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] in
      self?.shareViewModel.inputs.shareActivityCompletion(activityType: $0,
                                                          completed: $1,
                                                          returnedItems: $2,
                                                          activityError: $3)
    }

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      controller.modalPresentationStyle = .Popover
      controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
      self.presentViewController(controller, animated: true, completion: nil)

    } else {
      self.presentViewController(controller, animated: true, completion: nil)
    }
  }

  // MARK: Subviews

  lazy var navBarTitleStackViewBackgroundView = { UIView() }()
  lazy var navBarTitleStackView = { UIStackView() }()
  lazy var navBarLiveDotImageView = { UIImageView() }()
  lazy var navBarTitleLabel = { UILabel() }()

  lazy var shareBarButtonItem: UIBarButtonItem = {
    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .whiteColor()
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(LiveStreamContainerViewController.share(_:)))
      |> UIBarButtonItem.lens.enabled .~ false

    return shareBarButtonItem
  }()

  // MARK: Actions

  internal func close(sender: UIBarButtonItem) {
    self.viewModel.inputs.closeButtonTapped()
  }

  internal func share(sender: UIBarButtonItem) {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @IBAction internal func subscribe(sender: UIButton) {
    self.eventDetailsViewModel.inputs.subscribeButtonTapped()
  }
}
//swiftlint:enable type_body_length

extension LiveStreamContainerViewController: LiveStreamViewControllerDelegate {
  internal func numberOfPeopleWatchingChanged(controller: LiveStreamViewController, numberOfPeople: Int) {
    self.eventDetailsViewModel.inputs.setNumberOfPeopleWatching(numberOfPeople: numberOfPeople)
  }

  internal func liveStreamStateChanged(controller: LiveStreamViewController,
                                       state: LiveStreamViewControllerState) {
    self.viewModel.inputs.liveStreamViewControllerStateChanged(state: state)
    self.eventDetailsViewModel.inputs.liveStreamViewControllerStateChanged(state: state)
  }
}
