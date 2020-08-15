const { Client } = require("pg");

const pgClient = new Client(
  "postgres://app_user:password@localhost:5432/app_db?sslmode=disable"
);

pgClient.connect();

pgClient.query("LISTEN email");

pgClient.on("notification", (data) => {
  console.log(data);
});
