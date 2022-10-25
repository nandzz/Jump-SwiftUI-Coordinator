import Foundation
import SwiftUI
import Combine

public protocol ViewContainer: View {
    associatedtype Context: ViewContext
    associatedtype Status: ContextState
    var presentationContext: PresentationContext<Context, Status> { get set }
}

public extension View {

    /// This method defines the next presentation for the ChildView.
    /// It's important to call this function for each view using the router
    /// - Parameters:
    ///   - mode the type of presentation defined in the presentationContext
    ///   - isChildAppearing defines if the child of this view is appearing or not, everything is controlled
    ///   from the router
    ///   - childView it's the content's child view, the next view to be presented. This property is defined in the
    ///   presentationContent
    func routing(mode: Presentation, isChildAppearing: Binding<Bool>, childView: AnyView?, addNavigationView: Bool ) -> some View {
        modifier(PresentationModifier(
            mode: mode,
            isActive: isChildAppearing,
            childView: childView,
            addNavigationView: addNavigationView)
        )
    }
}

public struct PresentationModifier: ViewModifier {

    /// Defines the presentation mode
    ///
    ///     top
    ///     swap
    ///     fullScreenConver
    ///     push
    ///     swap
    ///     onTop
    ///     Alert
    ///
    let mode: Presentation

    /// The child view to be presented
    var childView: AnyView?

    /// Sheet has a native behaviour for sheet presentation
    var isSheet: Binding<Bool> = .constant(false)
    /// isFullScreenConver  has a native behaviour for fullScreenCover
    var isFullScreenCover: Binding<Bool> = .constant(false)
    /// is binding the navigationLink for push or pop navigation
    var isNavigating: Binding<Bool> = .constant(false)
    /// adds a ZStack for this content and place the child content onTop of it
    var isOnTop: Binding<Bool> = .constant(false)
    /// switch between one content and another content
    var isSwaped: Binding<Bool> = .constant(false)
    /// present an alert view
    var isAlert: Binding<Bool> = .constant(false)

    /// Defines if there is a navigationView wrapping the content
    let addNavigationView: Bool

    init(mode: Presentation, isActive: Binding<Bool>, childView: AnyView?, addNavigationView: Bool) {
        self.mode = mode
        self.addNavigationView = addNavigationView
        self.childView = childView
        switch mode {
        case .push:
            isNavigating = isActive
        case .fullScreen:
            isFullScreenCover = isActive
        case .sheet:
            isSheet = isActive
        case .swap:
            isSwaped = isActive
        case .top:
            isOnTop = isActive
        }
    }

    public func body(content: Content) -> some View {
        if isSwaped.wrappedValue == false {
            if addNavigationView {
                if isOnTop.wrappedValue == true {
                    onTopWithNavigation(content: content)
                } else {
                    withNavigationContent(content: content)
                }

            } else {

                if isOnTop.wrappedValue == true {
                    onTopWithoutNavigation(content: content)
                } else {
                    withoutNavigationContent(content: content)
                }
            }
        } else {
            childView
        }
    }

    /// In case a NavigationView has to be added to the Content
    /// Usually the first view being swapped/onTop/FullScreen or a Rootview has a NavigationView
    func withNavigationContent(content: Content) -> some View {
        NavigationView {
            ZStack {
                NavigationLink(
                    String.init(),
                    destination: childView,
                    isActive: isNavigating)
                .isDetailLink(false)
                content
            }
        }
        .sheet(isPresented: isSheet ) { childView }
        .fullScreenCover(isPresented: isFullScreenCover) { childView }
    }

    /// In case a NavigationView is not added to the Content
    func withoutNavigationContent(content: Content) -> some View {
        ZStack {
            content
                .sheet(isPresented: isSheet) { childView }
                .fullScreenCover(isPresented: isFullScreenCover) { childView }

            NavigationLink(
                String.init(),
                destination: childView,
                isActive: isNavigating
            ).isDetailLink(false)
        }
    }

    /// OnTop Child Content with Navigation View
    /// Adding a ZStack to place the child content on top of this content 
    func onTopWithNavigation(content: Content) -> some View {
        ZStack {
            NavigationView {
                ZStack {
                    NavigationLink(
                        String.init(),
                        destination: childView,
                        isActive: isNavigating)
                    .isDetailLink(false)
                    content
                }
            }
            .sheet(isPresented: isSheet) { childView }
            .fullScreenCover(isPresented: isFullScreenCover) { childView }

            childView
        }
    }

    /// OnTop Child Content without Navigation View
    /// Adding a ZStack to add the view to the Top of the content
    func onTopWithoutNavigation(content: Content) -> some View {
        ZStack {
            content
                .sheet(isPresented: isSheet) { childView }
                .fullScreenCover(isPresented: isFullScreenCover) { childView }

            NavigationLink(
                String.init(),
                destination: childView,
                isActive: isNavigating
            ).isDetailLink(false)

            childView
        }
    }


}
