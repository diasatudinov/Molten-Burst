import SwiftUI

struct PGMenuView: View {
    @State private var showGame = false
    @State private var showAchievement = false
    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var showDailyReward = false
    @State private var showShop = false
    
    @StateObject private var shopVM = CPShopViewModel()
    var body: some View {
        
        ZStack {
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button {
                        showSettings = true
                    } label: {
                        Image("settingsIconIF")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:50)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZZCoinBg()
                }
                
                VStack(alignment: .center) {
                    Image("loaderViewLogoIF")
                        .resizable()
                        .scaledToFit()
                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 140:163)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button {
                        showGame = true
                    } label: {
                        Image("playIconIF")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:90)
                    }
                    
                    Button {
                        showDailyReward = true
                    } label: {
                        Image("dailyIconIF")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:90)
                    }
                    
                    Button {
                        showAchievement = true
                    } label: {
                        Image("achievementsIconIF")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:90)
                    }
                    
                    Button {
                        showShop = true
                    } label: {
                        Image("shopIconIF")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:90)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
            }.padding()
                
            
            
        }.frame(maxWidth: .infinity)
            .background(
                ZStack {
                    Image(.appBgIF)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                }
            )
            .fullScreenCover(isPresented: $showGame) {
                GameView(viewModel: shopVM)
            }
            .fullScreenCover(isPresented: $showShop) {
                PGShopView(viewModel: shopVM)
            }
            .fullScreenCover(isPresented: $showSettings) {
                IFSettingsView()
            }
            .fullScreenCover(isPresented: $showAchievement) {
                IFAchivementsView()
            }
            .fullScreenCover(isPresented: $showDailyReward) {
                IFDailyView()
            }
        
    }
}

#Preview {
    PGMenuView()
}