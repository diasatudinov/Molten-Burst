//
//  MBShopViewModel.swift
//  Molten Burst
//
//



import SwiftUI


final class MBShopViewModel: ObservableObject {
    // MARK: – Shop catalogues
    @Published var shopBgItems: [MBItem] = [
        MBItem(name: "bg1", image: "bgImage1MB", icon: "gameBgIcon1MB", text: "gameBgText1MB", price: 100),
        MBItem(name: "bg2", image: "bgImage2MB", icon: "gameBgIcon2MB", text: "gameBgText2MB", price: 100),
        MBItem(name: "bg3", image: "bgImage3MB", icon: "gameBgIcon3MB", text: "gameBgText3MB", price: 100),
        MBItem(name: "bg4", image: "bgImage4MB", icon: "gameBgIcon4MB", text: "gameBgText4MB", price: 100),

    ]
    
    @Published var shopSkinItems: [MBItem] = [
        MBItem(name: "skin1", image: "skinImage1MB", icon: "skinIcon1MB", text: "skinText1MB", price: 100),
        MBItem(name: "skin2", image: "skinImage2MB", icon: "skinIcon2MB", text: "skinText2MB", price: 100),
        MBItem(name: "skin3", image: "skinImage3MB", icon: "skinIcon3MB", text: "skinText3MB", price: 100),
        MBItem(name: "skin4", image: "skinImage4MB", icon: "skinIcon4MB", text: "skinText4MB", price: 100),

    ]
    
    // MARK: – Bought
    @Published var boughtBgItems: [MBItem] = [
        MBItem(name: "bg1", image: "bgImage1MB", icon: "gameBgIcon1MB", text: "gameBgText1MB", price: 100),
    ] {
        didSet { saveBoughtBg() }
    }
    
    @Published var boughtSkinItems: [MBItem] = [
        MBItem(name: "skin1", image: "skinImage1MB", icon: "skinIcon1MB", text: "skinText1MB", price: 100),
    ] {
        didSet { saveBoughtSkins() }
    }
    
    // MARK: – Current selections
    @Published var currentBgItem: MBItem? {
        didSet { saveCurrentBg() }
    }
    @Published var currentSkinItem: MBItem? {
        didSet { saveCurrentSkin() }
    }
    
    // MARK: – UserDefaults keys
    private let bgKey            = "currentBgIF1"
    private let boughtBgKey      = "boughtBgIF1"
    private let skinKey          = "currentSkinIF1"
    private let boughtSkinKey    = "boughtSkinIF1"
    
    // MARK: – Init
    init() {
        loadCurrentBg()
        loadBoughtBg()
        
        loadCurrentSkin()
        loadBoughtSkins()
    }
    
    // MARK: – Save / Load Backgrounds
    private func saveCurrentBg() {
        guard let item = currentBgItem,
              let data = try? JSONEncoder().encode(item)
        else { return }
        UserDefaults.standard.set(data, forKey: bgKey)
    }
    private func loadCurrentBg() {
        if let data = UserDefaults.standard.data(forKey: bgKey),
           let item = try? JSONDecoder().decode(MBItem.self, from: data) {
            currentBgItem = item
        } else {
            currentBgItem = shopBgItems.first
        }
    }
    private func saveBoughtBg() {
        guard let data = try? JSONEncoder().encode(boughtBgItems) else { return }
        UserDefaults.standard.set(data, forKey: boughtBgKey)
    }
    private func loadBoughtBg() {
        if let data = UserDefaults.standard.data(forKey: boughtBgKey),
           let items = try? JSONDecoder().decode([MBItem].self, from: data) {
            boughtBgItems = items
        }
    }
    
    // MARK: – Save / Load Skins
    private func saveCurrentSkin() {
        guard let item = currentSkinItem,
              let data = try? JSONEncoder().encode(item)
        else { return }
        UserDefaults.standard.set(data, forKey: skinKey)
    }
    private func loadCurrentSkin() {
        if let data = UserDefaults.standard.data(forKey: skinKey),
           let item = try? JSONDecoder().decode(MBItem.self, from: data) {
            currentSkinItem = item
        } else {
            currentSkinItem = shopSkinItems.first
        }
    }
    private func saveBoughtSkins() {
        guard let data = try? JSONEncoder().encode(boughtSkinItems) else { return }
        UserDefaults.standard.set(data, forKey: boughtSkinKey)
    }
    private func loadBoughtSkins() {
        if let data = UserDefaults.standard.data(forKey: boughtSkinKey),
           let items = try? JSONDecoder().decode([MBItem].self, from: data) {
            boughtSkinItems = items
        }
    }
    
    // MARK: – Example buy action
    func buy(_ item: MBItem, category: MBItemCategory) {
        switch category {
        case .background:
            guard !boughtBgItems.contains(item) else { return }
            boughtBgItems.append(item)
        case .skin:
            guard !boughtSkinItems.contains(item) else { return }
            boughtSkinItems.append(item)
        }
    }
    
    func isPurchased(_ item: MBItem, category: MBItemCategory) -> Bool {
        switch category {
        case .background:
            return boughtBgItems.contains(where: { $0.name == item.name })
        case .skin:
            return boughtSkinItems.contains(where: { $0.name == item.name })
        }
    }
    
    func selectOrBuy(_ item: MBItem, user: ZZUser, category: MBItemCategory) {
        
        switch category {
        case .background:
            if isPurchased(item, category: .background) {
                currentBgItem = item
            } else {
                guard user.money >= item.price else {
                    return
                }
                user.minusUserMoney(for: item.price)
                buy(item, category: .background)
            }
        case .skin:
            if isPurchased(item, category: .skin) {
                currentSkinItem = item
            } else {
                guard user.money >= item.price else {
                    return
                }
                user.minusUserMoney(for: item.price)
                buy(item, category: .skin)
            }
        }
    }
    
    func isMoneyEnough(item: MBItem, user: ZZUser, category: MBItemCategory) -> Bool {
        user.money >= item.price
    }
    
    func isCurrentItem(item: MBItem, category: MBItemCategory) -> Bool {
        switch category {
        case .background:
            guard let currentItem = currentBgItem, currentItem.name == item.name else {
                return false
            }
            
            return true
            
        case .skin:
            guard let currentItem = currentSkinItem, currentItem.name == item.name else {
                return false
            }
            
            return true
        }
    }
    
    func nextCategory(category: MBItemCategory) -> MBItemCategory {
        if category == .skin {
            return .background
        } else {
            return .skin
        }
    }
}

enum MBItemCategory: String {
    case background = "background"
    case skin = "skin"
}

struct MBItem: Codable, Hashable {
    var id = UUID()
    var name: String
    var image: String
    var icon: String
    var text: String
    var price: Int
}
