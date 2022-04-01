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

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.mfcobolbook.businessinterop.MonthlyInterest;
import com.mfcobolbook.businessinterop.StatementDto;
import com.microfocus.cobol.runtimeservices.generic.RunUnit;

@RestController
@RequestMapping("/service/account")
public class StatementController {
    private static final Logger LOGGER = LoggerFactory
            .getLogger(StatementController.class);

    @GetMapping(value = "/{id}/statement/{date}") 
    public ResponseEntity<StatementDto> calculateStatement(
            @PathVariable("id") int id, 
            @PathVariable("date") String date,
            @RequestParam("rate") String rate, 
            @RequestParam("initialBalance") String balance) {
        BigDecimal dailyRate = null;
        BigDecimal initialBalance = null;
        LocalDate localDate = LocalDate.parse(date,
                DateTimeFormatter.BASIC_ISO_DATE);
        try {
            dailyRate = new BigDecimal(rate).divide(
                    (new BigDecimal(365 * 100)), 10, 
                    RoundingMode.HALF_UP);
            initialBalance = new BigDecimal(balance);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        try (RunUnit<MonthlyInterest> ru = new RunUnit<>(
                MonthlyInterest.class)) {
            MonthlyInterest statement = (MonthlyInterest) ru
                    .GetInstance(MonthlyInterest.class, true);
            try {
                statement.init(dailyRate, initialBalance, localDate,
                        id);
                return ResponseEntity.ok(
                        statement.getStatementDto());
            } catch (Exception e) {
                LOGGER.error(e.getMessage());
                return null;
            }
        }
    }
}
