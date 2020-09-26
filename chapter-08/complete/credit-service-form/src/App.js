import React from "react";
import "./App.css";
import CustomerList from "./CustomerList.js";
import AccountDetails from "./AccountDetails.js";
import TransactionList from "./TransactionList.js";
import AddCustomerForm from "./AddCustomer";
import RESTApi from "./RESTApi";

function App() {
  return <MainPage value="http://localhost:8080" />;
}

class MainPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      addCustomer: false,
      customerData: null,
      customerId: null,
      accountData: {
        id: "",
        customerId: "",
        balance: 0.0,
        type: "",
        creditLimit: 0.0,
      },

      transactionData: [],
    };
    this.RESTApi = new RESTApi(props.value);
    this.accountFetched = this.accountFetched.bind(this);
    this.accountFetchFailed = this.accountFetchFailed.bind(this);
    this.transactionsFetched = this.transactionsFetched.bind(this);
    this.transactionsFetchFailed = this.transactionsFetchFailed.bind(
      this
    );
    this.toggleAddCustomerDlg = this.toggleAddCustomerDlg.bind(
      this
    );
  }

  componentDidMount() {
    fetch(this.RESTApi.serviceUrl("service/customer"))
      .then((response) => {
        return response.json();
      })
      .then((myJson) => {
        this.setState({ customerData: myJson.array });
      });
  }

  /**************************************************/
  /* EVENT HANDLERS                                  /
  /**************************************************/

  toggleAddCustomerDlg() {
    this.setState({ addCustomer: !this.state.addCustomer });
  }

  handleCustomerSelected(customerId) {
    this.RESTApi.getAccount(
      customerId,
      this.accountFetched,
      this.accountFetchFailed
    );
  }

  accountFetched(account) {
    this.setState({
      customerId: account.id,
      accountData: account,
    });
    this.RESTApi.getTransactions(
      account.id,
      this.transactionsFetched,
      this.transactionsFetchFailed
    );
  }

  accountFetchFailed() {
    alert("Failed to fetch an account");
  }

  transactionsFetched(transactionJson) {
    this.setState({
      transactionData: transactionJson.array,
    });
  }

  transactionsFetchFailed(status) {
    if (status !== 404) {
      alert("Failed to fetch transactions");
    } else {
      this.setState({
        transactionData: [],
      });
    }
  }

  /**************************************************/
  /* RENDERING CODE
  /**************************************************/
  render() {
    return (
      <div>
        <div>
          <AddCustomerForm
            show={this.state.addCustomer}
            onClose={this.toggleAddCustomerDlg}
            success={(customer) => {
              this.toggleAddCustomerDlg();
              this.state.customerData.unshift(customer);
              this.setState({
                customerData: this.state.customerData,
              });
            }}
            failure={() => {
              alert("Couldn't add customer");
            }}
            service={this.RESTApi}
          />
        </div>
        <div className="row">
          <div className="col">
            <div>
              <div className="row">
                <h1 className="col">Customers</h1>
                <button
                  style={{ margin: 10 + "px", height: 40 + "px" }}
                  className="col"
                  onClick={this.toggleAddCustomerDlg}
                >
                  Add New
                </button>
                <div className="col" />
              </div>
              <div>
                <CustomerList
                  className="container scrollable"
                  value={{
                    onCustomerSelected: (x) =>
                      this.handleCustomerSelected(x),
                    customerData: this.state.customerData,
                  }}
                />
              </div>
            </div>
          </div>
          <div className="col">
            <div className="row">
              <div className="container">
                <h1>Account details</h1>
                <p>Select a customer to see account details.</p>
                <AccountDetails value={this.state.accountData} />
              </div>
            </div>
            <div className="row">
              <div className="container">
                <h1>Transactions</h1>
                <TransactionList
                  value={this.state.transactionData}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
export default App;
