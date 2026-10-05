import SwiftUI
import UIKit

@main
struct EZHeartZonesApp: App {
    init() {
        // The default page-indicator dots are near-white and invisible against our off-white
        // background; SwiftUI's TabView(.page) style doesn't expose dot colors directly, so this
        // goes through the underlying UIPageControl's appearance proxy instead.
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(AppColors.goalAccent)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(AppColors.secondaryText).withAlphaComponent(0.35)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
