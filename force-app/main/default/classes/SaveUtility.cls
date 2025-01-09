public with sharing class SaveUtility {
    private String processName;
    private String errMsgPrefix;
    private System.AccessLevel accessLevel;
    private List<String> errorDetails;

    public SaveUtility(String processName, String errMsgPrefix) {
        this.processName = processName;
        this.errMsgPrefix = errMsgPrefix;
        this.accessLevel = System.AccessLevel.USER_MODE;
        this.errorDetails = new List<String>();
    }

    public void setAccessLevel(System.AccessLevel lvl) {
        accessLevel = lvl;
    }

    public List<String> getErrors() {
        return errorDetails;
    }

    public SObject insertRecord(SObject record) {
        Database.SaveResult result = Database.insert(record, false, accessLevel);
        if (!result.isSuccess()) {
            ProcessLog log = generateLog(result, ProcessLogConstants.INSERT_TYPE);
            saveErrorDetails(log.create());
            return null;
        }
        return record;
    }

    public SObject updateRecord(SObject record) {
        Database.SaveResult result = Database.update(record, false, accessLevel);
        if (!result.isSuccess()) {
            ProcessLog log = generateLog(result, ProcessLogConstants.UPDATE_TYPE);
            saveErrorDetails(log.create());
            return null;
        }
        return record;
    }

    public SObject upsertRecord(SObject record) {
        Database.UpsertResult result = Database.upsert(record, false, accessLevel);
        if (!result.isSuccess()) {
            ProcessLog log = generateLog(result);
            saveErrorDetails(log.create());
            return null;
        }
        return record;
    }

    public List<SObject> bulkInsert(List<SObject> records) {
        List<Database.SaveResult> results = Database.insert(records, false, accessLevel);
        List<SObject> savedRecords = new List<SObject>();
        Integer i = 0;
        List<Process_Log__c> entries = new List<Process_Log__c>();
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                ProcessLog log = generateLog(result, ProcessLogConstants.INSERT_TYPE);
                entries.add(log.create());
                Logger.push(log);
            } else {
                savedRecords.add(records[i]);
            }
            i++;
        }
        Logger.flush();
        saveErrorDetails(entries);
        return savedRecords;
    }

    public List<SObject> bulkUpdate(List<SObject> records) {
        List<Database.SaveResult> results = Database.update(records, false, accessLevel);
        List<SObject> savedRecords = new List<SObject>();
        Integer i = 0;
        List<Process_Log__c> entries = new List<Process_Log__c>();
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                ProcessLog log = generateLog(result, ProcessLogConstants.UPDATE_TYPE);
                entries.add(log.create());
                Logger.push(log);
            } else {
                savedRecords.add(records[i]);
            }
            i++;
        }
        Logger.flush();
        saveErrorDetails(entries);
        return savedRecords;
    }

    public List<SObject> bulkUpsert(List<SObject> records) {
        List<Database.UpsertResult> results = Database.upsert(records, false, accessLevel);
        List<SObject> savedRecords = new List<SObject>();
        Integer i = 0;
        List<Process_Log__c> entries = new List<Process_Log__c>();
        for (Database.UpsertResult result : results) {
            if (!result.isSuccess()) {
                ProcessLog log = generateLog(result);
                entries.add(log.create());
                Logger.push(log);
            } else {
                savedRecords.add(records[i]);
            }
            i++;
        }
        Logger.flush();
        saveErrorDetails(entries);
        return savedRecords;
    }

    private ProcessLog generateLog(Database.UpsertResult result) {
        return generateLog(ProcessLogConstants.UPSERT_TYPE, result.getId(), result.getErrors());
    }

    private ProcessLog generateLog(Database.SaveResult result, String typ) {
        return generateLog(typ, result.getId(), result.getErrors());
    }

    private ProcessLog generateLog(String typ, Id recId, List<Database.Error> errs) {
        String dmlErrorDetails = 'DML Error Details: ';
        for (Database.Error dbError : errs) {
            dmlErrorDetails += 'Status Code = ' + dbError.getStatusCode();
            dmlErrorDetails += '; Message = ' + dbError.getMessage();
            dmlErrorDetails += '; Fields: ' + dbError.getFields();
            dmlErrorDetails += ' **** ';
        }
        return new ProcessLog(processName)
                .type(typ)
                .relatedRecord(recId)
                .message(errMsgPrefix)
                .additionalData(dmlErrorDetails);
    }

    private void saveErrorDetails(Process_Log__c log) {
        saveErrorDetails(new List<Process_Log__c>{ log });
    }

    private void saveErrorDetails(List<Process_Log__c> logs) {
        for (Process_Log__c log : logs) {
            this.errorDetails.add(log.Additional_Data__c);
        }
    }
}