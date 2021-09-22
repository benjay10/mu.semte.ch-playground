import { app, query, errorHandler } from 'mu';
import bodyParser from 'body-parser';

// Also parse application/json as json
//app.use( bodyParser.json( { type: function(req) { return /^application\/json/.test( req.get('content-type') ); } } ) );

// Respond to POST requests
app.post('/', function( req, res ) {

  //console.log(req);
  //console.log("#################################################################################################################");
  //console.log(req.body);

  //let allowedGroups = JSON.stringify(req.body);
  let allowedGroups = "CLEAR";

  console.log(allowedGroups);

  res
    .set('MU-AUTH-ALLOWED-GROUPS', allowedGroups)
    .status(204)
    .send();
});

