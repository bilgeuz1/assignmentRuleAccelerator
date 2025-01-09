@IsTest
private class SaveUtilityTest {
    @IsTest
    static void testSetAccessLevel_ifUserModeAndNoPermission_createProcessLog() {
        User guestUser = [SELECT Id FROM User WHERE UserType = 'Guest' LIMIT 1];
        Account acc = generateSuccessAccount();
        SaveUtility util = generateSaveUtility();
        System.runAs(guestUser) {
            Test.startTest();
            acc = (Account) util.insertRecord(acc);
            Test.stopTest();
        }
        assertSaveError(util, acc, ProcessLogConstants.INSERT_TYPE);
    }

    @IsTest
    static void testSetAccessLevel_ifSystemModeAndNoPermission_insertRecord() {
        User guestUser = [SELECT Id FROM User WHERE UserType = 'Guest' LIMIT 1];
        Account acc = generateSuccessAccount();
        SaveUtility util = generateSaveUtility();
        System.runAs(guestUser) {
            Test.startTest();
            util.setAccessLevel(AccessLevel.SYSTEM_MODE);
            acc = (Account) util.insertRecord(acc);
            Test.stopTest();
        }
        Assert.isNotNull(acc.Id, 'Id should be set on insert if no errors');
    }

    @IsTest
    static void testInsert_ifFail_createProcessLog() {
        Account acc = new Account();
        Test.startTest();
        SaveUtility util = generateSaveUtility();
        acc = (Account) util.insertRecord(acc);
        Test.stopTest();
        assertSaveError(util, acc, ProcessLogConstants.INSERT_TYPE);
    }

    @IsTest
    static void testInsert_ifSuccess_insertRecord() {
        Test.startTest();
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        Test.stopTest();
        Assert.isNotNull(acc.Id, 'Id should be set on insert if no errors');
    }

    @IsTest
    static void testUpdate_ifFail_createProcessLog() {
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        acc.Name = null;
        Test.startTest();
        acc = (Account) util.updateRecord(acc);
        Test.stopTest();
        assertSaveError(util, acc, ProcessLogConstants.UPDATE_TYPE);
    }

    @IsTest
    static void testUpdate_ifSuccess_updateRecord() {
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        acc.Name = 'UpdatedName';
        Test.startTest();
        acc = (Account) util.updateRecord(acc);
        Test.stopTest();
        acc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('UpdatedName', acc.Name, 'Name should be updated if no errors');
    }

    @IsTest
    static void testUpsert_ifInsertFail_createProcessLog() {
        Account acc = new Account();
        Test.startTest();
        SaveUtility util = generateSaveUtility();
        acc = (Account) util.upsertRecord(acc);
        Test.stopTest();
        assertSaveError(util, acc, ProcessLogConstants.UPSERT_TYPE);
    }

    @IsTest
    static void testUpsert_ifInsertSuccess_insertRecord() {
        Account acc = generateSuccessAccount();
        Test.startTest();
        SaveUtility util = generateSaveUtility();
        acc = (Account) util.upsertRecord(acc);
        Test.stopTest();
        Assert.isNotNull(acc.Id, 'Id should be set on insert if no errors');
    }

    @IsTest
    static void testUpsert_ifUpdateFail_createProcessLog() {
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        acc.Name = null;
        Test.startTest();
        acc = (Account) util.upsertRecord(acc);
        Test.stopTest();
        assertSaveError(util, acc, ProcessLogConstants.UPSERT_TYPE);
    }

    @IsTest
    static void testUpsert_ifUpdateSuccess_updateRecord() {
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        acc.Name = 'UpdatedName';
        Test.startTest();
        acc = (Account) util.upsertRecord(acc);
        Test.stopTest();
        acc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('UpdatedName', acc.Name, 'Name should be updated if no errors');
    }

