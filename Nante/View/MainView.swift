//
//  MainView.swift
//  Nante
//
//  Created by 谷内洋介 on 2023/08/27.
//
import SwiftUI

struct MainView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @EnvironmentObject var currentState: CurrentState
    @EnvironmentObject var audioList: AudioList
    @EnvironmentObject var user: User

    var body: some View {
        Group {
            if (!currentState.options.contains(.hasShownLogo)) {
                LogoView()
            } else if(!currentState.options.contains(.hasLoggedIn)){
                LoginView()
            } else if(currentState.options.contains(.isPlayer)){
                AudioPlayerView()
                    .environmentObject(audioList)
                    .environmentObject(currentState)
                    .environmentObject(audioPlayer)
            } else {
                TabSelectionView()
                    .environmentObject(user)
                    .environmentObject(currentState)
            }
        }
    }
}
