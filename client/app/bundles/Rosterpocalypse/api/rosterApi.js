var rp = require('request-promise');

class RosterApi {
  constructor(url) {
    baseUrl = url;
  }

  getAllRosters() {
    rp(baseUrl + "/rosters.json");
  }

  getRosterById(id) {
    rp(baseUrl + "/rosters/"+id+".json");
  }
}

// p = rp("http://www.google.com")

// p.then(page => {
//   console.log(page);
// });