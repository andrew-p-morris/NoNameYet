import SwiftUI

struct HealthPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    private var plan: HealthPlan? { onboardingData.generatedPlan }
    @State private var aiInput: String = ""
    @FocusState private var isTextFocused: Bool
    @State private var showConfirmation: Bool = false
    @State private var isMenuOpen: Bool = false
    @State private var selectedDestination: MenuDestination?

    var body: some View {
        ZStack(alignment: .leading) {
            simpleBackground()

            SideMenuView(isOpen: $isMenuOpen) { destination in
                selectedDestination = destination
            }
            .offset(x: isMenuOpen ? 0 : -280)

            mainContent
                .offset(x: isMenuOpen ? 280 : 0)
                .onTapGesture {
                    if isMenuOpen {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isMenuOpen = false
                        }
                    }
                }

            alertToast
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isMenuOpen)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showConfirmation)
        .sheet(item: $selectedDestination) { destination in
            NavigationStack {
                destinationView(for: destination)
            }
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 20) {
                header

                topUtilities
                    .padding(.top, 8)

                ScrollView {
                    if let plan {
                        planContentBody(plan)
                    } else {
                        missingPlanPlaceholder
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
        }
    }

    @ViewBuilder
    private func destinationView(for destination: MenuDestination) -> some View {
        switch destination {
        case .workout:
            WorkoutSectionView()
        case .nutrition:
            NutritionSectionView()
        case .calendar:
            CalendarSectionView()
        case .data:
            DataSectionView()
        case .settings:
            SettingsSectionView()
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SimplePalette.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(SimplePalette.cardBackground)
                            .overlay(
                                Circle()
                                    .stroke(SimplePalette.cardBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text("Your Health Plan")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)

                Text(tagline)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(SimplePalette.textSecondary)
            }
        }
    }

    private func planContentBody(_ plan: HealthPlan) -> some View {
        VStack(alignment: .leading, spacing: 26) {
            coachNotesSection

            summarySection(plan: plan)
        }
    }

    private var coachNotesSection: some View {
        VStack(spacing: 16) {
            SimpleCardPane {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Coach Notes")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(SimplePalette.textSecondary)

                    loggingBox
                }
                .simpleCardPadding()
            }

            Button(action: submitInput) {
                HStack(spacing: 10) {
                    Text("Submit to Coach")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(SimplePalette.textPrimary)

                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(SimplePalette.accentBlue)
                }
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(SimplePalette.accentLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(SimplePalette.accentBlue.opacity(0.4), lineWidth: 1)
                    )
            )
        }
    }

    private var topUtilities: some View {
        HStack(alignment: .center, spacing: 16) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isMenuOpen.toggle()
                }
            }) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(SimplePalette.textPrimary)
                    .frame(width: 58, height: 58)
                    .background(
                        Circle()
                            .fill(SimplePalette.cardBackground)
                            .overlay(
                                Circle().stroke(SimplePalette.cardBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: {}) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(SimplePalette.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(SimplePalette.accentLight)
                            .overlay(
                                Circle().stroke(SimplePalette.cardBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)

            Button(action: {}) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(SimplePalette.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(SimplePalette.accentLight)
                            .overlay(
                                Circle().stroke(SimplePalette.cardBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
    }

    private var loggingBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(SimplePalette.cardBorder, lineWidth: 1.2)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SimplePalette.cardBackground)
                    )

                TextEditor(text: $aiInput)
                    .focused($isTextFocused)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(SimplePalette.textPrimary)
                    .padding(18)
                    .frame(minHeight: 160, maxHeight: 180)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }

        }
    }

    private func summarySection(plan: HealthPlan) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            sectionPane(title: "Today's Workout") {
                VStack(alignment: .leading, spacing: 16) {
                    workoutRow(icon: "figure.run", title: "Cardio • 30 minutes", detail: cardioDetail(for: plan))
                    Divider().background(SimplePalette.cardBorder)
                    workoutRow(icon: "dumbbell", title: "Strength • 30 minutes", detail: strengthDetail(for: plan))
                }
            }

            sectionPane(title: "Daily Nutrition Targets") {
                macroGrid(plan.macroTargets)
            }

            sectionPane(title: "Hydration & Notes") {
                VStack(alignment: .leading, spacing: 16) {
                    hydrationRow(waterOz: plan.waterIntakeOz)

                    if !plan.dietaryHighlights.isEmpty {
                        Text(plan.dietaryHighlights.joined(separator: ", "))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(SimplePalette.textSecondary)
                    } else {
                        Text("No dietary restrictions noted.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(SimplePalette.textSecondary)
                    }
                }
            }
        }
    }

    private func sectionPane<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 18) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)
                    .padding(.bottom, 4)

                content()
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 28)
        }
    }

    private var missingPlanPlaceholder: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 16) {
                Text("Plan Not Ready")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)

                Text("Return to the previous step to finalize dietary preferences so we can generate your plan.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(SimplePalette.textSecondary)
            }
            .simpleCardPadding()
        }
    }

    private func workoutRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(SimplePalette.accentLight)
                .frame(width: 42, height: 42)
                .overlay(
                    Circle().stroke(SimplePalette.cardBorder, lineWidth: 1)
                )
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SimplePalette.accentBlue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)

                Text(detail)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(SimplePalette.textSecondary)
            }
        }
    }

    private func macroGrid(_ macros: MacroBreakdown) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            macroTile(title: "Calories", value: "\(macros.calories)", unit: "kcal")
            macroTile(title: "Protein", value: "\(macros.protein)", unit: "g")
            macroTile(title: "Carbs", value: "\(macros.carbs)", unit: "g")
            macroTile(title: "Sugar", value: "\(macros.sugar)", unit: "g")
        }
    }

    private func macroTile(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(SimplePalette.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)

                Text(unit)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(SimplePalette.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(SimplePalette.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(SimplePalette.cardBorder, lineWidth: 1)
                )
        )
    }

    private func hydrationRow(waterOz: Int) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(SimplePalette.accentLight)
                .frame(width: 42, height: 42)
                .overlay(
                    Circle().stroke(SimplePalette.cardBorder, lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "drop.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SimplePalette.accentBlue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Water target")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)

                Text("~\(waterOz) oz across the day")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(SimplePalette.textSecondary)
            }
        }
    }

    private var tagline: String {
        let name = onboardingData.username.isEmpty ? "Client" : onboardingData.username
        if let age = onboardingData.age {
            return "Built for \(name) • Age \(age)"
        } else {
            return "Built for \(name)"
        }
    }

    private func cardioDetail(for plan: HealthPlan) -> String {
        if plan.goalHighlights.contains(where: { $0.localizedCaseInsensitiveContains("endurance") }) {
            return "Moderate intervals with steady-state finish."
        }
        return "Mix brisk walking or cycling with light intervals."
    }

    private func strengthDetail(for plan: HealthPlan) -> String {
        if plan.goalHighlights.contains(where: { $0.localizedCaseInsensitiveContains("muscle") }) {
            return "Focus on compound lifts + accessory supersets."
        }
        return "Full-body circuit emphasizing form and tempo."
    }

    private func submitInput() {
        guard !aiInput.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            isTextFocused = true
            return
        }

        aiInput = ""
        isTextFocused = false
        showConfirmation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showConfirmation = false
        }
    }

    private var alertToast: some View {
        Group {
            if showConfirmation {
                Text("Coach received your update")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(SimplePalette.textPrimary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(SimplePalette.cardBackground)
                            .overlay(
                                Capsule().stroke(SimplePalette.cardBorder, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 4)
                    )
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthPlanView()
    }
    .environmentObject({
        let data = OnboardingData()
        data.username = "Jordan"
        data.age = 31
        data.goals = [1, 3]
        data.dietaryRestrictions = ["gluten", "shellfish"]
        data.generatePlaceholderPlan()
        return data
    }())
}


