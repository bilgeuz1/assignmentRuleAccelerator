/**
 * @name FireAssignmentRulesProcessor
 * @description Contains methods for processing assignment rules from invocable
 * @author Leslie Martin
 * @since 12/13/2024
 *
 * @see FireAssignmentRulesInvocable
 */
public without sharing class FireAssignmentRulesProcessor {

    @TestVisible
    private static List<AssignmentRule> testAssignmentRules = new List<AssignmentRule>();

    /**
     * @description Retrieves active assignment rule for object and applies it to all records contained in the invocable input
     * @param invocableInput List of input object AssignmentRuleInput containing case or lead list and dml options
     */
    public static void processRecordAssignments(FireAssignmentRulesInvocable.AssignmentRuleInput invocableInput) {
        List<SObject> objectsToFireAssignmentRulesAgainst = new List<SObject>();
        List<AssignmentRule> assignmentRules = getAssignmentRulesForObject(invocableInput.objectName);
        objectsToFireAssignmentRulesAgainst = setDMLOptions(assignmentRules, invocableInput);
        if (!objectsToFireAssignmentRulesAgainst.isEmpty()) {
            updateRecords(objectsToFireAssignmentRulesAgainst);
        }
    }

    /**
     * @description Retrieves the active assignment rule for the object API name
     * @param objectName String containing the object API name
     * @return List of AssignmentRule records for the object
     */
    public static List<AssignmentRule> getAssignmentRulesForObject(String objectName) {
        return [SELECT Id FROM AssignmentRule WHERE SobjectType = :objectName AND Active = TRUE];
    }

    /**
     * @description Checks that an assignment rule exists and sets the DML options
     * @param assignmentRules List of AssignmentRule records for the object
     * @param invocableInput List of input object AssignmentRuleInput containing case or lead list and dml options
     * @return List<SObject> of records to update
     */
    public static List<SObject> setDMLOptions(List<AssignmentRule> assignmentRules, FireAssignmentRulesInvocable.AssignmentRuleInput invocableInput) {
        List<SObject> objectsToFireAssignmentRulesAgainst = new List<SObject>();
        if (Test.isRunningTest()) {
            assignmentRules = testAssignmentRules;
        }
        if (!assignmentRules.isEmpty()) {
            Database.DMLOptions dmlOptions = setDmlOptionsForObject(assignmentRules.get(0).Id, invocableInput);
            objectsToFireAssignmentRulesAgainst = setDmlOptionsOnRecords(invocableInput.caseOrLeadList, dmlOptions);
        }
        return objectsToFireAssignmentRulesAgainst;
    }

    /**
     * @description Sets the DMLOptions passed from the invocable input for the object
     * @param assignmentRuleId String containing the assignment rule id for the active assignment rule
     * @param invocableInput List of input object AssignmentRuleInput containing case or lead list and dml options
     * @return Database.DMLOptions to use when updating the records contained in the invocable input
     */
    public static Database.DMLOptions setDmlOptionsForObject(String assignmentRuleId, FireAssignmentRulesInvocable.AssignmentRuleInput invocableInput) {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.assignmentRuleHeader.assignmentRuleId = assignmentRuleId;
        dmlOptions.emailHeader.triggerAutoResponseEmail = invocableInput.blnTriggerAutoResponseEmail;
        dmlOptions.optAllOrNone = invocableInput.blnOptAllOrNone;
        return dmlOptions;
    }

    /**
     * @description Sets the DMLOptions on each record passed from the invocable input
     * @param recordsToUpdate List of records to update
     * @param dmlOptions Database.DMLOptions to use when updating the records
     * @return List<SObject> of records to update
     */
    public static List<SObject> setDmlOptionsOnRecords(List<SObject> recordsToUpdate, Database.DMLOptions dmlOptions) {
        List<SObject> updatedRecords = new List<SObject>();
        for (SObject recordToUpdate : recordsToUpdate) {
            recordToUpdate.setOptions(dmlOptions);
            updatedRecords.add(recordToUpdate);
        }
        return updatedRecords;
    }

    /**
     * @description Updates the list of records passed from the invocable input
     * @param recordsToUpdate List<SObject> of records to update
     */
    public static void updateRecords(List<SObject> recordsToUpdate) {
        SaveUtility updateUtility = new SaveUtility(
                'Assignment Rules Invocable',
                'Failed to update assignment from assignment rules'
        );
        updateUtility.bulkUpsert(recordsToUpdate);
    }
}