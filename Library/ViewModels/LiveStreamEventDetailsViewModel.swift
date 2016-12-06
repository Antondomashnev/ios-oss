import KsApi
import KsLive
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public protocol LiveStreamEventDetailsViewModelType {
  var inputs: LiveStreamEventDetailsViewModelInputs { get }
  var outputs: LiveStreamEventDetailsViewModelOutputs { get }
}

public protocol LiveStreamEventDetailsViewModelInputs {
  func configureWith(project project: Project, event: LiveStreamEvent?)
  func fetchLiveStreamEvent()
  func subscribeButtonTapped()
  func setLiveStreamEvent(event event: LiveStreamEvent)
  func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int)
  func setSubcribed(subscribed subscribed: Bool)
  func viewDidLoad()
}

public protocol LiveStreamEventDetailsViewModelOutputs {
  var creatorAvatarUrl: Signal<NSURL, NoError> { get }
  var creatorName: Signal<String, NoError> { get }
  var introText: Signal<String, NoError> { get }
  var liveStreamTitle: Signal<String, NoError> { get }
  var liveStreamParagraph: Signal<String, NoError> { get }
  var numberOfPeopleWatchingText: Signal<String, NoError> { get }
  var retrieveEventInfo: Signal<String, NoError> { get }
  var showActivityIndicator: Signal<Bool, NoError> { get }
  var showSubscribeButtonActivityIndicator: Signal<Bool, NoError> { get }
  var subscribeButtonText: Signal<String, NoError> { get }
  var subscribeButtonImage: Signal<UIImage?, NoError> { get }
  var subscribed: Signal<Bool, NoError> { get }
  var subscribeLabelText: Signal<String, NoError> { get }
  var toggleSubscribe: Signal<(), NoError> { get }
}

public class LiveStreamEventDetailsViewModel: LiveStreamEventDetailsViewModelType,
  LiveStreamEventDetailsViewModelInputs, LiveStreamEventDetailsViewModelOutputs {

  public init () {
    let project = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal)
      .map(first)

    self.subscribed = Signal.merge(
      self.subscribedProperty.signal,
      self.liveStreamEventProperty.signal.ignoreNil().map { $0.stream.isSubscribed }
    )

    self.introText = self.liveStreamEventProperty.signal.ignoreNil().mapConst("is live now")
    self.creatorAvatarUrl = self.liveStreamEventProperty.signal.ignoreNil()
      .map { NSURL(string: $0.creator.avatar) }
      .ignoreNil()
    self.creatorName = self.liveStreamEventProperty.signal.ignoreNil().map { $0.creator.name }
    self.liveStreamTitle = self.liveStreamEventProperty.signal.ignoreNil().map { $0.stream.projectName }
    self.liveStreamParagraph = self.liveStreamEventProperty.signal.ignoreNil().map { $0.stream.description }

    self.retrieveEventInfo = combineLatest(
      project.map { $0.liveStreams.first }.ignoreNil().map { $0.id },
      self.fetchLiveStreamEventProperty.signal
    ).map(first)

    self.subscribeButtonImage = self.subscribed.map {
      $0 ? UIImage(named: "postcard-checkmark") : nil
    }

    self.subscribeLabelText = self.subscribed.map {
      $0 ? "Keep up with future live streams" : "Keep up with future live streams"
    }

    self.subscribeButtonText = self.subscribed.map {
      $0 ? "Subscribed" : "Subscribe"
    }

    self.showActivityIndicator = Signal.merge(
      self.retrieveEventInfo.mapConst(true),
      self.liveStreamEventProperty.signal.ignoreNil().mapConst(false)
    )

    self.showSubscribeButtonActivityIndicator = Signal.merge(
      self.subscribed.mapConst(false),
      self.subscribeButtonTappedProperty.signal.mapConst(true)
    )

    self.toggleSubscribe = self.subscribeButtonTappedProperty.signal

    self.numberOfPeopleWatchingText = self.numberOfPeopleWatchingProperty.signal.ignoreNil()
      .map { String($0) }
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project, event: LiveStreamEvent?) {
    self.projectProperty.value = project
    self.liveStreamEventProperty.value = event
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let fetchLiveStreamEventProperty = MutableProperty()
  public func fetchLiveStreamEvent() {
    self.fetchLiveStreamEventProperty.value = ()
  }

  private let liveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func setLiveStreamEvent(event event: LiveStreamEvent) {
    self.liveStreamEventProperty.value = event
  }

  private let numberOfPeopleWatchingProperty = MutableProperty<Int?>(nil)
  public func setNumberOfPeopleWatching(numberOfPeople numberOfPeople: Int) {
    self.numberOfPeopleWatchingProperty.value = numberOfPeople
  }

  private let subscribedProperty = MutableProperty(false)
  public func setSubcribed(subscribed subscribed: Bool) {
    self.subscribedProperty.value = subscribed
  }

  private let subscribeButtonTappedProperty = MutableProperty()
  public func subscribeButtonTapped() {
    self.subscribeButtonTappedProperty.value = ()
  }

  public let creatorAvatarUrl: Signal<NSURL, NoError>
  public let creatorName: Signal<String, NoError>
  public let introText: Signal<String, NoError>
  public let liveStreamTitle: Signal<String, NoError>
  public let liveStreamParagraph: Signal<String, NoError>
  public let numberOfPeopleWatchingText: Signal<String, NoError>
  public let retrieveEventInfo: Signal<String, NoError>
  public let showActivityIndicator: Signal<Bool, NoError>
  public let showSubscribeButtonActivityIndicator: Signal<Bool, NoError>
  public let subscribeButtonText: Signal<String, NoError>
  public let subscribeButtonImage: Signal<UIImage?, NoError>
  public let subscribed: Signal<Bool, NoError>
  public let subscribeLabelText: Signal<String, NoError>
  public let toggleSubscribe: Signal<(), NoError>

  public var inputs: LiveStreamEventDetailsViewModelInputs { return self }
  public var outputs: LiveStreamEventDetailsViewModelOutputs { return self }
}