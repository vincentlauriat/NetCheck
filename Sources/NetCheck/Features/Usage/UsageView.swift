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

                // La grille est toujours visible — les cartes passent de "attente" à "résultat"
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(UsageProfile.allCases, id: \.self) { profile in
                        UsageCard(
                            profile: profile,
                            result: vm.results.first(where: { $0.profile == profile }),
                            isLoading: vm.isLoading
                        )
                    }
                }
                .padding(.horizontal)
                .animation(.spring(duration: 0.45), value: vm.results.count)

                if vm.isLoading {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.75)
                            .tint(.indigo)
                        Text("Mesure en cours…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity)
                }

                Spacer()

                Button("Actualiser") { vm.refresh() }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isLoading)
                    .padding(.bottom, 20)
            }
            .animation(.easeInOut(duration: 0.3), value: vm.isLoading)
        }
        .onAppear { vm.refresh() }
    }
}

struct UsageCard: View {
    let profile: UsageProfile
    let result: UsageResult?
    var isLoading: Bool = false

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
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        Text("—")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                Group {
                    if let result {
                        StatusBadge(quality: result.quality)
                            .transition(.scale(scale: 0.6).combined(with: .opacity))
                    } else {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(.indigo.opacity(0.6))
                            .transition(.opacity)
                    }
                }
                .animation(.spring(duration: 0.4), value: result != nil)
            }
        }
    }
}
