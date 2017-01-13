import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
@testable import LiveStream

internal final class LiveStreamCountdownViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    self.recordMode = true
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    let liveStream = .template
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 + 195_753)
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.user.isSubscribed .~ true
      // FIXME: i wouldnt think we would use project name
      |> LiveStreamEvent.lens.stream.projectName .~ "Title of the live stream goes here and can be 60 chr max"
      |> LiveStreamEvent.lens.stream.description .~ "175 char max. 175 char max 175 char max message with a max character count. Hi everyone! We’re doing an exclusive performance of one of our new tracks!"
    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEvent))

    AppEnvironment.replaceCurrentEnvironment(liveStreamService: liveStreamService)

    let devices = [Device.phone4_7inch, Device.phone4inch, Device.pad]

    combos(Language.allLanguages, devices).forEach { lang, device in
      let vc = LiveStreamCountdownViewController.configuredWith(project: .template, liveStream: liveStream)

      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
      self.scheduler.advance()

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(lang)_device_\(device)")
    }
  }

  // FIXME: do small device screen
}
