/**
 * @name Uncontrolled command line
 * @description Using externally controlled strings in a command line may allow a malicious
 *              user to change the meaning of the command.
 * @kind path-problem
 * @problem.severity error
 * @sub-severity high
 * @precision low
 * @id py/command-line-injection-local
 * @tags correctness
 *       security
 *       external/owasp/owasp-a1
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Concepts
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.ApiGraphs
import DataFlow::PathGraph

// ========== Sinks ==========
abstract private class LocalSinks extends DataFlow::Node { }

// class STDInput extends LocalSinks {
//   STDInput() {
//     exists(CallNode call |
//     // this = API::moduleImport("builtins").getMember("input").getACall()
//       this = call.getFunction().refersTo(Object::builtin("input"))
//     )
//   }
// }

class ArgumentsSources extends LocalSinks {
  ArgumentsSources() {
    exists(DataFlow::Node call |
      (
        // sys.args[1]
        call = API::moduleImport("sys").getMember("argv").getAUse() or
        // parser = argparse.ArgumentParser(__name__)
        // ...
        // arguments = parser.parse_args()
        call = API::moduleImport("argparse").getMember("ArgumentParser").getACall()
      ) and
      this = call
    )
  }
}

class EnviromentVariables extends LocalSinks {
  EnviromentVariables() {
    exists(DataFlow::Node call |
      (
        call = API::moduleImport("os").getMember("getenv").getACall() or
        // TODO: os.environ['abc']
        // call = API::moduleImport("os").getMember("environ").getAMember() or
        call = API::moduleImport("os").getMember("environ").getMember("get").getACall()
      ) and
      this = call
    )
  }
}


// ========== Configuration ==========
class CommandInjectionConfiguration extends TaintTracking::Configuration {
  CommandInjectionConfiguration() { this = "LocalCommandInjectionConfiguration" }

  override predicate isSource(DataFlow::Node source) { source instanceof LocalSinks }

  override predicate isSink(DataFlow::Node sink) {
    sink = any(SystemCommandExecution e).getCommand() and
    not sink.getScope().getEnclosingModule().getName() in ["os", "subprocess", "platform", "popen2"]
  }

  override predicate isSanitizerGuard(DataFlow::BarrierGuard guard) {
    guard instanceof StringConstCompare
  }
}

from CommandInjectionConfiguration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "This command depends on $@.", source.getNode(),
  "a user-provided value"
