import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Concepts
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.ApiGraphs
import DataFlow::PathGraph
import semmle.python.frameworks.Flask

abstract class CredentialSink extends DataFlow::Node { }

Expr getDictValueByKey(Dict dict, string key) {
  exists(KeyValuePair item |
    // d = {KEY: VALUE}
    item = dict.getAnItem() and
    key = item.getKey().(StrConst).getS() and
    result = item.getValue()
  )
}

Expr getAssignStmtByKey(AssignStmt assign, string key) {
  exists(Subscript sub |
    // dict['KEY'] = VALUE
    sub = assign.getASubExpression() and
    // Make sure the keys match
    // TODO: What happens if this value itself is not static?
    key = sub.getASubExpression().(StrConst).getS() and
    // TODO: Only supports static strings, resolve the value??
    // result = assign.getASubExpression().(StrConst)
    result = sub.getValue()
  )
}

Expr getAnyAssignStmtByKey(string key) { result = getAssignStmtByKey(any(AssignStmt a), key) }

class FlaskCredentialSink extends CredentialSink {
  FlaskCredentialSink() {
    exists(API::Node node |
      exists(AssignStmt stmt |
        // app = flask.Flask(__name__)
        // app.secret_key = VALUE
        node = Flask::FlaskApp::instance().getMember("secret_key") and
        stmt = node.getAUse().asExpr().getParentNode() and
        this = DataFlow::exprNode(stmt.getValue())
      )
      or
      exists(Expr assign, AssignStmt stmt |
        // app.config['SECRET_KEY'] = VALUE
        assign = getAnyAssignStmtByKey("SECRET_KEY").getParentNode() and
        stmt = assign.getParentNode() and
        this = DataFlow::exprNode(stmt.getValue())
      )
      or
      // app.config.update(SECRET_KEY=VALUE)
      node = Flask::FlaskApp::instance().getMember("config").getMember("update") and
      this = DataFlow::exprNode(node.getACall().getArgByName("SECRET_KEY").asExpr())
    )
  }
}
