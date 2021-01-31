
import SwiftUI

public enum KSTimerStatus {
    case notStarted, running, paused
}
    
public struct KSTimerView: View {
    
    // MARK: - Private Properties
    @State private var offset: CGFloat = 70
    @State private var completedTime: TimeInterval = 0
    @State private var shouldShowMenus = true // Need to use this for future enhancement
    @State private var status: KSTimerStatus = .notStarted
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var backgroundAt = Date()
    
    private var progress: CGFloat {
        CGFloat((timerInterval - completedTime) / timerInterval)
    }

    // MARK: - Public Properties and Init
    @Binding var timerInterval: TimeInterval
    
    var configuration = KSTimerView.Configuration(timerBgColor: .green, timerRingBgColor: .green, actionButtonsBgColor: .blue, foregroundColor: .white, stepperValue: 5)
    
    
    public init(timerInterval: Binding<TimeInterval>, configuration: KSTimerView.Configuration = KSTimerView.Configuration(timerBgColor: .green, timerRingBgColor: .green, actionButtonsBgColor: .blue, foregroundColor: .white, stepperValue: 5)) {
        self._timerInterval = timerInterval
        self.configuration = configuration
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack {
            Color.clear
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { (_) in
                    self.stopTimer()
                    self.backgroundAt = Date()
                }
            Color.clear
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { (_) in
                    if self.status == .running {
                        let backgroundInterval = TimeInterval(Int(Date().timeIntervalSince(self.backgroundAt) + 1))
                        if (self.completedTime + backgroundInterval) >= (self.timerInterval - 1) {
                            self.resetDetails()
                        } else {
                            self.completedTime = self.completedTime + backgroundInterval
                            self.startTimer()
                        }
                    }
                }
            if shouldShowMenus {
                Color.white
                    .opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
            }

            // Main timer view button
            ZStack {
                if status == .running || status == .paused {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(configuration.timerRingBgColor, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .animation((status == .running || status == .paused) ? Animation.linear(duration: 1) : nil)
                        .rotationEffect(.degrees(-90))
                        .frame(width: shouldShowMenus ? 220 : 70, height: shouldShowMenus ? 220 : 70)
                }
                
                Text("\((Int(timerInterval - completedTime) == 0) ? Int(timerInterval) : Int(timerInterval - completedTime))s")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .animation(nil)
                    .frame(width: shouldShowMenus ? 200 : 50, height: shouldShowMenus ? 200 : 50)
                    .background(configuration.timerBgColor)
                    .clipShape(Circle())
                
                Button(action: {
                    HapticHelper.shared.hapticFeedback()
                    if self.status == .running {
                        self.status = .paused
                    } else if self.status == .paused || self.status == .notStarted {
                        self.status = .running
                    }
                    configureTimerAndNotification()
                }) {
                    Color.clear
                }
                .frame(width: shouldShowMenus ? 200 : 50, height: shouldShowMenus ? 200 : 50)
                .padding(10)
                .shadow(radius: shouldShowMenus ? 5 : 0)
            }
            .offset(y: shouldShowMenus ? -(offset) : 0)
            .animation(.spring())
            
            // Minus button
            Button(action: {
                HapticHelper.shared.hapticFeedback(style: .soft)
                if self.timerInterval > configuration.stepperValue {
                    self.timerInterval = self.timerInterval - configuration.stepperValue
                    LocalNotificationHelper.shared.addLocalNoification(interval: TimeInterval(self.timerInterval - self.completedTime))
                }
            }) {
                Text("-\(Int(configuration.stepperValue))s")
                    .timerControlStyle(backgroundColor: configuration.actionButtonsBgColor)
            }
            .shadow(radius: shouldShowMenus ? 5 : 0)
            .offset(x: shouldShowMenus ? -offset : 0, y: shouldShowMenus ? (offset + 20) : 0)
            .animation(.spring())
            
            // Plus button
            Button(action: {
                HapticHelper.shared.hapticFeedback(style: .soft)
                self.timerInterval = self.timerInterval + configuration.stepperValue
                LocalNotificationHelper.shared.addLocalNoification(interval: TimeInterval(self.timerInterval - self.completedTime))
            }) {
                Text("+\(Int(configuration.stepperValue))s")
                    .timerControlStyle(backgroundColor: configuration.actionButtonsBgColor)
            }
            .shadow(radius: shouldShowMenus ? 5 : 0)
            .offset(x: shouldShowMenus ? offset : 0, y: shouldShowMenus ? (offset + 20) : 0)
            .animation(.spring())

            // Stop button
            if status == .running || status == .notStarted {
                Button(action: {
                    HapticHelper.shared.hapticFeedback()
                    if status == .running {
                        self.resetDetails()
                        LocalNotificationHelper.shared.resetTimerNotification()
                    } else {
                        status = .running
                        configureTimerAndNotification()
                    }
                }) {
                    Image(systemName: status == .running ? "stop" : "play")
                        .timerControlStyle(backgroundColor: status == .running ? Color.red : configuration.actionButtonsBgColor)
                }
                .shadow(radius: shouldShowMenus ? 5 : 0)
                .offset(y: shouldShowMenus ? (offset + 20) : 0)
                .zIndex(10)
            }
        }
        .padding(.leading, shouldShowMenus ? 0 : 10)
        .onReceive(timer, perform: { (_) in
            if self.status == .running {
                self.completedTime += 1
                if self.completedTime >= self.timerInterval - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.resetDetails()
                    }
                }
            }
            print("⚠️ \(self.completedTime)")
        })
    }
    
    // MARK: - Custom Methods
    /**Configures timer and local notification*/
    private func configureTimerAndNotification() {
        if self.status == .running {
            self.startTimer()
            LocalNotificationHelper.shared.addLocalNoification(interval: TimeInterval(self.timerInterval - self.completedTime))
        } else if self.status == .paused {
            self.stopTimer()
            LocalNotificationHelper.shared.resetTimerNotification()
        }
    }
    
    /**Resets local properties to default*/
    private func resetDetails() {
        self.status = .notStarted
        self.stopTimer()
        self.completedTime = 0
    }
    
    private func stopTimer() {
        self.timer.connect().cancel()
    }
    
    private func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common)
        _ = timer.connect()
    }

}

public extension KSTimerView {
    
    struct Configuration {
        var timerBgColor: Color = .blue
        var timerRingBgColor: Color = .blue
        var actionButtonsBgColor: Color = .blue
        var foregroundColor: Color = .white
        var stepperValue: TimeInterval = 10
        var enableLocalNotification: Bool = true
        var enableHapticFeedback: Bool = true
        
        public init(timerBgColor: Color = .blue, timerRingBgColor: Color = .blue, actionButtonsBgColor: Color = .blue, foregroundColor: Color = .white, stepperValue: TimeInterval = 10, enableLocalNotification: Bool = true, enableHapticFeedback: Bool = true) {
            self.timerBgColor = timerBgColor
            self.timerRingBgColor = timerRingBgColor
            self.actionButtonsBgColor = actionButtonsBgColor
            self.foregroundColor = foregroundColor
            self.stepperValue = stepperValue
            LocalNotificationHelper.shared.isEnabled = enableLocalNotification
            HapticHelper.shared.isEnabled = enableHapticFeedback
        }
    }
    
}

// MARK: - Custom Modifier
struct TimerControlStyle: ViewModifier {
    
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.body)
            .frame(width: 60, height: 30)
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

extension View {
    
    func timerControlStyle(backgroundColor: Color) -> some View {
        self.modifier(TimerControlStyle(backgroundColor: backgroundColor))
    }
    
}
