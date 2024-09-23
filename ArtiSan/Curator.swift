//
//  Curator.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/22/24.
//

import Foundation
import AppKit
import SwiftUI

/// A helper class that handles downloading  full resolution images for display and saving images to disk.
class Curator {
    
    /// Opens the system save panel
    @MainActor
    func savePanel(name: String) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.jpeg, .image]
        savePanel.canCreateDirectories = false
        savePanel.isExtensionHidden = false
        savePanel.nameFieldStringValue = name
        savePanel.title = "Save Album Art"
        
        return savePanel.runModal() == .OK ? savePanel.url : nil
    }
    
    /// Downloads full resolution album art and returns a tuple with an NSImage suitable for saving and an Image suitable for display
    @MainActor
    func downloadImage(from url: URL) async -> (NSImage, Image)? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            guard let nsImage = NSImage(data: data) else { return nil }
            let image = Image(nsImage: nsImage)
            return (nsImage, image)
        } catch {
            return nil
        }
    }
    
    /// Creates a filename string by combining the album title without spaces and the downloaded image resolution, separated by an underscore.
    func getImageFileName(from image: NSImage?, with name: String) -> String {
        guard let image else { return ""}
        var newName = name.replacingOccurrences(of: " ", with: "")
        newName = newName + "_\(Int(image.size.width))x\(Int(image.size.height))"
        return newName
    }
    
    /// Saves a downloaded image to disk. For use with a save panel.
    @MainActor
    func saveImage(image: NSImage?, path: URL) async {
        guard let imageToSave = image else { return }
        let imageRepresentation = NSBitmapImageRep(data: imageToSave.tiffRepresentation!)
        let jpegData = imageRepresentation?.representation(using: .jpeg, properties: [:])
        do {
            try jpegData!.write(to: path)
        } catch {
            print (error)
        }
    }
}
