import SwiftUI

struct HeroStat: View {
    @Environment(\.colorScheme) private var scheme
    let label: String
    let value: String
    var tip: String? = nil
    var accent: Color? = nil

    var body: some View {
        BrutalCard(accent: accent ?? Theme.primary, padding: 20) {
            VStack(alignment: .leading, spacing: 8) {
                if let tip {
                    TooltipLabel(label: label, tip: tip)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.mutedText(scheme))
                        .textCase(.uppercase)
                        .tracking(0.8)
                } else {
                    BrutalText(
                        text: label,
                        variant: .caption,
                        color: Theme.mutedText(scheme),
                        uppercase: true,
                        tracking: 0.8
                    )
                }
                BrutalText(
                    text: value,
                    variant: .hero,
                    color: accent ?? Theme.ink(scheme)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
