import SwiftUI

public struct FeatureWindowBackground<Content: View>: View {
    let tintColor: Color
    let content: Content

    public init(tintColor: Color = .blue, @ViewBuilder content: () -> Content) {
        self.tintColor = tintColor
        self.content = content()
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(.background)
                .overlay(tintColor.opacity(0.06))

            OrganicBubble(size: 90,  color: tintColor, offset: CGPoint(x: -80, y: -100))
            OrganicBubble(size: 60,  color: tintColor, offset: CGPoint(x:  90, y: -80))
            OrganicBubble(size: 70,  color: tintColor, offset: CGPoint(x: -60, y:  80))
            OrganicBubble(size: 45,  color: tintColor, offset: CGPoint(x:  80, y:  90))

            content
        }
        .ignoresSafeArea()
    }
}
