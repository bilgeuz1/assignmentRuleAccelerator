/**
 * @name FireAssignmentRulesInvocableTest
 * @description Unit tests for controller
 * @author Leslie Martin
 * @since 12/11/2024
 *
 * @see FireAssignmentRulesInvocable
 * @see FireAssignmentRulesProcessor
 */
@IsTest
private class FireAssignmentRulesInvocableTest {

    // test for no assignment rules
    // test not allowed object
    // test owner is changed when assignment rule exists

    /**
     * @description Set up test data
     */
    @TestSetup
    private static void makeData(){
        FireAssignmentRulesTestDataFactory.createAccount('Test Account',true);
        FireAssignmentRulesTestDataFactory.createCase(true);
    }

    /**
     * @description Tests that
     */
    @IsTest
    private static void testAssignCases_Success(){
        List<Case> cases = [SELECT Id, OwnerId FROM Case];
        String originalOwnerId = cases[0].OwnerId;
        List<AssignmentRule> testAssignmentRules = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE];
        FireAssignmentRulesProcessor.testAssignmentRules = testAssignmentRules;
        Test.startTest();
        FireAssignmentRulesInvocable.assignRecords(buildInvocableInputListToTest('Case', cases));
        Test.stopTest();

        Case c = [SELECT OwnerId FROM Case LIMIT 1];
        Assert.areNotEqual(originalOwnerId, c.OwnerId, 'Case should be reassigned');
    }

    /**
     * @description Test method for assignCases()
     */
    @IsTest
    private static void testAssignCases_Failure_NotAllowedObject(){
        List<Account> accounts = [SELECT Id, OwnerId FROM Account];
        List<AssignmentRule> testAssignmentRules = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE];
        FireAssignmentRulesProcessor.testAssignmentRules = testAssignmentRules;
        try {
            FireAssignmentRulesInvocable.assignRecords(buildInvocableInputListToTest('Account', accounts));
            Assert.isFalse(true, 'Exception should be thrown when invocable run on invalid objects');
        } catch (FireAssignmentRulesInvocable.FireAssignmentRulesInvocableException exc) {
            Assert.areEqual(
                    FireAssignmentRulesInvocable.exceptionMessage,
                    exc.getMessage(),
                    'Exception message should be set'
            );
        }
    }

    @IsTest
    private static void testAssignCases_Success_NoAssignmentRules(){
        List<Case> cases = [SELECT Id, OwnerId FROM Case];
        String originalOwnerId = cases[0].OwnerId;
        List<AssignmentRule> testAssignmentRules = new List<AssignmentRule>();
        FireAssignmentRulesProcessor.testAssignmentRules = testAssignmentRules;
        Test.startTest();
        FireAssignmentRulesInvocable.assignRecords(buildInvocableInputListToTest('Case', cases));
        Test.stopTest();

        Case c = [SELECT OwnerId FROM Case LIMIT 1];
        Assert.areEqual(originalOwnerId, c.OwnerId, 'Case should not be reassigned');
    }

    private static List<FireAssignmentRulesInvocable.AssignmentRuleInput> buildInvocableInputListToTest(String objectName, List<SObject> objectsToTest) {
        List<FireAssignmentRulesInvocable.AssignmentRuleInput> inputsToTest = new List<FireAssignmentRulesInvocable.AssignmentRuleInput>();
        FireAssignmentRulesInvocable.AssignmentRuleInput assignmentRuleInput = new FireAssignmentRulesInvocable.AssignmentRuleInput();
        assignmentRuleInput.caseOrLeadList = objectsToTest;
        assignmentRuleInput.blnOptAllOrNone = true;
        assignmentRuleInput.objectName = objectName;
        assignmentRuleInput.blnTriggerAutoResponseEmail = false;
        inputsToTest.add(assignmentRuleInput);
        return inputsToTest;
    }

}