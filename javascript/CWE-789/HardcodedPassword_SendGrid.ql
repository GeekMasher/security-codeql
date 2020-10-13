/**
 * @name Hardcoded Password (SendGrid)
 * @kind path-problem
 * @problem.severity error
 * @id js/hardcoded-credentials
 * @tags security
 *       external/cwe/cwe-259
 *       external/cwe/cwe-321
 *       external/cwe/cwe-798
 */
import javascript


/**
 * SendGrid Docs: https://sendgrid.com/docs/for-developers/sending-email/quickstart-nodejs/#complete-code-block
*/

from CallExpr call, Expr expr, string str
where call.getCalleeName() = "setApiKey"
    and
    call.getArgument(0) = expr
    and
    expr.getStringValue() = str
select expr, "Hardcoded SendGrid token was found: " + str
