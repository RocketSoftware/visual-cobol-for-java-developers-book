import React from "react";
import "./App.css";
import CustomerList from "./CustomerList.js";
import AccountDetails from "./AccountDetails.js";
import TransactionList from "./TransactionList.js";
// Step 2: Uncomment the line below to import the AddCustomerForm
// import AddCustomerForm from "./AddCustomer";
import RESTApi from "./RESTApi";

function App() {
  return <MainPage value="http://localhost:8080" />;
}

class MainPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      // Step 5: Uncomment following line to add dialog display state
      // addCustomer: false 
      customerData: null,
      customerId: null,
      accountData: {
        id: "",
        customerId: "",
        balance: 0.0,
        type: "",
        creditLimit: 0.0
      },

      transactionData: []
    };
    this.RESTApi = new RESTApi(props.value);
    this.accountFetched = this.accountFetched.bind(this);
    this.accountFetchFailed = this.accountFetchFailed.bind(this);
    this.transactionsFetched = this.transactionsFetched.bind(this);
    this.transactionsFetchFailed = this.transactionsFetchFailed.bind(
      this);
    // Uncomment following three lines to bind toggleAddCustomerDlg
    // to object.
    // this.toggleAddCustomerDlg = this.toggleAddCustomerDlg.bind(
    //   this
    // );      
  }

  componentDidMount() {
    fetch(this.RESTApi.serviceUrl("service/customer"))
      .then(response => {
        return response.json();
      })
      .then(myJson => {
        this.setState({ customerData: myJson.array });
      });
  }

  /**************************************************/
  /* EVENT HANDLERS                                  /
  /**************************************************/

  // Step 4: Add toogleAddCustomerDlg function here

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
      accountData: account
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
      transactionData: transactionJson.array
    });
  }

  transactionsFetchFailed(status) {
    if (status !== 404) {
      alert("Failed to fetch transactions");
    } else {
      this.setState({
        transactionData: []
      });
    }
  }

  /**************************************************/
  /* RENDERING CODE
  /**************************************************/
  render() {
    return (
      // Step 3: Insert AddCustomerForm dialog code here

      <div className="row">
        <div className="col">
          <div>
            {/* Step 1: Insert button code between here  */}
            <h1>Customers</h1>
            {/* and here  */}

            <div>
              <CustomerList
                className="container scrollable"
                value={{
                  onCustomerSelected: x =>
                    this.handleCustomerSelected(x),
                  customerData: this.state.customerData
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
      // Close div element here after adding the AddCustomerFormDialog.
    );
  }
}
export default App;
