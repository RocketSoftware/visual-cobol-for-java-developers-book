import React from "react";
import "./App.css";
import { Formik, Field, Form } from "formik";

class AddCustomerForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      customerData: null,
      show: props.show,
    };
    this.hide = this.hide.bind(this);
  }

  hide() {
    this.setState({ show: false });
  }

  render() {
    if (!this.props.show) {
      return null;
    }

    return (
      <div className="modal-dialog modal-dialog-centered">
        <Formik
          onSubmit={(values) => {
            this.props.service.postCustomer(
              values,
              this.props.success,
              this.props.failure
            );
          }}
        >
          <Form>
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modalTitle">Add New Customer</h5>
                <button
                  type="button"
                  className="close"
                  data-dismiss="modal"
                  aria-label="Close"
                  onClick={this.props.onClose}
                >
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div className="modal-body">
                <div className="row">
                  <label className="col">First Name</label>
                  <Field
                    style={{ marginRight: 20 + "px" }}
                    className="col"
                    type="input"
                    name="firstName"
                    value={this.props.firstName}
                  />
                </div>
                <div className="row">
                  <label className="col">Last Name</label>
                  <Field
                    style={{ marginRight: 20 + "px" }}
                    className="col"
                    type="input"
                    name="lastName"
                    value={this.props.lastName}
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button
                  type="button"
                  onClick={this.props.onClose}
                  className="btn btn-secondary"
                  data-dismiss="modal"
                >
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Save changes
                </button>
              </div>
            </div>
          </Form>
        </Formik>
      </div>
    );
  }
}

export default AddCustomerForm;
