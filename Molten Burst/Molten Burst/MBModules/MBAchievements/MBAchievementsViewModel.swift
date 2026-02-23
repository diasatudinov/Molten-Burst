//
//  IFAchievementsViewModel.swift
//  Molten Burst
//
//


import SwiftUI

class IFAchievementsViewModel: ObservableObject {
    
    @Published var achievements: [MBAchievement] = [
        MBAchievement(image: "achieve1ImageMB", title: "achieve1TextMB", isAchieved: false),
        MBAchievement(image: "achieve2ImageMB", title: "achieve2TextMB", isAchieved: false),
        MBAchievement(image: "achieve3ImageMB", title: "achieve3TextMB", isAchieved: false),
        MBAchievement(image: "achieve4ImageMB", title: "achieve4TextMB", isAchieved: false),
        MBAchievement(image: "achieve5ImageMB", title: "achieve5TextMB", isAchieved: false),
    ] {
        didSet {
            saveAchievementsItem()
        }
    }
        
    init() {
        loadAchievementsItem()
    }
    
    private let userDefaultsAchievementsKey = "achievementsKeyMB"
    
    func achieveToggle(_ achive: MBAchievement) {
        guard let index = achievements.firstIndex(where: { $0.id == achive.id })
        else {
            return
        }
        achievements[index].isAchieved.toggle()
        
    }
   
    
    
    func saveAchievementsItem() {
        if let encodedData = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsAchievementsKey)
        }
        
    }
    
    func loadAchievementsItem() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsAchievementsKey),
           let loadedItem = try? JSONDecoder().decode([MBAchievement].self, from: savedData) {
            achievements = loadedItem
        } else {
            print("No saved data found")
        }
    }
}

struct MBAchievement: Codable, Hashable, Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var isAchieved: Bool
}
