const main = require('Main');

if (module.hot) {
  module.hot.accept('./dist/main.js', function() {
    console.log('Accepting the updated main module!');
    main.main();
  })
}
main.main();
