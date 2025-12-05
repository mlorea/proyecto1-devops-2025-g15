const app = require('./app');
const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`To-Do API listening on port ${port}`);
});
