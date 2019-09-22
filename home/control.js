
const url = 'http://192.168.50.131:8080';
let state = {};

const reload = () => {
  fetch(url)
  .then(response => {
    return response.json();
  })
  .then(myJson => {
    state = myJson;
    refresh();
    console.log("reload done");
  });
};

const refresh = () => {
  console.log(state);
  for (let i = 0; i < 8; i++) {
    let v = state[i];
    let x = $("#CH0" + i);
    if (v) {
      x.removeClass("btn-default");
      x.addClass("btn-primary");
    } else {
      x.removeClass("btn-primary");
      x.addClass("btn-default");
    }
  }
};

$(document).ready(() => {

  reload();
  // refresh();

  $("button").click(event => {
    // console.log(event.target.id);

    if (state === undefined) {
      reload();
    }

    let id = undefined;
    if (event.target.id && event.target.id.startsWith("CH0")) {
      id = event.target.id.substring(3);
      // console.log(id);

      let v = state[id];
      console.log(v);

      state[id] = !state[id];
      console.log("" + id + " flip = " + state[id]);

      console.log(JSON.stringify(state));
    }


    fetch(url, {
      method: 'POST',
      body: JSON.stringify(state),
      headers:{
        'Content-Type': 'application/json'
      }
    }).then(res => {
      refresh();
    })
    .catch(error => console.error('Error:', error));
  });
});
