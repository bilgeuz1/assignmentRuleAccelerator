/**
 * @name FireAssignmentRuleInvocable
 * @description Class to allow  Community Site Guest Users to fire assignment rules 
 *              Must be run without sharing to enforce system mode
 * @author Dupont Circle Solutions
 * @since 10/14/2024
 */
public without sharing class FireAssignmentRulesInvocable {
    private final static List<String> allowedObjects = new List<String>{'LEAD', 'CASE'};

    @TestVisible
    private final static String exceptionMessage = 'Input list should have at least one record and objectName must be Case or Lead';

    /**
     * @description Invocable for flows to allow assignment rules to be run on demand
     * @param invocableInputs List of input object AssignmentRuleInput containing case or lead list and dml options
     */
    @InvocableMethod
    public static void assignRecords(List<AssignmentRuleInput> invocableInputs) {
        for (AssignmentRuleInput input : invocableInputs) {
            input.validate();
            FireAssignmentRulesProcessor.processRecordAssignments(input);
        }
    }


    /**
     * Inner class representation of invocable method input
     * - caseOrLeadList: List of generic SObject 
     * - blnTriggerAutoResponseEmail: Boolean if autoresponse email should be triggered
     * - blnOptAllOrNone: Boolean of allOrNone DML option, true means any errors will rollback entire update, false will allow for partial success
     * - objectName: Name of object type of records in caseOrLeadList
     */
    public class AssignmentRuleInput {
        @InvocableVariable(Required=true)
        public List<SObject> caseOrLeadList;

        @InvocableVariable(DefaultValue='false')
        public Boolean blnTriggerAutoResponseEmail;

        @InvocableVariable(DefaultValue='true' Description='DML option determining if partial success is allowed. Select FALSE if partial success is allowed.')
        public Boolean blnOptAllOrNone;

        @InvocableVariable(Required=true Description='Specify if list of records is Case Or Lead')
        public String objectName;

        /**
         * @description Method to validate inputs from flow, checks that records are present in caseOrLeadList and the objectName provided is in the allowed objects list.
         *  If either of the checked inputs are not valid an error is thrown
         */
        public void validate() {
            if (this.caseOrLeadList.isEmpty() || !allowedObjects.contains(this.objectName.toUpperCase())) {
                throw new FireAssignmentRulesInvocableException(exceptionMessage);
            }
        }
    }

    /**
     * @description Custom exception class
     */
    public class FireAssignmentRulesInvocableException extends Exception {}
}