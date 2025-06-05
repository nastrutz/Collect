//
//  FolderDetailView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI

struct FolderDetailView: View {
    @AppStorage("themeRed") private var themeRed: Double = 0.0
    @AppStorage("themeGreen") private var themeGreen: Double = 0.478
    @AppStorage("themeBlue") private var themeBlue: Double = 1.0

    let folder: Folder
    let folders: [Folder]

    @State private var displayMode: DisplayMode = .nameAndImage
    @State private var showingFolderSettings = false

    enum DisplayMode: String, CaseIterable, Identifiable {
        case nameOnly = "Name"
        case nameAndImage = "Name + Image"
        case imageOnly = "Image"
        
        var id: String { rawValue }
    }

    var body: some View {
        Group {
            switch displayMode {
            case .nameOnly:
                List {
                    ForEach(folder.items) { item in
                        NavigationLink(destination: ItemDetailView(folders: folders, item: item)) {
                            Text(item.name)
                                .font(.body)
                        }
                    }
                }

            case .nameAndImage:
                List {
                    ForEach(folder.items) { item in
                        NavigationLink(destination: ItemDetailView(folders: folders, item: item)) {
                            HStack {
                                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Text(item.name)
                                    .font(.body)
                            }
                        }
                    }
                }

            case .imageOnly:
                ItemGridView(items: folder.items)
            }
        }
        .navigationTitle(folder.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Picker("View", selection: $displayMode) {
                    ForEach(DisplayMode.allCases) { mode in
                        Image(systemName: {
                            switch mode {
                            case .nameOnly: return "line.3.horizontal"
                            case .nameAndImage: return "list.bullet"
                            case .imageOnly: return "square.grid.2x2"
                            }
                        }()).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFolderSettings = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(Color(red: themeRed, green: themeGreen, blue: themeBlue))
                }
            }
        }
        .sheet(isPresented: $showingFolderSettings) {
            FolderSettingsView(folder: folder, isPresented: $showingFolderSettings)
        }
    }
}


struct FolderSettingsView: View {
    @AppStorage("themeRed") private var themeRed: Double = 0.0
    @AppStorage("themeGreen") private var themeGreen: Double = 0.478
    @AppStorage("themeBlue") private var themeBlue: Double = 1.0

    @ObservedObject var folder: Folder
    @Binding var isPresented: Bool
    @State private var updatedFolderName: String
    @State private var useFaceID: Bool

    init(folder: Folder, isPresented: Binding<Bool>) {
        self.folder = folder
        self._isPresented = isPresented
        _updatedFolderName = State(initialValue: folder.name)
        _useFaceID = State(initialValue: folder.isLocked)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Settings")) {
                    TextField("Folder Name", text: $updatedFolderName)
                    Toggle("Lock with Face ID", isOn: $useFaceID)
                }
            }
            .navigationTitle("Info/Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        folder.name = updatedFolderName
                        folder.isLocked = useFaceID
                        isPresented = false
                    }
                }
            }
        }
        .tint(
            (themeRed == 0.0 && themeGreen == 0.478 && themeBlue == 1.0)
            ? .blue
            : Color(red: themeRed, green: themeGreen, blue: themeBlue)
        )
    }
}
