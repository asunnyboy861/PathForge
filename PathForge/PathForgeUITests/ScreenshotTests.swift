import XCTest

final class ScreenshotTests: XCTestCase {

    @MainActor
    func testTakeScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        let screenshotDir = "/tmp/PathForge_screenshots"
        try FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)

        let homeScreenshot = app.screenshot()
        let homeURL = URL(fileURLWithPath: "\(screenshotDir)/01_home.png")
        try homeScreenshot.image.pngData()!.write(to: homeURL)

        let tabBar = app.tabBars.firstMatch
        let statsTab = tabBar.buttons["Stats"]
        if statsTab.exists {
            statsTab.tap()
            sleep(1)
            let statsScreenshot = app.screenshot()
            let statsURL = URL(fileURLWithPath: "\(screenshotDir)/02_stats.png")
            try statsScreenshot.image.pngData()!.write(to: statsURL)
        }

        let settingsTab = tabBar.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)
            let settingsScreenshot = app.screenshot()
            let settingsURL = URL(fileURLWithPath: "\(screenshotDir)/03_settings.png")
            try settingsScreenshot.image.pngData()!.write(to: settingsURL)
        }

        let homeTab = tabBar.buttons["Home"]
        if homeTab.exists {
            homeTab.tap()
            sleep(1)
        }

        let addButton = app.buttons["Add"]
        if addButton.exists {
            addButton.tap()
            sleep(1)
            let generationScreenshot = app.screenshot()
            let generationURL = URL(fileURLWithPath: "\(screenshotDir)/04_path_generation.png")
            try generationScreenshot.image.pngData()!.write(to: generationURL)
        }

        let createPathButton = app.buttons["Create New Path"]
        if createPathButton.exists {
            createPathButton.tap()
            sleep(1)
            let createScreenshot = app.screenshot()
            let createURL = URL(fileURLWithPath: "\(screenshotDir)/05_create_path.png")
            try createScreenshot.image.pngData()!.write(to: createURL)
        }
    }
}
