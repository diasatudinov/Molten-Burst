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

    private var timer: Timer?
    private var roadCrossCount: Int = 0 // для подсчета “сколько дорог пересек”

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

        // Создадим стартовый набор полос (снизу вверх)
        // Нижняя — sidewalk (безопасная)
        lanes.append(makeSidewalkLane())
        // Далее немного полос
        while lanes.count < visibleRows {
            lanes.append(makeRandomLane(distance: lanes.count))
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
            car.x < -2.0 || car.x > Double(columns) + 2.0
        }

        // 3) Спавн машин в road lanes
        for idx in lanes.indices {
            if lanes[idx].type == .road || lanes[idx].type == .crosswalk {
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
        if nextRow < lanes.count {
            playerRowIndex = nextRow
        }

        // После движения вверх: “камера” едет так, чтобы игрок оставался ближе к низу,
        // а мир генерировался сверху.
        recenterWorldIfNeeded()

        // Подсчет очков: “количество успешно пройденных дорог”
        // Засчитываем, если игрок перешел на safe lane после road,
        // или можно проще: увеличивать за каждый шаг вверх. Ниже — вариант именно “дороги”.
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
                    c = Car(x: c.x, yIndex: c.yIndex - 1, direction: c.direction, speed: c.speed)
                    return c
                }

            // Игрок “опускается” на 1 (потому что мы убрали низ)
            playerRowIndex -= 1

            // Добавляем новую полосу сверху
            let distance = (score + lanes.count) // условная “дальность”
            lanes.append(makeRandomLane(distance: distance))
        }

        // Поддерживаем размер массива полос ровно visibleRows
        while lanes.count < visibleRows {
            lanes.append(makeRandomLane(distance: lanes.count + score))
        }
        while lanes.count > visibleRows {
            lanes.removeFirst()
            cars = cars.filter { $0.yIndex != 0 }.map { Car(x: $0.x, yIndex: $0.yIndex - 1, direction: $0.direction, speed: $0.speed) }
            playerRowIndex = max(0, playerRowIndex - 1)
        }
    }

    // MARK: - Смерть / столкновения
    private func checkDeath() {
        guard !isGameOver else { return }
        let lane = lanes[safe: playerRowIndex]

        // Вариант А: смерть просто за то, что стоишь в road полосе
        if deathOnAnyRoadLane, let lane, (lane.type == .road || lane.type == .crosswalk) {
            gameOver()
            return
        }

        // Вариант Б: смерть при совпадении клетки игрока с машиной
        // Машины движутся по x (Double). Считаем, что машина занимает 1 клетку по ширине.
        let px = playerX
        let pr = playerRowIndex
        for car in cars where car.yIndex == pr {
            let carCell = Int(round(car.x))
            if carCell == px {
                gameOver()
                return
            }
        }
    }

    private func gameOver() {
        isGameOver = true
        isRunning = false
    }

    // MARK: - Очки “пройденных дорог”
    private func updateScoreAfterMove() {
        // Логика: считаем, сколько road lanes игрок “пересек” (прошел через них вверх).
        // Простой подход:
        // - Если игрок оказался на sidewalk, а полоса под ним была road/crosswalk — значит пересек дорогу.
        guard playerRowIndex > 0 else { return }
        let current = lanes[playerRowIndex]
        let below = lanes[playerRowIndex - 1]

        if (below.type == .road || below.type == .crosswalk) && current.type == .sidewalk {
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
    private func makeRandomLane(distance: Int) -> Lane {
        // distance влияет на сложность (скорость/частоту)
        // Шанс дорожной полосы увеличим чуть-чуть
        let roll = Int.random(in: 0...99)

        if roll < 55 {
            // road или crosswalk
            let isCrosswalk = (Int.random(in: 0...9) == 0) // 10% переход
            return makeRoadLane(distance: distance, type: isCrosswalk ? .crosswalk : .road)
        } else {
            return makeSidewalkLane()
        }
    }

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

    private func makeRoadLane(distance: Int, type: LaneType) -> Lane {
        let dir = Bool.random() ? 1 : -1

        // скорость растет с distance
        // baseSpeed = 2.0 клетки/сек, дальше растет до ~6
        let baseSpeed = 2.0
        let speed = min(6.0, baseSpeed + Double(distance) * 0.05)

        // spawnRate тоже немного растет
        let baseSpawn = 0.6
        let spawnRate = min(2.0, baseSpawn + Double(distance) * 0.01)

        return Lane(
            type: type,
            direction: dir,
            speed: speed,
            spawnRate: spawnRate,
            spawnAccumulator: 0,
            obstacles: []
        )
    }

    private func spawnCar(inLaneIndex idx: Int) {
        guard lanes.indices.contains(idx) else { return }
        let lane = lanes[idx]
        guard lane.type == .road || lane.type == .crosswalk else { return }

        // Спавним за границей экрана
        let startX: Double = (lane.direction == 1) ? -1.0 : Double(columns) + 1.0

        // Можно добавить правило “не спавнить слишком близко к другой машине в той же lane”
        // но в твоем ТЗ машины не сталкиваются и не останавливаются — это ок.
        let car = Car(
            x: startX,
            yIndex: idx,
            direction: lane.direction,
            speed: lane.speed
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