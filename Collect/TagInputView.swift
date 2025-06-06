//
//  TagInputView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/6/25.
//

import SwiftUI

struct TagInputView: View {
    @Binding var tagInput: String
    @Binding var tagInputTags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Enter tags", text: $tagInput)
                    .onChange(of: tagInput) { oldValue, newValue in
                        if newValue.contains(" ") || newValue.contains(",") {
                            let parts = newValue
                                .split(whereSeparator: { $0 == " " || $0 == "," })
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                .filter { !$0.isEmpty }
                            for tag in parts {
                                if !tagInputTags.contains(tag) {
                                    tagInputTags.append(tag)
                                }
                            }
                            tagInput = ""
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minWidth: 0, maxWidth: .infinity)

                Button(action: {
                    tagInput = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .opacity(tagInput.isEmpty ? 0 : 1)
            }
            .padding(.horizontal, 40)

            WrapView(data: tagInputTags, spacing: 8) { tag in
                HStack(spacing: 4) {
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                    Button(action: {
                        tagInputTags.removeAll { $0 == tag }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(4)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .fixedSize()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 40)
        }
    }
}