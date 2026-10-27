import SwiftUI

extension View {
    /// On iPad, iPadOS 26 runs this iPhone app in a resizable window whose close/minimize controls
    /// sit over the top-leading corner. Our screens hide the navigation bar (which would otherwise
    /// dodge them for us), so leading header content shifts itself clear of the controls instead.
    /// Apply to a whole header row (one with a Spacer to give up the room) rather than a single
    /// view, so neighbours shift along with it. A no-op wherever there are no window controls, e.g.
    /// on iPhone. Only takes effect outside a ScrollView, so headers stay pinned above the scrolling
    /// content.
    @ViewBuilder
    func avoidingWindowControls() -> some View {
        if #available(iOS 26.0, *) {
            containerCornerOffset(.leading, sizeToFit: true)
        } else {
            self
        }
    }
}
