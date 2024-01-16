import go
private import semmle.go.security.SqlInjectionCustomizations
private import semmle.go.security.CommandInjectionCustomizations
private import semmle.go.security.RequestForgeryCustomizations

predicate findByLocation(DataFlow::Node node, string relative_path, int linenumber) {
  node.getFile().getRelativePath() = relative_path and
  node.getStartLine() = linenumber
}

class Sinks extends DataFlow::Node {
  Sinks() {
    this instanceof SqlInjection::Sink or
    this instanceof RequestForgery::Sink or
    this instanceof CommandInjection::Sink
  }
}
