//
//  LaneType.swift
//  Molten Burst
//
//  Created by Dias Atudinov on 24.02.2026.
//


import Foundation

enum LaneType: CaseIterable {
    case sidewalk   // безопасно, препятствия
    case road       // опасно, машины
}

enum ObstacleType: CaseIterable {
    case box, tree, hydrant

    var imageName: String {
        switch self {
        case .box: return "ob_box"
        case .tree: return "ob_tree"
        case .hydrant: return "ob_hydrant"
        }
    }

    var fallbackColor: Color {
        switch self {
        case .box: return .brown
        case .tree: return .green
        case .hydrant: return .cyan
        }
    }
}

struct Obstacle: Identifiable, Hashable {
    let id = UUID()
    let x: Int
    let type: ObstacleType
}

struct Car: Identifiable, Hashable {
    let id = UUID()
    var x: Double
    let yIndex: Int
    let direction: Int
    let speed: Double

    let type: VehicleType
    let imageName: String?
}

import Foundation

struct Lane: Identifiable {
    let id = UUID()
    let type: LaneType

    // Для road:
    let direction: Int
    let speed: Double
    let spawnRate: Double
    var spawnAccumulator: Double = 0

    // Для sidewalk:
    var obstacles: [Obstacle] = []

    // NEW: клетки перехода на этой дорожной линии (макс 2)
    var crosswalkXs: [Int] = []
}

import SwiftUI

enum VehicleType: CaseIterable {
    case car
    case bus
    case minibus

    var size: CGSize {
        switch self {
        case .car:     return CGSize(width: 54,  height: 39)
        case .bus:     return CGSize(width: 104, height: 46)
        case .minibus: return CGSize(width: 72,  height: 46)
        }
    }

    /// Имена ассетов. Можешь добавить несколько вариантов — будет рандом.
    var imageNames: [String] {
        switch self {
        case .car:
            return ["car_1"]
        case .bus:
            return ["bus_1"]
        case .minibus:
            return ["minibus_1"]
        }
    }

    /// Цвет для фолбэка (если картинки нет)
    var fallbackColor: Color {
        switch self {
        case .car: return .red
        case .bus: return .yellow
        case .minibus: return .orange
        }
    }
}
