/// Errors thrown while evaluating a `TimeLimitedRegex`.
public enum RegexEvaluationError: Error, Equatable {
  case timeout
}
