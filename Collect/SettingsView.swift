//
//  SettingsView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/4/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("defaultDisplayMode") var defaultDisplayMode: DisplayMode = .nameAndImage
    @AppStorage("enableFolderLocking") var enableFolderLocking: Bool = true

    @State private var tempDisplayMode: DisplayMode
    @State private var tempEnableFolderLocking: Bool

    init() {
        let storedDisplayMode = UserDefaults.standard.string(forKey: "defaultDisplayMode")
        _tempDisplayMode = State(initialValue: DisplayMode(rawValue: storedDisplayMode ?? DisplayMode.nameAndImage.rawValue) ?? .nameAndImage)
        _tempEnableFolderLocking = State(initialValue: UserDefaults.standard.bool(forKey: "enableFolderLocking"))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("App Settings")) {
                    Picker("Default View Mode", selection: $tempDisplayMode) {
                        ForEach(DisplayMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }

                    Toggle("Enable Folder Locking", isOn: $tempEnableFolderLocking)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        UserDefaults.standard.set(tempDisplayMode.rawValue, forKey: "defaultDisplayMode")
                        UserDefaults.standard.set(tempEnableFolderLocking, forKey: "enableFolderLocking")
                        dismiss()
                    }
                }
            }
        }
    }
}
