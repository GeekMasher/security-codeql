/**
 * @name Hard-coded credentials
 * @description Credentials are hard coded in the source code of the application.
 * @kind problem
 * @problem.severity error
 * @precision low
 * @id cs/hardcoded-credentials
 * @tags security
 *       external/cwe/cwe-259
 *       external/cwe/cwe-321
 *       external/cwe/cwe-798
 */

import csharp

from Field field
where field.toString().toLowerCase().regexpMatch(".*(secret|token|password|pwd).*")
select field.getAChildExpr(), "Possible Password found " + field.getAnAssignedValue()
