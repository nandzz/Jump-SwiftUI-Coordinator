import Foundation
import SwiftUI
import Combine


public extension View {
    
    /// This method defines the next presentation for the ChildView.
    /// It's important to call this function for each view using the router
    /// - Parameters:
    ///   - mode the type of presentation defined in the presentationContext
    ///   - isChildAppearing defines if the child of this view is appearing or not, everything is controlled
    ///   from the router
    ///   - childView it's the content's child view, the next view to be presented. This property is defined in the
    ///   presentationContent
    @ViewBuilder
    func routing(child: Context) -> some View {
            modifier(PresentationModifier(child: child))
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
    var mode: Presentation? = .idle

    /// Defines if there is a navigationView wrapping the content
    var addNavigationView: Bool = false
    
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
    


    init(child context: Context) {
        self.mode = context.presentationMode
        self.addNavigationView = context.addNavigationView

        if let view = context.view {
            self.childView = view
        }

        let isActive = context.isOnScreen

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
        case .idle:
            break
        case .none:
            break
        }
    }
    
    public func body(content: Content) -> some View {
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
    }
    
    /// In case a NavigationView has to be added to the Content
    /// Usually the first view being swapped/onTop/FullScreen or a Rootview has a NavigationView
    @ViewBuilder
    func withNavigationContent(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            ZStack {
                content
                    .background(NavigationLink(
                        String.init(),
                        destination: childView,
                        isActive: isNavigating)
                        .isDetailLink(false))

                VStack{}

                    .fullScreenCover(isPresented: isFullScreenCover) { childView }
            }
            .sheet(isPresented: isSheet ) { childView }
            .swap(isPresented: isSwaped)  { childView}
        } else {
            ZStack {
                content
                    .background(NavigationLink(
                        String.init(),
                        destination: childView,
                        isActive: isNavigating)
                        .isDetailLink(false))

                VStack{}
                    .fullScreenCover(isPresented: isFullScreenCover) { childView }
            }
            .sheet(isPresented: isSheet ) { childView }
            .swap(isPresented: isSwaped)  { childView}
        }
    }
    
    /// In case a NavigationView is not added to the Content
    @ViewBuilder
    func withoutNavigationContent(content: Content) -> some View {
        if #available(iOS 16.0, *) {
                content
                
                VStack{}
                    .background(NavigationLink(
                        String.init(),
                        destination: childView,
                        isActive: isNavigating)
                        .isDetailLink(false))
                    .fullScreenCover(isPresented: isFullScreenCover) { childView }
            .sheet(isPresented: isSheet) { childView }
            .swap(isPresented: isSwaped)  { childView}

        } else {
            ZStack {
                content
                    .background(NavigationLink(
                        String.init(),
                        destination: childView,
                        isActive: isNavigating
                    ).isDetailLink(false))
                
                
                VStack{}
                    .fullScreenCover(isPresented: isFullScreenCover) { childView }
            }
            .sheet(isPresented: isSheet) { childView }
            .swap(isPresented: isSwaped)  { childView}
        }
    }
    
    /// OnTop Child Content with Navigation View
    /// Adding a ZStack to place the child content on top of this content
    @ViewBuilder
    func onTopWithNavigation(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            ZStack {
                NavigationStack {
                    content
                        .swap(isPresented: isSwaped)  { childView}
                    
                    VStack{}
                        .background(NavigationLink(
                            String.init(),
                            destination: childView,
                            isActive: isNavigating)
                            .isDetailLink(false))
                        .fullScreenCover(isPresented: isFullScreenCover) { childView }
                }
                childView
            }
            .sheet(isPresented: isSheet) { childView }
            
        } else {
            ZStack {
                content
                    .background(   NavigationLink(
                        String.init(),
                        destination: childView,
                        isActive: isNavigating)
                        .isDetailLink(false))


                VStack{}
                    .fullScreenCover(isPresented: isFullScreenCover) { childView }
                    .sheet(isPresented: isSheet) { childView }
                    .swap(isPresented: isSwaped)  { childView}
            }
            childView
        }
    }
    
    /// OnTop Child Content without Navigation View
    /// Adding a ZStack to add the view to the Top of the content
    func onTopWithoutNavigation(content: Content) -> some View {
        ZStack {
            content
                .swap(isPresented: isSwaped)  { childView}
            
            VStack{}
                .fullScreenCover(isPresented: isFullScreenCover) { childView }
            
            childView
        }
        .ignoresSafeArea()
        .sheet(isPresented: isSheet) { childView }
    }
}

public extension View {
    
    @ViewBuilder
    func swap<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        if isPresented.wrappedValue {
            content()
        } else {
            self
        }
    }

    @ViewBuilder
    func onTop<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        if isPresented.wrappedValue {
            ZStack {
                self
                content()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        } else {
            self
        }
    }
}
