import SwiftUI
import Context

// Example of Context Name
public enum HomeContextName: Equatable {
    case root
    case viewA
    case viewB
}

// Example of Context Status
public enum HomeContextState: ContextState {
    case didFailWithError(error: NSError)
}

// Example of Context
public struct HomeContext: ViewContext {
    public typealias ContextName = HomeContextName
    public var id: UUID = UUID()
    public var name: HomeContextName

    public var view: AnyView {
        switch name {
        case .root:
            return AnyView(SomeView())
        case .viewA:
            return AnyView(SomeView())
        case .viewB:
            return AnyView(SomeView())
        }
    }
}

class ExampleRouter: Router<HomeContext, HomeContextState> {

    override func onNext(from context: HomeContext, state: HomeContextState) {
        super.onNext(from: context, state: state)
        switch context.name {
        case .root:
            get(context: context, mode: .push)
        case .viewA:
            get(context: context, mode: .push)
        case .viewB:
            get(context: context, mode: .push)
        }
    }

    override func onRoot(from context: HomeContext, state: HomeContextState) {
        
    }

    override func onPop(from context: HomeContext, to: HomeContext, state: HomeContextState) {

    }

    required init(root: HomeContext) {
        super.init(root: root)
    }
}


let one = ExampleRouter(root: .init(name: .root)).current?.childView

// Example of View Using Context
public struct SomeView: View {

    @EnvironmentObject public var presentationContext: PresentationContext<HomeContext, HomeContextState>

    public typealias Context = HomeContext
    public typealias Status = HomeContextState

    public var body: some View {
        Text("")
            .routing(
                isChildAppearing: $presentationContext.isChildPresented,
                childView: $presentationContext.childView
            )
    }
}


