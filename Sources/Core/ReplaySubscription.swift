//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class ReplaySubscription<Output, Failure>: Subscription where Failure: Error {
    var onCancel: (() -> Void)?

    private var subscriber: AnySubscriber<Output, Failure>?
    private var buffer = DemandBuffer<Output>()
    private var pendingValues: [Output] = []

    init<S>(subscriber: S, values: [Output]) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        self.subscriber = AnySubscriber(subscriber)
    }

    func request(_ demand: Subscribers.Demand) {
        process(buffer.request(demand))
    }

    func cancel() {
        subscriber = nil
        onCancel?()
        onCancel = nil
    }

    func append(_ value: Output) {
        pendingValues += buffer.append(value)
    }

    func send() {
        let values = pendingValues
        pendingValues = []
        process(values)
    }

    func send(completion: Subscribers.Completion<Failure>) {
        process(completion: completion)
    }

    private func process(_ values: [Output]) {
        guard let subscriber else { return }
        values.forEach { value in
            let demand = subscriber.receive(value)
            request(demand)
        }
    }

    private func process(completion: Subscribers.Completion<Failure>?) {
        guard let subscriber, let completion else { return }
        subscriber.receive(completion: completion)
    }
}
