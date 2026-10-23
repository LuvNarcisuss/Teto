import UIKit

/// Joint pose for the practice figure. Screen-right follows the word "right".
struct PhrasePose: Equatable {
    var shift: CGFloat = 0
    var lift: CGFloat = 0
    var plie: CGFloat = 0
    var bow: CGFloat = 0
    var sway: CGFloat = 0
    var armLift: CGFloat = 0
    var armOpen: CGFloat = 0.28
    var reach: CGFloat = 0
    var head: CGFloat = 0
    var point: CGFloat = 0
    var kick: CGFloat = 0
    var clap: CGFloat = 0
    var cross: CGFloat = 0
    var turn: CGFloat = 0

    static let ready = PhrasePose(plie: 0.08, armOpen: 0.22)

    func mixed(toward other: PhrasePose, _ t: CGFloat) -> PhrasePose {
        func blend(_ a: CGFloat, _ b: CGFloat) -> CGFloat { a + (b - a) * t }
        return PhrasePose(
            shift: blend(shift, other.shift),
            lift: blend(lift, other.lift),
            plie: blend(plie, other.plie),
            bow: blend(bow, other.bow),
            sway: blend(sway, other.sway),
            armLift: blend(armLift, other.armLift),
            armOpen: blend(armOpen, other.armOpen),
            reach: blend(reach, other.reach),
            head: blend(head, other.head),
            point: blend(point, other.point),
            kick: blend(kick, other.kick),
            clap: blend(clap, other.clap),
            cross: blend(cross, other.cross),
            turn: blend(turn, other.turn))
    }
}

