/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 
package com.mfcobolbook.creditservice.webservice;

import static io.restassured.RestAssured.given;
import static io.restassured.RestAssured.when;

import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.emptyArray;
import static org.hamcrest.Matchers.not;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThat;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collections;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.junit4.SpringRunner;

import com.mfcobolbook.businessinterop.AbstractBusinessAccess ;
import com.mfcobolbook.businessinterop.TransactionDataAccess;
import com.mfcobolbook.businessinterop.TransactionDto;
import com.mfcobolbook.creditservice.forms.TransactionForm;
import com.microfocus.cobol.runtimeservices.generic.RunUnit;

@RunWith(SpringRunner.class)
@SpringBootTest
public class WebserviceTransactionTests extends WebserviceApplicationTests {

    private static final String ID = "id";

    
    private static final String ACCOUNT_ID = "accountId";
    private static final String TRANS_DATE = "transDate";
    private static final String AMOUNT = "amount";
    private static final String DESCRIPTION = "description";

    private static final float CREDIT_LIMIT_DATA = 10000.00f;
    private static final float AMOUNT_DATA = 334.50f;

    private static final int ACCOUNT_ID_DATA = 300;
    private static final float TRANSACTION_AMOUNT_DATA = 55.50f;
    private static final String FIRST_TRANSACTION_DATE = "20190701";
    private static final LocalDate TRANSACTION_DATE_DATA = LocalDate.now();
    private static final String DESCRIPTION_DATA = "My first transaction data";
    
    private static final int NEW_TRANSACTION_ID = 280;

    @BeforeClass
    public static void setup() {
        WebserviceApplicationTests.setup();
    }

    @Before
    public void initTestData() throws IOException {
        super.initTestData();
    }

    @Test
    public void testFindByAccountId() {
        
    }
    
    @Test
    public void shouldLoadTransaction() {
        when().get("/service/transaction/1").then().assertThat()
            .statusCode(HttpStatus.OK.value())
                .body(ID, equalTo(1))
                .body(ACCOUNT_ID, equalTo(1))
                .body(AMOUNT, equalTo(60.08f))
                .body(TRANS_DATE, equalTo(FIRST_TRANSACTION_DATE));
    }

    @Test
    public void shouldAddNewTransaction() {
        TransactionForm transaction = new TransactionForm(
                new TransactionDto(0, ACCOUNT_ID_DATA,
                        TRANSACTION_DATE_DATA,
                        new BigDecimal(AMOUNT_DATA),
                        DESCRIPTION_DATA));

        given().body(transaction)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().post("/service/transaction/").then().assertThat()
                .statusCode(equalTo(200))
                .body(ID, equalTo(NEW_TRANSACTION_ID))
                .body(ACCOUNT_ID, equalTo(ACCOUNT_ID_DATA))
                .body(AMOUNT, equalTo(AMOUNT_DATA))
                .body(DESCRIPTION, equalTo(DESCRIPTION_DATA));

        try (RunUnit<TransactionDataAccess> ru = new RunUnit<>(
                TransactionDataAccess.class)) {
            try (TransactionDataAccess accessor = (TransactionDataAccess) ru
                    .GetInstance(TransactionDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.read);
                TransactionDto dto = accessor.getTransaction(NEW_TRANSACTION_ID);
                assertNotNull(dto);
                assertThat(dto.getTransactionId(),
                        equalTo(NEW_TRANSACTION_ID));
                assertThat(dto.getAmount().floatValue(),
                        equalTo(AMOUNT_DATA));
                assertThat(dto.getDescription(),
                        equalTo(DESCRIPTION_DATA));
            }
        }
    }

    @Test
    public void shouldDeleteTransaction() {
        when().delete("/service/transaction/1").then().assertThat()
                .statusCode(HttpStatus.NO_CONTENT.value());

        when().get("/service/transaction/1").then().assertThat()
                .statusCode(HttpStatus.NOT_FOUND.value());

        when().delete("/service/transaction/1").then().assertThat()
                .statusCode(HttpStatus.NOT_FOUND.value());

    }

    @Test
    public void shouldUpdateExistingTransaction() {
        TransactionForm transaction = new TransactionForm(
                new TransactionDto(1, ACCOUNT_ID_DATA, TRANSACTION_DATE_DATA, 
                        new BigDecimal(TRANSACTION_AMOUNT_DATA), DESCRIPTION_DATA));

        given().body(transaction)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().put("/service/transaction/").then().assertThat()
                .statusCode(equalTo(HttpStatus.NO_CONTENT.value()));

        when().get("/service/transaction/1").then().assertThat()
                .body(ID, equalTo(1))
                .body(ACCOUNT_ID, equalTo(ACCOUNT_ID_DATA))
                .body(TRANS_DATE, equalTo(formatDateAsString(TRANSACTION_DATE_DATA)))
                .body(AMOUNT, equalTo(TRANSACTION_AMOUNT_DATA))
                .body(DESCRIPTION, equalTo(DESCRIPTION_DATA)); 
    }

    @Test
    public void shouldNotUpdateForNewTransaction() {
        TransactionForm transaction = new TransactionForm(
                new TransactionDto(9999, ACCOUNT_ID_DATA,
                        TRANSACTION_DATE_DATA,
                        new BigDecimal(CREDIT_LIMIT_DATA),
                        DESCRIPTION_DATA));

        given().body(transaction)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().put("/service/transaction/").then().assertThat()
                .statusCode(equalTo(HttpStatus.NOT_FOUND.value()));
    }
    
    @Test
    public void shouldReadTransactionsForAccount() { 
        when().get("service/transaction/account/1")
            .then().assertThat()
            .statusCode(HttpStatus.OK.value())
            .body("array", not(emptyArray())); 
    }
    
    @Test
    public void shouldReturnNotFoundForNoTransactions() {
        when().get("service/transaction/account/99999")
        .then().assertThat()
        .statusCode(HttpStatus.NOT_FOUND.value());
    }
    

    private static String formatDateAsString(
            LocalDate transactionDateData) {
        return DateTimeFormatter.BASIC_ISO_DATE.format(transactionDateData) ;
    }

}
