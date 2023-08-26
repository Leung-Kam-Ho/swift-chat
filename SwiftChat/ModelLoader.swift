//
//  ModelLoader.swift
//  SwiftChat
//
//  Created by Pedro Cuenca on 5/5/23.
//

import CoreML
import Path
import Models

class ModelLoader {
    static let models = Path.applicationSupport / "swiftChat-compiled-transformers"
    static let lastCompiledModel = models / "last-model.mlmodelc"
        
    static func load(url: URL? = nil, compiledURL : URL? = nil) async throws -> LanguageModel {
        
        if let url = url {
            print("Compiling model \(url)")
            let compiledURL = try await MLModel.compileModel(at: url)
            
            // Cache compiled (keep last one only)
//            try models.delete()
            let compiledPath = models / url.deletingPathExtension().appendingPathExtension("mlmodelc").lastPathComponent
//            let compiledPath = lastCompiledModel
            
            try ModelLoader.models.mkdir(.p)
            try Path(url: compiledURL)?.move(to: compiledPath, overwrite: true)
            
            // Create symlink (alternative: store name in UserDefaults)
//            try compiledPath.symlink(as: lastCompiledModel)
            return try LanguageModel.loadCompiled(url: compiledPath.url, computeUnits: .all)
        }
        
        // Load last model used (or the one we just compiled)
        var lastURL = lastCompiledModel.url
        
        if let compiledURL = compiledURL{
            lastURL = compiledURL
        }
        
        
//        try print(lastCompiledModel.readlink())
        return try LanguageModel.loadCompiled(url: lastURL, computeUnits: .all)
    }
}

import Combine

extension LanguageModel: ObservableObject {}
