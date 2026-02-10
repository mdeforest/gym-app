import SwiftUI

struct AddCustomExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ExerciseLibraryViewModel

    @State private var name = ""
    @State private var selectedMuscleGroup: MuscleGroup = .chest

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Name") {
                    TextField("e.g. Incline Dumbbell Press", text: $name)
                }

                Section("Muscle Group") {
                    Picker("Muscle Group", selection: $selectedMuscleGroup) {
                        ForEach(MuscleGroup.allCases) { group in
                            Text(group.displayName).tag(group)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        viewModel.addCustomExercise(
                            name: name.trimmingCharacters(in: .whitespaces),
                            muscleGroup: selectedMuscleGroup
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
    }
}
