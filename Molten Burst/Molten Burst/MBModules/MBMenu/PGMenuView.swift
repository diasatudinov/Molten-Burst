//
//  PGMenuView.swift
//  Molten Burst
//
//


import SwiftUI

struct PGMenuView: View {
    @State private var showGame = false
    @State private var showAchievement = false
    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var showDailyReward = false
    @State private var showShop = false
    
    @StateObject private var shopVM = MBShopViewModel()
    var body: some View {
        
        ZStack {
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button {
                        showSettings = true
                    } label: {
                        Image("settingsIconMB")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:92)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZZCoinBg()
                }
                
                VStack(alignment: .center) {
                    Image("menuViewLogoMB")
                        .resizable()
                        .scaledToFit()
                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 140:133)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button {
                        showGame = true
                    } label: {
                        Image("playIconMB")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:100)
                    }
                    
                    Button {
                        showShop = true
                    } label: {
                        Image("shopIconMB")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:87)
                    }
                    
                    Button {
                        showAchievement = true
                    } label: {
                        Image("achievementsIconMB")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:87)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                HStack {
                    Button {
                        showDailyReward = true
                    } label: {
                        Image("dailyIconMB")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:90)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.padding()
                
            
            
        }.frame(maxWidth: .infinity)
            .background(
                ZStack {
                    Image(.appBgMB)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                }
            )
            .fullScreenCover(isPresented: $showGame) {
                GameView(shopVM: shopVM)
            }
            .fullScreenCover(isPresented: $showShop) {
                MBShopView(viewModel: shopVM)
            }
            .fullScreenCover(isPresented: $showSettings) {
                MBSettingsView()
            }
            .fullScreenCover(isPresented: $showAchievement) {
                MBAchievementsView()
            }
            .fullScreenCover(isPresented: $showDailyReward) {
                MBDailyView()
            }
        
    }
}

#Preview {
    PGMenuView()
}
