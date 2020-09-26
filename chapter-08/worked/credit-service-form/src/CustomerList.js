import React from "react";
import "./App.css";

function Customer(props) {
  return (
    <div
      className={
        "padded highlightable row " +
        (props.value.index % 2 === 0 ? "grey" : "white")
      }
      onClick={props.onClick}
    >
      <div className="padded col">{props.value.customer.id}</div>
      <div className="col">{props.value.customer.firstName}</div>
      <div className="col">{props.value.customer.lastName}</div>
    </div>
  );
}

class CustomerList extends React.Component {
  customerSelected(customerId) {
    if (this.props.value.onCustomerSelected) {
      this.props.value.onCustomerSelected(customerId);
    } else {
      console.debug(
        "No onselected handler provided to CustomerList"
      );
    }
  }

  render() {
    const customers = [];
    if (this.props.value.customerData) {
      this.props.value.customerData.map((x, index) =>
        customers.push(
          <Customer
            key={index}
            value={{ customer: x, index: index }}
            onClick={() => {
              this.customerSelected(x.id);
            }}
          ></Customer>
        )
      );
    }

    return <div className="scrollable">{customers}</div>;
  }
}

export default CustomerList;
