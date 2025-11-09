import SwiftUI

struct RetroPicker<Value: Hashable & Comparable>: View where Value: Strideable, Value.Stride: SignedInteger {
    @Binding var selection: Value
    let range: ClosedRange<Value>
    let format: (Value) -> String
    
    private let itemHeight: CGFloat = 50
    
    var body: some View {
        GeometryReader { geometry in
            let centerY = geometry.size.height / 2
            let selectedIndex = index(for: selection)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(SimplePalette.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(SimplePalette.cardBorder, lineWidth: 2)
                    )
                
                // Selection indicator
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(SimplePalette.retroRed.opacity(0.3))
                    .frame(height: itemHeight)
                    .offset(y: 0)
                
                // Items
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(range.enumerated()), id: \.element) { index, value in
                                pickerItem(value: value, isSelected: value == selection)
                                    .id(index)
                                    .frame(height: itemHeight)
                            }
                        }
                        .padding(.vertical, centerY - itemHeight / 2)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(selectedIndex, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: selection) { newValue in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            proxy.scrollTo(index(for: newValue), anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    private func pickerItem(value: Value, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selection = value
            }
        }) {
            Text(format(value))
                .font(SimplePalette.retroFont(size: isSelected ? 20 : 16, weight: .bold))
                .foregroundStyle(isSelected ? SimplePalette.retroBlack : SimplePalette.cardTextSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: itemHeight)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(isSelected ? SimplePalette.retroRed : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(isSelected ? SimplePalette.retroBlack : Color.clear, lineWidth: 2)
                        )
                        .shadow(color: isSelected ? Color.black.opacity(0.3) : Color.clear, radius: 0, x: 2, y: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func index(for value: Value) -> Int {
        let array = Array(range)
        return array.firstIndex(of: value) ?? 0
    }
}

