import SwiftUI

struct GameView: View {

    @StateObject private var vm = GameViewModel()

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
            Text("Score: \(vm.score)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            Toggle("Death on Road", isOn: $vm.deathOnAnyRoadLane)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(.bottom, 8)
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
                    Rectangle()
                        .strokeBorder(Color(white: 0.15), lineWidth: 1)
                        .frame(width: vm.tileSize, height: vm.tileSize)
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
            if lane.type == .crosswalk {
                crosswalkMarks(rowIndex: rowIndex)
            }
        }
    }

    private func obstacleView(_ ob: Obstacle, rowIndex: Int) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange)
            .frame(width: vm.tileSize * 0.8, height: vm.tileSize * 0.8)
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
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.red)
            .frame(width: vm.tileSize * 0.95, height: vm.tileSize * 0.6)
            .position(
                x: CGFloat(car.x) * vm.tileSize + vm.tileSize / 2,
                y: yForRow(car.yIndex)
            )
    }

    private var playerView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.green)
            .frame(width: vm.tileSize * 0.75, height: vm.tileSize * 0.75)
            .position(
                x: xForColumn(vm.playerX),
                y: yForRow(vm.playerRowIndex)
            )
            .shadow(radius: 6)
    }

    private var gameOverOverlay: some View {
        VStack(spacing: 12) {
            Text("GAME OVER")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Score: \(vm.score)")
                .foregroundColor(.white.opacity(0.9))

            Button {
                vm.reset()
            } label: {
                Text("Restart")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color.black.opacity(0.7))
        .cornerRadius(18)
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
        case .crosswalk: return Color(white: 0.12)
        }
    }
}