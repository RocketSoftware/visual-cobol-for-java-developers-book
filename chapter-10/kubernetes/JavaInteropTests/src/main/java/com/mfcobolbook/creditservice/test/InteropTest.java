/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 
package com.mfcobolbook.creditservice.test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.mfcobolbook.businessinterop.AbstractBusinessAccess;
import com.mfcobolbook.businessinterop.AccountDataAccess;
import com.mfcobolbook.businessinterop.AccountDto;
import com.mfcobolbook.businessinterop.CustomerDataAccess;
import com.mfcobolbook.businessinterop.CustomerDto;
import com.mfcobolbook.businessinterop.MonthlyInterest;
import com.mfcobolbook.businessinterop.RecordNotFoundException;
import com.mfcobolbook.businessinterop.TransactionDataAccess;
import com.mfcobolbook.businessinterop.TransactionDto;
import com.mfcobolbook.database.DatabaseInitializerWrapper;

public class InteropTest {
    private static BigDecimal DAILY_RATE = new BigDecimal(0.1)
            .divide(new BigDecimal(365), 10, RoundingMode.HALF_UP);

    private static final int CUSTOMER_ID_FOR_DELETION = 22;
    private static final int ACCOUNT_ID_FOR_DELETION = 23;

    private DatabaseInitializerWrapper databaseInitializerWrapper;

    @Before
    public void initTestData() throws IOException {
        databaseInitializerWrapper = new DatabaseInitializerWrapper();
        createEmptyTables();
        populateTables();
    }

    private void populateTables() throws IOException {
        InputStream csvStream = getCsvStream("customer.csv");
        databaseInitializerWrapper.loadCustomerData(csvStream);
        csvStream = getCsvStream("account.csv");
        databaseInitializerWrapper.loadAccountData(csvStream);
        csvStream = getCsvStream("transaction.csv");
        databaseInitializerWrapper.loadTransactionData(csvStream);
    }

    private void createEmptyTables() {
        databaseInitializerWrapper.dropAndCreateTables();
    }

