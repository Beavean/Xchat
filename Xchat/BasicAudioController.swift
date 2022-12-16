//
//  BasicAudioController.swift
//  Xchat
//
//  Created by Beavean on 06.12.2022.
//

import Foundation
import AVFoundation
import MessageKit

enum PlayerState {
    case playing
    case pause
    case stopped
}

final class BasicAudioController: NSObject, AVAudioPlayerDelegate {

    var audioPlayer: AVAudioPlayer?
    weak var playingCell: AudioMessageCell?
    var playingMessage: MessageType?
    private(set) var state: PlayerState = .stopped
    weak var messageCollectionView: MessagesCollectionView?
    var progressTimer: Timer?

    // MARK: - Init Methods

    public init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }

    // MARK: - Methods

    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if playingMessage?.messageId == message.messageId, let collectionView = messageCollectionView, let player = audioPlayer {
            playingCell = cell
            cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
            cell.playButton.isSelected = (player.isPlaying == true) ? true : false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
        }
    }

    func playSound(for message: MessageType, in audioCell: AudioMessageCell) {
        switch message.kind {
        case .audio(let item):
            playingCell = audioCell
            playingMessage = message
            guard let player = try? AVAudioPlayer(contentsOf: item.url) else {
                print("Failed to create audio player for URL: \(item.url)")
                return
            }
            audioPlayer = player
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            audioPlayer?.play()
            state = .playing
            audioCell.playButton.isSelected = true
            startProgressTimer()
            audioCell.delegate?.didStartAudio(in: audioCell)
        default:
            print("BasicAudioPlayer failed play sound because given message kind is not Audio")
        }
    }

    func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        audioPlayer?.pause()
        state = .pause
        audioCell.playButton.isSelected = false
        progressTimer?.invalidate()
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }

    func stopAnyOngoingPlaying() {
        guard let player = audioPlayer, let collectionView = messageCollectionView else { return }
        player.stop()
        state = .stopped
        if let cell = playingCell {
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.duration), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        progressTimer?.invalidate()
        progressTimer = nil
        audioPlayer = nil
        playingMessage = nil
        playingCell = nil
    }

    func resumeSound() {
        guard let player = audioPlayer, let cell = playingCell else {
            stopAnyOngoingPlaying()
            return
        }
        player.prepareToPlay()
        player.play()
        state = .playing
        startProgressTimer()
        cell.playButton.isSelected = true
        cell.delegate?.didStartAudio(in: cell)
    }

    // MARK: - Fire Methods

    @objc private func didFireProgressTimer(_ timer: Timer) {
        guard let player = audioPlayer, let collectionView = messageCollectionView, let cell = playingCell else {
            return
        }
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            if let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView), currentMessage.messageId == playingMessage?.messageId {
                cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
            } else {
                stopAnyOngoingPlaying()
            }
        }
    }

    // MARK: - Private Methods

    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BasicAudioController.didFireProgressTimer(_:)), userInfo: nil, repeats: true)
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAnyOngoingPlaying()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopAnyOngoingPlaying()
    }

}
