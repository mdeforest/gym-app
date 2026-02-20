import SwiftUI

struct SetRowView: View {
    let setNumber: Int
    var setType: SetType = .normal
    @Binding var weight: String
    @Binding var reps: String
    let isCompleted: Bool
    var onComplete: (() -> Void)?
    var onDelete: (() -> Void)?
    var onToggleSetType: (() -> Void)?
    var rpe: Binding<Double?>?
    var onRPETap: (() -> Void)?
    var prTypes: [PRType] = []

    @State private var offset: CGFloat = 0
    @State private var showingDelete = false

    private let deleteButtonWidth: CGFloat = 70
    private let deleteThreshold: CGFloat = -50

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button revealed behind the row
            if onDelete != nil, showingDelete || offset < 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onDelete?()
                        offset = 0
                        showingDelete = false
                    }
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(width: deleteButtonWidth)
                        .frame(maxHeight: .infinity)
                }
                .background(AppTheme.Colors.destructive)
            }

            // Main row content
            HStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    onToggleSetType?()
                } label: {
                    Text(setType == .warmup ? "W" : "\(setNumber)")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(setType == .warmup ? AppTheme.Colors.warning : AppTheme.Colors.textSecondary)
                        .frame(width: 28)
                }
                .buttonStyle(.borderless)
                .disabled(onToggleSetType == nil)

                NumberInputField(label: "lbs", value: $weight)

                Text("x")
                    .font(.callout)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                NumberInputField(label: "reps", value: $reps)

                if let onComplete {
                    Button(action: onComplete) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.title2)
                            .foregroundStyle(isCompleted ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
                    }
                    .frame(width: AppTheme.Layout.minTouchTarget, height: AppTheme.Layout.minTouchTarget)
                }

                if let rpe, let onRPETap {
                    RPEBadgeView(rpe: rpe.wrappedValue, onTap: onRPETap)
                }

                if !prTypes.isEmpty {
                    PRBadgeView(prTypes: prTypes, style: .compact)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(
                isCompleted
                    ? (setType == .warmup ? AppTheme.Colors.warning.opacity(0.15) : AppTheme.Colors.accentMuted.opacity(0.4))
                    : (setType == .warmup ? AppTheme.Colors.surfaceTertiary.opacity(0.5) : AppTheme.Colors.surface)
            )
            .offset(x: offset)
            .gesture(
                onDelete != nil
                    ? DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            let translation = value.translation.width
                            if translation < 0 {
                                offset = translation
                            } else if showingDelete {
                                offset = -deleteButtonWidth + translation
                            }
                        }
                        .onEnded { value in
                            withAnimation(.easeOut(duration: 0.2)) {
                                if offset < deleteThreshold {
                                    offset = -deleteButtonWidth
                                    showingDelete = true
                                } else {
                                    offset = 0
                                    showingDelete = false
                                }
                            }
                        }
                    : nil
            )
        }
        .clipped()
    }
}

#Preview {
    SetRowView(
        setNumber: 1,
        weight: .constant("135"),
        reps: .constant("8"),
        isCompleted: false,
        onComplete: {},
        onDelete: {}
    )
    .background(AppTheme.Colors.surface)
}
