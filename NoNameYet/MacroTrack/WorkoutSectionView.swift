import SwiftUI

struct WorkoutSectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var onboardingData: OnboardingData

    @State private var workouts: [Workout] = []
    @State private var selectedDate: Date = Date()
    @State private var showAddWorkoutSheet = false
    @State private var editingWorkoutIndex: Int?
    @State private var editingWorkout: Workout?
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            simpleBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("WORKOUT PLANNER")
                        .font(SimplePalette.retroFont(size: 28, weight: .bold))
                        .foregroundStyle(SimplePalette.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    dateSelectorCard

                    workoutsList
                        .id(selectedDate)
                        .transition(.opacity)
                        .opacity(isLoading ? 0.3 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                        .animation(.easeInOut(duration: 0.3), value: selectedDate)
                    
                    if workouts.count < 4 {
                        addWorkoutButton
                            .opacity(isLoading ? 0.3 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isLoading)
                    }
                    
                    stepsCountedSection
                }
                .padding(.bottom, 32)
            }
            
            // Loading indicator overlay
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                        )
                        .padding(.bottom, 100)
                    Spacer()
                }
            }
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadFromPlan)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    saveToPlan()
                    dismiss()
                }) {
                    Text("SAVE")
                        .font(SimplePalette.retroFont(size: 16, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                        .frame(width: 80, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(SimplePalette.retroWhite)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(SimplePalette.retroBlack, lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showAddWorkoutSheet) {
            AddWorkoutSheet(
                workoutType: .cardio,
                onSave: { workout in
                    workouts.append(workout)
                    saveToPlan()
                }
            )
        }
        .sheet(item: $editingWorkout) { workout in
            if let index = editingWorkoutIndex {
                EditWorkoutSheet(
                    workout: workout,
                    onSave: { updatedWorkout in
                        workouts[index] = updatedWorkout
                        saveToPlan()
                        editingWorkout = nil
                        editingWorkoutIndex = nil
                    },
                    onCancel: {
                        editingWorkout = nil
                        editingWorkoutIndex = nil
                    }
                )
            }
        }
    }
    
    private var workoutsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if workouts.isEmpty {
                SimpleCardPane {
                    VStack(spacing: 12) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                        Text("NO WORKOUTS PLANNED")
                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextPrimary)
                        Text("TAP 'ADD WORKOUT' TO CREATE YOUR PLAN")
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .simpleCardPadding()
                }
                .padding(.horizontal, 24)
            } else {
                ForEach(Array(workouts.enumerated()), id: \.element.id) { index, workout in
                    workoutCard(workout: workout, index: index)
                }
            }
        }
    }
    
    private func workoutCard(workout: Workout, index: Int) -> some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: workout.type == .cardio ? "figure.run" : "dumbbell")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                    
                    Text((workout.type == .cardio ? "CARDIO" : "STRENGTH").uppercased())
                        .font(SimplePalette.retroFont(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        editingWorkoutIndex = index
                        editingWorkout = workout
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        workouts.remove(at: index)
                        saveToPlan()
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(SimplePalette.retroRed)
                    }
                    .buttonStyle(.plain)
                }
                
                if let cardio = workout.cardio {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TYPE: \(cardio.type.rawValue.uppercased())")
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                        Text("DURATION: \(cardio.duration) MIN")
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                        if let distance = cardio.distance {
                            Text("DISTANCE: \(String(format: "%.1f", distance)) MI")
                                .font(SimplePalette.retroFont(size: 14, weight: .medium))
                                .foregroundStyle(SimplePalette.cardTextSecondary)
                        }
                        Text("INTENSITY: \(cardio.intensity.rawValue.uppercased())")
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                    }
                } else if let strength = workout.strength {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EXERCISE: \(strength.exercise.rawValue.uppercased())")
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                        Text("SETS: \(strength.sets)")
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                        Text("REPS: \(strength.reps)")
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                        Text("INTENSITY: \(strength.intensity.rawValue.uppercased())")
                            .font(SimplePalette.retroFont(size: 14, weight: .medium))
                            .foregroundStyle(SimplePalette.cardTextSecondary)
                    }
                }
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }
    
    private var addWorkoutButton: some View {
        Button(action: {
            showAddWorkoutSheet = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                Text("ADD WORKOUT")
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
            }
            .foregroundStyle(SimplePalette.retroBlack)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(SimplePalette.retroRed)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(SimplePalette.retroBlack, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 0, x: 4, y: 4)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }

    private var dateSelectorCard: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 16) {
                Text("SELECT DATE")
                    .font(SimplePalette.retroFont(size: 16, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)

                weekDateGrid
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }

    private var weekDateGrid: some View {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(weekDays, id: \.self) { date in
                Button(action: {
                    withAnimation {
                        isLoading = true
                        selectedDate = date
                    }
                    // Brief delay to show loading indicator
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        loadFromPlan()
                        isLoading = false
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(dayOfWeekAbbrev(for: date).uppercased())
                            .font(SimplePalette.retroFont(size: 11, weight: .bold))
                            .foregroundStyle(SimplePalette.cardTextSecondary)

                        Text("\(calendar.component(.day, from: date))")
                            .font(SimplePalette.retroFont(size: 16, weight: .bold))
                            .foregroundStyle(calendar.isDate(date, inSameDayAs: selectedDate) ? SimplePalette.retroWhite : SimplePalette.cardTextPrimary)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? SimplePalette.retroRed : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(SimplePalette.retroBlack, lineWidth: 2)
                                    )
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
    }

    private func dayOfWeekAbbrev(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func loadFromPlan() {
        withAnimation(.easeInOut(duration: 0.2)) {
            workouts = onboardingData.workoutsArray(for: selectedDate)
        }
    }

    private func saveToPlan() {
        onboardingData.setWorkoutsArray(workouts, for: selectedDate)
    }
    
    private var stepsCountedSection: some View {
        SimpleCardPane {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.retroRed)
                    
                    Text("STEPS COUNTED")
                        .font(SimplePalette.retroFont(size: 20, weight: .bold))
                        .foregroundStyle(SimplePalette.cardTextPrimary)
                }
                
                Text("0 STEPS")
                    .font(SimplePalette.retroFont(size: 18, weight: .bold))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
                
                Text("CONNECT APPLE WATCH TO TRACK STEPS")
                    .font(SimplePalette.retroFont(size: 14, weight: .medium))
                    .foregroundStyle(SimplePalette.cardTextSecondary)
            }
            .simpleCardPadding()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Add Workout Sheet

private struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    let workoutType: WorkoutType
    let onSave: (Workout) -> Void
    
    @State private var selectedType: WorkoutType = .cardio
    @State private var cardioType: CardioType = .run
    @State private var cardioDuration: Int = 30
    @State private var cardioDistance: Double? = 2.0
    @State private var cardioIntensity: Intensity = .moderate
    
    @State private var strengthExercise: StrengthExercise = .squats
    @State private var strengthSets: Int = 3
    @State private var strengthReps: Int = 12
    @State private var strengthIntensity: Intensity = .moderate
    
    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Picker("Workout Type", selection: $selectedType) {
                            Text("Cardio").tag(WorkoutType.cardio)
                            Text("Strength").tag(WorkoutType.strength)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        if selectedType == .cardio {
                            cardioEditor
                        } else {
                            strengthEditor
                        }
                    }
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if selectedType == .cardio {
                            let cardio = CardioWorkout(
                                type: cardioType,
                                duration: cardioDuration,
                                distance: cardioDistance,
                                intensity: cardioIntensity
                            )
                            onSave(Workout(cardio: cardio))
                        } else {
                            let strength = StrengthWorkout(
                                exercise: strengthExercise,
                                sets: strengthSets,
                                reps: strengthReps,
                                intensity: strengthIntensity
                            )
                            onSave(Workout(strength: strength))
                        }
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var cardioEditor: some View {
        VStack(alignment: .leading, spacing: 20) {
            SimpleCardPane {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Type", selection: $cardioType) {
                        ForEach(CardioType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                            Picker("", selection: $cardioDuration) {
                                ForEach([15, 20, 30, 45, 60], id: \.self) { mins in
                                    Text("\(mins) min").tag(mins)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        if [CardioType.run, .walk, .bike].contains(cardioType) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Distance")
                                Picker("", selection: Binding(
                                    get: { cardioDistance ?? 2.0 },
                                    set: { cardioDistance = $0 }
                                )) {
                                    ForEach([1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0], id: \.self) { dist in
                                        Text(String(format: "%.1f mi", dist)).tag(dist)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                    }
                    
                    Picker("Intensity", selection: $cardioIntensity) {
                        ForEach(Intensity.allCases) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var strengthEditor: some View {
        VStack(alignment: .leading, spacing: 20) {
            SimpleCardPane {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Exercise", selection: $strengthExercise) {
                        ForEach(StrengthExercise.allCases) { exercise in
                            Text(exercise.rawValue).tag(exercise)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sets")
                            Picker("", selection: $strengthSets) {
                                ForEach(1...5, id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reps")
                            Picker("", selection: $strengthReps) {
                                ForEach([8, 10, 12, 15, 20], id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    
                    Picker("Intensity", selection: $strengthIntensity) {
                        ForEach(Intensity.allCases) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Edit Workout Sheet

private struct EditWorkoutSheet: View, Identifiable {
    var id: UUID { workout.id }
    @Environment(\.dismiss) private var dismiss
    let workout: Workout
    let onSave: (Workout) -> Void
    let onCancel: () -> Void
    
    @State private var cardioType: CardioType
    @State private var cardioDuration: Int
    @State private var cardioDistance: Double?
    @State private var cardioIntensity: Intensity
    
    @State private var strengthExercise: StrengthExercise
    @State private var strengthSets: Int
    @State private var strengthReps: Int
    @State private var strengthIntensity: Intensity
    
    init(workout: Workout, onSave: @escaping (Workout) -> Void, onCancel: @escaping () -> Void) {
        self.workout = workout
        self.onSave = onSave
        self.onCancel = onCancel
        
        if let cardio = workout.cardio {
            _cardioType = State(initialValue: cardio.type)
            _cardioDuration = State(initialValue: cardio.duration)
            _cardioDistance = State(initialValue: cardio.distance)
            _cardioIntensity = State(initialValue: cardio.intensity)
            _strengthExercise = State(initialValue: .squats)
            _strengthSets = State(initialValue: 3)
            _strengthReps = State(initialValue: 12)
            _strengthIntensity = State(initialValue: .moderate)
        } else if let strength = workout.strength {
            _cardioType = State(initialValue: .run)
            _cardioDuration = State(initialValue: 30)
            _cardioDistance = State(initialValue: nil)
            _cardioIntensity = State(initialValue: .moderate)
            _strengthExercise = State(initialValue: strength.exercise)
            _strengthSets = State(initialValue: strength.sets)
            _strengthReps = State(initialValue: strength.reps)
            _strengthIntensity = State(initialValue: strength.intensity)
        } else {
            _cardioType = State(initialValue: .run)
            _cardioDuration = State(initialValue: 30)
            _cardioDistance = State(initialValue: nil)
            _cardioIntensity = State(initialValue: .moderate)
            _strengthExercise = State(initialValue: .squats)
            _strengthSets = State(initialValue: 3)
            _strengthReps = State(initialValue: 12)
            _strengthIntensity = State(initialValue: .moderate)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                simpleBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if workout.type == .cardio {
                            cardioEditor
                        } else {
                            strengthEditor
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedWorkout = workout
                        if workout.type == .cardio {
                            updatedWorkout.cardio = CardioWorkout(
                                type: cardioType,
                                duration: cardioDuration,
                                distance: cardioDistance,
                                intensity: cardioIntensity
                            )
                        } else {
                            updatedWorkout.strength = StrengthWorkout(
                                exercise: strengthExercise,
                                sets: strengthSets,
                                reps: strengthReps,
                                intensity: strengthIntensity
                            )
                        }
                        onSave(updatedWorkout)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var cardioEditor: some View {
        VStack(alignment: .leading, spacing: 20) {
            SimpleCardPane {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Type", selection: $cardioType) {
                        ForEach(CardioType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                            Picker("", selection: $cardioDuration) {
                                ForEach([15, 20, 30, 45, 60], id: \.self) { mins in
                                    Text("\(mins) min").tag(mins)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        if [CardioType.run, .walk, .bike].contains(cardioType) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Distance")
                                Picker("", selection: Binding(
                                    get: { cardioDistance ?? 2.0 },
                                    set: { cardioDistance = $0 }
                                )) {
                                    ForEach([1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0], id: \.self) { dist in
                                        Text(String(format: "%.1f mi", dist)).tag(dist)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                    }
                    
                    Picker("Intensity", selection: $cardioIntensity) {
                        ForEach(Intensity.allCases) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var strengthEditor: some View {
        VStack(alignment: .leading, spacing: 20) {
            SimpleCardPane {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Exercise", selection: $strengthExercise) {
                        ForEach(StrengthExercise.allCases) { exercise in
                            Text(exercise.rawValue).tag(exercise)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sets")
                            Picker("", selection: $strengthSets) {
                                ForEach(1...5, id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reps")
                            Picker("", selection: $strengthReps) {
                                ForEach([8, 10, 12, 15, 20], id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    
                    Picker("Intensity", selection: $strengthIntensity) {
                        ForEach(Intensity.allCases) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .simpleCardPadding()
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutSectionView()
    }
    .environmentObject({
        let data = OnboardingData()
        data.generatePlaceholderPlan()
        return data
    }())
}
