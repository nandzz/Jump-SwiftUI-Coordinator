import Jump
import SwiftUI

enum TestContextActions: ContextAction {
    case didTapClose
    case didTapContinue
    case didTapBack
    case dismissAfterSucceed
    case dismissAfterError(NSError)
}

enum TestContextPaths: ContextPath {
    case root
    case viewA
    case viewB
    case viewC
    case viewD
    case viewE
    case viewF
    case viewG
    case viewH
    case viewI
    case viewJ
}
