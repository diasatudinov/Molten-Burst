import SwiftUI

struct ZZCoinBg: View {
    @StateObject var user = ZZUser.shared
    var height: CGFloat = ZZDeviceManager.shared.deviceType == .pad ? 80:50
    var body: some View {
        ZStack {
            Image("coinsBgIF")
                .resizable()
                .scaledToFit()
            
            Text("\(user.money)")
                .font(.system(size: ZZDeviceManager.shared.deviceType == .pad ? 45:16, weight: .bold))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .offset(x: 15, y: 0)
            
            
            
        }.frame(height: height)
        
    }
}

#Preview {
    ZZCoinBg()
}
