//
//  GameViewModel.swift
//  Molten Burst
//
//  Created by Dias Atudinov on 24.02.2026.
//


import SwiftUI

final class GameViewModel: ObservableObject {

    // MARK: - Конфиг
    let tileSize: CGFloat = 60
    let columns: Int = 7            // ширина поля (клеток)
    let visibleRows: Int = 11       // сколько полос видно на экране
    let baseTick: Double = 1.0 / 60.0

    /// Если true — смерть просто за факт стояния в road полосе (как ты описал "нахождение в полосе движения").
    /// Если false — смерть только при совпадении клетки с машиной.
    @Published var deathOnAnyRoadLane: Bool = false

    // MARK: - Состояние игры
    @Published var lanes: [Lane] = []
    @Published var cars: [Car] = []

    @Published var playerX: Int = 3
    @Published var playerRowIndex: Int = 0   // индекс полосы в массиве lanes, где стоит игрок (0 = нижняя видимая)
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isRunning: Bool = true

    @AppStorage("BestSCore") var bestScore = 0
    
    private var timer: Timer?
    private var roadCrossCount: Int = 0 // для подсчета “сколько дорог пересек”

    // MARK: - Генератор паттерна: Sidewalk -> Road(1..3) -> Sidewalk -> ...
    private enum GenerationPhase {
        case needSidewalk
        case roads(remaining: Int) // сколько road полос еще нужно сгенерировать до следующего sidewalk
    }

    private var genPhase: GenerationPhase = .needSidewalk

    // MARK: - Init / Start
    init() {
        reset()
    }

