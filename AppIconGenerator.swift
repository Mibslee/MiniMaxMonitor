import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 128, height: 128)
            
            Circle()
                .stroke(Color.green, lineWidth: 6)
                .frame(width: 100, height: 100)
            
            Text("m")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.green)
        }
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
            .previewLayout(.sizeThatFitsLayout)
            .exportedAsImage(filename: "AppIcon")
    }
}

extension View {
    func exportedAsImage(filename: String) -> some View {
        self.exportAsImage(filename: filename)
    }
    
    @MainActor
    func exportAsImage(filename: String) -> some View {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 2.0
        
        if let image = renderer.nsImage {
            saveImage(image, filename: filename)
        }
        
        return self
    }
    
    @MainActor
    private func saveImage(_ image: NSImage, filename: String) {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return
        }
        
        let url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
            .appendingPathComponent("\(filename).png")
        
        try? pngData.write(to: url)
    }
}