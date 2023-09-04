//
//  Audio.swift
//  Nante
//
//  Created by 谷内洋介 on 2023/09/03.
//

import Foundation


class ProgressModel: ObservableObject {
    @Published var value: Float = 0.0
}

// 仮の音源メタデータの構造体
class Audio: Identifiable, Equatable, ObservableObject {
    let id = UUID()
    let title: String
    let resourceURL: URL
    let publishDate: Date
    let platformSpecificMetadata: String
    var transription: Transcription?
    var progress = ProgressModel()
    init(_ resourceURL: URL, _ title: String, _ publishDate: Date, _ platformSpecificMetadata: String){
        self.resourceURL = resourceURL
        self.title = title
        self.publishDate = publishDate
        self.platformSpecificMetadata = platformSpecificMetadata
    }
    static func == (leftHandSide: Audio, rightHandSide: Audio) -> Bool {
            return leftHandSide.id == rightHandSide.id
    }
}

class AudioList {
    @Published var items: [Audio]? = nil
    @Published var selectionIndex: Int? = nil
    func insert(_ audio: Audio){
        if var unwrappedItems = items {
            unwrappedItems.insert(audio, at:0)
            items = unwrappedItems
        } else {
            // FirstSpeech
            items = [audio]
        }
    }
}