    func reset() {
        isGameOver = false
        isRunning = true
        score = 0
        roadCrossCount = 0
        playerX = columns / 2
        playerRowIndex = 0

        lanes = []
        cars = []

        lanes.append(makeSidewalkLane())

        // После sidewalk обязаны быть дороги 1..3
        genPhase = .roads(remaining: Int.random(in: 1...3))

        while lanes.count < visibleRows {
            lanes.append(makeNextLane(distance: lanes.count))
        }

        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: baseTick, repeats: true) { [weak self] _ in
            self?.tick(dt: self?.baseTick ?? 0)
        }
    }

    // MARK: - Tick
    private func tick(dt: Double) {
        guard isRunning, !isGameOver else { return }

        // 1) Двигаем машины
        for i in cars.indices {
            cars[i].x += Double(cars[i].direction) * cars[i].speed * dt
        }

        // 2) Удаляем машины, которые ушли далеко за границы
        cars.removeAll { car in
            let wCells = Double(car.type.size.width) / Double(tileSize)
            return car.x < -wCells - 2.0 || car.x > Double(columns) + wCells + 2.0
        }

        // 3) Спавн машин в road lanes
        for idx in lanes.indices {
            if lanes[idx].type == .road {
                lanes[idx].spawnAccumulator += dt * lanes[idx].spawnRate
                while lanes[idx].spawnAccumulator >= 1.0 {
                    lanes[idx].spawnAccumulator -= 1.0
                    spawnCar(inLaneIndex: idx)
                }
            }
        }

        // 4) Проверка смерти
        checkDeath()
    }

    // MARK: - Управление (свайпы)
    func moveUp() {
        guard !isGameOver else { return }

            
        // нельзя выходить выше текущей верхушки? можно — мы добавим полосу при “камера вверх”
        // Игрок двигается на 1 полосу вверх
        let nextRow = playerRowIndex + 1
        
        guard nextRow < lanes.count else { return }
        
        if isBlocked(x: playerX, rowIndex: nextRow) {
            return
        }
        
        playerRowIndex = nextRow
        
        recenterWorldIfNeeded()
        updateScoreAfterMove()
        checkDeath()
    }

    func moveLeft() {
        guard !isGameOver else { return }
        let nx = playerX - 1
        guard nx >= 0 else { return }
        if isBlocked(x: nx, rowIndex: playerRowIndex) { return }
        playerX = nx
        checkDeath()
    }

    func moveRight() {
        guard !isGameOver else { return }
        let nx = playerX + 1
        guard nx < columns else { return }
        if isBlocked(x: nx, rowIndex: playerRowIndex) { return }
        playerX = nx
        checkDeath()
    }

    // MARK: - Логика камеры / бесконечность
    private func recenterWorldIfNeeded() {
        // Идея: если игрок поднялся слишком высоко (например выше середины экрана),
        // мы “сдвигаем мир вниз”: удаляем нижнюю полосу, добавляем новую сверху,
        // а игрок остается в видимой области.
        let threshold = visibleRows / 2
        if playerRowIndex >= threshold {
            // Сдвигаем: удаляем 1 нижнюю полосу
            lanes.removeFirst()

            // Машины, которые были в удаленной полосе, тоже надо удалить.
            // А у остальных скорректировать yIndex.
            cars = cars
                .filter { $0.yIndex != 0 }
                .map { car in
                    var c = car
                    c = Car(
                        x: car.x,
                        yIndex: car.yIndex - 1,
                        direction: car.direction,
                        speed: car.speed,
                        type: car.type,
                        imageName: car.imageName
                    )
                    return c
                }

            // Игрок “опускается” на 1 (потому что мы убрали низ)
            playerRowIndex -= 1

            // Добавляем новую полосу сверху
            let distance = (score + lanes.count) // условная “дальность”
            lanes.append(makeNextLane(distance: distance))
        }

        // Поддерживаем размер массива полос ровно visibleRows
        while lanes.count < visibleRows {
            lanes.append(makeNextLane(distance: lanes.count + score))
        }
        while lanes.count > visibleRows {
            lanes.removeFirst()
            cars = cars.filter { $0.yIndex != 0 }.map { Car(x: $0.x, yIndex: $0.yIndex - 1, direction: $0.direction, speed: $0.speed, type: $0.type, imageName: $0.imageName) }
            playerRowIndex = max(0, playerRowIndex - 1)
        }
    }

    // MARK: - Смерть / столкновения
    private func checkDeath() {
        guard !isGameOver else { return }
        let lane = lanes[safe: playerRowIndex]

        if deathOnAnyRoadLane, let lane, lane.type == .road {
            gameOver()
            return
        }

        // Rect игрока (центр клетки)
        let playerCenterX = (Double(playerX) + 0.5) * Double(tileSize)
        let playerCenterY = (Double(playerRowIndex) + 0.5) * Double(tileSize)

        // Размер игрока (подстрой под свой спрайт)
        let playerW = Double(tileSize) * 0.75
        let playerH = Double(tileSize) * 0.75

        let playerRect = CGRect(
            x: playerCenterX - playerW / 2,
            y: playerCenterY - playerH / 2,
            width: playerW,
            height: playerH
        )

        // Машины
        for car in cars where car.yIndex == playerRowIndex {
            let carCenterX = (car.x + 0.5) * Double(tileSize)
            let carCenterY = playerCenterY // та же полоса

            let w = Double(car.type.size.width)
            let h = Double(car.type.size.height)

            let carRect = CGRect(
                x: carCenterX - w / 2,
                y: carCenterY - h / 2,
                width: w,
                height: h
            )

            if playerRect.intersects(carRect) {
                gameOver()
                return
            }
        }
    }

    private func gameOver() {
        isGameOver = true
        isRunning = false
        if bestScore < score {
            bestScore = score
        }
        ZZUser.shared.updateUserMoney(for: score)
    }

    // MARK: - Очки “пройденных дорог”
    private func updateScoreAfterMove() {
        // Логика: считаем, сколько road lanes игрок “пересек” (прошел через них вверх).
        // Простой подход:
        // - Если игрок оказался на sidewalk, а полоса под ним была road/crosswalk — значит пересек дорогу.
        guard playerRowIndex > 0 else { return }
        let current = lanes[playerRowIndex]
        let below = lanes[playerRowIndex - 1]

        if (below.type == .road) && current.type == .sidewalk {
            roadCrossCount += 1
            score = roadCrossCount
        }
    }

    // MARK: - Блокировки препятствиями
    private func isBlocked(x: Int, rowIndex: Int) -> Bool {
        guard let lane = lanes[safe: rowIndex] else { return true }
        if lane.type == .sidewalk {
            return lane.obstacles.contains(where: { $0.x == x })
        }
        return false
    }

    // MARK: - Генерация полос
    private func makeNextLane(distance: Int) -> Lane {
        switch genPhase {

        case .needSidewalk:
            // Генерим тротуар (всегда одиночный)
            genPhase = .roads(remaining: Int.random(in: 1...3))
            return makeSidewalkLane()

        case .roads(let remaining):
            // Генерим дорогу, уменьшаем счетчик
            let nextRemaining = remaining - 1
            if nextRemaining <= 0 {
                genPhase = .needSidewalk
            } else {
                genPhase = .roads(remaining: nextRemaining)
            }
            return makeRoadLane(distance: distance)
        }
    }
    
