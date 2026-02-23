//
//  IFDailyView.swift
//  Molten Burst
//
//


import SwiftUI

struct MBDailyView: View {
    @StateObject var user = ZZUser.shared
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("claim2") var claim: Bool = false
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
                
                
                Image(.dailyBgMB)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 43)
                    .overlay(alignment: .bottom) {
                        Button {
                            claim.toggle()
                            if claim {
                                user.updateUserMoney(for: 10)
                            }
                        } label: {
                            
                            Image(!claim ? .collectTextMB:.collectedBtnMB)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:75)
                        }
                        .offset(y: 35)
                    }
                
                Spacer()
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
    MBDailyView()
}
