/**
 * Created by lesliemartin on 1/9/25.
 */
@IsTest
public class FireAssignmentRulesTestDataFactory {
    public static List<Account> createAccounts(String accountName, Integer numberOfAccountsToCreate, Boolean insertAccounts) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfAccountsToCreate; i++) {
            accounts.add(new Account(
                    Name = accountName + i
            ));
        }

        if (insertAccounts) {
            insert accounts;
        }

        return accounts;
    }

    public static Account createAccount(String accountName, Boolean insertAccount) {
        return createAccounts(accountName, 1, insertAccount)[0];
    }

    public static List<Case> createCases(Integer numberOfCasesToCreate, Boolean insertCases) {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < numberOfCasesToCreate; i++) {
            cases.add(new Case());
        }

        if (insertCases) {
            insert cases;
        }

        return cases;
    }

    public static Case createCase(Boolean insertCase) {
        return createCases(1, insertCase)[0];
    }
}