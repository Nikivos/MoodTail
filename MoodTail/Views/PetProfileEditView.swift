import SwiftUI

struct PetProfileEditView: View {
    @ObservedObject var viewModel: PetProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var gender: PetGender = .unknown
    @State private var birthDate: Date = Date()
    @State private var specialNotes: String = ""
    
    @State private var showingImagePicker = false
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Photo Section
                    photoSection
                    
                    // Basic Info Section
                    basicInfoSection
                    
                    // Additional Info Section
                    additionalInfoSection
                    
                    // Notes Section
                    notesSection
                    
                    // Save Button
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.moodColors.background.ignoresSafeArea())
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            loadCurrentData()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: Binding(
                get: { nil },
                set: { image in
                    if let image = image {
                        viewModel.setPetPhoto(image)
                    }
                }
            ))
        }
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: 16) {
            Text("Фото питомца")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            ModernPetAvatar(
                image: viewModel.getPetPhoto(),
                size: 100
            ) {
                showingImagePicker = true
            }
            
            Text("Нажмите, чтобы изменить фото")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Основная информация")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Name
                ModernInputField(
                    title: "Имя питомца",
                    text: $name,
                    placeholder: "Введите имя",
                    icon: "pawprint.fill",
                    color: Color.moodColors.happy
                )
                
                // Breed
                ModernInputField(
                    title: "Порода",
                    text: $breed,
                    placeholder: "Введите породу",
                    icon: "tag.fill",
                    color: Color.moodColors.excited
                )
                
                // Gender
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пол")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        ForEach(PetGender.allCases, id: \.self) { genderOption in
                            ModernGenderButton(
                                gender: genderOption,
                                isSelected: gender == genderOption,
                                action: {
                                    gender = genderOption
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Additional Info Section
    private var additionalInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Дополнительная информация")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Age
                ModernInputField(
                    title: "Возраст (лет)",
                    text: $age,
                    placeholder: "Введите возраст",
                    icon: "calendar",
                    color: Color.moodColors.calm,
                    keyboardType: .numberPad
                )
                
                // Weight
                ModernInputField(
                    title: "Вес (кг)",
                    text: $weight,
                    placeholder: "Введите вес",
                    icon: "scalemass",
                    color: Color.moodColors.sad,
                    keyboardType: .decimalPad
                )
                
                // Birth Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Дата рождения")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Color.moodColors.excited)
                            
                            Text(birthDate, style: .date)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.moodColors.cardBackground)
                                .shadow(color: Color.moodColors.cardShadow, radius: 4, x: 0, y: 2)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Особенности и заметки")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Аллергии, предпочтения, особенности характера")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextEditor(text: $specialNotes)
                    .frame(minHeight: 100)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.moodColors.cardBackground)
                            .shadow(color: Color.moodColors.cardShadow, radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.moodColors.calm.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        ModernSaveButton(
            isEnabled: !name.isEmpty,
            isLoading: false
        ) {
            saveProfile()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadCurrentData() {
        guard let profile = viewModel.petProfile else { return }
        
        name = profile.name
        breed = profile.breed
        age = profile.age > 0 ? "\(profile.age)" : ""
        
        // Безопасная обработка веса
        let safeWeight = profile.weight.isNaN ? 0.0 : profile.weight
        weight = safeWeight > 0 ? String(format: "%.1f", safeWeight) : ""
        
        gender = profile.gender
        birthDate = profile.birthDate
        specialNotes = profile.specialNotes ?? ""
    }
    
    private func saveProfile() {
        // Безопасная обработка числовых значений
        let ageValue = Int(age) ?? 0
        let weightValue = Double(weight) ?? 0.0
        
        // Проверяем на NaN
        let safeWeight = weightValue.isNaN ? 0.0 : weightValue
        
        let updatedProfile = PetProfile(
            name: name,
            breed: breed,
            age: ageValue,
            weight: safeWeight,
            gender: gender,
            birthDate: birthDate,
            photoData: viewModel.petProfile?.photoData,
            specialNotes: specialNotes.isEmpty ? nil : specialNotes
        )
        
        viewModel.updatePetProfile(updatedProfile)
        dismiss()
    }
}

// MARK: - Modern Input Field
struct ModernInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    let color: Color
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled(keyboardType == .numberPad || keyboardType == .decimalPad)
                    .textInputAutocapitalization(keyboardType == .numberPad || keyboardType == .decimalPad ? .never : .words)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            HStack {
                                Spacer()
                                Button("Готово") {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(color)
                            }
                        }
                    }
                    .onChange(of: text) { oldValue, newValue in
                        // Безопасная обработка ввода для числовых полей
                        if keyboardType == .numberPad || keyboardType == .decimalPad {
                            let filtered = newValue.filter { "0123456789.,".contains($0) }
                            if filtered != newValue {
                                DispatchQueue.main.async {
                                    text = filtered
                                }
                            }
                        }
                    }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.moodColors.cardBackground)
                    .shadow(color: Color.moodColors.cardShadow, radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Modern Gender Button
struct ModernGenderButton: View {
    let gender: PetGender
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            VStack(spacing: 8) {
                Text(gender.emoji)
                    .font(.system(size: 24))
                
                Text(gender.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.moodColors.happy : Color.moodColors.cardBackground)
                    .shadow(color: isSelected ? Color.moodColors.happy.opacity(0.3) : Color.moodColors.cardShadow, radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
} 