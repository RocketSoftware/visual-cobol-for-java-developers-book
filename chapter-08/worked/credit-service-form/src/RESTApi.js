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
    argumentsArray.forEach(element => {
      url = url + "/" + element;
    });
    return url;
  }

  // Step 6: Insert the postCustomer() function here


  async get(url, succeeded, failed) {
    const response = await fetch(url, {
      mode: "cors", // no-cors, *cors, same-origin
      cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
      headers: {
        "Content-Type": "application/json"
      },
      redirect: "follow", // manual, *follow, error
      referrerPolicy: "no-referrer" // no-referrer, *client
    });
    if (response.status === 200) 
      {succeeded(await response.json());}
    else 
      {failed(response.status);}
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
