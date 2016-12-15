import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude
import KsLive

public protocol LiveStreamCountdownViewModelType {
  var inputs: LiveStreamCountdownViewModelInputs { get }
  var outputs: LiveStreamCountdownViewModelOutputs { get }
}

public protocol LiveStreamCountdownViewModelInputs {
  func closeButtonTapped()
  func configureWith(project project: Project, now: NSDate?)
  func setLiveStreamEvent(event event: LiveStreamEvent)
  func setNow(date date: NSDate)
  func viewDidLoad()
}

public protocol LiveStreamCountdownViewModelOutputs {
  var categoryId: Signal<Int, NoError> { get }
  var daysString: Signal<(String, String), NoError> { get }
  var dismiss: Signal<(), NoError> { get }
  var hoursString: Signal<(String, String), NoError> { get }
  var minutesString: Signal<(String, String), NoError> { get }
  var projectImageUrl: Signal<NSURL, NoError> { get }
  var pushLiveStreamViewController: Signal<(Project, LiveStreamEvent), NoError> { get }
  var retrieveEventInfo: Signal<String, NoError> { get }
  var secondsString: Signal<(String, String), NoError> { get }
  var viewControllerTitle: Signal<String, NoError> { get }
}

public final class LiveStreamCountdownViewModel: LiveStreamCountdownViewModelType,
LiveStreamCountdownViewModelInputs, LiveStreamCountdownViewModelOutputs {

  public init() {
    let project = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    let dateComponents = combineLatest(
      project.map { $0.liveStreams.first }.ignoreNil()
        .map { NSDate(timeIntervalSince1970: $0.startDate) },
      self.nowProperty.signal.ignoreNil()
      )
      .map {
        NSCalendar.currentCalendar().components(
          [.Day, .Hour, .Minute, .Second],
          fromDate: $1,
          toDate: $0,
          options: []
        )
    }

    let days = dateComponents
      .map { $0.day >= 0 ? $0.day : 0  }
      .skipRepeats()

    let hours = dateComponents
      .map { $0.hour >= 0 ? $0.hour : 0  }
      .skipRepeats()

    let minutes = dateComponents
      .map { $0.minute >= 0 ? $0.minute : 0  }
      .skipRepeats()

    let seconds = dateComponents
      .map { $0.second >= 0 ? $0.second : 0  }
      .skipRepeats()

    self.daysString = days
      .map { (String(format: "%02d", $0), "days") }

    self.hoursString = hours
      .map { (String(format: "%02d", $0), "hours") }

    self.minutesString = minutes
      .map { (String(format: "%02d", $0), "minutes") }

    self.secondsString = seconds
      .map { (String(format: "%02d", $0), "seconds") }

    let countdownEnded = combineLatest(
      project.map { $0.liveStreams.first }.ignoreNil()
        .map { NSDate(timeIntervalSince1970: $0.startDate) },
      self.nowProperty.signal.ignoreNil()
      )
      .filter { $0.earlierDate($1) == $0 }

    self.projectImageUrl = project
      .map { NSURL(string: $0.photo.full) }
      .ignoreNil()

    self.categoryId = project.map { $0.category.rootId }.ignoreNil()
    self.dismiss = self.closeButtonTappedProperty.signal
    self.viewControllerTitle = viewDidLoadProperty.signal.mapConst("Live stream countdown")

    self.retrieveEventInfo = project.map { $0.liveStreams.first }.ignoreNil().map { $0.id }

    self.pushLiveStreamViewController = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.liveStreamEventProperty.signal.ignoreNil(),
      countdownEnded
      ).map { project, event, _ in (project, event) }
      .take(1)
  }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project, now: NSDate? = NSDate()) {
    self.projectProperty.value = project
    self.nowProperty.value = now
  }

  private let nowProperty = MutableProperty<NSDate?>(nil)
  public func setNow(date date: NSDate) {
    self.nowProperty.value = date
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func setLiveStreamEvent(event event: LiveStreamEvent) {
    self.liveStreamEventProperty.value = event
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let categoryId: Signal<Int, NoError>
  public let daysString: Signal<(String, String), NoError>
  public let dismiss: Signal<(), NoError>
  public let hoursString: Signal<(String, String), NoError>
  public let minutesString: Signal<(String, String), NoError>
  public let projectImageUrl: Signal<NSURL, NoError>
  public let pushLiveStreamViewController: Signal<(Project, LiveStreamEvent), NoError>
  public let retrieveEventInfo: Signal<String, NoError>
  public let secondsString: Signal<(String, String), NoError>
  public let viewControllerTitle: Signal<String, NoError>

  public var inputs: LiveStreamCountdownViewModelInputs { return self }
  public var outputs: LiveStreamCountdownViewModelOutputs { return self }
}