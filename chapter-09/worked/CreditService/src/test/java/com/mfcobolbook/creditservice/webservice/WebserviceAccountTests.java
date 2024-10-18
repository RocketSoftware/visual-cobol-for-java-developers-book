/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 
package com.mfcobolbook.creditservice.webservice;

import static io.restassured.RestAssured.given;
import static io.restassured.RestAssured.when;
import static org.hamcrest.Matchers.closeTo;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThat;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Collections;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.junit4.SpringRunner;

import com.mfcobolbook.businessinterop.AbstractBusinessAccess;
import com.mfcobolbook.businessinterop.AccountDataAccess;
import com.mfcobolbook.businessinterop.AccountDto;
import com.mfcobolbook.creditservice.forms.AccountForm;
import com.microfocus.cobol.runtimeservices.generic.RunUnit;

@RunWith(SpringRunner.class)
@SpringBootTest
public class WebserviceAccountTests
        extends WebserviceApplicationTests {

    private static final String ID = "id";

    private static final String CUSTOMER_ID = "customerId";
    private static final String BALANCE = "balance";
    private static final String CREDIT_LIMIT = "creditLimit";

//  TODO UNCOMMENT THE LINE BELOW
//    private static final int ACCOUNT_ID_FOR_DELETION = 23;

//    TODO Change the constant below from 300 to 21
    private static final int CUSTOMER_ID_DATA = 300;

    private static final float BALANCE_DATA = 5432.0f;
    private static final byte TYPE_DATA = 'C';
    private static final float CREDIT_LIMIT_DATA = 10000.00f;
    private static final BigDecimal BIG_DECIMAL_ERROR = new BigDecimal(
            0.001);

    @BeforeClass
    public static void setup() {
        WebserviceApplicationTests.setup();
    }

    @Before
    public void initTestData() throws IOException {
        super.initTestData();
    }

    @Test
    public void shouldLoadAccount() {
        when().get("/service/account/1").then().assertThat()
                .body(ID, equalTo(1)).body(CUSTOMER_ID, equalTo(1))
                .body(BALANCE, equalTo(989.99f))
                .body(CREDIT_LIMIT, equalTo(3000.00f));
    }

    @Test
    public void shouldDisplayAllAccounts() {
//      TODO Change the expected size from 21 to 22 
        when().get("/service/account/").then().assertThat()
                .body("array", hasSize(21));
    }

    @Test
    public void shouldAddNewAccount() {
        AccountForm account = new AccountForm(new AccountDto(0,
                CUSTOMER_ID_DATA, new BigDecimal(BALANCE_DATA),
                TYPE_DATA, new BigDecimal(CREDIT_LIMIT_DATA)));

//      TODO Change the expected id from 22 to 24
        given().body(account)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().post("/service/account/").then()
                .assertThat().statusCode(equalTo(200))
                .body(ID, equalTo(22))
                .body(CUSTOMER_ID, equalTo(CUSTOMER_ID_DATA))
                .body(BALANCE, equalTo(5432))
                .body(CREDIT_LIMIT, equalTo(10000));

//      TODO Change id to fetch from 22 to 24
        try (RunUnit<AccountDataAccess> ru = new RunUnit<>(
                AccountDataAccess.class)) {
            try (AccountDataAccess accessor = (AccountDataAccess) ru
                    .GetInstance(AccountDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess.OpenMode.read);
                AccountDto dto = accessor.getAccount(22);
                assertNotNull(dto);
                assertThat(dto.getCustomerId(),
                        equalTo(CUSTOMER_ID_DATA));
                assertThat(dto.getBalance(),
                        closeTo(new BigDecimal(BALANCE_DATA),
                                BIG_DECIMAL_ERROR));
                assertThat(dto.getCreditLimit().intValue(),
                        equalTo((int) CREDIT_LIMIT_DATA));

            }
        }
    }

    @Test
    public void shouldDeleteAccount() {

//      TODO Replace the statement below with the commented out 
//      statement
        when().delete("/service/account/1").then().assertThat()
                .statusCode(HttpStatus.NO_CONTENT.value());

//        when().delete(String.format("/service/account/%d",
//                ACCOUNT_ID_FOR_DELETION)).then().assertThat()
//               .statusCode(HttpStatus.NO_CONTENT.value());
        
//      TODO Replace the statement below with the commented out 
//      statement
        when().get("/service/account/1").then().assertThat()
                .statusCode(HttpStatus.NOT_FOUND.value());

//        when().get(String.format("/service/account/%d",
//                ACCOUNT_ID_FOR_DELETION)).then().assertThat()
//                .statusCode(HttpStatus.NOT_FOUND.value());

        
        when().delete("/service/account/1").then().assertThat()
                .statusCode(HttpStatus.NOT_FOUND.value());

    }

    @Test
    public void shouldUpdateExistingAccount() {
        AccountForm account = new AccountForm(new AccountDto(1,
                CUSTOMER_ID_DATA, new BigDecimal(BALANCE_DATA),
                TYPE_DATA, new BigDecimal(CREDIT_LIMIT_DATA)));

        given().body(account)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().put("/service/account/").then().assertThat()
                .statusCode(equalTo(HttpStatus.NO_CONTENT.value()));

        when().get("/service/account/1").then().assertThat()
                .body(ID, equalTo(1))
                .body(CUSTOMER_ID, equalTo(CUSTOMER_ID_DATA))
                .body(BALANCE, equalTo(BALANCE_DATA))
                .body(CREDIT_LIMIT, equalTo(CREDIT_LIMIT_DATA));
    }

    @Test
    public void shouldNotUpdateForNewAccount() {
        AccountForm account = new AccountForm(new AccountDto(999,
                CUSTOMER_ID_DATA, new BigDecimal(BALANCE_DATA),
                TYPE_DATA, new BigDecimal(CREDIT_LIMIT_DATA)));

        given().body(account)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().put("/service/account/").then().assertThat()
                .statusCode(equalTo(HttpStatus.NOT_FOUND.value()));
    }
}
