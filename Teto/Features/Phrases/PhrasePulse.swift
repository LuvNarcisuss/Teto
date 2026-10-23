import AVFoundation
import UIKit

/// The practice transport owns source position. Video and count highlights share its host anchor.
/// Video readiness gates starting a segment; video progress never advances this clock.
@MainActor
final class PhraseLessonClock {
    var prepare: ((TimeInterval, ClosedRange<TimeInterval>, Float, @escaping (Bool) -> Void) -> Void)?
    var onStart: ((TimeInterval, Float, TimeInterval) -> Void)?
    var onTime: ((TimeInterval) -> Void)?
    var onStopped: (() -> Void)?
    var onFailed: (() -> Void)?
    var onPickup: ((Int?) -> Void)?
    var onClickFailed: (() -> Void)?
    private(set) var pickup: Int?
    private var pickupInterval: TimeInterval = 0.75
    private let pickupTone = PhraseClickTone()
    private(set) var isPlaying = false
    private(set) var isPreparing = false
    private var ranges: [ClosedRange<TimeInterval>] = []
    private var segment = 0
    private var rate: Float = 1
    private var repeats = false
    private var anchorSource: TimeInterval = 0
    private var anchorHost: TimeInterval = 0
    private var generation = 0
    private var timer: DispatchSourceTimer?

    var currentTime: TimeInterval {
        guard isPlaying, !isPreparing, ranges.indices.contains(segment) else { return anchorSource }
        return min(ranges[segment].upperBound, anchorSource + max(0, Self.hostTime - anchorHost) * Double(rate))
    }

    /// Source ranges exclude their upper endpoint. Keep a paused highlight inside its segment,
    /// while retaining the exact transport endpoint for continuation or looping.
    var cueTime: TimeInterval {
        guard ranges.indices.contains(segment) else { return currentTime }
        return min(currentTime, ranges[segment].upperBound.nextDown)
    }

    private static var hostTime: TimeInterval { CMClockGetTime(CMClockGetHostTimeClock()).seconds }

    func play(
        ranges: [ClosedRange<TimeInterval>], rate: Float, loop: Bool, from time: TimeInterval,
        pickupBeatDuration: TimeInterval = 0.75
    ) {
        pause()
        guard !ranges.isEmpty, time.isFinite, rate.isFinite, rate > 0,
              ranges.allSatisfy({ $0.lowerBound.isFinite && $0.upperBound.isFinite && $0.lowerBound < $0.upperBound })
        else { return }
        let interval = pickupBeatDuration / Double(rate)
        guard pickupBeatDuration.isFinite, pickupBeatDuration > 0, interval.isFinite, interval > 0 else { return }
        pickupInterval = interval
        self.ranges = ranges
        self.rate = rate
        repeats = loop
        if let index = ranges.firstIndex(where: { time < $0.upperBound }) {
            segment = index
            anchorSource = max(ranges[index].lowerBound, time)
        } else {
            segment = 0
            anchorSource = ranges[0].lowerBound
        }
        isPlaying = true
        prepareSegment(withPickup: true)
    }

    func pause() {
        let position = currentTime
        generation += 1
        timer?.cancel()
        timer = nil
        isPlaying = false
        isPreparing = false
        anchorSource = position
        pickupTone.stop()
        setPickup(nil)
    }

    func position(at time: TimeInterval) {
        pause()
        ranges = []
        segment = 0
        anchorSource = time
        onTime?(time)
    }

    private func prepareSegment(withPickup: Bool) {
        generation += 1
        let request = generation
        isPreparing = true
        timer?.cancel()
        timer = nil
        onTime?(anchorSource)
        guard isPlaying, generation == request else { return }
        guard let prepare else { fail(); return }
        prepare(anchorSource, ranges[segment], rate) { [weak self] ready in
            guard let self, self.isPlaying, self.generation == request else { return }
            guard ready else { self.fail(); return }
            if withPickup {
                if !self.pickupTone.prepare(configureAmbientSession: false) {
                    self.onClickFailed?()
                }
                guard self.isPlaying, self.generation == request else { return }
                self.advancePickup(5, request: request)
            } else {
                self.startSegment(request: request)
            }
        }
    }

    /// Each number gets a full interval, including 8; source time stays fixed until the next 1.
    private func advancePickup(_ number: Int, request: Int) {
        guard isPlaying, generation == request else { return }
        timer?.cancel()
        timer = nil
        guard number <= 8 else {
            pickupTone.stop()
            setPickup(nil)
            startSegment(request: request)
            return
        }
        setPickup(number)
        guard isPlaying, generation == request else { return }
        pickupTone.play(strong: number == 5)
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + pickupInterval)
        timer.setEventHandler { [weak self] in self?.advancePickup(number + 1, request: request) }
        self.timer = timer
        timer.resume()
    }

    private func setPickup(_ value: Int?) {
        guard pickup != value else { return }
        pickup = value
        onPickup?(value)
    }

    private func startSegment(request: Int) {
        guard isPlaying, generation == request else { return }
        anchorHost = Self.hostTime
        isPreparing = false
        onStart?(anchorSource, rate, anchorHost)
        guard isPlaying, generation == request else { return }
        onTime?(anchorSource)
        guard isPlaying, generation == request else { return }
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(20))
        timer.setEventHandler { [weak self] in
            guard let self, self.generation == request else { return }
            self.tick()
        }
        self.timer = timer
        timer.resume()
    }

    private func tick() {
        guard isPlaying, !isPreparing else { return }
        let time = currentTime
        if time >= ranges[segment].upperBound {
            segment += 1
            let restartsLoop = segment == ranges.count && repeats
            if segment == ranges.count {
                if repeats { segment = 0 }
                else {
                    anchorSource = ranges[ranges.count - 1].upperBound
                    pause()
                    onTime?(anchorSource)
                    onStopped?()
                    return
                }
            }
            anchorSource = ranges[segment].lowerBound
            prepareSegment(withPickup: restartsLoop)
        } else {
            onTime?(time)
        }
    }

    private func fail() {
        pause()
        onFailed?()
    }

    deinit { timer?.cancel() }
}

