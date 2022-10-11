import SwiftUI


// Example of Context Name
public enum HomeContextName: Equatable {
    case root
    case viewA
    case viewB
}

// Example of Context Status
public enum HomeContextState: ContextState {
    enum HightlightStatus {
        case didFailWithError(error: Error)
    }
}

// Example of Context
public struct HomeContext: ViewContext {
    typealias ContextName = HomeContextName
    var id: UUID = UUID()
    var name: HomeContextName

    var view: AnyView {
        switch name {
        case .root:
            return AnyView(Text(""))
        case .viewA:
            return AnyView(Text(""))
        case .viewB:
            return AnyView(Text(""))
        }
    }
}


// Example of View Using Context
public struct SomeView: View {

    let presentationContext: PresentationContext<HomeContext, HomeContextState>

    var body: some View {
        Text("")
            .onTapGesture {
                presentationContext.next(emit: .HightlightStatus)
            }
    }
}
