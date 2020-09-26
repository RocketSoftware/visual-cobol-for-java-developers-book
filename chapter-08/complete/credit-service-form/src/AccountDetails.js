import React from "react";
import "./App.css";
import { Formik, Field } from "formik";

class AccountDetails extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      accountData: null
    };
    console.debug("AccountDetails.ctor(" + props.value +")");
  }

  render() {
    return (
      <div>
        <Formik>
          <form>
            <div className="row">
              <label className="col">AccountId</label>
              <Field className="col" type="input" name="AccountId" value={this.props.value.id} />
            </div>
            <div className="row">
              <label className="col">Balance</label>
              <Field className="col" type="input" name="Balance" value={this.props.value.balance} />
            </div>
          </form>
        </Formik>
      </div>
    );
  }
}

export default AccountDetails;
