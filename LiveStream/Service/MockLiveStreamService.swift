import Prelude
import ReactiveCocoa

internal struct MockLiveStreamService: LiveStreamServiceProtocol {

  private let fetchEventError: LiveApiError?
  private let fetchEventResponse: LiveStreamEvent?
  private let subscribeToError: LiveApiError?
  private let subscribeToResponse: Bool?

  // FIXME: do this instead
  //private subscribeToResult: Result<Bool, LiveApiError>

  internal init() {
    self.init(fetchEventError: nil)
  }

  internal init(fetchEventError: LiveApiError? = nil,
                fetchEventResponse: LiveStreamEvent? = nil,
                subscribeToError: LiveApiError? = nil,
                subscribeToResponse: Bool? = nil) {
    self.fetchEventError = fetchEventError
    self.fetchEventResponse = fetchEventResponse
    self.subscribeToError = subscribeToError
    self.subscribeToResponse = subscribeToResponse
  }

  internal func fetchEvent(eventId eventId: Int, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError> {
    if let error = self.fetchEventError {
      return SignalProducer(error: error)
    }

    return SignalProducer(value:
      self.fetchEventResponse
        // FIXME: get rid of force unwrap
        ?? .template |> LiveStreamEvent.lens.id .~ eventId
    )
  }

  internal func subscribeTo(eventId eventId: Int, uid: Int, isSubscribed: Bool)
    -> SignalProducer<Bool, LiveApiError> {

      if let error = self.subscribeToError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.subscribeToResponse ?? isSubscribed)
  }
}
