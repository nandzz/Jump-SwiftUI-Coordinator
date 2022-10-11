import Foundation
import SwiftUI

public protocol ViewContext: Equatable, Identifiable {
    associatedtype ContextName: Hashable
    var id: UUID { get }
    var name: ContextName { get set }
    var view: AnyView { get }
}

public protocol ContextState: Equatable {}
