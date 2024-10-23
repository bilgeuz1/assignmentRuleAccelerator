/**
 * @name FireAssignmentRuleInvocable
 * @description Class to allow  Community Site Guest Users to fire assignment rules 
 *              Must be run without sharing to enforce system mode
 * @author Dupont Circle Solutions
 * @since 10/14/2024
 */
public without sharing class FireAssignmentRulesInvocable {
    private List<String> allowedObjects = new List<String>{'LEAD', 'CASE'};
    /**
     * @description Invocable for flows to allow assignment rules to be run on demand
     * @param assignmentRuleInput Instance of input object AssignmentRuleInput containing case or lead list and dml options
     */
    @Invocablemethod
    public static void assignRecords(AssignmentRuleInput input) {
        //Active assignment rules for lead or case
        input.validate();
        AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = :input.objectName AND Active = true LIMIT 1];
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;
        dmlOptions.emailHeader.triggerAutoResponseEmail = input.blnTriggerAutoResponseEmail;
        dmlOptions.optAllOrNone = input.blnOptAllOrNone;
        if (!caseOrLeadList.isEmpty()) {
            Database.update(caseOrLeadList, dmlOptions);
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
        @InvocableVariable(required=true)
        public List<SObject> caseOrLeadList;

        @InvocableVariable(defaultValue=false)
        public Boolean blnTriggerAutoResponseEmail;

        @InvocableVariable(defaultValue=true description="DML option determining if partial success is allowed. Select FALSE if partial success is allowed.")
        public Boolean blnOptAllOrNone;

        @InvocableVariable(required=true description="Specify if list of records is Case Or Lead")
        public String objectName;

        /**
         * @description Method to validate inputs from flow, checks that records are present in caseOrLeadList and the objectName provided is in the allowed objects list. 
         *  If either of the checked inputs are not valid an error is thrown
         */
        public void validate() {
            if (this.caseOrLeadList.isEmpty() || !allowedObjects.contains(this.objectName.toUpperCase())) {
                throw new FireAssignmentRulesInvocableException('Input list should have at least one record and objectName must be Case or Lead');
            }
        }
    }

    /**
     * @description Custom exception class
     */
    class FireAssignmentRulesInvocableException extends Exception {}
}