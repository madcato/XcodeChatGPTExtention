//
//  XcodeCommand.swift
//  XcodeChatGPTExtension
//
//  Created by Daniel Vela on 1/10/23.
//

import Foundation
import XcodeKit

protocol XcodeCommand {
  func command(prompt: Prompt, with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void
}

extension XcodeCommand {
  func command(prompt type: Prompt, with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    let code = selectedCode(from: invocation.buffer) ?? invocation.buffer.completeBuffer
    Task {
      do {
        if let response = try await XcodeGPT().perform(prompt: type, on: code) {
          invocation.buffer.completeBuffer.append("\n\n\(response)")
          completionHandler(nil)
        }
      } catch {
        completionHandler(error)
      }
    }
  }

  func selectedCode(from buffer: XCSourceTextBuffer) -> String? {
    var text = ""
    for case let range as XCSourceTextRange in buffer.selections {
      for lineNumber in range.start.line..<range.end.line {
        guard let line = buffer.lines[lineNumber] as? String else { return nil }
        text.append(line)
      }
    }
    return text.isEmpty ? nil : text.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
