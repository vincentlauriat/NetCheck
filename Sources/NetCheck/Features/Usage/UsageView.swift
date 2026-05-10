import SwiftUI
import NetCheckCore
import NetCheckUI

struct UsageView: View {
    @State private var vm = UsageViewModel()

    var body: some View {
        FeatureWindowBackground(tintColor: .indigo) {
            VStack(spacing: 16) {
                Text("Qualité par usage")
                    .font(.title2.bold())
                    .padding(.top, 20)

                if vm.isLoading {
                    ProgressView("Mesure en cours…")
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 10) {
                        ForEach(UsageProfile.allCases, id: \.self) { profile in
                            UsageCard(
                                profile: profile,
                                result: vm.results.first(where: { $0.profile == profile })
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button("Actualiser") { vm.refresh() }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isLoading)
                    .padding(.bottom, 20)
            }
        }
        .onAppear { vm.refresh() }
    }
}

struct UsageCard: View {
    let profile: UsageProfile
    let result: UsageResult?

    var body: some View {
        GlassPanelView {
            HStack {
                Image(systemName: profile.icon)
                    .font(.title3)
                    .foregroundStyle(.indigo)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.rawValue).font(.subheadline.weight(.semibold))
                    if let ms = result?.latencyMs {
                        Text(String(format: "%.0f ms", ms))
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let result {
                    StatusBadge(quality: result.quality)
                } else {
                    ProgressView().scaleEffect(0.7)
                }
            }
        }
    }
}
