import SwiftUI

struct WeightSectionView: View {
    @EnvironmentObject private var onboardingData: OnboardingData
    
    @State private var weightCheckInText: String = ""
    @State private var weightTargetText: String = ""
    @State private var timer: Timer?
    @State private var daysRemaining: Int = 0
    @FocusState private var focusedField: WeightField?
    
    private enum WeightField {
        case weightCheckIn
        case weightTarget
    }
    
    var body: some View {
        ZStack {
            simpleBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("WEIGHT TRACKER")
                        .font(SimplePalette.retroFont(size: 28, weight: .bold))
                        .foregroundStyle(SimplePalette.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    weightCheckInCard
                    currentToTargetRow
                    lastRecordedCard
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Weight")
        .onAppear {
            loadWeightData()
            startCountdownTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var weightCheckInCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 20) {
                Text("WEIGHT CHECK IN")
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                
                // Weight input
                HStack(spacing: 12) {
                    TextField("", text: $weightCheckInText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weightCheckIn)
                        .font(SimplePalette.retroFont(size: 24, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(SimplePalette.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(SimplePalette.cardBorder, lineWidth: 2)
                                )
                        )
                        .disabled(daysRemaining > 0)
                        .opacity(daysRemaining > 0 ? 0.6 : 1.0)
                        .onChange(of: weightCheckInText) { newValue in
                            if let weight = Int(newValue), !newValue.isEmpty {
                                onboardingData.currentWeight = weight
                            }
                        }
                        .onSubmit {
                            // When user submits (presses return/done), record the weight
                            if let weight = Int(weightCheckInText), daysRemaining == 0 {
                                onboardingData.recordWeight(weight)
                                updateCountdown()
                            }
                        }
                    
                    Text(onboardingData.weightUnit.shortLabel.uppercased())
                        .font(SimplePalette.retroFont(size: 18, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                    
                    // Record button (only shown when countdown is 0)
                    if daysRemaining == 0 && !weightCheckInText.isEmpty {
                        Button(action: {
                            if let weight = Int(weightCheckInText) {
                                onboardingData.recordWeight(weight)
                                weightCheckInText = ""
                                updateCountdown()
                            }
                        }) {
                            Text("RECORD")
                                .font(SimplePalette.retroFont(size: 14, weight: .bold))
                                .foregroundStyle(SimplePalette.retroBlack)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(SimplePalette.retroRed)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .stroke(SimplePalette.retroBlack, lineWidth: 2)
                                        )
                                        .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(Int(weightCheckInText) == nil)
                    }
                }
                
                Divider().background(SimplePalette.cardBorder)
                
                // Countdown display
                VStack(alignment: .leading, spacing: 8) {
                    Text("NEXT CHECK IN")
                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                    
                    if daysRemaining > 0 {
                        HStack(spacing: 8) {
                            Text("\(daysRemaining)")
                                .font(SimplePalette.retroFont(size: 32, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextPrimary)
                            
                            Text("DAYS")
                                .font(SimplePalette.retroFont(size: 18, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextSecondary)
                        }
                    } else {
                        Text("READY TO CHECK IN")
                            .font(SimplePalette.retroFont(size: 20, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                    }
                }
                
                Divider().background(SimplePalette.cardBorder)
                
                // Frequency selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("FREQUENCY")
                        .font(SimplePalette.retroFont(size: 14, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                    
                    HStack(spacing: 8) {
                        ForEach(WeighInFrequency.allCases) { frequency in
                            Button(action: {
                                onboardingData.weighInFrequency = frequency
                                updateCountdown()
                            }) {
                                Text(frequency.rawValue.uppercased())
                                    .font(SimplePalette.retroFont(size: 11, weight: .bold))
                                    .foregroundStyle(onboardingData.weighInFrequency == frequency ? SimplePalette.retroBlack : SimplePalette.cardTextPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(onboardingData.weighInFrequency == frequency ? SimplePalette.retroWhite : SimplePalette.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .stroke(SimplePalette.retroBlack, lineWidth: 2)
                                            )
                                            .shadow(color: Color.black.opacity(0.3), radius: 0, x: 2, y: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }
    
    private var currentToTargetRow: some View {
        SimpleCardPane {
            HStack(spacing: 16) {
                // Current Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("CURRENT WEIGHT")
                        .font(SimplePalette.retroFont(size: 12, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                    
                    HStack(spacing: 4) {
                        Text(onboardingData.currentWeight != nil ? "\(onboardingData.currentWeight!)" : "--")
                            .font(SimplePalette.retroFont(size: 24, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                        
                        Text(onboardingData.weightUnit.shortLabel.uppercased())
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Arrow
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SimplePalette.retroRed)
                    .frame(width: 40)
                
                // Target Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("TARGET WEIGHT")
                        .font(SimplePalette.retroFont(size: 12, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                    
                    HStack(spacing: 4) {
                        TextField("", text: $weightTargetText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .weightTarget)
                            .font(SimplePalette.retroFont(size: 24, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.leading)
                            .onChange(of: weightTargetText) { newValue in
                                if let target = Int(newValue) {
                                    onboardingData.weightTarget = target
                                } else if newValue.isEmpty {
                                    onboardingData.weightTarget = nil
                                }
                            }
                        
                        Text(onboardingData.weightUnit.shortLabel.uppercased())
                            .font(SimplePalette.retroFont(size: 14, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }
    
    private var lastRecordedCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 16) {
                Text("LAST RECORDED WEIGHT")
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextPrimary)
                
                if let lastWeight = onboardingData.weightHistory.last {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Text("\(lastWeight.weight)")
                                .font(SimplePalette.retroFont(size: 28, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextPrimary)
                            
                            Text(onboardingData.weightUnit.shortLabel.uppercased())
                                .font(SimplePalette.retroFont(size: 16, weight: .bold))
                                .foregroundStyle(SimplePalette.cardTextSecondary)
                        }
                        
                        Text(formatDate(lastWeight.date))
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                    }
                } else {
                    Text("NO WEIGHT RECORDED")
                        .font(SimplePalette.retroFont(size: 16, weight: .medium))
                        .foregroundStyle(SimplePalette.cardTextSecondary)
                }
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }
    
    private func loadWeightData() {
        // Initialize from sign-up weight if available and no current weight set
        if onboardingData.currentWeight == nil, let signUpWeight = onboardingData.weight {
            // Convert to current unit if needed
            let weightInCurrentUnit = onboardingData.weightUnit == .pounds ? signUpWeight : onboardingData.weightUnit.convert(value: signUpWeight, to: onboardingData.weightUnit)
            onboardingData.currentWeight = weightInCurrentUnit
            weightCheckInText = "\(weightInCurrentUnit)"
        } else if let currentWeight = onboardingData.currentWeight {
            weightCheckInText = "\(currentWeight)"
        }
        
        if let weightTarget = onboardingData.weightTarget {
            weightTargetText = "\(weightTarget)"
        }
        
        updateCountdown()
    }
    
    private func updateCountdown() {
        if let lastDate = onboardingData.lastWeighInDate {
            let calendar = Calendar.current
            let today = Date()
            let nextDate = calendar.date(byAdding: .day, value: onboardingData.weighInFrequency.days, to: lastDate) ?? today
            
            if nextDate > today {
                let components = calendar.dateComponents([.day], from: today, to: nextDate)
                daysRemaining = max(0, components.day ?? 0)
            } else {
                daysRemaining = 0
            }
        } else {
            // If never weighed in, allow immediate check-in
            daysRemaining = 0
        }
    }
    
    private func startCountdownTimer() {
        updateCountdown()
        timer = Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { _ in
            updateCountdown()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        WeightSectionView()
    }
    .environmentObject(OnboardingData())
}
