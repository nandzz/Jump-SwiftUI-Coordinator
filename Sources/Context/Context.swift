import Foundation
import SwiftUI

public protocol ViewContext: Equatable, Hashable {
    var view: AnyView { get }
}

public protocol ContextState: Equatable {}
