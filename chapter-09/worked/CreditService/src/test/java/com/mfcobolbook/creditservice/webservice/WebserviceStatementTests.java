/*****************************************************************
 *                                                               *
 * Copyright (C) 2020-2022 Micro Focus. All Rights Reserved.     *
 * This software may be used, modified, and distributed          *
 * (provided this notice is included without modification)       *
 * solely for demonstration purposes with other                  *
 * Micro Focus software, and is otherwise subject to the EULA at *
 * https://www.microfocus.com/en-us/legal/software-licensing.    *
 *                                                               *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ALL IMPLIED             *
 * WARRANTIES, INCLUDING THE IMPLIED WARRANTIES OF               *
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,         *
 * SHALL NOT APPLY.                                              *
 * TO THE EXTENT PERMITTED BY LAW, IN NO EVENT WILL              *
 * MICRO FOCUS HAVE ANY LIABILITY WHATSOEVER IN CONNECTION       *
 * WITH THIS SOFTWARE.                                           *
 *                                                               *
 *****************************************************************/
 
package com.mfcobolbook.creditservice.webservice;

import static io.restassured.RestAssured.when;
import static org.hamcrest.Matchers.equalTo;

import java.io.IOException;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;


@RunWith(SpringRunner.class)
@SpringBootTest
public class WebserviceStatementTests extends WebserviceApplicationTests {
    
    private static final String MINIMUM_PAYMENT = "minimumPayment";

    private static final String ACCOUNT_ID = "accountId";
    private static final String INTEREST_AMOUNT = "interestAmount";
    private static final String START_DATE = "startDate";


    
    @BeforeClass
    public static void setup() {
        WebserviceApplicationTests.setup();
    }

    @Before
    public void initTestData() throws IOException {
        super.initTestData();
    }
    
    @Test
    public void testCalculateStatement() {
        when()
        .get("/service/account/1/statement/20190701?rate=25&initialBalance=100")
        .then().assertThat()
                .statusCode(200)
                .body(MINIMUM_PAYMENT, equalTo(58.85f))
                .body(ACCOUNT_ID, equalTo(1))
                .body(INTEREST_AMOUNT, equalTo(13.68f))
                .body(START_DATE, equalTo("2019-07-01"));
    }
    
    @Test
    public void testNoRateParameter() {
        when().get("/service/account/1/statement/20190701").then().assertThat()
            .statusCode(400) ;
    }
    
    


}
