import SwiftUI

struct TestRow: View {
    let filename: String
    let newName: String?
    
    var body: some View {
        HStack(spacing: 0) {
            // Left
            HStack {
                Text("1.")
                Image(systemName: "photo")
                Text(filename)
                Spacer()
            }
            .frame(width: 300)
            .border(Color.red)
            
            // Right
            HStack {
                if let new = newName {
                    Image(systemName: "checkmark.circle")
                    Text(new)
                }
                Spacer()
            }
            .frame(width: 300)
            .border(Color.blue)
        }
    }
}

print("This would show: photo1.jpg and Photo_001.jpg")
