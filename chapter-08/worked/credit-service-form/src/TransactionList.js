import React from "react";
import "./App.css";

function Transaction(props) {
  return (
    <div
      className={
        "padded highlightable row " +
        (props.value.index % 2 === 0 ? "grey" : "white")
      }
    >
      <div className="padded col">{props.value.transaction.id}</div>
      <div className="padded col">{props.value.transaction.transDate}</div>
      <div className="padded col">{props.value.transaction.amount}</div>
      <div className="padded col">{props.value.transaction.description}</div>
    </div>
  );
}

class TransactionList extends React.Component {
  render() {
    const transactions = [];
    if (this.props.value) {
      this.props.value.map((x, index) =>
        transactions.push(
          <Transaction
            key={index}
            value={{ transaction: x, index: index }}
          ></Transaction>
        )
      );
    }

    return <div className="scrollable">{transactions}</div>;
  }
}

export default TransactionList;
