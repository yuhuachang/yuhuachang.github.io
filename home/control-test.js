
const test = () => {
  fetch('http://127.0.0.1:8080/test')
  .then(response => {
    return response.json();
  })
  .then(myJson => {
    console.log(myJson);
  });
};

const tests = () => {
  fetch('https://127.0.0.1:8080/test')
  .then(response => {
    return response.json();
  })
  .then(myJson => {
    console.log(myJson);
  });
};