struct PhraseBeat {
    var eightIndex: Int
    var count: Int
    var pickup: Int?
}

/// A count click for one open phrase. The highlight still advances when the tone cannot start.
@MainActor
final class PhrasePulse {
    private(set) var isPlaying = false
    private var timer: DispatchSourceTimer?
    private let tone = PhraseClickTone()
    private var steps: [PhraseBeat] = []
    private var step = 0
    private var loopStart: Int?
    private var onBeat: ((PhraseBeat) -> Void)?
    private var onClickFailed: (() -> Void)?
    var onStopped: (() -> Void)?
    private var reportedClickFailure = false
    private var idleDisabled = false

    func play(
        tempo: PhraseTempo, groupSizes: [Int], startEight: Int, loopOneEight: Bool,
        onBeat: @escaping (PhraseBeat) -> Void, onClickFailed: @escaping () -> Void
    ) {
        stop()
        let eights = groupSizes.count
        guard eights > 0, groupSizes.allSatisfy({ (1...8).contains($0) }) else { return }
        let start = min(max(0, startEight), eights - 1)
        var sequence: [PhraseBeat] = [5, 6, 7, 8].map {
            PhraseBeat(eightIndex: start, count: 0, pickup: $0)
        }
        let last = loopOneEight ? start : eights - 1
        if eights > 0 {
            for eight in start...last {
                for count in 1...groupSizes[eight] {
                    sequence.append(PhraseBeat(eightIndex: eight, count: count, pickup: nil))
                }
            }
        }
        steps = sequence
        loopStart = loopOneEight ? 0 : nil
        step = 0
        self.onBeat = onBeat
        self.onClickFailed = onClickFailed
        reportedClickFailure = false
        prepareTone()
        isPlaying = true
        idleDisabled = true
        UIApplication.shared.isIdleTimerDisabled = true
        emitCurrent()
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + tempo.beatDuration, repeating: tempo.beatDuration)
        timer.setEventHandler { [weak self] in self?.advance() }
        timer.resume()
        self.timer = timer
    }

    func stop() {
        timer?.cancel()
        timer = nil
        tone.stop()
        isPlaying = false
        steps = []
        onBeat = nil
        if idleDisabled {
            UIApplication.shared.isIdleTimerDisabled = false
            idleDisabled = false
        }
    }

    deinit {
        timer?.cancel()
    }

    private func advance() {
        guard isPlaying else { return }
        step += 1
        if step >= steps.count {
            if let loopStart, loopStart < steps.count {
                step = loopStart
            } else {
                let finish = onStopped
                stop()
                finish?()
                return
            }
        }
        emitCurrent()
    }

    private func emitCurrent() {
        guard steps.indices.contains(step) else { return }
        let beat = steps[step]
        onBeat?(beat)
        playTone(strong: beat.pickup == nil && beat.count == 1)
    }

    private func prepareTone() {
        if !tone.prepare(configureAmbientSession: true) { failClick() }
    }

    private func playTone(strong: Bool) {
        tone.play(strong: strong)
    }

    private func failClick() {
        guard !reportedClickFailure else { return }
        reportedClickFailure = true
        onClickFailed?()
    }
}

/// Shared synthesized clicks. A lesson keeps the video session's existing audio category.
@MainActor
private final class PhraseClickTone {
    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private var softClick: AVAudioPCMBuffer?
    private var strongClick: AVAudioPCMBuffer?

    func prepare(configureAmbientSession: Bool) -> Bool {
        stop()
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1),
              let soft = click(frequency: 880, amplitude: 0.35, format: format),
              let strong = click(frequency: 1320, amplitude: 0.55, format: format) else { return false }
        engine.connect(player, to: engine.mainMixerNode, format: format)
        do {
            let session = AVAudioSession.sharedInstance()
            if configureAmbientSession {
                try session.setCategory(.ambient, options: [.mixWithOthers])
            }
            try session.setActive(true)
            try engine.start()
            player.play()
            softClick = soft
            strongClick = strong
            self.engine = engine
            self.player = player
            return true
        } catch {
            player.stop()
            engine.stop()
            return false
        }
    }

    func play(strong: Bool) {
        guard let player, let buffer = strong ? strongClick : softClick else { return }
        player.scheduleBuffer(buffer, completionHandler: nil)
    }

    func stop() {
        player?.stop()
        engine?.stop()
        engine = nil
        player = nil
        softClick = nil
        strongClick = nil
    }

    private func click(frequency: Double, amplitude: Float, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frames = AVAudioFrameCount(format.sampleRate * 0.04)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
            let samples = buffer.floatChannelData?[0]
        else { return nil }
        buffer.frameLength = frames
        for index in 0..<Int(frames) {
            let time = Double(index) / format.sampleRate
            let envelope = Float(1 - Double(index) / Double(frames))
            samples[index] = amplitude * envelope * Float(sin(2 * Double.pi * frequency * time))
        }
        return buffer
    }
}
