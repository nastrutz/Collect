import SwiftUI

struct WrapView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var data: Data
    var spacing: CGFloat = 8
    var content: (Data.Element) -> Content

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(data), id: \.self) { item in
                self.content(item)
                    .padding([.horizontal, .vertical], 4)
                    .background(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                if width + geo.size.width > geometry.size.width {
                                    width = 0
                                    height += geo.size.height + spacing
                                }
                                width += geo.size.width + spacing
                                totalHeight = max(totalHeight, height + geo.size.height)
                            }
                    })
                    .offset(x: width, y: height)
            }
        }
    }
}