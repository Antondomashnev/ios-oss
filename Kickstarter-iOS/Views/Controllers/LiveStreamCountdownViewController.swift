import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit
import KsLive

internal final class LiveStreamCountdownViewController: UIViewController {
  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarWidthConstraint: NSLayoutConstraint!
  @IBOutlet private var countdownColons: [UILabel]?
  @IBOutlet private weak var countdownContainerStackView: UIStackView!
  @IBOutlet private weak var countdownStackView: UIStackView!
  @IBOutlet private var countdownLabels: [UILabel]?
  @IBOutlet private weak var creatorNameLabel: UILabel!
  @IBOutlet private weak var daysLabel: UILabel!
  @IBOutlet private weak var detailsContainerStackView: UIStackView!
  @IBOutlet private weak var detailsContainerStackViewTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var detailsStackViewBackgroundView: UIView!
  @IBOutlet private weak var detailsStackView: UIStackView!
  @IBOutlet private weak var gradientView: GradientView!
  @IBOutlet private weak var hoursLabel: UILabel!
  @IBOutlet private weak var introLabel: UILabel!
  @IBOutlet private weak var liveStreamTitleLabel: UILabel!
  @IBOutlet private weak var liveStreamParagraphLabel: UILabel!
  @IBOutlet private weak var minutesLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var secondsLabel: UILabel!
  @IBOutlet private weak var subscribeActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var subscribeButton: UIButton!

  private let viewModel: LiveStreamCountdownViewModelType = LiveStreamCountdownViewModel()
  private let eventDetailsViewModel: LiveStreamEventDetailsViewModelType = LiveStreamEventDetailsViewModel()
  private var timerProducer: Disposable?

