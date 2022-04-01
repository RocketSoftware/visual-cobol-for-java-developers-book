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
 
package com.mfcobolbook.creditservice.test;

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

import com.mfcobolbook.businessinterop.MonthlyInterest;
import com.mfcobolbook.businessinterop.RecordNotFoundException;
import com.mfcobolbook.businessinterop.TransactionDto;
import com.mfcobolbook.database.CsvReader;

public class InteropTest {
    private static BigDecimal DAILY_RATE = new BigDecimal(0.1)
            .divide(new BigDecimal(365), 10, RoundingMode.HALF_UP);

    private List<TransactionDto> transactions; 
    
    
    @Before
    public void initTestData() throws IOException {
        InputStream csvStream = getCsvStream("transaction.csv");
        transactions = new ArrayList<TransactionDto>(); 
        try (CsvReader reader = new CsvReader(csvStream)) {
            for (String[] row : reader.getRows()) {
                TransactionDto dto = new TransactionDto(
                        Integer.parseInt(row[0]), 
                        Integer.parseInt(row[1]), 
                        parseDateString(row[2]), 
                        new BigDecimal(row[3]), 
                        row[4]); 
                transactions.add(dto) ; 
            }
        }
    }

    private LocalDate parseDateString(String s ) {
        int year = Integer.parseInt(s.substring(0,4));
        int month = Integer.parseInt(s.substring(4,6)); 
        int day = Integer.parseInt(s.substring(6,8)); 
        return LocalDate.of(year, month, day ) ; 
    }

    private InputStream getCsvStream(String source) throws IOException {
        return InteropTest.class.getClassLoader()
                .getResourceAsStream(source);
        
    }

    @Test
    public void createMonthlyStatement() {

        BigDecimal startingAmount = new BigDecimal(100);
        LocalDate startDate = LocalDate.of(2019, 7, 1);
        int accountId = 20;
        MonthlyInterest statement = new MonthlyInterest();
        statement.init(DAILY_RATE, startingAmount, startDate,
                accountId, transactions);
        statement.getEndingAmount();
        assertTrue(statement.getEndingAmount()
                .compareTo(new BigDecimal(0)) > 0);
    }

    @Test(expected = RecordNotFoundException.class)
    public void createMonthlyStatementNoTransactions() {

        BigDecimal startingAmount = new BigDecimal(100);
        LocalDate startDate = LocalDate.of(2019, 7, 1);
        int accountId = 20;
        MonthlyInterest statement = new MonthlyInterest();
        statement.init(DAILY_RATE, startingAmount, startDate,
                accountId, new ArrayList<TransactionDto>());
        statement.getEndingAmount();
    }



}
