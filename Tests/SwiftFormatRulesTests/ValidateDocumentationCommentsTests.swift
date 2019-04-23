import Foundation
import SwiftSyntax
import XCTest

@testable import SwiftFormatRules

public class ValidateDocumentationCommentsTests: DiagnosingTestCase {
  public func testParameterDocumentation() {
    let input =
    """
    /// Uses 'Parameters' when it only has one parameter.
    ///
    /// - Parameters singular: singular description.
    /// - Returns: A string containing the contents of a
    ///   description
    func testPluralParamDesc(singular: String) -> Bool {}

    /// Uses 'Parameter' with a list of parameters.
    ///
    /// - Parameter
    ///   - command: The command to execute in the shell environment.
    ///   - stdin: The string to use as standard input.
    /// - Returns: A string containing the contents of the invoked process's
    ///   standard output.
    func execute(command: String, stdin: String) -> String {
    // ...
    }

    /// Returns the output generated by executing a command with the given string
    /// used as standard input.
    ///
    /// - Parameter command: The command to execute in the shell environment.
    /// - Parameter stdin: The string to use as standard input.
    /// - Returns: A string containing the contents of the invoked process's
    ///   standard output.
    func testInvalidParameterDesc(command: String, stdin: String) -> String {}
    """
    performLint(ValidateDocumentationComments.self, input: input)
    XCTAssertDiagnosed(.useSingularParameter)
    XCTAssertDiagnosed(.usePluralParameters)
    XCTAssertDiagnosed(.usePluralParameters)
  }

  public func testParametersName() {
    let input =
    """
    /// Parameters dont match.
    ///
    /// - Parameters:
    ///   - sum: The sum of all numbers.
    ///   - avg: The average of all numbers.
    /// - Returns: The sum of sum and avg.
    func sum(avg: Int, sum: Int) -> Int {}

    /// Missing one parameter documentation.
    ///
    /// - Parameters:
    ///   - p1: Parameter 1.
    ///   - p2: Parameter 2.
    /// - Returns: an integer.
    func foo(p1: Int, p2: Int, p3: Int) -> Int {}
    """
    performLint(ValidateDocumentationComments.self, input: input)
    XCTAssertDiagnosed(.parametersDontMatch(funcName: "sum"))
    XCTAssertDiagnosed(.parametersDontMatch(funcName: "foo"))
  }

  public func testReturnDocumentation() {
    let input =
    """
    /// One sentence summary.
    ///
    /// - Parameters:
    ///   - p1: Parameter 1.
    ///   - p2: Parameter 2.
    ///   - p3: Parameter 3.
    /// - Returns: an integer.
    func noReturn(p1: Int, p2: Int, p3: Int) {}

    /// One sentence summary.
    ///
    /// - Parameters:
    ///   - p1: Parameter 1.
    ///   - p2: Parameter 2.
    ///   - p3: Parameter 3.
    func foo(p1: Int, p2: Int, p3: Int) -> Int {}
    """
    performLint(ValidateDocumentationComments.self, input: input)
    XCTAssertDiagnosed(.removeReturnComment(funcName: "noReturn"))
    XCTAssertDiagnosed(.documentReturnValue(funcName: "foo"))
  }

  public func testValidDocumentation() {
    let input =
    """
    /// Returns the output generated by executing a command.
    ///
    /// - Parameter command: The command to execute in the shell environment.
    /// - Returns: A string containing the contents of the invoked process's
    ///   standard output.
    func singularParam(command: String) -> String {
    // ...
    }

    /// Returns the output generated by executing a command with the given string
    /// used as standard input.
    ///
    /// - Parameters:
    ///   - command: The command to execute in the shell environment.
    ///   - stdin: The string to use as standard input.
    /// - Returns: A string containing the contents of the invoked process's
    ///   standard output.
    func pluralParam(command: String, stdin: String) -> String {
    // ...
    }

    /// Parameter(s) and Returns tags may be omitted only if the single-sentence
    /// brief summary fully describes the meaning of those items and including the
    /// tags would only repeat what has already been said
    func ommitedFunc(p1: Int)
    """
    performLint(ValidateDocumentationComments.self, input: input)
    XCTAssertNotDiagnosed(.useSingularParameter)
    XCTAssertNotDiagnosed(.usePluralParameters)

    XCTAssertNotDiagnosed(.documentReturnValue(funcName: "singularParam"))
    XCTAssertNotDiagnosed(.removeReturnComment(funcName: "singularParam"))
    XCTAssertNotDiagnosed(.parametersDontMatch(funcName: "singularParam"))

    XCTAssertNotDiagnosed(.documentReturnValue(funcName: "pluralParam"))
    XCTAssertNotDiagnosed(.removeReturnComment(funcName: "pluralParam"))
    XCTAssertNotDiagnosed(.parametersDontMatch(funcName: "pluralParam"))

    XCTAssertNotDiagnosed(.documentReturnValue(funcName: "ommitedFunc"))
    XCTAssertNotDiagnosed(.removeReturnComment(funcName: "ommitedFunc"))
    XCTAssertNotDiagnosed(.parametersDontMatch(funcName: "ommitedFunc"))
  }
}
