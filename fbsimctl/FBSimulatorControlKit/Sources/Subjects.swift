/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Foundation

public protocol EventReporterSubject : CustomStringConvertible {
  var jsonDescription: JSON { get }
  var subSubjects: [EventReporterSubject] { get }
}

extension EventReporterSubject {
  public var subSubjects: [EventReporterSubject] { get {
    return [self]
  }}
}

extension EventReporterSubject  {
  public func append(_ other: EventReporterSubject) -> EventReporterSubject {
    let joined = self.subSubjects + other.subSubjects
    guard let firstElement = joined.first else {
      return CompositeSubject([])
    }
    if joined.count == 1 {
      return firstElement
    }
    return CompositeSubject(joined)
  }
}

struct SimpleSubject : EventReporterSubject {
  let eventName: EventName
  let eventType: EventType
  let subject: EventReporterSubject

  init(_ eventName: EventName, _ eventType: EventType, _ subject: EventReporterSubject) {
    self.eventName = eventName
    self.eventType = eventType
    self.subject = subject
  }

  var jsonDescription: JSON { get {
    return JSON.jDictionary([
      "event_name" : JSON.jString(self.eventName.rawValue),
      "event_type" : JSON.jString(self.eventType.rawValue),
      "subject" : self.subject.jsonDescription,
      "timestamp" : JSON.jNumber(NSNumber(value: round(Date().timeIntervalSince1970) as Double)),
    ])
  }}

  var shortDescription: String { get {
    switch self.eventType {
    case .Discrete:
      return self.subject.description
    default:
      return "\(self.eventName) \(self.eventType): \(self.subject.description)"
    }
  }}

  var description: String { get {
      return self.shortDescription
  }}
}

struct ControlCoreSubject : EventReporterSubject {
  let value: ControlCoreValue

  init(_ value: ControlCoreValue) {
    self.value = value
  }

  var jsonDescription: JSON { get {
    guard let json = try? JSON.encode(self.value.jsonSerializableRepresentation() as AnyObject) else {
      return JSON.jNull
    }
    return json
  }}

  var description: String { get {
    return self.value.description
  }}
}

struct iOSTargetSubject: EventReporterSubject {
  let target: FBiOSTarget
  let format: FBiOSTargetFormat

  var jsonDescription: JSON { get {
    let dictionary = self.format.extract(from: self.target)
    return try! JSON.encode(dictionary as AnyObject)
  }}

  var description: String { get {
    return self.format.format(self.target)
  }}
}

struct iOSTargetWithSubject : EventReporterSubject {
  let targetSubject: iOSTargetSubject
  let eventName: EventName
  let eventType: EventType
  let subject: EventReporterSubject
  let timestamp: Date

  init(targetSubject: iOSTargetSubject, eventName: EventName, eventType: EventType, subject: EventReporterSubject) {
    self.targetSubject = targetSubject
    self.eventName = eventName
    self.eventType = eventType
    self.subject = subject
    self.timestamp = Date()
  }

  var jsonDescription: JSON { get {
    return JSON.jDictionary([
      "event_name" : JSON.jString(self.eventName.rawValue),
      "event_type" : JSON.jString(self.eventType.rawValue),
      "target" : self.targetSubject.jsonDescription,
      "subject" : self.subject.jsonDescription,
      "timestamp" : JSON.jNumber(NSNumber(value: round(self.timestamp.timeIntervalSince1970) as Double)),
    ])
  }}

  var description: String { get {
    switch self.eventType {
    case .Discrete:
      return "\(self.targetSubject): \(self.eventName.rawValue): \(self.subject.description)"
    default:
      return ""
    }
  }}
}

struct LogSubject : EventReporterSubject {
  let logString: String
  let level: Int32

  var jsonDescription: JSON { get {
    return JSON.jDictionary([
      "event_name" : JSON.jString(EventName.Log.rawValue),
      "event_type" : JSON.jString(EventType.Discrete.rawValue),
      "level" : JSON.jString(self.levelString),
      "subject" : JSON.jString(self.logString),
      "timestamp" : JSON.jNumber(NSNumber(value: round(Date().timeIntervalSince1970) as Double)),
    ])
  }}

  var description: String { get {
    return self.logString
  }}

  var levelString: String { get {
    switch self.level {
    case Constants.asl_level_debug(): return "debug"
    case Constants.asl_level_err(): return "error"
    case Constants.asl_level_info(): return "info"
    default: return "unknown"
    }
  }}
}

struct CompositeSubject: EventReporterSubject {
  let array: [EventReporterSubject]

  init (_ array: [EventReporterSubject]) {
    self.array = array
  }

  var subSubjects: [EventReporterSubject] { get {
    return self.array
  }}

  var jsonDescription: JSON { get {
    return JSON.jArray(self.array.map { $0.jsonDescription } )
  }}

  var description: String { get {
    return "[\(self.array.map({ $0.description }).joined(separator: ", "))]"
  }}
}

struct StringsSubject: EventReporterSubject {
  let strings: [String]

  init (_ strings: [String]) {
    self.strings = strings
  }

  var jsonDescription: JSON { get {
    return JSON.jArray(self.strings.map { $0.jsonDescription } )
  }}

  var description: String { get {
    return "[\(self.strings.map({ $0.description }).joined(separator: ", "))]"
  }}
}

extension String : EventReporterSubject {
  public var jsonDescription: JSON { get {
    return JSON.jString(self)
  }}

  public var description: String { get {
    return self
  }}
}

extension Bool : EventReporterSubject {
  public var jsonDescription: JSON { get {
    return JSON.jNumber(NSNumber(value: self as Bool))
  }}
}
