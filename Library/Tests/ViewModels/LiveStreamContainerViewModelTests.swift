import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class LiveStreamContainerViewModelTests: TestCase {
  private let vm: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  private let availableForLabelHidden = TestObserver<Bool, NoError>()
  private let createAndConfigureLiveStreamViewController = TestObserver<(Project, Int?,
    LiveStreamEvent), NoError>()
  private let creatorAvatarLiveDotImageViewHidden = TestObserver<Bool, NoError>()
  private let creatorIntroText = TestObserver<String, NoError>()
  private let dismiss = TestObserver<(), NoError>()
  private let liveStreamState = TestObserver<LiveStreamViewControllerState, NoError>()
  private let loaderText = TestObserver<String, NoError>()
  private let navBarLiveDotImageViewHidden = TestObserver<Bool, NoError>()
  private let numberWatchingButtonHidden = TestObserver<Bool, NoError>()
  private let projectImageUrl = TestObserver<URL, NoError>()
  private let showErrorAlert = TestObserver<String, NoError>()
  private let videoViewControllerHidden = TestObserver<Bool, NoError>()
  private let titleViewText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.availableForLabelHidden.observe(self.availableForLabelHidden.observer)
    self.vm.outputs.createAndConfigureLiveStreamViewController.observe(
      self.createAndConfigureLiveStreamViewController.observer)
    self.vm.outputs.creatorAvatarLiveDotImageViewHidden
      .observe(self.creatorAvatarLiveDotImageViewHidden.observer)
    self.vm.outputs.creatorIntroText.map { $0.string }.observe(self.creatorIntroText.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.liveStreamState.observe(self.liveStreamState.observer)
    self.vm.outputs.loaderText.observe(self.loaderText.observer)
    self.vm.outputs.navBarLiveDotImageViewHidden.observe(self.navBarLiveDotImageViewHidden.observer)
    self.vm.outputs.numberWatchingButtonHidden.observe(self.numberWatchingButtonHidden.observer)
    self.vm.outputs.projectImageUrl.observe(self.projectImageUrl.observer)
    self.vm.outputs.videoViewControllerHidden.observe(self.videoViewControllerHidden.observer)
    self.vm.outputs.titleViewText.observe(self.titleViewText.observer)
  }

  func testCreatorIntroText_Live() {
    let stream = LiveStreamEvent.template.stream
      |> LiveStreamEvent.Stream.lens.startDate .~ MockDate().date
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream .~ stream
      |> LiveStreamEvent.lens.stream.liveNow .~ true

    self.creatorIntroText.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.creatorIntroText.assertValues(["Creator Name is live now"])
  }

  func testCreatorIntroText_Replay() {
    let stream = LiveStreamEvent.template.stream
      |> LiveStreamEvent.Stream.lens.startDate .~ MockDate().date
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream .~ stream
    |> LiveStreamEvent.lens.stream.liveNow .~ false

    self.creatorIntroText.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.creatorIntroText.assertValues(["Creator Name was live right now"])
  }

  func testCreateLiveStreamViewController() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.createAndConfigureLiveStreamViewController.lastValue == (project, nil, event))
  }

  func testDismiss() {
    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }

  func testShowErrorAlert() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .error(error: .sessionInterrupted), startTime: 0))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .error(error: .failedToConnect), startTime: 0))

    self.showErrorAlert.assertValues([
      "The live stream was interrupted",
      "The live stream failed to connect"
    ])
  }

  func testLabelVisibilities_Live() {
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ true

    self.navBarLiveDotImageViewHidden.assertValueCount(0)
    self.createAndConfigureLiveStreamViewController.assertValueCount(0)
    self.numberWatchingButtonHidden.assertValueCount(0)
    self.availableForLabelHidden.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.navBarLiveDotImageViewHidden.assertValues([true, false])
    self.creatorAvatarLiveDotImageViewHidden.assertValues([true, false])
    self.numberWatchingButtonHidden.assertValues([true, false])
    self.availableForLabelHidden.assertValues([true])
  }

  func testLabelVisibilities_Replay() {
    let project = Project.template
    let event = LiveStreamEvent.template
      |> LiveStreamEvent.lens.stream.liveNow .~ false

    self.navBarLiveDotImageViewHidden.assertValueCount(0)
    self.createAndConfigureLiveStreamViewController.assertValueCount(0)
    self.numberWatchingButtonHidden.assertValueCount(0)
    self.availableForLabelHidden.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.navBarLiveDotImageViewHidden.assertValues([true])
    self.creatorAvatarLiveDotImageViewHidden.assertValues([true])
    self.numberWatchingButtonHidden.assertValues([true])
    self.availableForLabelHidden.assertValues([true, false])
  }

  func testLiveStreamStates() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .loading, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .playing, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .live(playbackState: .error(error: .sessionInterrupted), startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .loading, duration: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .playing, duration: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .error(error: .failedToConnect),
        duration: 123))

    // Test begins with an implicit loading state before any others
    self.liveStreamState.assertValues([
      .loading,
      .greenRoom,
      .loading,
      .live(playbackState: .loading, startTime: 123),
      .live(playbackState: .playing, startTime: 123),
      .live(playbackState: .error(error: .sessionInterrupted), startTime: 123),
      .replay(playbackState: .loading, duration: 123),
      .replay(playbackState: .playing, duration: 123),
      .replay(playbackState: .error(error: .failedToConnect), duration: 123)
    ])
  }

  func testLoaderText() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .loading, duration: 123))

    self.loaderText.assertValues([
      "Loading",
      "The live stream will start soon",
      "Loading",
      "The replay will start soon"
    ])
  }

  func testProjectImageUrl() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, event: nil)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(self.projectImageUrl.lastValue?.absoluteString == "http://www.kickstarter.com/full.jpg")
  }

  func testShowVideoView() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .playing, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .playing, duration: 123))

    self.videoViewControllerHidden.assertValues([
      true,
      true,
      false,
      true,
      false
    ])
  }

  func testTitleViewText() {
    let project = Project.template
    let event = LiveStreamEvent.template

    self.vm.inputs.configureWith(project: project, event: event)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.liveStreamViewControllerStateChanged(state: .greenRoom)
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .live(playbackState: .loading, startTime: 123))
    self.vm.inputs.liveStreamViewControllerStateChanged(state: .loading)
    self.vm.inputs.liveStreamViewControllerStateChanged(
      state: .replay(playbackState: .loading, duration: 123))

    self.titleViewText.assertValues([
      "Loading",
      "Starting soon",
      "Live",
      "Loading",
      "Recorded Live"
    ])
  }
}

private func == (tuple1: (Project, Int?, LiveStreamEvent)?,
                 tuple2: (Project, Int?, LiveStreamEvent)) -> Bool {
  if let tuple1 = tuple1 {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1
  }

  return false
}
