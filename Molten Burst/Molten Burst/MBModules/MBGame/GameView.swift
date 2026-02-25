//
//  GameView.swift
//  Molten Burst
//
//  Created by Dias Atudinov on 24.02.2026.
//


import SwiftUI

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm = GameViewModel()
    @ObservedObject var shopVM: MBShopViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topHUD

                ZStack {
                    board
                    
                    if vm.isGameOver { gameOverOverlay }
                }
                .frame(
                    width: CGFloat(vm.columns) * vm.tileSize,
                    height: CGFloat(vm.visibleRows) * vm.tileSize
                )
                .clipped()
                .background(Color(white: 0.08))
                .gesture(swipeGesture)
            }
            .padding()
        }
    }

    private var topHUD: some View {
        HStack {
            
            Button {
                presentationMode.wrappedValue.dismiss()
                
            } label: {
                Image(.backIconMB)
                    .resizable()
                    .scaledToFit()
                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:41)
            }
            
            ZStack {
                Image(.scoreBgMB)
                    .resizable()
                    .scaledToFit()
                VStack {
                    Text("SCORE")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                    Text("\(vm.score)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.white)

            }
            .frame(height: 65)
                .frame(maxWidth: .infinity, alignment: .trailing)

        }
        .padding(.bottom, 8)
        .padding(.horizontal, 32)
    }

    private var board: some View {
        ZStack {
            // Полосы (фон + препятствия)
            ForEach(Array(vm.lanes.enumerated()), id: \.offset) { (rowIndex, lane) in
                laneRowView(lane: lane, rowIndex: rowIndex)
            }

            // Машины
            ForEach(vm.cars) { car in
                carView(car)
            }

            // Игрок
            playerView
        }
    }

    private func laneRowView(lane: Lane, rowIndex: Int) -> some View {
        ZStack {
            // Фон полосы
            Rectangle()
                .fill(colorForLane(lane.type))
                .frame(
                    width: CGFloat(vm.columns) * vm.tileSize,
                    height: vm.tileSize
                )
                .position(
                    x: CGFloat(vm.columns) * vm.tileSize / 2,
                    y: yForRow(rowIndex)
                )

            // “Клетки” (если хочешь видеть сетку)
            HStack(spacing: 0) {
                ForEach(0..<vm.columns, id: \.self) { _ in
                    Image(tileName(for: lane.type))
                        .resizable()
                        .interpolation(.none) // важно для пиксель-арта
                        .scaledToFill()
                        .frame(width: vm.tileSize, height: vm.tileSize)
                        .clipped()
//                    Rectangle()
//                        .strokeBorder(Color(white: 0.15), lineWidth: 1)
//                        .frame(width: vm.tileSize, height: vm.tileSize)
                }
            }
            .position(
                x: CGFloat(vm.columns) * vm.tileSize / 2,
                y: yForRow(rowIndex)
            )

            // Препятствия (только sidewalk)
            if lane.type == .sidewalk {
                ForEach(lane.obstacles) { ob in
                    obstacleView(ob, rowIndex: rowIndex)
                }
            }

            // Разметка “переход” (если crosswalk)
            if lane.type == .road, !lane.crosswalkXs.isEmpty {
                crosswalkTiles(lane: lane, rowIndex: rowIndex)
            }
        }
    }

    private func crosswalkTiles(lane: Lane, rowIndex: Int) -> some View {
        ZStack {
            ForEach(lane.crosswalkXs, id: \.self) { x in
                // Вариант 1: простая разметка поверх асфальта
                Image("tile_crosswalk")
                    .resizable()
                    .interpolation(.none)     // пиксель-арт без размытия
                    .scaledToFill()
                    .frame(width: vm.tileSize, height: vm.tileSize)
                    .clipped()
                    .position(x: xForColumn(x), y: yForRow(rowIndex))
            }
        }
    }
    
    private func tileName(for type: LaneType) -> String {
        switch type {
        case .sidewalk: return "tile_sidewalk"
        case .road: return "tile_road"
        }
    }
    
    private func obstacleView(_ ob: Obstacle, rowIndex: Int) -> some View {
        Group {
            if UIImage(named: ob.type.imageName) != nil {
                Image(ob.type.imageName)
                    .resizable()
                    .interpolation(.none)   // если пиксель-арт
                    .scaledToFit()
                    .padding(ob.type == .box ? 10 : 0)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(ob.type.fallbackColor)
            }
        }
        .frame(width: vm.tileSize * 0.9, height: vm.tileSize * 0.9)
        .position(x: xForColumn(ob.x), y: yForRow(rowIndex))
    }

    private func crosswalkMarks(rowIndex: Int) -> some View {
        HStack(spacing: vm.tileSize * 0.2) {
            ForEach(0..<vm.columns, id: \.self) { _ in
                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: vm.tileSize * 0.15, height: vm.tileSize * 0.7)
            }
        }
        .position(x: CGFloat(vm.columns) * vm.tileSize / 2, y: yForRow(rowIndex))
    }

    private func carView(_ car: Car) -> some View {
        let sz = car.type.size

        return Group {
            if let name = car.imageName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .interpolation(.none) // пиксель-арт, если нужно
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(car.type.fallbackColor)
            }
        }
        .frame(width: sz.width, height: sz.height)
        .scaleEffect(x: car.direction == -1 ? -1 : 1, y: 1) // разворот по направлению
        .position(
            x: CGFloat(car.x) * vm.tileSize + vm.tileSize / 2,
            y: yForRow(car.yIndex)
        )
    }

    @ViewBuilder private var playerView: some View {
        if let currentSkin = shopVM.currentSkinItem,  UIImage(named: currentSkin.image) != nil {
            Image(currentSkin.image)
                .resizable()
                .interpolation(.none) // пиксель-арт, если нужно
                .scaledToFit()
                .frame(width: vm.tileSize * 0.75, height: vm.tileSize * 0.75)
                .position(
                    x: xForColumn(vm.playerX),
                    y: yForRow(vm.playerRowIndex)
                )
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green)
                .frame(width: vm.tileSize * 0.75, height: vm.tileSize * 0.75)
                .position(
                    x: xForColumn(vm.playerX),
                    y: yForRow(vm.playerRowIndex)
                )
                .shadow(radius: 6)
        }
        
    }

    private var gameOverOverlay: some View {
        Image(.gameOverBgMB)
            .resizable()
            .scaledToFit()
            .padding(.horizontal, 50)
            .overlay(alignment: .bottom) {
                HStack {
                    VStack {
                        Text("YOUR:")
                        
                        Image(.scoreBgMB)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 63)
                            .overlay {
                                VStack {
                                    Text("SCORE")
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    Text("\(vm.score)")
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(.white)
                            }
                    }
                    
                    VStack {
                        VStack {
                            Text("BEST:")
                            
                            Image(.scoreBgMB)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 63)
                                .overlay {
                                    VStack {
                                        Text("SCORE")
                                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        Text("\(vm.bestScore)")
                                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    }
                                    .foregroundColor(.white)
                                }
                        }
                    }
                }
                .padding(.bottom, 70)
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    
                    Button {
                        vm.reset()
                    } label: {
                        Image(.replayBtnMB)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                    }
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(.mainBtnMB)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                    }
                }
                .offset(y: 60)
            }
            .offset(y: -80)
    }

    // MARK: - Swipe Gesture
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .local)
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height

                if abs(dx) > abs(dy) {
                    if dx > 0 { vm.moveRight() }
                    else { vm.moveLeft() }
                } else {
                    if dy < 0 { vm.moveUp() }
                    // вниз запрещен — игнорируем
                }
            }
    }

    // MARK: - Helpers координат
    private func xForColumn(_ col: Int) -> CGFloat {
        CGFloat(col) * vm.tileSize + vm.tileSize / 2
    }

    private func yForRow(_ rowIndex: Int) -> CGFloat {
        // rowIndex 0 — низ экрана; SwiftUI y растет вниз,
        // поэтому переворачиваем: низ = maxY.
        let totalH = CGFloat(vm.visibleRows) * vm.tileSize
        let yFromBottom = CGFloat(rowIndex) * vm.tileSize + vm.tileSize / 2
        return totalH - yFromBottom
    }

    private func colorForLane(_ type: LaneType) -> Color {
        switch type {
        case .sidewalk: return Color(white: 0.18)
        case .road: return Color(white: 0.10)
        }
    }
}

#Preview {
    GameView(shopVM: MBShopViewModel())
}
