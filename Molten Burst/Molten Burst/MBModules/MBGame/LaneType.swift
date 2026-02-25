import Foundation

enum LaneType: CaseIterable {
    case sidewalk   // безопасно, препятствия
    case road       // опасно, машины
    case crosswalk  // можно трактовать как road с рисунком перехода
}
