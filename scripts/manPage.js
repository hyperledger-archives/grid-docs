/*
  Copyright 2020 Cargill Incorporated

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

function generateManPage() {
  var current_file = window.location.pathname.substring(
    window.location.pathname.lastIndexOf("/") + 1
  );

  if (current_file.includes(".1.")) {
    // clear out main-content
    var children = $("#main-content").children();
    $("#main-content").empty();

    // set title for man page
    document.title = current_file.substring(0, current_file.length - 7);

    // add h1 with the command name
    $("#main-content").append(
      "<h1>"+current_file.substring(0, current_file.length - 7)+"</h1>");

    var i;
    // ignore first line (only required for man page generation)
    for (i = 1; i < children.length; i++) {
      let element = children[i];
      if (i !=0) {
        // Do not include text after the SEE ALSO section
        if (element.innerText == "SEE ALSO") {
          return;
        }

        // Change h1 headers to only captilize the first leter and be h2
        if ($(element).is("h1")) {
          element.innerHTML = "<h2>"+capitilizeFirst(element.innerText)+"</h2>";
          console.log(element.innerHTML);
        }

        $("#main-content").append(element);
      }
    }
  }
}

function capitilizeFirst(word) {
    word = word.toLowerCase();
    word = word.charAt(0).toUpperCase() + word.slice(1);
    return word;
}
