/*****************************************************************
 *                                                               *
 * Copyright 2020-2023 Open Text. All Rights Reserved.           *
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
 
package com.mfcobolbook.lambda; 
import java.math.BigDecimal;
import java.time.LocalDate;

public class CalculationRequest {
    private int accountId; 
    private BigDecimal dayRate ; 
    private BigDecimal startingAmount; 
    private LocalDate startDate ;
    private String[][] transactions;

    public int getAccountId() {
        return accountId;
    }
    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }
    public LocalDate getStartDate() {
        return startDate;
    }
    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }
    public BigDecimal getDayRate() {
        return dayRate;
    }
    public void setDayRate(BigDecimal dayRate) {
        this.dayRate = dayRate;
    }
    public BigDecimal getStartingAmount() {
        return startingAmount;
    }
    public void setStartingAmount(BigDecimal startingAmount) {
        this.startingAmount = startingAmount;
    }
    public String[][] getTransactions() {
        return transactions;
    }
    public void setTransactions(String[][] transactions) {
        this.transactions = transactions;
    }
    @Override
    public String toString() {
        return String.format("CR: %s %s %d transactions", getDayRate().toPlainString(), getStartingAmount().toPlainString(), getTransactions().length) ; 
    }
    

}
