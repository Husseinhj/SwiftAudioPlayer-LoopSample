//
//  ContentView.swift
//  Shared
//
//  Created by husseinhj on 8/8/21.
//

import SwiftUI
import SwiftAudioPlayer

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello, world!")
                    .padding()
                
                Button(action: {
                    guard let path = Bundle.main.path(forResource: "sample", ofType:"mp3") else {
                        return }
                    let url = URL(fileURLWithPath: path)
                    
                    SAPlayer.shared.setStartTime(at: 0.0)
                    SAPlayer.shared.setEndTime(at: 5.0)
                    SAPlayer.shared.play(url: url)
                }, label: {
                    Text("Play loop")
                })
                
                Button(action: {
                    SAPlayer.shared.pause()
                }, label: {
                    Text("Pause")
                })
            }
            
        }.onAppear(perform: {
            _ = SAPlayer.Updates.PlayingStatus.subscribe({ url, state in
                print("Player status \(state)")
            })
            
            _ = SAPlayer.Updates.ElapsedTime.subscribe({ url, time in
                print("Player ElapsedTime \(time)")
                
            })
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

var elpasedSub: UInt?
var endTime: Double = -1
var startTime: Double = 0

extension SAPlayer {
    
    func setStartTime(at: Double) {
        startTime = at
        SAPlayer.shared.seekTo(seconds: at)
    }
    
    func setEndTime(at: Double) {
        endTime = at
    }
    
    func play(url: URL) {
        if elpasedSub != nil {
            SAPlayer.Updates.ElapsedTime.unsubscribe(elpasedSub!)
        }
        elpasedSub = SAPlayer.Updates.ElapsedTime.subscribe({ url, time in
            if time >= endTime && endTime > -1 {
                SAPlayer.shared.seekTo(seconds: startTime)
            }
        })
        
        SAPlayer.shared.startSavedAudio(withSavedUrl: url)
        SAPlayer.shared.play()
    }
}
