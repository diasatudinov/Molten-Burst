//
//  ZZCoinBg.swift
//  Molten Burst
//
//


import SwiftUI

struct ZZCoinBg: View {
    @StateObject var user = ZZUser.shared
    var height: CGFloat = ZZDeviceManager.shared.deviceType == .pad ? 80:50
    var body: some View {
        ZStack {
            Image("coinsBgMB")
                .resizable()
                .scaledToFit()
            
            Text("\(user.money)")
                .font(.system(size: ZZDeviceManager.shared.deviceType == .pad ? 45:20, weight: .bold))
                .foregroundStyle(.black)
                .textCase(.uppercase)
                .offset(x: 20, y: 0)
            
            
            
        }.frame(height: height)
        
    }
}

#Preview {
    ZZCoinBg()
}
