import Testing

@testable import SwiftUniversalMain

struct CommandLineTests {
  @Test
  func executableNameMatchesLastArgument() {
    let expected = CommandLine.arguments[0].split(separator: "/").last.map(String.init) ?? ""
    #expect(CommandLine.executableName == expected)
  }
}
