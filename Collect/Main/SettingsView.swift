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
    @AppStorage("disableSuggestedFolders") var disableSuggestedFolders: Bool = false
    @AppStorage("themeRed") var themeRed: Double = 0.0
    @AppStorage("themeGreen") var themeGreen: Double = 0.478
    @AppStorage("themeBlue") var themeBlue: Double = 1.0
    @AppStorage("hideBadgesManually") var hideBadgesManually: Bool = false
    @AppStorage("hideBadgeList") var hideBadgeList: Bool = false

    @State private var tempDisplayMode: DisplayMode
    @State private var tempEnableFolderLocking: Bool
    @State private var tempDisableSuggestedFolders: Bool
    @State private var tempThemeRed: Double
    @State private var tempThemeGreen: Double
    @State private var tempThemeBlue: Double
    @State private var tempHideBadgesManually: Bool
    @State private var tempHideBadgeList: Bool

    init() {
        let storedDisplayMode = UserDefaults.standard.string(forKey: "defaultDisplayMode")
        _tempDisplayMode = State(initialValue: DisplayMode(rawValue: storedDisplayMode ?? DisplayMode.nameAndImage.rawValue) ?? .nameAndImage)
        _tempEnableFolderLocking = State(initialValue: UserDefaults.standard.bool(forKey: "enableFolderLocking"))
        _tempDisableSuggestedFolders = State(initialValue: UserDefaults.standard.bool(forKey: "disableSuggestedFolders"))
        _tempThemeRed = State(initialValue: UserDefaults.standard.double(forKey: "themeRed"))
        _tempThemeGreen = State(initialValue: UserDefaults.standard.double(forKey: "themeGreen"))
        _tempThemeBlue = State(initialValue: UserDefaults.standard.double(forKey: "themeBlue"))
        _tempHideBadgesManually = State(initialValue: UserDefaults.standard.bool(forKey: "hideBadgesManually"))
        _tempHideBadgeList = State(initialValue: UserDefaults.standard.bool(forKey: "hideBadgeList"))
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
                        .tint(
                            (tempThemeRed == 0.0 && tempThemeGreen == 0.478 && tempThemeBlue == 1.0)
                            ? .green
                            : Color(red: tempThemeRed, green: tempThemeGreen, blue: tempThemeBlue)
                        )
                    Toggle("Disable Suggested Folders", isOn: $tempDisableSuggestedFolders)
                        .tint(
                            (tempThemeRed == 0.0 && tempThemeGreen == 0.478 && tempThemeBlue == 1.0)
                            ? .green
                            : Color(red: tempThemeRed, green: tempThemeGreen, blue: tempThemeBlue)
                        )
                    Toggle("Hide Highest Badge", isOn: $tempHideBadgesManually)
                        .tint(
                            (tempThemeRed == 0.0 && tempThemeGreen == 0.478 && tempThemeBlue == 1.0)
                            ? .green
                            : Color(red: tempThemeRed, green: tempThemeGreen, blue: tempThemeBlue)
                        )
                    Toggle("Hide Badge List", isOn: $tempHideBadgeList)
                        .tint(
                            (tempThemeRed == 0.0 && tempThemeGreen == 0.478 && tempThemeBlue == 1.0)
                            ? .green
                            : Color(red: tempThemeRed, green: tempThemeGreen, blue: tempThemeBlue)
                        )
                }
                Section(header: Text("Theme Color")) {
                    VStack {
                        Color(red: tempThemeRed, green: tempThemeGreen, blue: tempThemeBlue)
                            .frame(height: 40)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                            .padding(.bottom)

                        HStack {
                            Slider(value: $tempThemeRed, in: 0...1)
                                .accentColor(.red)
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray5))
                                TextField("0-255", value: Binding(
                                    get: { Int(tempThemeRed * 255) },
                                    set: { tempThemeRed = Double(min(max($0, 0), 255)) / 255 }
                                ), formatter: NumberFormatter())
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                            }
                            .frame(width: 50, height: 30)
                        }
                        HStack {
                            Slider(value: $tempThemeGreen, in: 0...1)
                                .accentColor(.green)
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray5))
                                TextField("0-255", value: Binding(
                                    get: { Int(tempThemeGreen * 255) },
                                    set: { tempThemeGreen = Double(min(max($0, 0), 255)) / 255 }
                                ), formatter: NumberFormatter())
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                            }
                            .frame(width: 50, height: 30)
                        }
                        HStack {
                            Slider(value: $tempThemeBlue, in: 0...1)
                                .accentColor(.blue)
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray5))
                                TextField("0-255", value: Binding(
                                    get: { Int(tempThemeBlue * 255) },
                                    set: { tempThemeBlue = Double(min(max($0, 0), 255)) / 255 }
                                ), formatter: NumberFormatter())
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                            }
                            .frame(width: 50, height: 30)
                        }
                    }
                }
                Section {
                    Button {
                        tempDisplayMode = .nameAndImage
                        tempEnableFolderLocking = true
                        tempDisableSuggestedFolders = false
                        tempThemeRed = 0.0
                        tempThemeGreen = 0.478
                        tempThemeBlue = 1.0
                        tempHideBadgesManually = false
                        tempHideBadgeList = false
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset Settings")
                            Spacer()
                        }
                    }
                    .foregroundColor(.red)

                    Button {
                        tempThemeRed = 0.0
                        tempThemeGreen = 0.478
                        tempThemeBlue = 1.0
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset Theme Color")
                            Spacer()
                        }
                    }
                    .foregroundColor(.red)
                    
                    Button {
                        UserDefaults.standard.removeObject(forKey: "badge5Unlocked")
                        UserDefaults.standard.removeObject(forKey: "badge10Unlocked")
                        UserDefaults.standard.removeObject(forKey: "badge20Unlocked")
                        UserDefaults.standard.removeObject(forKey: "hideBadges")
                        // Force refresh by reassigning all @AppStorage-bound values
                        UserDefaults.standard.set(false, forKey: "badge5Unlocked")
                        UserDefaults.standard.set(false, forKey: "badge10Unlocked")
                        UserDefaults.standard.set(false, forKey: "badge20Unlocked")
                        UserDefaults.standard.set(false, forKey: "hideBadges")
                        UserDefaults.standard.set(0, forKey: "totalItemsCollected")
                        NotificationCenter.default.post(name: Notification.Name("ResetBadgesNotification"), object: nil)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset Badge Progress")
                            Spacer()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        UserDefaults.standard.set(tempDisplayMode.rawValue, forKey: "defaultDisplayMode")
                        UserDefaults.standard.set(tempEnableFolderLocking, forKey: "enableFolderLocking")
                        UserDefaults.standard.set(tempDisableSuggestedFolders, forKey: "disableSuggestedFolders")
                        UserDefaults.standard.set(tempThemeRed, forKey: "themeRed")
                        UserDefaults.standard.set(tempThemeGreen, forKey: "themeGreen")
                        UserDefaults.standard.set(tempThemeBlue, forKey: "themeBlue")
                        UserDefaults.standard.set(tempHideBadgesManually, forKey: "hideBadgesManually")
                        UserDefaults.standard.set(tempHideBadgeList, forKey: "hideBadgeList")
                        dismiss()
                    }
                    .foregroundColor(Color(red: tempThemeRed, green: tempThemeGreen, blue: tempThemeBlue))
                }
            }
        }
    }
}