    private void addCustomerToEmpty() {
        CustomerDto customer = new CustomerDto(0, "Cherin",
                "Mureil");
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.write);
            cda.addCustomer(customer);
        }
    }

    private void addAccountToEmpty() {
        final BigDecimal newBalance = new BigDecimal(35.50);
        final BigDecimal creditLimit = new BigDecimal(5000);
        addCustomerToEmpty();
        AccountDto account = new AccountDto(0, 1, newBalance,
                (byte) 'c', creditLimit);
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.write);
            ada.addAccount(account);
        }

    }

    private InputStream getCsvStream(String source) throws IOException {
        return InteropTest.class.getClassLoader()
                .getResourceAsStream(source);
        
    }

    @Test
    public void readAllCustomers() throws Exception {
        int count = 0;
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.read);
            for (CustomerDto dto : cda.getCustomers()) {
                count++;
                assertTrue(dto != null);
                System.out.println(String.format("%s %s",
                        dto.getFirstName(), dto.getLastName()));
            }
            assertTrue(count > 1);
        }
    }

    @Test
    public void readLastCustomer() {
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.read);
            CustomerDto dto = cda.getLastCustomer();
            assertTrue(dto != null);
            assertEquals(22, dto.getCustomerId());
            System.out.println(String.format("%s %s",
                    dto.getFirstName(), dto.getLastName()));
        }

    }

    @Test
    public void readNonExistentCustomer() {
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.read);
            CustomerDto dto = cda.getCustomer(2000);
            assertNull(dto);
        }
    }

    @Test
    public void updateCustomer() {
        int id = 2;
        String newLastName = "Vonnegut";
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.rw);
            CustomerDto dto = cda.getCustomer(id);
            assertNotNull(dto);
            dto.setLastName(newLastName);
            assertTrue(cda.updateCustomer(dto));
        }
        try (CustomerDataAccess ada = new CustomerDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            CustomerDto dto = ada.getCustomer(id);
            assertTrue(dto != null);
            assertEquals(newLastName, dto.getLastName());
        }
    }

    @Test
    public void createMonthlyStatement() {

        BigDecimal startingAmount = new BigDecimal(100);
        LocalDate startDate = LocalDate.of(2019, 7, 1);
        int accountId = 20;
        MonthlyInterest statement = new MonthlyInterest();
        statement.init(DAILY_RATE, startingAmount, startDate,
                accountId);
        statement.getEndingAmount();
        assertTrue(statement.getEndingAmount()
                .compareTo(new BigDecimal(0)) > 0);
    }

    @Test
    public void addAccountToEnd() {
        final BigDecimal balance = new BigDecimal(35.50);
        final BigDecimal creditLimit = new BigDecimal(5000);
        int id = 0;
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.rw);
            AccountDto dto = new AccountDto(0, 1, balance,
                    (byte) 'C', creditLimit);
            id = ada.addAccount(dto);
        }

        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            AccountDto dto = ada.getAccount(id);
            assertTrue(dto != null);
            assertTrue(creditLimit
                    .compareTo(dto.getCreditLimit()) == 0);
        }
    }

    /**
     * Regression test for a bug where the account id was calculated incorrectly
     * from the customerid
     */
    @Test
    public void regressionAddAccountWhereCustomerIdCausesDuplicateAccoundId() {

        final BigDecimal balance = new BigDecimal(35.50);
        final BigDecimal creditLimit = new BigDecimal(5000);
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.rw);
            AccountDto dto = new AccountDto(0, 1, balance,
                    (byte) 'C', creditLimit);
            ada.addAccount(dto);
        }
        // will throw exception if the index is being calculated incorrectly.
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.rw);
            AccountDto dto = new AccountDto(0, 1, balance,
                    (byte) 'C', creditLimit);
            ada.addAccount(dto);
        }

    }

    @Test
    public void addAccountToEmptyFile() throws Exception {
        final BigDecimal balance = new BigDecimal(35.50);
        final BigDecimal creditLimit = new BigDecimal(5000);
        createEmptyTables();
        addCustomerToEmpty();
        int id = 0;
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.rw);
            AccountDto dto = new AccountDto(0, 1, balance,
                    (byte) 'C', creditLimit);
            id = ada.addAccount(dto);
        }

        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            AccountDto dto = ada.getAccount(id);
            assertTrue(dto != null);
            assertEquals(1, id);
            assertTrue(creditLimit
                    .compareTo(dto.getCreditLimit()) == 0);
        }
    }

    @Test
    public void deleteAccount() {
        try (AccountDataAccess cda = new AccountDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.rw);
            AccountDto dto = cda
                    .getAccount(ACCOUNT_ID_FOR_DELETION);
            assertTrue(dto != null);
            assertTrue(cda.deleteAccount(ACCOUNT_ID_FOR_DELETION));
            dto = cda.getAccount(ACCOUNT_ID_FOR_DELETION);
            assertNull(dto);
        }
    }

    @Test
    public void updateAccount() {
        final BigDecimal newBalance = new BigDecimal(35.50);
        BigDecimal currentBalance;
        int id = 2;
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.rw);
            AccountDto dto = ada.getAccount(id);
            assertNotNull(dto);
            currentBalance = dto.getBalance();
            dto.setBalance(newBalance);
            assertTrue(ada.updateAccount(dto));
        }

        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            AccountDto dto = ada.getAccount(id);
            assertTrue(dto != null);
            assertTrue(currentBalance
                    .compareTo(dto.getBalance()) == 1);
        }
    }

    @Test
    public void updateNonExistentAccount() {
        final BigDecimal newBalance = new BigDecimal(35.50);
        final BigDecimal creditLimit = new BigDecimal(5000);
        int id = 99999;
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.rw);
            AccountDto dto = new AccountDto(id, id, newBalance,
                    (byte) 'c', creditLimit);
            assertFalse(ada.updateAccount(dto));
        }
    }

    @Test
    public void printAllStatements() {
        BigDecimal startingAmount = new BigDecimal(100);
        LocalDate startDate = LocalDate.of(2018, 1, 1);
        for (int accountId = 59; accountId <= 59; accountId++) {
            try {
                MonthlyInterest statement = new MonthlyInterest();
                statement.init(DAILY_RATE, startingAmount,
                        startDate, accountId);
                assertTrue(statement.getEndingAmount()
                        .compareTo(new BigDecimal(0)) > 0);
            }

            catch (RecordNotFoundException e) {
                System.out.println(e.getMessage());
            }
        }
    }

    @Test
    public void readAccount() {
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            AccountDto dto = ada.getAccount(1);
            assertTrue(dto != null);
            System.out
                    .println(String
                            .format("%d %d %s", dto.getAccountId(),
                                    dto.getCustomerId(),
                                    dto.getCreditLimit())
                            .toString());
        }
    }

    @Test
    public void readNonExistentAccount() {
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            AccountDto dto = ada.getAccount(2001);
            assertNull(dto);
        }
    }

    @Test
    public void closeWithoutOpening() {
        try (AccountDataAccess ada = new AccountDataAccess()) {
            System.out.println("Inside try-with-resources");
        }
    }

    @Test
    public void readAllAccounts() {
        int count = 0;
        try (AccountDataAccess cda = new AccountDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.read);

            cda.getAccounts()
                    .forEach((dto) -> System.out.println(String
                            .format("%d %d %s", dto.getAccountId(),
                                    dto.getCustomerId(),
                                    dto.getCreditLimit())
                            .toString()));

            for (AccountDto dto : cda.getAccounts()) {
                count++;
                assertTrue(dto != null);
                System.out.println(String.format("%d %d %s",
                        dto.getAccountId(), dto.getCustomerId(),
                        dto.getCreditLimit()).toString());
            }
            assertTrue(count > 1);
        }
    }

    @Test
    public void forEachAllAccounts() {
        try (AccountDataAccess cda = new AccountDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.read);
            cda.getAccounts()
                    .forEach((dto) -> System.out.println(String
                            .format("%d %d %s", dto.getAccountId(),
                                    dto.getCustomerId(),
                                    dto.getCreditLimit())
                            .toString()));
        }
    }

    @Test
    public void readTransaction() {
        try (AccountDataAccess ada = new AccountDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);

            AccountDto dto = ada.getAccount(1);
            assertTrue(dto != null);
            System.out
                    .println(String
                            .format("%d %d %s", dto.getAccountId(),
                                    dto.getCustomerId(),
                                    dto.getCreditLimit())
                            .toString());
        }
    }

    @Test
    public void addTransactionToEnd() throws Exception {
        final BigDecimal amount = new BigDecimal(35.50);
        final LocalDate transactionDate = LocalDate
                .parse("2019-07-01");
        final String description = "Virconium tickets";
        int id = 0;
        try (TransactionDataAccess tda = new TransactionDataAccess()) {
            tda.open(AbstractBusinessAccess.OpenMode.rw);
            TransactionDto dto = new TransactionDto(0, 1,
                    transactionDate, amount, description);
            id = tda.addTransaction(dto);
        }

        try (TransactionDataAccess ada = new TransactionDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            TransactionDto dto = ada.getTransaction(id);
            assertTrue(dto != null);
            assertTrue(amount.compareTo(dto.getAmount()) == 0);
        }
    }

    @Test
    public void addTransactionToEmptyFile() throws Exception {
        createEmptyTables();
        addAccountToEmpty();
        final BigDecimal amount = new BigDecimal(35.50);
        final LocalDate transactionDate = LocalDate
                .parse("2019-07-01");
        final String description = "Virconium tickets";
        int id = 0;
        try (TransactionDataAccess tda = new TransactionDataAccess()) {
            tda.open(AbstractBusinessAccess.OpenMode.rw);
            TransactionDto dto = new TransactionDto(0, 1,
                    transactionDate, amount, description);
            id = tda.addTransaction(dto);
        }

        try (TransactionDataAccess ada = new TransactionDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            TransactionDto dto = ada.getTransaction(id);
            assertTrue(dto != null);
            assertTrue(amount.compareTo(dto.getAmount()) == 0);
            assertEquals(1, dto.getTransactionId());
        }
    }

    @Test
    public void deleteTransaction() {
        try (TransactionDataAccess tda = new TransactionDataAccess()) {
            tda.open(AbstractBusinessAccess.OpenMode.rw);
            TransactionDto dto = tda.getTransaction(1);
            assertTrue(dto != null);
            assertTrue(tda.deleteTransaction(1));
            dto = tda.getTransaction(1);
            assertNull(dto);
        }
    }

    @Test
    public void updateTransaction() {
        BigDecimal currentAmount;
        int id = 2;
        try (TransactionDataAccess tda = new TransactionDataAccess()) {
            tda.open(AbstractBusinessAccess.OpenMode.rw);
            TransactionDto dto = tda.getTransaction(id);
            assertNotNull(dto);
            currentAmount = dto.getAmount();
            dto.setAmount(
                    currentAmount.multiply(new BigDecimal(10)));
            assertTrue(tda.updateTransaction(dto));
        }

        try (TransactionDataAccess ada = new TransactionDataAccess()) {
            ada.open(AbstractBusinessAccess.OpenMode.read);
            TransactionDto dto = ada.getTransaction(id);
            assertTrue(dto != null);
            assertTrue(
                    currentAmount.compareTo(dto.getAmount()) == -1);
        }
    }

    @Test
    public void readAllTransactionsForAccount() {
        int count = 0;
        try (TransactionDataAccess tda = new TransactionDataAccess()) {
            tda.open(AbstractBusinessAccess.OpenMode.read);
            for (TransactionDto dto : tda
                    .getTransactionsByAccount(4)) {
                count++;
                assertTrue(dto != null);
                System.out.println(String.format("%d %d %s",
                        dto.getAccountId(), dto.getTransactionId(),
                        dto.getDescription()));
                assertEquals(4, dto.getAccountId());
            }
            assertTrue(count > 1);
        }
    }

    @Test
    public void shouldNotReturnNonExistentTransactionsForAccount() {
        final List<TransactionDto> transactions = new ArrayList<TransactionDto>();
        try (TransactionDataAccess tda = new TransactionDataAccess()) {
            tda.open(AbstractBusinessAccess.OpenMode.read);
            tda.getTransactionsByAccount(444455).forEach(
                    (TransactionDto dto) -> transactions.add(dto));
        }
        assertTrue(transactions.size() == 0);
    }

    @Test
    public void deleteCustomer() {
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.rw);
            CustomerDto dto = cda.getCustomer(1);
            assertTrue(dto != null);
            assertTrue(
                    cda.deleteCustomer(CUSTOMER_ID_FOR_DELETION));
            dto = cda.getCustomer(CUSTOMER_ID_FOR_DELETION);
            assertNull(dto);
            assertFalse(
                    cda.deleteCustomer(CUSTOMER_ID_FOR_DELETION));
        }
    }

    @Test
    public void addCustomerToEnd() {
        int id = 0;
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.write);
            CustomerDto dto = new CustomerDto(0, "Jim", "Moriarty");
            id = cda.addCustomer(dto);
        }

        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.read);
            CustomerDto dto = cda.getCustomer(id);
            assertTrue(dto != null);
            System.out.println(String.format("%s %s",
                    dto.getFirstName(), dto.getLastName()));
        }
    }

    @Test
    public void addCustomerToEmptyFile() throws Exception {
        createEmptyTables();
        int id = 0;
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.write);
            CustomerDto dto = new CustomerDto(0, "Jim", "Moriarty");
            id = cda.addCustomer(dto);
        }

        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.read);
            CustomerDto dto = cda.getCustomer(id);
            assertTrue(dto != null);
            assertEquals(1, id);
            System.out.println(String.format("%s %s",
                    dto.getFirstName(), dto.getLastName()));
        }
    }

    @Test
    public void readCustomer() throws Exception {
        try (CustomerDataAccess cda = new CustomerDataAccess()) {
            cda.open(AbstractBusinessAccess.OpenMode.read);
            CustomerDto dto = cda.getCustomer(1);
            assertTrue(dto != null);
            System.out.println(String.format("%s %s",
                    dto.getFirstName(), dto.getLastName()));
        }
    }

}