enum PhraseMotion {
    /// A pose read from one English count. `step` alternates when the line names no side.
    static func pose(for line: String, step: Int) -> PhrasePose {
        let text = line.lowercased()
        var pose = PhrasePose.ready
        let right = text.contains("right")
        let left = text.contains("left")
        let side: CGFloat = right && !left ? 1 : (left && !right ? -1 : (step.isMultiple(of: 2) ? 1 : -1))
        let arms = text.contains("arm") || text.contains("hand") || text.contains("reach")
        let both = text.contains("both") || (arms && !right && !left)
        let settling = text.contains("together") || text.contains("center") || text.contains("front")
            || text.contains("stay")
            || ((text.contains("hold") || text.contains("freeze") || text.contains("rest")) && !arms)
        if settling {
            pose.shift = 0
            pose.point = 0
            pose.kick = 0
            pose.sway = 0
            pose.turn = 0
            pose.head = 0
            pose.cross = 0
            pose.reach = 0
            pose.clap = 0
            pose.bow = 0
            pose.lift = 0
            pose.plie = 0.08
            pose.armLift = 0
            pose.armOpen = 0.22
        }
        if text.contains("step") || text.contains("walk") || text.contains("tap") {
            pose.shift = side * 0.9
            pose.plie = 0.22
        }
        if text.contains("touch") {
            pose.shift = side * 0.4
            pose.point = -side * 0.45
        }
        if text.contains("cross") && !arms {
            pose.shift = side * 0.55
            pose.cross = side
        }
        if text.contains("hip") || text.contains("sit") {
            pose.shift = side * 0.75
            pose.sway = side * 0.85
        }
        if text.contains("shift") || text.contains("weight") {
            pose.shift = side * 0.9
            pose.sway = side * 0.6
            pose.plie = 0.32
        }
        if text.contains("sway") || text.contains("shoulder") || text.contains("chest") || text.contains("circle") {
            pose.sway = side
            pose.armOpen = 0.45
        }
        if text.contains("forward") { pose.bow = max(pose.bow, 0.2) }
        if text.contains("rock") && text.contains("back") { pose.bow = -0.16 }
        if text.contains("step back") {
            pose.shift = side * 0.35
            pose.bow = 0.12
            pose.plie = 0.22
        }
        if text.contains("bounce") {
            pose.plie = 0.5
            pose.lift = 0.22
        }
        if (text.contains("drop") || text.contains("low")) && !arms {
            pose.plie = 0.92
            pose.bow = 0.1
            pose.lift = 0
        }
        if text.contains("rise") {
            pose.plie = 0.05
            pose.lift = 0.28
            pose.bow = 0
        }
        if text.contains("turn") {
            let spin: CGFloat = right || left ? side : 1
            pose.turn = spin
            pose.head = spin * 0.35
            pose.shift = spin * 0.16
        }
        if text.contains("balance") || text.contains("one foot") {
            pose.point = side == 0 ? 1 : side
            pose.plie = 0.02
            pose.armOpen = max(pose.armOpen, 0.55)
            pose.armLift = max(pose.armLift, 0.35)
        }
        if text.contains("stand") || (text.contains("tall") && !arms) || text.contains("grow") {
            pose.plie = 0.04
            pose.bow = 0
            pose.lift = 0
            if !arms {
                pose.armLift = 0
                pose.armOpen = 0.22
                pose.reach = 0
            }
        }
        let toHead = text.contains("head")
        let raising = arms && (text.contains("up") || text.contains("reach") || text.contains("lift") || toHead
            || text.contains("wide") || text.contains("open"))
        let lowering = arms && (text.contains("lower") || text.contains("down") || text.contains("drop") || text.contains("rest"))
        if raising {
            pose.armLift = toHead ? 1 : 0.95
            pose.bow = min(pose.bow, 0.05)
            if toHead {
                pose.armOpen = 0.12
                pose.reach = 0
            } else if both {
                pose.reach = 0
                pose.armOpen = 0.62
            } else {
                pose.reach = side
                pose.armOpen = 0.35
            }
        }
        if arms && (text.contains("wide") || text.contains("open")) {
            pose.armOpen = 1
            pose.armLift = max(pose.armLift, 0.45)
            pose.reach = 0
        }
        if text.contains("gather") || (arms && text.contains("close")) {
            pose.armOpen = 0.04
            pose.armLift = 0.12
            pose.reach = 0
        }
        if arms && text.contains("cross") {
            pose.armOpen = 0.02
            pose.armLift = toHead ? 0.9 : 0.7
            pose.reach = 0
            pose.clap = 0.85
            pose.cross = 0
        }
        if text.contains("hold") && text.contains("reach") {
            pose.armLift = max(pose.armLift, 0.95)
            pose.armOpen = max(pose.armOpen, 0.55)
            pose.reach = 0
        }
        if lowering {
            pose.armLift = 0
            pose.armOpen = 0.2
            pose.reach = 0
            pose.clap = 0
        }
        if text.contains("fold") || text.contains("melt") || text.contains("hang") {
            pose.bow = 0.92
            pose.armLift = 0.08
            pose.armOpen = 0.2
        }
        if text.contains("roll") {
            pose.bow = 0.28
            pose.armLift = 0.4
        }
        if text.contains("point") || text.contains("tendu") {
            pose.point = side
            pose.shift = side * 0.15
        }
        if text.contains("kick") {
            pose.kick = side
            pose.shift = -side * 0.1
        }
        if text.contains("knee") && !text.contains("elbow") {
            pose.plie = 0.62
            pose.lift = 0.12
        }
        if text.contains("jump") {
            pose.lift = 1
            pose.plie = 0.08
        }
        if text.contains("land") {
            pose.lift = 0
            pose.plie = 0.55
        }
        if text.contains("clap") || text.contains("hit") {
            pose.clap = 1
            pose.reach = side == 0 ? 1 : side
        }
        if text.contains("look") {
            if text.contains("up") {
                pose.head = 0
                pose.bow = -0.22
            } else {
                pose.head = side
            }
        }
        if text.contains("elbow") {
            pose.armLift = max(pose.armLift, 0.72)
            pose.armOpen = 0.48
        } else if text.contains("bend") || (text.contains("soft") && !text.contains("land")) {
            pose.plie = max(pose.plie, 0.45)
        }
        if text.contains("first") {
            pose.shift = 0
            pose.armOpen = 0.16
            pose.point = 0
        }
        if text.contains("heel") {
            pose.plie = max(pose.plie, 0.48)
            pose.lift = 0
        }
        return pose
    }
}

/// A drawn dancer that eases from one pose to the next across a single count.
final class PhraseFigureView: UIView {
    private var fromPose = PhrasePose.ready
    private var toPose = PhrasePose.ready
    private var moveStart = CACurrentMediaTime()
    private var moveDuration: CFTimeInterval = 0.01
    private var link: CADisplayLink?
    private let clock = Tick()

