import SwiftUI

struct PetProfileView: View {
    @StateObject private var viewModel = PetProfileViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Pet Info Section
                    petInfoSection
                    
                    // Statistics Section
                    statisticsSection
                    
                    // Actions Section
                    actionsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.moodColors.background.ignoresSafeArea())
            .navigationTitle("Профиль питомца")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(Color.moodColors.happy)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingEditProfile) {
            PetProfileEditView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingImagePicker) {
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Avatar
            ModernPetAvatar(
                image: viewModel.getPetPhoto(),
                size: 120
            ) {
                viewModel.showingImagePicker = true
            }
            
            // Pet Name and Gender
            VStack(spacing: 8) {
                Text(viewModel.displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                if let profile = viewModel.petProfile {
                    HStack(spacing: 8) {
                        Text(profile.gender.emoji)
                            .font(.system(size: 20))
                        
                        Text(profile.gender.displayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Pet Info Section
    private var petInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Информация")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ModernPetInfoCard(
                    title: "Порода",
                    value: viewModel.displayBreed,
                    icon: "pawprint.fill",
                    color: Color.moodColors.happy
                )
                
                ModernPetInfoCard(
                    title: "Возраст",
                    value: viewModel.displayAge,
                    icon: "calendar",
                    color: Color.moodColors.excited
                )
                
                ModernPetInfoCard(
                    title: "Вес",
                    value: viewModel.displayWeight,
                    icon: "scalemass",
                    color: Color.moodColors.calm
                )
                
                ModernPetInfoCard(
                    title: "Дней с нами",
                    value: "\(Calendar.current.dateComponents([.day], from: viewModel.petProfile?.createdAt ?? Date(), to: Date()).day ?? 0)",
                    icon: "heart.fill",
                    color: Color.moodColors.sad
                )
            }
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Статистика")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ModernStatisticsCard(
                    title: "Всего записей",
                    value: "\(viewModel.statistics.totalEntries)",
                    subtitle: "настроений",
                    icon: "chart.bar.fill",
                    color: Color.moodColors.happy
                )
                
                ModernStatisticsCard(
                    title: "Среднее настроение",
                    value: String(format: "%.1f", viewModel.statistics.averageMood),
                    subtitle: "из 10 баллов",
                    icon: "heart.fill",
                    color: Color.moodColors.excited
                )
                
                if let favoriteEmotion = viewModel.statistics.favoriteEmotion {
                    ModernStatisticsCard(
                        title: "Любимая эмоция",
                        value: favoriteEmotion.displayName,
                        subtitle: favoriteEmotion.emoji,
                        icon: "star.fill",
                        color: Color.moodColors.calm
                    )
                }
                
                if let mostActiveDay = viewModel.statistics.mostActiveDay {
                    ModernStatisticsCard(
                        title: "Самый активный день",
                        value: mostActiveDay,
                        subtitle: "недели",
                        icon: "calendar.badge.clock",
                        color: Color.moodColors.sad
                    )
                }
            }
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Действия")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ModernEditButton(title: "Редактировать профиль") {
                    viewModel.showingEditProfile = true
                }
                
                if let lastEntry = viewModel.statistics.lastEntryDate {
                    Text("Последняя запись: \(lastEntry, style: .relative)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
} 