  internal static func configuredWith(project project: Project)
    -> LiveStreamCountdownViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamCountdownViewController)
      vc.viewModel.inputs.configureWith(project: project, now: NSDate())
      vc.eventDetailsViewModel.inputs.configureWith(project: project, event: nil)
      vc.eventDetailsViewModel.inputs.fetchLiveStreamEvent()
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .whiteColor()
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(LiveStreamCountdownViewController.close(_:)))

    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .whiteColor()
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(LiveStreamCountdownViewController.share(_:)))

    self.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.navigationItem.rightBarButtonItem = shareBarButtonItem

    self.viewModel.inputs.viewDidLoad()
    self.eventDetailsViewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill

    self.countdownStackView
      |> UIStackView.lens.alignment .~ .Top
      |> UIStackView.lens.distribution .~ .FillProportionally

    self.countdownContainerStackView
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.spacing .~ Styles.grid(6)
      |> UIStackView.lens.distribution .~ .Fill

    self.countdownLabels?.forEach { label in
      label
        |> UILabel.lens.textAlignment .~ .Center
        |> UILabel.lens.numberOfLines .~ 2
        |> UILabel.lens.textColor .~ .whiteColor()
    }

    self.countdownColons?.forEach { label in
      label
        |> UILabel.lens.textAlignment .~ .Center
        |> UILabel.lens.numberOfLines .~ 2
        |> UILabel.lens.textColor .~ .whiteColor()
        |> UILabel.lens.font .~ .ksr_title1(size: 24)
    }

    self.detailsContainerStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(
        top: 0, left: Styles.grid(4), bottom: Styles.grid(4), right: Styles.grid(4))

    self.detailsStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.grid(8), left: Styles.grid(4),
                                                        bottom: Styles.grid(7), right: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.detailsStackViewBackgroundView
      |> roundedStyle(cornerRadius: 2)

    self.detailsContainerStackViewTopConstraint.constant = -Styles.grid(4)
    self.creatorAvatarWidthConstraint.constant = Styles.grid(10)

    self.introLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_navy_600

    self.creatorAvatarImageView
      |> UIImageView.lens.layer.masksToBounds .~ true

    self.creatorNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_navy_700

    self.liveStreamTitleLabel
      |> UILabel.lens.font .~ UIFont.ksr_title3()
      |> UILabel.lens.textColor .~ .ksr_navy_700

    self.liveStreamParagraphLabel
      |> UILabel.lens.font .~ UIFont.ksr_subhead()
      |> UILabel.lens.textColor .~ .ksr_navy_600

    self.subscribeButton
      |> greenBorderContainerButtonStyle
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(right: -Styles.grid(1))
      |> UIButton.lens.tintColor .~ self.subscribeButton.currentTitleColor
    
    self.subscribeButton.semanticContentAttribute = .ForceRightToLeft

    self.activityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .Gray
      |> UIActivityIndicatorView.lens.animating .~ true
  }

  internal override func prefersStatusBarHidden() -> Bool {
    return true
  }

  internal override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.subscribeButton.layer.cornerRadius = self.subscribeButton.frame.size.height / 2
    self.creatorAvatarImageView.layer.cornerRadius = self.creatorAvatarImageView.frame.size.height / 2
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.daysLabel.rac.attributedText = self.viewModel.outputs
      .daysString
      .observeForUI()
      .map { [weak self] in
      self?.attributedCountdownString($0, suffix: $1)
      }.ignoreNil()

    self.hoursLabel.rac.attributedText = self.viewModel.outputs.hoursString
      .observeForUI()
      .map { [weak self] in
      self?.attributedCountdownString($0, suffix: $1)
      }.ignoreNil()

    self.minutesLabel.rac.attributedText = self.viewModel.outputs.minutesString
      .observeForUI()
      .map { [weak self] in
      self?.attributedCountdownString($0, suffix: $1)
      }.ignoreNil()

    self.secondsLabel.rac.attributedText = self.viewModel.outputs.secondsString
      .observeForUI()
      .map { [weak self] in
      self?.attributedCountdownString($0, suffix: $1)
      }.ignoreNil()

    self.timerProducer = timer(1, onScheduler: QueueScheduler(queue: dispatch_get_main_queue()))
      .startWithNext { [weak self] in
        self?.viewModel.inputs.setNow(date: $0)
    }

    self.introLabel.rac.text = self.eventDetailsViewModel.outputs.introText.observeForUI()
    self.creatorNameLabel.rac.text = self.eventDetailsViewModel.outputs.creatorName.observeForUI()
    self.liveStreamTitleLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamTitle.observeForUI()
    self.liveStreamParagraphLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamParagraph
      .observeForUI()

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(next: { [weak self] image in self?.projectImageView.image = nil })
      .observeNext { [weak self] in self?.projectImageView.af_setImageWithURL($0) }

    self.eventDetailsViewModel.outputs.creatorAvatarUrl
      .observeForUI()
      .on(next: { [weak self] image in self?.creatorAvatarImageView.image = nil })
      .observeNext { [weak self] in self?.creatorAvatarImageView.af_setImageWithURL($0) }

    self.viewModel.outputs.categoryId
      .observeForUI()
      .observeNext { [weak self] in
      let (startColor, endColor) = discoveryGradientColors(forCategoryId: $0)
      self?.gradientView.setGradient([(startColor, 0.0), (endColor, 1.0)])
    }

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeNext { [weak self] in
      self?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.navigationItem.rac.title = self.viewModel.outputs.viewControllerTitle
    self.subscribeButton.rac.title = self.eventDetailsViewModel.outputs.subscribeButtonText

    self.eventDetailsViewModel.outputs.subscribeButtonImage
      .observeForUI()
      .observeNext { [weak self] in
      self?.subscribeButton.setImage($0, forState: .Normal)
    }

    self.viewModel.outputs.retrieveEventInfo
      .observeForUI()
      .on(next: { [weak self] image in self?.creatorAvatarImageView.image = nil })
      .observeNext { [weak self] in
        guard let userId = AppEnvironment.current.currentUser?.id else { return }
        KsLiveApp.retrieveEvent($0, uid: String(userId)).startWithResult {
          switch $0 {
          case .Success(let event):
            self?.viewModel.inputs.setLiveStreamEvent(event: event)
            self?.eventDetailsViewModel.inputs.setLiveStreamEvent(event: event)
          case .Failure(let error):
            print(error)
          }
        }
    }

    self.activityIndicatorView.rac.hidden = self.eventDetailsViewModel.outputs.showActivityIndicator
      .observeForUI()
      .map(negate)
    
    self.detailsStackView.rac.hidden = self.eventDetailsViewModel.outputs.showActivityIndicator
      .observeForUI()

    self.subscribeActivityIndicatorView.rac.hidden = self.eventDetailsViewModel.outputs
      .showSubscribeButtonActivityIndicator
      .observeForUI()
      .map(negate)

    self.subscribeButton.rac.hidden = self.eventDetailsViewModel.outputs
      .showSubscribeButtonActivityIndicator
      .observeForUI()

    self.eventDetailsViewModel.outputs.toggleSubscribe
      .observeForUI()
      .observeNext { [weak self] in
        guard let userId = AppEnvironment.current.currentUser?.id else { return }
        KsLiveApp.subscribe($0.0, uid: String(userId), subscribe: $0.1).startWithResult {
          switch $0 {
          case .Success(let result):
            self?.eventDetailsViewModel.inputs.setSubcribed(subscribed: result)
          case .Failure(let error):
            print(error)
          }
        }
    }

    self.viewModel.outputs.pushLiveStreamViewController
      .observeForControllerAction()
      .observeNext { [weak self] in
      let liveStreamContainerViewController = LiveStreamContainerViewController
        .configuredWith(project: $0, event: $1)

      self?.navigationController?.pushViewController(liveStreamContainerViewController, animated: true)
    }
  }

  deinit {
    self.timerProducer?.dispose()
  }

  private func attributedCountdownString(prefix: String, suffix: String) -> NSAttributedString {

    let fontDescriptorAttributes = [
      UIFontDescriptorFeatureSettingsAttribute: [
        [
          UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
          UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
        ]
      ]
    ]
    
    let fontDescriptor = UIFont.ksr_title1(size: 24)
      .fontDescriptor()
      .fontDescriptorByAddingAttributes(fontDescriptorAttributes)

    let prefixAttributes = [NSFontAttributeName : UIFont(descriptor: fontDescriptor, size: 24)]
    let suffixAttributes = [NSFontAttributeName : UIFont.ksr_headline(size: 14)]

    let prefix = NSMutableAttributedString(string: prefix, attributes: prefixAttributes)
    let suffix = NSAttributedString(string: "\n\(suffix)", attributes: suffixAttributes)
    prefix.appendAttributedString(suffix)

    return NSAttributedString(attributedString: prefix)
  }

  // MARK: Actions

  internal func close(sender: UIBarButtonItem) {
    self.viewModel.inputs.closeButtonTapped()
  }

  internal func share(sender: UIBarButtonItem) {

  }

  @IBAction internal func subscribe(sender: UIButton) {
    self.eventDetailsViewModel.inputs.subscribeButtonTapped()
  }
}