/**
 * @name Use of unsafe lodash.template() function
 * @description Specific versions of the lodash library are vulnerable to prototype pollution. Avoid calling
 *              their template() function.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id js/lodash-template
 * @tags security
 *       external/cwe/cwe-020
 */

import javascript
import semmle.javascript.dependencies.Dependencies
import semmle.javascript.dependencies.SemVer

class Unsafe_Call extends DataFlow::CallNode {
  Unsafe_Call() {
    exists(NPMDependency dep |
      dep.getNPMPackageName() = "lodash" and
      dep.getVersion().(DependencySemVer).maybeBefore("4.17.16") and
      this = DataFlow::dependencyModuleImport(dep).getAMemberCall("template")
    )
  }
}

from Unsafe_Call uc
select uc,
  "Potential prototype pollution via 'options' argument! Please upgrade dependency 'lodash'!"
