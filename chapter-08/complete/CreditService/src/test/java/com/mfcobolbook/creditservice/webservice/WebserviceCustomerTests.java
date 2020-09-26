package com.mfcobolbook.creditservice.webservice;

import static io.restassured.RestAssured.given;
import static io.restassured.RestAssured.when;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThat;

import java.io.IOException;
import java.util.Collections;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.junit4.SpringRunner;

import com.mfcobolbook.businessinterop.AbstractBusinessAccess ;
import com.mfcobolbook.businessinterop.CustomerDataAccess;
import com.mfcobolbook.businessinterop.CustomerDto;
import com.mfcobolbook.creditservice.forms.CustomerForm;
import com.microfocus.cobol.runtimeservices.generic.RunUnit;

@RunWith(SpringRunner.class)
@SpringBootTest
public class WebserviceCustomerTests extends WebserviceApplicationTests {

    private static final String FIRST_NAME = "firstName";
    private static final String LAST_NAME = "lastName";
    private static final String ID = "id";


    private static final String FIRST_NAME_DATA = "Neal";
    private static final String LAST_NAME_DATA = "Gibson";
    private static final int NEW_CUSTOMER_ID = 22;


    @BeforeClass
    public static void setup() {
        WebserviceApplicationTests.setup();
    }

    @Before
    public void initTestData() throws IOException {
        super.initTestData();
    }

     @Test
    public void contextLoads() {
    }

    @Test
    public void shouldLoadCustomer() {
        when().get("/service/customer/1").then().assertThat()
                .body(ID, equalTo(1)).body(FIRST_NAME, equalTo("Marthe"))
                .body(LAST_NAME, equalTo("Widdison"));
    }

    @Test
    public void shouldDisplayAllCustomers() {
        when().get("/service/customer/").
            then().assertThat().body("array",
                hasSize(21));
    }

    @Test
    public void shouldAddNewCustomer() {
        CustomerForm customer = new CustomerForm(
                new CustomerDto(0, FIRST_NAME_DATA, LAST_NAME_DATA));

        given().body(customer)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().post("/service/customer/").then().assertThat()
                .statusCode(equalTo(200))
                .body(ID, equalTo(NEW_CUSTOMER_ID))
                .body(FIRST_NAME, equalTo(FIRST_NAME_DATA))
                .body(LAST_NAME, equalTo(LAST_NAME_DATA));

        try (RunUnit<CustomerDataAccess> ru = new RunUnit<>(
                CustomerDataAccess.class)) {
            try (CustomerDataAccess accessor = (CustomerDataAccess) ru
                    .GetInstance(CustomerDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.read);
                CustomerDto dto = accessor.getCustomer(NEW_CUSTOMER_ID);
                assertNotNull(dto);
                assertThat(dto.getFirstName(), equalTo(FIRST_NAME_DATA));
                assertThat(dto.getLastName(), equalTo(LAST_NAME_DATA));
            }
        }
    }

    @Test
    public void shouldDeleteCustomer() {
        when().delete("/service/customer/1").then().assertThat()
                .statusCode(HttpStatus.NO_CONTENT.value());

        when().get("/service/customer/1").then().assertThat()
                .statusCode(HttpStatus.NOT_FOUND.value());

        when().delete("/service/customer/1").then().assertThat()
                .statusCode(HttpStatus.NOT_FOUND.value());

    }

    @Test
    public void shouldUpdateExistingCustomer() {
        CustomerForm customer = new CustomerForm(
                new CustomerDto(1, FIRST_NAME_DATA, LAST_NAME_DATA));

        given().body(customer)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().put("/service/customer/").then().assertThat()
                .statusCode(equalTo(HttpStatus.NO_CONTENT.value()));

        when().get("/service/customer/1").then().assertThat()
                .body(ID, equalTo(1))
                .body(FIRST_NAME, equalTo(FIRST_NAME_DATA))
                .body(LAST_NAME, equalTo(LAST_NAME_DATA));
    }

    @Test
    public void shouldNotUpdateForNewCustomer() {
        CustomerForm customer = new CustomerForm(
                new CustomerDto(999, FIRST_NAME_DATA, LAST_NAME_DATA));

        given().body(customer)
                .headers(Collections.singletonMap("Content-Type",
                        "application/json"))
                .when().put("/service/customer/").then().assertThat()
                .statusCode(equalTo(HttpStatus.NOT_FOUND.value()));
    }

}