    private let skin = UIColor(red: 0.91, green: 0.73, blue: 0.61, alpha: 1)
    private let hair = UIColor(red: 0.16, green: 0.14, blue: 0.13, alpha: 1)
    private let shoe = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor(red: 0.93, green: 0.96, blue: 0.91, alpha: 1)
        contentMode = .redraw
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        clock.view = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    deinit { link?.invalidate() }

    func move(to pose: PhrasePose, duration: TimeInterval) {
        fromPose = renderedPose()
        toPose = pose
        moveStart = CACurrentMediaTime()
        moveDuration = max(0.05, duration)
        if link == nil {
            let link = CADisplayLink(target: clock, selector: #selector(Tick.step))
            link.add(to: .main, forMode: .common)
            self.link = link
        }
        setNeedsDisplay()
    }

    fileprivate func tick() {
        setNeedsDisplay()
        if CACurrentMediaTime() - moveStart >= moveDuration {
            link?.invalidate()
            link = nil
        }
    }

    private func renderedPose() -> PhrasePose {
        let t = min(1, max(0, (CACurrentMediaTime() - moveStart) / moveDuration))
        let eased = t * t * (3 - 2 * t)
        return fromPose.mixed(toward: toPose, eased)
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let pose = renderedPose()
        let beat = sin(min(1, max(0, (CACurrentMediaTime() - moveStart) / moveDuration)) * .pi)
        let span = min(rect.width, rect.height)
        let cx = rect.midX + pose.shift * span * 0.16
        let ground = rect.height * 0.9
        let bounce = beat * span * 0.028 + pose.lift * span * 0.07
        let legReach = span * 0.38 * (1 - pose.plie * 0.2)
        let hip = CGPoint(x: cx, y: ground - legReach - bounce)
        let bow = pose.bow * 1.05
        let spine = span * 0.23
        let shoulder = CGPoint(
            x: hip.x + sin(bow) * spine + pose.sway * span * 0.045,
            y: hip.y - cos(bow) * spine)
        let head = CGPoint(
            x: shoulder.x + sin(bow) * span * 0.05 + pose.head * span * 0.035,
            y: shoulder.y - cos(bow) * span * 0.11)

        let shadow = UIBezierPath(
            ovalIn: CGRect(x: cx - span * 0.16, y: ground - span * 0.03, width: span * 0.32, height: span * 0.045))
        ctx.setFillColor(UIColor(red: 0.18, green: 0.32, blue: 0.26, alpha: 0.16).cgColor)
        ctx.addPath(shadow.cgPath)
        ctx.fillPath()

        ctx.saveGState()
        ctx.translateBy(x: hip.x, y: hip.y)
        ctx.rotate(by: pose.turn * 0.55)
        ctx.translateBy(x: -hip.x, y: -hip.y)

        let leftHip = CGPoint(x: hip.x - span * 0.055, y: hip.y)
        let rightHip = CGPoint(x: hip.x + span * 0.055, y: hip.y)
        let leftLeg = limbEnd(from: leftHip, side: -1, pose: pose, span: span)
        let rightLeg = limbEnd(from: rightHip, side: 1, pose: pose, span: span)
        capsule(leftHip, leftLeg.knee, span * 0.055, TetoTheme.emerald, ctx)
        capsule(leftLeg.knee, leftLeg.foot, span * 0.048, skin, ctx)
        capsule(rightHip, rightLeg.knee, span * 0.055, TetoTheme.emerald, ctx)
        capsule(rightLeg.knee, rightLeg.foot, span * 0.048, skin, ctx)
        capsule(leftLeg.foot, CGPoint(x: leftLeg.foot.x + span * 0.045, y: leftLeg.foot.y), span * 0.028, shoe, ctx)
        capsule(rightLeg.foot, CGPoint(x: rightLeg.foot.x + span * 0.045, y: rightLeg.foot.y), span * 0.028, shoe, ctx)

        let torso = UIBezierPath()
        let half = span * 0.09
        torso.move(to: CGPoint(x: shoulder.x - half, y: shoulder.y))
        torso.addLine(to: CGPoint(x: shoulder.x + half, y: shoulder.y))
        torso.addLine(to: CGPoint(x: hip.x + span * 0.07, y: hip.y))
        torso.addLine(to: CGPoint(x: hip.x - span * 0.07, y: hip.y))
        torso.close()
        ctx.setFillColor(TetoTheme.lime.cgColor)
        ctx.addPath(torso.cgPath)
        ctx.fillPath()

        let leftArm = armPoints(shoulder: shoulder, side: -1, pose: pose, span: span)
        let rightArm = armPoints(shoulder: shoulder, side: 1, pose: pose, span: span)
        capsule(leftArm.shoulder, leftArm.elbow, span * 0.04, skin, ctx)
        capsule(leftArm.elbow, leftArm.hand, span * 0.036, skin, ctx)
        capsule(rightArm.shoulder, rightArm.elbow, span * 0.04, skin, ctx)
        capsule(rightArm.elbow, rightArm.hand, span * 0.036, skin, ctx)
        fillCircle(leftArm.hand, span * 0.022, skin, ctx)
        fillCircle(rightArm.hand, span * 0.022, skin, ctx)

        fillCircle(head, span * 0.075, skin, ctx)
        let hairPath = UIBezierPath(
            ovalIn: CGRect(
                x: head.x - span * 0.078, y: head.y - span * 0.09, width: span * 0.156, height: span * 0.09))
        ctx.setFillColor(hair.cgColor)
        ctx.addPath(hairPath.cgPath)
        ctx.fillPath()
        fillCircle(CGPoint(x: head.x, y: head.y - span * 0.07), span * 0.028, hair, ctx)
        let eyeY = head.y - span * 0.008
        let eyeShift = pose.head * span * 0.01
        fillCircle(CGPoint(x: head.x - span * 0.025 + eyeShift, y: eyeY), span * 0.008, hair, ctx)
        fillCircle(CGPoint(x: head.x + span * 0.025 + eyeShift, y: eyeY), span * 0.008, hair, ctx)
        ctx.restoreGState()
    }

    private func limbEnd(from hip: CGPoint, side: CGFloat, pose: PhrasePose, span: CGFloat) -> (knee: CGPoint, foot: CGPoint) {
        let pointing = max(0, pose.point * side) + max(0, pose.kick * side)
        let knee = CGPoint(
            x: hip.x + side * span * (0.02 + pose.plie * 0.03) + pose.cross * side * span * 0.04,
            y: hip.y + span * (0.17 - pose.plie * 0.025))
        let foot = CGPoint(
            x: knee.x + side * pointing * span * 0.18 - pose.cross * side * span * 0.02,
            y: knee.y + span * (0.17 - pointing * 0.11 - pose.lift * 0.02))
        return (knee, foot)
    }

    private func armPoints(shoulder: CGPoint, side: CGFloat, pose: PhrasePose, span: CGFloat) -> (shoulder: CGPoint, elbow: CGPoint, hand: CGPoint) {
        let root = CGPoint(x: shoulder.x + side * span * 0.08, y: shoulder.y + span * 0.02)
        let lead = max(0, pose.reach * side)
        if pose.armLift > 0.85 && pose.armOpen < 0.25 && abs(pose.reach) < 0.15 && pose.clap < 0.45 {
            let hand = CGPoint(x: shoulder.x + side * span * 0.07, y: shoulder.y - span * 0.13)
            let elbow = CGPoint(x: root.x + side * span * 0.02, y: root.y - span * 0.06)
            return (root, elbow, hand)
        }
        let lift = min(1, pose.armLift * 0.85 + lead * 1.05 + pose.armOpen * 0.15)
        let spread = side * span * (0.05 + pose.armOpen * 0.2)
        let elbow = CGPoint(x: root.x + spread * 0.5, y: root.y + span * 0.06 - lift * span * 0.22)
        var hand = CGPoint(x: elbow.x + spread * 0.55, y: elbow.y + span * 0.04 - lift * span * 0.2)
        if pose.clap > 0.45 {
            hand = CGPoint(x: shoulder.x + side * span * 0.025, y: shoulder.y + span * 0.04)
            let mid = CGPoint(x: (root.x + hand.x) / 2, y: (root.y + hand.y) / 2)
            return (root, mid, hand)
        }
        return (root, elbow, hand)
    }

    private func capsule(_ a: CGPoint, _ b: CGPoint, _ width: CGFloat, _ color: UIColor, _ ctx: CGContext) {
        ctx.saveGState()
        ctx.translateBy(x: a.x, y: a.y)
        ctx.rotate(by: atan2(b.y - a.y, b.x - a.x))
        let length = max(hypot(b.x - a.x, b.y - a.y), 0.5)
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: -width / 2, width: length, height: width), cornerRadius: width / 2)
        ctx.setFillColor(color.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        ctx.restoreGState()
    }

