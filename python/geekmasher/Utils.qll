import python
import semmle.python.dataflow.new.DataFlow

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
