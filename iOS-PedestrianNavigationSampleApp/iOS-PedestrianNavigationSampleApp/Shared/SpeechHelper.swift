//
//  SpeechHelper.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/2/24.
//

import Foundation
import AVFoundation

final class SpeechHelper: NSObject {
    
    let synchronizer: AVSpeechSynthesizer
    var utterance: AVSpeechUtterance!
    
    init(synchronizer: AVSpeechSynthesizer = AVSpeechSynthesizer(),
         utterance: AVSpeechUtterance = AVSpeechUtterance()) {
        self.synchronizer = synchronizer
        self.utterance = utterance
    }
    
    func speak(_ text: String) {
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synchronizer.speak(utterance)
    }
}
