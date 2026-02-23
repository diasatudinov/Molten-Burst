//
//  MBSettingsView.swift
//  Molten Burst
//
//

import SwiftUI

struct MBSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var settingsVM = MBSettingsViewModel()
    var body: some View {
        
        VStack(spacing: 8) {
            
            HStack {
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
                
            }.padding()
            
            VStack(spacing: 8) {
                VStack(spacing: 8) {
                    
                    Image(.musicTextMB)
                        .resizable()
                        .scaledToFit()
                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:120)
                    
                    HStack(spacing: 8) {
                        Button {
                            withAnimation {
                                settingsVM.musicEnabled = true
                            }
                        } label: {
                            Image(settingsVM.musicEnabled ? .onOnMB:.onOffMB)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:87)
                        }
                        
                        Button {
                            withAnimation {
                                settingsVM.musicEnabled = false
                            }
                        } label: {
                            Image(settingsVM.musicEnabled ? .offOffMB :.offOnMB)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:87)
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    
                    Image(.soundTextMB)
                        .resizable()
                        .scaledToFit()
                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:120)
                    
                    HStack(spacing: 8) {
                        Button {
                            withAnimation {
                                settingsVM.soundEnabled = true
                            }
                        } label: {
                            Image(settingsVM.soundEnabled ? .onOnMB:.onOffMB)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:87)
                        }
                        
                        Button {
                            withAnimation {
                                settingsVM.soundEnabled = false
                            }
                        } label: {
                            Image(settingsVM.soundEnabled ? .offOffMB :.offOnMB)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:87)
                        }
                    }
                }
            }.frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 30)
        }.frame(maxWidth: .infinity)
            .background(
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
    MBSettingsView()
}
