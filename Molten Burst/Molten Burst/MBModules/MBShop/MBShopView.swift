//
//  MBShopView.swift
//  Molten Burst
//
//

import SwiftUI

struct MBShopView: View {
    @StateObject var user = ZZUser.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: MBShopViewModel
    @State var category: MBItemCategory = .skin
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    @State var indexSkin = 0
    @State var indexBg = 0
    var body: some View {
        ZStack {
            
//            if let category = category {
            if category == .skin {
                achievementItem(item: viewModel.shopSkinItems[indexSkin], category: .skin)
            } else {
                achievementItem(item: viewModel.shopBgItems[indexBg], category: .background)

            }
//                VStack(spacing: 35) {
//                    
//                    Image(category == .skin ? .skinsHeadMB : .bgHeadMB)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
//                    
//                    LazyVGrid(columns: columns, spacing: 12) {
//                        
//                        ForEach(category == .skin ?  :viewModel.shopBgItems, id: \.self) { item in
//                            
//                            
//                        }
//                    }
//                    
//                }

//                ZStack {
//                    
//                    VStack(spacing: 20) {
//                        Button {
//                            category = .skin
//                        } label: {
//                            Image(.skinsHeadMB)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:75)
//                        }
//                        
//                        Button {
//                            category = .background
//                        } label: {
//                            Image(.bgHeadMB)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:75)
//                        }
//                    }
//                    
//                }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:400)
            
            
            
            
            VStack {
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
                Spacer()
                
                
                
            }
        }.frame(maxWidth: .infinity)
            .background(
                Image(.appBgMB)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
            )
    }
    
    @ViewBuilder func achievementItem(item: MBItem, category: MBItemCategory) -> some View {
        ZStack {
            Image(.itemBgMB)
                .resizable()
                .scaledToFit()
                .overlay(alignment: .top) {
                    HStack(spacing: 8) {
                        Button {
                            if self.category == .skin {
                                self.category = .background
                            } else {
                                self.category = .skin
                            }
                        } label: {
                            Image(.btnLeftBM)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                        }.buttonStyle(.plain)
                        
                        Image(category == .skin ? .skinsHeadMB : .bgHeadMB)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:55)
                        
                        Button {
                            if self.category == .skin {
                                self.category = .background
                            } else {
                                self.category = .skin
                            }
                        } label: {
                            Image(.btnRightBM)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                        }.buttonStyle(.plain)
                    }
                    .offset(y: 50)
                }
                .overlay(alignment: .center) {
                    
                        Image(item.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 200:270)
                            .padding(.top, 64)
                    
                }
                .overlay(alignment: .center) {
                HStack(spacing: 0) {
                    Button {
                        if self.category == .skin {
                            if indexSkin > 0 {
                                indexSkin -= 1
                            }
                        } else {
                            if indexBg > 0 {
                                indexBg -= 1
                            }
                        }
                    } label: {
                        Image(.btnLeftBM)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button {
                        if self.category == .skin {
                            if indexSkin < viewModel.shopSkinItems.count - 1 {
                                indexSkin += 1
                            }
                        } else {
                            if indexBg < viewModel.shopBgItems.count - 1 {
                                indexBg += 1
                            }
                        }
                    } label: {
                        Image(.btnRightBM)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 80)
                }
                .overlay(alignment: .bottom) {
                    Button {
                        viewModel.selectOrBuy(item, user: user, category: category)
                    } label: {
                        
                        if viewModel.isPurchased(item, category: category) {
                            ZStack {
                                Image(viewModel.isCurrentItem(item: item, category: category) ? .usedBtnBgMB : .useBtnBgMB)
                                    .resizable()
                                    .scaledToFit()
                                
                            }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 50:70)
                            
                        } else {
                            Image(viewModel.isMoneyEnough(item: item, user: user, category: category) ? "hundredCoinMB" : "hundredOffCoinMB")
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 50:70)
                        }
                        
                        
                    }
                    .padding(.bottom)
                }
            
            
            
            VStack {
                Spacer()
                
            }.offset(y: 0)
            
        }.padding(.horizontal, 40)
        
    }
}

#Preview {
    MBShopView(viewModel: MBShopViewModel())
}
