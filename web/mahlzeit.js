if ("serviceWorker" in navigator) {
  try {
    const registration = navigator.serviceWorker.register("service-worker.js");

    if (registration.installing) {
      console.log("Service worker installing");
    } else if (registration.waiting) {
      console.log("Service worker installed");
    } else if (registration.active) {
      console.log("Service worker active");
    }
  } catch (error) {
    console.error(`Registration failed with ${error}`);
  }
}

const dayNames = [
  "Sonntag",
  "Montag",
  "Dienstag",
  "Mittwoch",
  "Donnerstag",
  "Freitag",
];

var today = new XDate().addDays(0);
var currentDayIndex = today.getDay();

$("#prev-day").click(function () {
  currentDayIndex =
  (currentDayIndex - 1 + dayNames.length) % dayNames.length;
  updateMenu();
});

$("#next-day").click(function () {
  currentDayIndex = (currentDayIndex + 1) % dayNames.length;
  updateMenu();
});

$(document).ready(function () {
  updateMenu();
});

function updateMenu() {
  $("#today").empty();

  var currentDay = dayNames[currentDayIndex];
  var currentWeek = new XDate().addDays(currentDayIndex - today.getDay());
  var currentWeekString = currentWeek.toString("yyyy'W'ww");

  $("#headline").text(
    currentDay + ", " + currentWeek.toString("dd.MM.yyyy")
  );
  $.getJSON("mahlzeit.json", function (data) {
    var p = $('<p class="lead mb-4 mz-dish"></p>');
    if (
      typeof data[currentWeekString] === "undefined" ||
      typeof data[currentWeekString][currentDay] === "undefined"
    ) {
      p.text("😭 | No menu available for this day.").appendTo("#today");
    } else {
      $.each(data[currentWeekString][currentDay], function (key, val) {
        p.clone().text(val).appendTo("#today");
      });
    }
  }).fail(function () {
    $("#headline").text("Oops! Could not load the menu!");
  });
}
