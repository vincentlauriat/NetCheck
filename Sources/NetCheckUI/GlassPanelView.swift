import SwiftUI

public struct GlassPanelView<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    }
}
