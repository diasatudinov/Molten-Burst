//
//  IFSettingsViewModel.swift
//  Molten Burst
//
//


import SwiftUI

class MBSettingsViewModel: ObservableObject {
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("musicEnabled") var musicEnabled: Bool = true

}
