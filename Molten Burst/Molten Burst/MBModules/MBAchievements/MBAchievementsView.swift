//
//  MBAchievementsView.swift
//  Molten Burst
//
//

import SwiftUI

struct MBAchievementsView: View {
    @StateObject var user = ZZUser.shared
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = MBAchievementsViewModel()
    @State private var index = 0
    var body: some View {
        ZStack {
            
            VStack {
                
                ZStack {
                    
                    HStack(alignment: .center) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            
                        } label: {
                            Image(.backIconMB)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:41)
                        }
                        
                        Spacer()
                        
                        ZZCoinBg()
                        
                    }.padding(.horizontal).padding([.top])
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        ForEach(viewModel.achievements, id: \.self) { item in
                            HStack(spacing: 8) {
                                Image(item.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 130)
                                    .overlay(alignment: .bottom) {
                                        if item.isAchieved {
                                            Image(.collectTextMB)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 50)
                                                .offset(y: 25)
                                        }
                                    }
                                    .onTapGesture {
                                        if item.isAchieved {
                                            user.updateUserMoney(for: 10)
                                        }
                                        viewModel.achieveToggle(item)
                                    }
                                
                                Image(item.isAchieved ? .starOnImgMB: .starOffImgMB)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                            }
                        }
                    }
                }
            }
        }.background(
            ZStack {
                Image(.appBgMB)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
            }
        )
    }
}


#Preview {
    MBAchievementsView()
}
