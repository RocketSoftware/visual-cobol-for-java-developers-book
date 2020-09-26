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
