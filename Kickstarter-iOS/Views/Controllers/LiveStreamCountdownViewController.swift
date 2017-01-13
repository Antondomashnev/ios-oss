import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import UIKit

internal final class LiveStreamCountdownViewController: UIViewController {
  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var creatorAvatarBottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarWidthConstraint: NSLayoutConstraint!
  @IBOutlet private var countdownColons: [UILabel]!
  @IBOutlet private weak var countdownStackView: UIStackView!
  @IBOutlet private var countdownLabels: [UILabel]!
  @IBOutlet private weak var daysLabel: UILabel!
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

  private let eventDetailsViewModel: LiveStreamEventDetailsViewModelType = LiveStreamEventDetailsViewModel()
  private let viewModel: LiveStreamCountdownViewModelType = LiveStreamCountdownViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  internal static func configuredWith(project: Project, liveStream: Project.LiveStream)
    -> LiveStreamCountdownViewController {

      let vc = Storyboard._LiveStreamTesting.instantiate(LiveStreamCountdownViewController.self)
      vc.viewModel.inputs.configureWith(project: project, liveStream: liveStream)
      vc.eventDetailsViewModel.inputs.configureWith(project: project, liveStream: liveStream, event: nil)
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(close))

    self.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

    self.viewModel.inputs.viewDidLoad()
    self.eventDetailsViewModel.inputs.viewDidLoad()
  }

  //swiftlint:disable:next function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> LiveStreamCountdownViewController.lens.view.layoutMargins .~ .zero

    _ = self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    _ = self.countdownStackView
      |> UIStackView.lens.alignment .~ .firstBaseline
      |> UIStackView.lens.distribution .~ .equalCentering
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins %~~ { _, s in
        s.traitCollection.isRegularRegular
          ? .init(topBottom: 0, leftRight: Styles.grid(18))
          : .init(topBottom: 0, leftRight: Styles.grid(6))
    }

    _ = self.countdownLabels
      ||> UILabel.lens.textAlignment .~ .center
      ||> UILabel.lens.numberOfLines .~ 2
      ||> UILabel.lens.textColor .~ .white
      ||> UILabel.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityRequired
      ||> UILabel.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ UILayoutPriorityRequired

    _ = self.countdownColons
      ||> UILabel.lens.text .~ ":"
      ||> UILabel.lens.textAlignment .~ .center
      ||> UILabel.lens.numberOfLines .~ 2
      ||> UILabel.lens.textColor .~ .white
      ||> UILabel.lens.font .~ .ksr_title1(size: 24)

    _ = self.detailsStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.grid(4), left: Styles.grid(4),
                                                        bottom: Styles.grid(7), right: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.detailsStackViewBackgroundView
      |> roundedStyle(cornerRadius: 2)

    self.creatorAvatarBottomConstraint.constant = -Styles.grid(4)
    self.creatorAvatarWidthConstraint.constant = self.traitCollection.isRegularRegular
      ? Styles.grid(20)
      : Styles.grid(10)

    _ = self.introLabel
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.liveStreamTitleLabel
      |> UILabel.lens.font %~~ { _, v in
        v.traitCollection.isRegularRegular ?  UIFont.ksr_title2() : UIFont.ksr_title3()
      }
      |> UILabel.lens.textColor .~ .ksr_navy_700
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.liveStreamParagraphLabel
      |> UILabel.lens.font %~~ { _, v in
        v.traitCollection.isRegularRegular ?  UIFont.ksr_body() : UIFont.ksr_subhead()
      }
      |> UILabel.lens.textColor .~ .ksr_navy_600

    _ = self.subscribeButton
      |> greenBorderContainerButtonStyle
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(right: -Styles.grid(1))
      |> UIButton.lens.tintColor .~ self.subscribeButton.currentTitleColor

    self.subscribeButton.semanticContentAttribute = .forceRightToLeft

    _ = self.activityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .gray
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true

    _ = self.subscribeActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .gray
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.animating .~ false

    _ = self.gradientView
      |> UIView.lens.layoutMargins %~~ { _, s in
        s.traitCollection.horizontalSizeClass == .regular
          ? .init(top: 0, left: Styles.grid(12), bottom: Styles.grid(4), right: Styles.grid(12))
          : .init(top: 0, left: Styles.grid(4), bottom: Styles.grid(4), right: Styles.grid(4))
    }
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.subscribeButton.layer.cornerRadius = self.subscribeButton.frame.size.height / 2
  }

  //swiftlint:disable:next function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.daysLabel.rac.attributedText = self.viewModel.outputs.daysString
    self.hoursLabel.rac.attributedText = self.viewModel.outputs.hoursString
    self.minutesLabel.rac.attributedText = self.viewModel.outputs.minutesString
    self.secondsLabel.rac.attributedText = self.viewModel.outputs.secondsString

    self.eventDetailsViewModel.outputs.configureShareViewModel
      .observeValues { [weak self] in
        self?.shareViewModel.inputs.configureWith(shareContext: ShareContext.liveStream($0, $1))
    }

    self.shareBarButtonItem.rac.enabled = self.eventDetailsViewModel.outputs.shareButtonEnabled

    self.introLabel.rac.attributedText = self.viewModel.outputs.upcomingIntroText
    self.liveStreamTitleLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamTitle
    self.liveStreamParagraphLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamParagraph

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(event: { [weak self] image in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .observeValues { [weak self] in self?.projectImageView.ksr_setImageWithURL($0) }

    self.eventDetailsViewModel.outputs.creatorAvatarUrl
      .observeForUI()
      .on(event: { [weak self] image in
        self?.creatorAvatarImageView.af_cancelImageRequest()
        self?.creatorAvatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] in self?.creatorAvatarImageView.ksr_setImageWithURL($0) }

    self.viewModel.outputs.categoryId
      .observeForUI()
      .observeValues { [weak self] in
        let (startColor, endColor) = discoveryGradientColors(forCategoryId: $0)
        self?.gradientView.setGradient([(startColor, 0.0), (endColor, 1.0)])
    }

    self.eventDetailsViewModel.outputs.retrievedLiveStreamEvent
      .observeValues { [weak self] in
        self?.viewModel.inputs.retrievedLiveStreamEvent(event: $0)
    }

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.navigationItem.rac.title = self.viewModel.outputs.viewControllerTitle
    self.subscribeButton.rac.title = self.eventDetailsViewModel.outputs.subscribeButtonText

    self.eventDetailsViewModel.outputs.subscribeButtonImage
      .observeForUI()
      .observeValues { [weak self] imageName in
        self?.subscribeButton.setImage(image(named: imageName ?? ""), for: .normal)
    }

    self.activityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateActivityIndicator

    self.detailsStackView.rac.hidden = self.eventDetailsViewModel.outputs
      .animateActivityIndicator

    self.subscribeActivityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.subscribeButton.rac.hidden = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.viewModel.outputs.pushLiveStreamViewController
      .observeForControllerAction()
      .observeValues { [weak self] project, liveStream, event in
        let liveStreamContainerViewController = LiveStreamContainerViewController
          .configuredWith(project: project, liveStream: liveStream, event: event)

        self?.navigationController?.pushViewController(liveStreamContainerViewController, animated: true)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showShareSheet(controller: $0) }

    self.eventDetailsViewModel.outputs.showErrorAlert
      .observeForUI()
      .observeValues { [weak self] in
        self?.present(UIAlertController.genericError($0), animated: true, completion: nil)
    }
  }

  // FIXME: this can be an IBOutlet
  lazy var shareBarButtonItem: UIBarButtonItem = {
    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(share))
      |> UIBarButtonItem.lens.enabled .~ false

    return shareBarButtonItem
  }()

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in

      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(activityType: activityType,
                    completed: completed,
                    returnedItems: returnedItems,
                    activityError: error)
      )
    }

    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
      self.present(controller, animated: true, completion: nil)

    } else {
      self.present(controller, animated: true, completion: nil)
    }
  }

  // MARK: Actions

  @objc private func close() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func share() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @IBAction internal func subscribe(_ sender: UIButton) {
    self.eventDetailsViewModel.inputs.subscribeButtonTapped()
  }
}
