import python
private import semmle.python.dataflow.new.DataFlow

/**
 * Find Node at Location
 */
predicate findByLocation(DataFlow::Node node, string relative_path, int linenumber) {
  node.getLocation().getFile().getRelativePath() = relative_path and
  node.getLocation().getStartLine() = linenumber
}

class FunctionArgs extends DataFlow::Node {
  FunctionArgs() {
    exists(Function func | func.getScope().inSource() | this.asExpr() = func.getAnArg())
  }
}

class FunctionCallArgs extends DataFlow::Node {
  FunctionCallArgs() {
    exists(Call calls | calls.getScope().inSource() | this.asExpr() = calls.getAnArg())
  }
}
