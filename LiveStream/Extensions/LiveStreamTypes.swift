import Foundation

public enum LiveVideoPlaybackError {
  case failedToConnect
  case sessionInterrupted
}

public enum LiveVideoPlaybackState: Equatable {
  // FIXME: alpha
  case loading
  case playing
  case error(error: LiveVideoPlaybackError)

  public var isError: Bool {
    if case .error = self {
      return true
    }
    return false
  }
}

public func == (lhs: LiveVideoPlaybackState, rhs: LiveVideoPlaybackState) -> Bool {
  switch (lhs, rhs) {
  case (.loading, .loading): return true
  case (.playing, .playing): return true
  case (.error(let lhsError), .error(let rhsError)):
    return lhsError == rhsError
  default:
    return false
  }
}

public enum LiveStreamType: Equatable {
  case openTok(sessionConfig: OpenTokSessionConfig)
  case hlsStream(hlsStreamUrl: String)
}

public func == (lhs: LiveStreamType, rhs: LiveStreamType) -> Bool {
  switch (lhs, rhs) {
  case (.hlsStream(let lhsHLSStreamUrl), .hlsStream(let rhsHLSStreamUrl)):
    return lhsHLSStreamUrl == rhsHLSStreamUrl

  case (.openTok(let lhsSessionConfig), .openTok(let rhsSessionConfig)):
    return lhsSessionConfig.apiKey == rhsSessionConfig.apiKey
      && lhsSessionConfig.sessionId == rhsSessionConfig.sessionId
      && lhsSessionConfig.token == rhsSessionConfig.token

  default:
    return false
  }
}

public enum LiveStreamViewControllerState: Equatable {
  case loading
  case greenRoom
  case live(playbackState: LiveVideoPlaybackState, startTime: NSTimeInterval)
  case replay(playbackState: LiveVideoPlaybackState, replayAvailable: Bool, duration: NSTimeInterval)
  case error(error: LiveVideoPlaybackError)
}

public func == (lhs: LiveStreamViewControllerState, rhs: LiveStreamViewControllerState) -> Bool {
  switch (lhs, rhs) {
  case (.loading, .loading): return true
  case (.greenRoom, .greenRoom): return true
  case (.live(let lhsPlaybackState, let lhsStartTime), .live(let rhsPlaybackState, let rhsStartTime))
    // FIXME: change where's to just return the bool
    where
    lhsPlaybackState == rhsPlaybackState &&
    lhsStartTime == rhsStartTime:

    return true
  case (.replay(let lhsPlaybackState, let lhsReplayAvailable, let lhsDuration), .replay(
    let rhsPlaybackState, let rhsReplayAvailable, let rhsDuration))
    where
    lhsPlaybackState == rhsPlaybackState &&
    lhsReplayAvailable == rhsReplayAvailable &&
    lhsDuration == rhsDuration:

    return true
  case (.error(let lhsError), .error(let rhsError))
    where lhsError == rhsError:

    return true
  default:
    return false
  }
}
