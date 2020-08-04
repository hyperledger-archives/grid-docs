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

// Set the active links in the left sidebar and the left sidebar's version
// dropdown
function setActiveLinks() {
    $(document).ready(function () {
        var left_sidebar_links = $('.left-sidebar-group a').filter(function() {
            return window.location.pathname.startsWith(this.getAttribute("href"));
        });
        $(getElementWithLongestPath(left_sidebar_links)).addClass('active');

        var dropdown_links = $('#left-sidebar .dropdown-item').filter(function() {
            return window.location.pathname.startsWith(this.getAttribute("href"));
        }).addClass('active');
        $(getElementWithLongestPath(dropdown_links)).addClass('active');
    });
}

function getElementWithLongestPath(elements) {
    var longest_path = elements.get(0);
    for (var i = 1; i < elements.length; i++) {
        if (elements.get(i).getAttribute("href").length > longest_path.getAttribute("href").length) {
            longest_path = elements.get(i);
        }
    }
    return longest_path;
}
