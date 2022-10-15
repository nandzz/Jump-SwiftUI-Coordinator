import Foundation
import SwiftUI

public protocol ViewContainer: View {
    associatedtype Context: ViewContext
    associatedtype Status: ContextState
    var presentationContext: PresentationContext<Context, Status> { get set }
}

public extension View {
    func routing(mode: Presentation, isChildAppearing: Binding<Bool>, childView: AnyView? ) -> some View {
        modifier(PresentationModifier(mode: mode, isActive: isChildAppearing, childView: childView))
    }
}

public extension View {

    func sync(published: Binding<Bool>, with binding: Binding<Bool>) -> some View {
        self
            .onChange(of: published.wrappedValue, perform: { isPresented in
                binding.wrappedValue = isPresented
            })
            .onChange(of: binding.wrappedValue, perform: { isPresented in
                published.wrappedValue = isPresented
            })
    }
}

public struct PresentationModifier: ViewModifier {

    let mode: Presentation
    var childView: AnyView?
    var isSheetPresented: Binding<Bool>?
    var isFullScreenCover: Binding<Bool>?
    var isNavigating: Binding<Bool>?
    var isAlertPresented: Binding<Bool>?
    var isSwaped: Binding<Bool>?


    init(mode: Presentation, isActive: Binding<Bool>, childView: AnyView?) {
        self.mode = mode
        self.childView = childView
        switch mode {
        case .push:
            isNavigating = isActive
        case .fullScreen:
            isFullScreenCover = isActive
        case .sheet:
            isSheetPresented = isActive
        case .swap:
            isSwaped = isActive
        default:
            break
        }
    }

    public func body(content: Content) -> some View {
        NavigationLink(destination: childView, isActive: isNavigating ?? .constant(false)) {
            content
                .sheet(isPresented: isSheetPresented ?? .constant(false)) { childView }
                .fullScreenCover(isPresented: isFullScreenCover ?? .constant(false)) { childView }
        }
        .isDetailLink(false)
    }
}