    private func fillCircle(_ center: CGPoint, _ radius: CGFloat, _ color: UIColor, _ ctx: CGContext) {
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }

    private final class Tick: NSObject {
        weak var view: PhraseFigureView?
        @objc func step() { view?.tick() }
    }
}

/// Phrase card in the voice-room shape: a dance cover, the style, then the author.
@MainActor
final class PhraseFigureCard: UIControl {
    var phraseID = ""
    var onTap: (() -> Void)?
    var onAvatar: (() -> Void)?
    private let cover = TetoPhoto()
    private let avatar = TetoPhoto(size: 22, round: true)
    private let avatarHit = UIButton(type: .custom)
    private let styleLabel = UILabel()
    private let nameLabel = UILabel()
    private var authorName = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = false
        let frameView = UIView()
        frameView.isUserInteractionEnabled = false
        frameView.backgroundColor = .black
        frameView.layer.cornerRadius = 18
        frameView.layer.cornerCurve = .continuous
        frameView.clipsToBounds = true
        frameView.translatesAutoresizingMaskIntoConstraints = false
        cover.isUserInteractionEnabled = false
        cover.contentMode = .scaleAspectFill
        frameView.addSubview(cover)
        cover.pin(to: frameView)
        let shade = UIView()
        shade.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        shade.isUserInteractionEnabled = false
        shade.translatesAutoresizingMaskIntoConstraints = false
        frameView.addSubview(shade)
        styleLabel.font = TetoTheme.font(16, title: true)
        styleLabel.textColor = .white
        styleLabel.numberOfLines = 1
        nameLabel.font = TetoTheme.font(13)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        avatar.addSubview(avatarHit)
        avatarHit.pin(to: avatar)
        avatarHit.isAccessibilityElement = false
        avatarHit.addAction(UIAction { [weak self] _ in self?.onAvatar?() }, for: .touchUpInside)
        let person = stack([avatar, nameLabel], axis: .horizontal, spacing: 6)
        person.alignment = .center
        person.isUserInteractionEnabled = false
        let caption = stack([styleLabel, person], spacing: 6)
        caption.isUserInteractionEnabled = false
        shade.addSubview(caption)
        caption.pin(to: shade, insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        addSubview(frameView)
        NSLayoutConstraint.activate([
            frameView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            frameView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            frameView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            frameView.bottomAnchor.constraint(equalTo: bottomAnchor),
            shade.leadingAnchor.constraint(equalTo: frameView.leadingAnchor),
            shade.trailingAnchor.constraint(equalTo: frameView.trailingAnchor),
            shade.bottomAnchor.constraint(equalTo: frameView.bottomAnchor),
        ])
        addAction(UIAction { [weak self] _ in self?.onTap?() }, for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityHint = "Opens the phrase"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    func bind(_ phrase: DancePhrase, avatar image: UIImage?, coverURL: URL? = nil) {
        phraseID = phrase.id
        authorName = phrase.authorName
        styleLabel.text = phrase.style.title
        nameLabel.text = phrase.authorName
        if let image { avatar.image = image }
        if let url = coverURL ?? Self.coverURL(for: phrase) { cover.load(url) }
        accessibilityLabel = phrase.style.title + ", " + phrase.authorName
        accessibilityIdentifier = phrase.id
        refreshAvatarAccess()
    }

    func setPlaying(_ playing: Bool) {}

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard onAvatar != nil else { return super.hitTest(point, with: event) }
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01, bounds.contains(point) else { return nil }
        let local = avatar.convert(point, from: self)
        if avatar.bounds.insetBy(dx: -8, dy: -8).contains(local) { return avatarHit }
        return self
    }

    private static func coverURL(for phrase: DancePhrase) -> URL? {
        guard let name = DancePhraseCatalog.filmAsset[phrase.id] else { return nil }
        return DanceVideoCatalog.entries.first { $0.assetName == name }?.resourceURL(fileExtension: "jpg")
    }

    private func refreshAvatarAccess() {
        guard onAvatar != nil else {
            accessibilityCustomActions = nil
            return
        }
        let name = authorName.isEmpty ? "profile" : authorName + "'s profile"
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Open " + name) { [weak self] _ in
                self?.onAvatar?()
                return true
            },
        ]
    }
}
