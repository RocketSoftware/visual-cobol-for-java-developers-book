class RESTApi {
  constructor(serviceRoot) {
    this.serviceRoot = serviceRoot;
  }

  /**
   * Construct a URL by concatenating a path to the host.
   * takes a variable number of arguments.
   */
  serviceUrl() {
    var url = this.serviceRoot;
    var argumentsArray = Array.prototype.slice.apply(arguments);
    argumentsArray.forEach((element) => {
      url = url + "/" + element;
    });
    return url;
  }

  /**
   * Call REST service to add a new customer in data.
   * succeeded and failed functions called depending on
   * success
   * @param {*} data
   * @param {*} succeeded
   * @param {*} failed
   */
  async postCustomer(data, succeeded, failed) {
    var url = this.serviceUrl("service/customer");
    const response = await fetch(url, {
      method: "POST", // *GET, POST, PUT, DELETE, etc.
      mode: "cors", // no-cors, *cors, same-origin
      cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
      headers: {
        "Content-Type": "application/json",
      },
      redirect: "follow", // manual, *follow, error
      referrerPolicy: "no-referrer", // no-referrer, *client
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    if (response.status === 200) {
      succeeded(await response.json());
    } else {
      failed(data);
    }
  }

  async get(url, succeeded, failed) {
    const response = await fetch(url, {
      mode: "cors", // no-cors, *cors, same-origin
      cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
      headers: {
        "Content-Type": "application/json",
      },
      redirect: "follow", // manual, *follow, error
      referrerPolicy: "no-referrer", // no-referrer, *client
    });
    if (response.status === 200) {
      succeeded(await response.json());
    } else {
      failed(response.status);
    }
  }

  async getAccount(customerId, succeeded, failed) {
    var url = this.serviceUrl("service/account", customerId);
    this.get(url, succeeded, failed);
  }

  async getTransactions(accountId, succeeded, failed) {
    var url = this.serviceUrl(
      "service/transaction/account",
      accountId
    );
    this.get(url, succeeded, failed);
  }
}

export default RESTApi;