    @IsTest
    static void testBulkUpsert_ifInsertFail_createProcessLog() {
        Account acc = new Account();
        Test.startTest();
        SaveUtility util = generateSaveUtility();
        List<Account> successes = (List<Account>) util.bulkUpsert(new List<Account>{ acc });
        Test.stopTest();
        Assert.isTrue(successes.isEmpty(), 'No success records should be returned');
        assertSaveError(util, null, ProcessLogConstants.UPSERT_TYPE);
    }

    @IsTest
    static void testBulkUpsert_ifInsertSuccess_insertRecord() {
        Account acc = generateSuccessAccount();
        Test.startTest();
        SaveUtility util = generateSaveUtility();
        List<Account> successes = (List<Account>) util.bulkUpsert(new List<Account>{ acc });
        Test.stopTest();
        Assert.areEqual(1, successes.size(), 'Account should be returned as success');
        Assert.isNotNull(successes[0].Id, 'Id should be set on insert if no errors');
    }

    @IsTest
    static void testBulkUpsert_ifUpdateFail_createProcessLog() {
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        acc.Name = null;
        Test.startTest();
        List<Account> successes = (List<Account>) util.bulkUpsert(new List<Account>{ acc });
        Test.stopTest();
        Assert.isTrue(successes.isEmpty(), 'No success records should be returned');
        assertSaveError(util, null, ProcessLogConstants.UPSERT_TYPE);
    }

    @IsTest
    static void testBulkUpsert_ifUpdateSuccess_updateRecord() {
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        acc.Name = 'UpdatedName';
        Test.startTest();
        List<Account> successes = (List<Account>) util.bulkUpsert(new List<Account>{ acc });
        Test.stopTest();
        Assert.areEqual(1, successes.size(), 'Account should be returned as success');
        acc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('UpdatedName', acc.Name, 'Name should be updated if no errors');
    }

    @IsTest
    static void testBulkUpdate_ifFail_createProcessLog() {
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        acc.Name = null;
        Test.startTest();
        List<Account> successes = (List<Account>) util.bulkUpdate(new List<Account>{ acc });
        Test.stopTest();
        Assert.isTrue(successes.isEmpty(), 'No success records should be returned');
        assertSaveError(util, null, ProcessLogConstants.UPDATE_TYPE);
    }

    @IsTest
    static void testBulkUpdate_ifSuccess_updateRecord() {
        SaveUtility util = generateSaveUtility();
        Account acc = insertSuccessAccount(util);
        acc.Name = 'UpdatedName';
        Test.startTest();
        List<Account> successes = (List<Account>) util.bulkUpdate(new List<Account>{ acc });
        Test.stopTest();
        Assert.areEqual(1, successes.size(), 'Account should be returned as success');
        acc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('UpdatedName', acc.Name, 'Name should be updated if no errors');
    }

    static Account generateSuccessAccount() {
        return new Account(Name = 'Test Account');
    }

    static Account insertSuccessAccount(SaveUtility util) {
        Account acc = generateSuccessAccount();
        return (Account) util.insertRecord(acc);
    }

    static SaveUtility generateSaveUtility() {
        return new SaveUtility('Test Process', 'Test error message');
    }

    static void assertSaveError(SaveUtility util, Account acc, String typ) {
        Assert.isNull(acc, 'Null should be returned with errors');
        List<Process_Log__c> logs = [
                SELECT Id, Type__c, Process__c, Message__c, Additional_Data__c
                FROM Process_Log__c
        ];
        Assert.areEqual(1, logs.size(), '1 process log should be generated');
        Assert.areEqual(typ, logs[0].Type__c, 'Type should be set');
        Assert.areEqual('Test error message', logs[0].Message__c, 'Message should be set');
        Assert.areEqual('Test Process', logs[0].Process__c, 'Process should be set');
        Assert.isNotNull(logs[0].Additional_Data__c, 'Additional data should be set');

        List<String> errs = util.getErrors();
        Assert.areEqual(1, errs.size(), '1 error should be logged');
        Assert.areEqual(
                logs[0].Additional_Data__c,
                errs[0].trim(),
                'Error detail should be equal to additional data that was set'
        );
    }
}