//    private func makeRandomLane(distance: Int) -> Lane {
//        // distance влияет на сложность (скорость/частоту)
//        // Шанс дорожной полосы увеличим чуть-чуть
//        let roll = Int.random(in: 0...99)
//
//        if roll < 55 {
//            // road или crosswalk
//            let isCrosswalk = (Int.random(in: 0...9) == 0) // 10% переход
//            return makeRoadLane(distance: distance)
//        } else {
//            return makeSidewalkLane()
//        }
//    }

    private func makeSidewalkLane() -> Lane {
        var lane = Lane(
            type: .sidewalk,
            direction: 0,
            speed: 0,
            spawnRate: 0,
            spawnAccumulator: 0,
            obstacles: []
        )

        // Случайные препятствия (не в центре сразу)
        let count = Int.random(in: 0...2)
        var usedX: Set<Int> = []
        for _ in 0..<count {
            let x = Int.random(in: 0..<(columns))
            if usedX.contains(x) { continue }
            usedX.insert(x)
            lane.obstacles.append(Obstacle(x: x, type: ObstacleType.allCases.randomElement()!))
        }
        return lane
    }

    private func makeRoadLane(distance: Int) -> Lane {
        let dir = Bool.random() ? 1 : -1

        let baseSpeed = 2.0
        let speed = min(6.0, baseSpeed + Double(distance) * 0.05)

        let baseSpawn = 0.6
        let spawnRate = min(2.0, baseSpawn + Double(distance) * 0.01)

        // NEW: 0..2 клеток перехода
        // (если хочешь реже — уменьши вероятность)
        let count: Int
        let r = Int.random(in: 0...99)
        if r < 60 { count = 0 }       // 60% нет перехода
        else if r < 90 { count = 1 }  // 30% одна клетка
        else { count = 2 }            // 10% две клетки

        var xs: Set<Int> = []
        while xs.count < count {
            xs.insert(Int.random(in: 0..<columns))
        }

        return Lane(
            type: .road,
            direction: dir,
            speed: speed,
            spawnRate: spawnRate,
            spawnAccumulator: 0,
            obstacles: [],
            crosswalkXs: Array(xs).sorted()
        )
    }

    private func spawnCar(inLaneIndex idx: Int) {
        guard lanes.indices.contains(idx) else { return }
        let lane = lanes[idx]
        guard lane.type == .road else { return }

        // Выбор типа (можешь настроить вероятности)
        let roll = Int.random(in: 0...99)
        let vType: VehicleType
        if roll < 65 { vType = .car }          // 65%
        else if roll < 85 { vType = .minibus } // 20%
        else { vType = .bus }                  // 15%

        // случайная картинка из списка типа
        let chosenName = vType.imageNames.randomElement()

        // Спавним за границей экрана. Учитываем реальную ширину транспорта.
        let width = vType.size.width
        let startXPoints: Double
        if lane.direction == 1 {
            startXPoints = -Double(width) // слева за экраном
        } else {
            startXPoints = Double(columns) * Double(tileSize) + Double(width) // справа за экраном
        }

        // Важно: сейчас x у нас в "клетках" (Double). Для точных размеров удобнее перевести
        // машины на "поинты". Но чтобы не ломать всё, сделаем так:
        // x будет в поинтах / tileSize.
        let startX = startXPoints / Double(tileSize)

        let car = Car(
            x: startX,
            yIndex: idx,
            direction: lane.direction,
            speed: lane.speed,   // скорость в "клетках/сек" как раньше
            type: vType,
            imageName: chosenName
        )
        cars.append(car)
    }
}

// MARK: - Safe index helper
private extension Array {
    subscript(safe idx: Int) -> Element? {
        guard indices.contains(idx) else { return nil }
        return self[idx]
    }
}
