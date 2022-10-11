import Foundation
import SwiftUI

public protocol ViewContainer: View {
    associatedtype Context: ViewContext
    associatedtype Status: ContextState
    var presentationContext: PresentationContext<Context, Status> { get set }
}

public extension View {
    func routing(isChildAppearing: Binding<Bool>, childView: Binding<AnyView?>? ) -> some View {
        NavigationLink(destination: childView?.wrappedValue, isActive: isChildAppearing) {
            self.sheet(isPresented: isChildAppearing) { childView?.wrappedValue }
                .fullScreenCover(isPresented: isChildAppearing) { childView?.wrappedValue }
        }
    }
}
