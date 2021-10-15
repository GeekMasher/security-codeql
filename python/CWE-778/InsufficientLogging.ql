/**
 * @name Insuffcient Logging
 * @description Insuffcient Logging
 * @kind problem
 * @id py/insuffcient-logging
 * @problem.severity warning
 * @security-severity 1.0
 * @sub-severity low
 * @precision low
 * @tags security
 *       external/cwe/cwe-778
 */

import python

from ExceptStmt exceptBlock, Pass pass, Continue continue
where
  pass.getParentNode() = exceptBlock or
  continue.getParentNode() = exceptBlock
select exceptBlock, "Try-catch except, Pass/Continue detected."
