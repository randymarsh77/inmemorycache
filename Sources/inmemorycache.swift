import Foundation
import IDisposable
import PubSubCache
import Scope

public class InMemoryCache : PubSubCache, IDisposable
{
	public init() {
		_cache = [:]
		_subscribers = Array<Subscriber>()
	}

	public func get(_ keys: Array<String>) -> [String : Data?] {
		return CreateDictionary(keys.map { ($0, _cache[$0]) })
	}

	public func set(_ keysAndValues: [String : Data?]) -> Void {
		var changed: [String : Data?] = [:]
		for (key, value) in keysAndValues {
			let cached = _cache[key]
			if (cached != value) {
				_cache[key] = value
				changed[key] = value
			}
		}
		for subscriber in _subscribers! {
			let changeDictionary = CreateDictionary(changed.filter { subscriber.matches($0.0) })
			if (changeDictionary.keys.count != 0) {
				subscriber.callback(changeDictionary)
			}
		}
	}

	public func subscribe(keys: Array<KeyMatch>, onChange: @escaping ([String : Data?]) -> ()) -> Scope {
		return try! addSubscriber(Subscriber(keys, onChange))
	}

	public func dispose() {
		if (_subscribers == nil) {
			return
		}

		for subscriber in _subscribers! {
			_ = subscriber.scope?.transfer()
		}
		_subscribers = nil
	}

	private func addSubscriber(_ subscriber: Subscriber) throws -> Scope {
		if (_subscribers == nil) {
			throw ObjectDisposedException.ObjectDisposed
		}

		let scope = Scope {
			self._subscribers = self._subscribers!.filter { $0 !== subscriber }
		}

		subscriber.scope = scope
		_subscribers?.append(subscriber)
		return scope
	}

	private var _cache: [String : Data] = [:]
	private var _subscribers: Array<Subscriber>?
}

fileprivate typealias Callback = ([String : Data?]) -> ()

fileprivate class Subscriber
{
	fileprivate init(_ keyMatches: Array<KeyMatch>, _ callback: @escaping Callback) {
		self.keyMatches = keyMatches
		self.callback = callback
	}

	public func matches(_ key: String) -> Bool {
		return keyMatches.filter { $0.matches(key) }.count != 0
	}

	public var keyMatches: Array<KeyMatch>
	public var callback: Callback
	public var scope: Scope?
}

fileprivate typealias KeyValueTuple = (String, Data?)

fileprivate func CreateDictionary(_ tuples: Array<KeyValueTuple>) -> [String : Data?] {
	var dict: [String : Data?] = [:]
	for (key, value) in tuples {
		dict[key] = value
	}
	return dict
}
