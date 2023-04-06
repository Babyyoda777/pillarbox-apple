//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct TwinsView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var mode: Mode = .both

    private var topPlayer: Player {
        mode != .bottom ? player : Player(configuration: .externalPlaybackDisabled)
    }

    private var bottomPlayer: Player {
        mode != .top ? player : Player(configuration: .externalPlaybackDisabled)
    }

    var body: some View {
        VStack(spacing: 10) {
            Group {
                BasicPlaybackView(player: topPlayer)
                BasicPlaybackView(player: bottomPlayer)
            }
            .background(.black)

            Picker("Mode", selection: $mode) {
                Text("Both").tag(Mode.both)
                Text("Top").tag(Mode.top)
                Text("Bottom").tag(Mode.bottom)
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .onAppear(perform: play)
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

private extension TwinsView {
    enum Mode {
        case both
        case top
        case bottom
    }
}

struct TwinsView_Previews: PreviewProvider {
    static var previews: some View {
        TwinsView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}