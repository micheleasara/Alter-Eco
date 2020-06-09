import SwiftUI

public struct ImagePicker: UIViewControllerRepresentable{
    @Environment(\.presentationMode) var presentationMode
    private var callback: ((UIImage?) -> Void)!
    
    public init(onCompletionCallback: @escaping (UIImage?) -> Void) {
        callback = onCompletionCallback
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(callback: { image in
            self.presentationMode.wrappedValue.dismiss()
            self.callback(image)
        })
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private var callback: ((UIImage?) -> Void)!
        
        init(callback: @escaping (UIImage?) -> Void) {
            self.callback = callback
        }
        
        public func imagePickerController(_ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                callback(uiImage)
            }
        }
    }
}
