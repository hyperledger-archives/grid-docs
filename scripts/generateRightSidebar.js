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

function generateRightSidebar() {
  var current_file = window.location.pathname.substring(
    window.location.pathname.lastIndexOf("/") + 1
  );

  $("#main-content").children().each(function (idx, element) {
      if (current_file.includes(".1.")) {
        // skip the first h1 header in a man page, it is the title
        if ($(element).is("h1") && idx !=0) {
          // Treat H1 headers in man pages as H2 headers for right sidebars
          $("#right-sidebar").append(
              "<a href=#" + element.id + " class=\"right-sidebar-h2\">" +
              element.innerText + "</a>"
          );
        }
      }

      if ($(element).is("h2")) {
          $("#right-sidebar").append(
              "<a href=#" + element.id + " class=\"right-sidebar-h2\">" +
              element.innerText + "</a>"
          );
      }
      if ($(element).is("h3")) {
          $("#right-sidebar").append(
              "<a href=#" + element.id + " class=\"right-sidebar-h3\">" +
              element.innerText + "</a>"
          );
      }
  });
}
