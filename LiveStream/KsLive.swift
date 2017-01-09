import FirebaseAnalytics
import FirebaseDatabase
import ReactiveCocoa
import Result
import Argo

public protocol LiveStreamServiceProtocol {
  init()
  func fetchEvent(eventId id: String, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError>
  func subscribeTo(eventId eventId: String, uid: Int, subscribe: Bool) -> SignalProducer<Bool, LiveApiError>
}

internal struct MockLiveStreamService: LiveStreamServiceProtocol {
  internal func fetchEvent(eventId id: String, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError> {
    return .empty
  }

  internal func subscribeTo(eventId eventId: String, uid: Int, subscribe: Bool) -> SignalProducer<Bool, LiveApiError> {
    return .empty
  }
}

public struct LiveStreamService: LiveStreamServiceProtocol {
  public init() {
  }

  public func fetchEvent(eventId eventId: String, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError> {


    return SignalProducer { (observer, disposable) in
      let uidString = uid
        .flatMap { "?uid=\($0)" }
        .coalesceWith("")

      let urlString = "\(Secrets.LiveStreams.endpoint)/\(eventId)\(uidString)"
      guard let url = NSURL(string: urlString) else {
        observer.sendFailed(.invalidEventId)
        return
      }

      let urlSession = NSURLSession(configuration: .defaultSessionConfiguration())

      let task = urlSession.dataTaskWithURL(url) { data, _, error in
        guard error == nil else {
          observer.sendFailed(.genericFailure)
          return
        }

        let event = data
          .flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
          .map(JSON.init)
          .map(LiveStreamEvent.decode)
          .flatMap { $0.value }
          .map(Event<LiveStreamEvent, LiveApiError>.Next)
          .coalesceWith(.Failed(.genericFailure))

        observer.action(event)
        observer.sendCompleted()
      }

      task.resume()

      disposable.addDisposable({
        task.cancel()
        observer.sendInterrupted()
      })
    }
  }

  public func subscribeTo(eventId eventId: String, uid: Int, subscribe: Bool) -> SignalProducer<Bool, LiveApiError> {


    return SignalProducer { (observer, disposable) in

      let urlString = "\(Secrets.LiveStreams.endpoint)/\(eventId)/subscribe"
      guard let url = NSURL(string: urlString) else {
        observer.sendFailed(.invalidEventId)
        return
      }

      let urlSession = NSURLSession(configuration: .defaultSessionConfiguration())

      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "POST"
      request.HTTPBody = "uid=\(uid)&subscribe=\(String(!subscribe))"
        .dataUsingEncoding(NSUTF8StringEncoding)

      let task = urlSession.dataTaskWithRequest(request) { data, _, error in
        let result = data
          .flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
          .map { _ in !subscribe }
          .coalesceWith(subscribe)

        observer.sendNext(result)
        observer.sendCompleted()
      }

      task.resume()

      disposable.addDisposable({
        task.cancel()
        observer.sendInterrupted()
      })
    }
  }
}




public enum LiveApiError: ErrorType {
  case genericFailure
  case invalidEventId
  case invalidJson
}

public class KsLiveApp {

  private static func start() {
    let options =
      FIROptions(googleAppID: Secrets.Firebase.Huzza.Production.googleAppID,
                 bundleID: Secrets.Firebase.Huzza.Production.bundleID,
                 GCMSenderID: Secrets.Firebase.Huzza.Production.gcmSenderID,
                 APIKey: Secrets.Firebase.Huzza.Production.apiKey,
                 clientID: Secrets.Firebase.Huzza.Production.clientID,
                 trackingID: "",
                 androidClientID: "",
                 databaseURL: Secrets.Firebase.Huzza.Production.databaseURL,
                 storageBucket: Secrets.Firebase.Huzza.Production.storageBucket,
                 deepLinkURLScheme: "")

    FIRApp.configureWithName(Secrets.Firebase.Huzza.Production.appName, options: options)
  }

  public static func firebaseApp() -> FIRApp? {
    guard let app = FIRApp(named: Secrets.Firebase.Huzza.Production.appName) else {
      self.start()
      return FIRApp(named: Secrets.Firebase.Huzza.Production.appName)
    }

    return app
  }

  public static func apiUrl() -> String {
    return Secrets.LiveStreams.endpoint
  }
}
