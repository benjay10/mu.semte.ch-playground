export default [
  {
    // About bids
    match: {
      predicate: { type: "uri", value: "http://www.semanticweb.org/ben/ontologies/auction#hasBid" },
    },
    callback: {
      url: "http://localhost/doesnotexist:80", method: "POST"
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true
    }
  },
  {
    // About favorites
    match: {
      predicate: { type: "uri", value: "http://www.semanticweb.org/ben/ontologies/auction#hasFavorite" },
    },
    callback: {
      url: "http://localhost/doesnotexist:80", method: "POST"
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true
    }
  }
]

