/**
 * @name Hardcoded Password (SendGrid)
 * @description Hardcoded Password for SendGrid
 * @kind problem
 * @problem.severity error
 * @id js/hardcoded-credentials
 * @tags security
 *       external/cwe/cwe-259
 *       external/cwe/cwe-321
 *       external/cwe/cwe-798
 */
import javascript

// SendGrid Docs
// - https://sendgrid.com/docs/ui/account-and-settings/api-keys
// - https://sendgrid.com/docs/for-developers/sending-email/quickstart-nodejs/#complete-code-block

from StringLiteral sl
where sl.getValue().regexpMatch("(SG.[a-zA-Z0-9-]*.[a-zA-Z0-9-]*)")
select sl, "Possible sendgrid API token found \"" + sl.getValue() + "\""
