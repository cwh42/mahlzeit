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

const dayNames = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag'];
var today = new XDate().addDays(0);
if (today.getHours() >= 13) { today.addDays(1) };
var weekday = dayNames[today.getDay()];
var weekString = today.toString("yyyy'W'ww");

$(document).ready(function(){
  $( "#headline").text(weekday);
  $.getJSON( "mahlzeit.json", function( data ) {
    var p = $( "#today .mz-dish" );

    if ( typeof data[weekString][weekday] !== 'undefined' ) {
      p.remove();
    }

    $.each( data[weekString][weekday], function( key, val ) {
      p.clone().text(val).appendTo("#today");
    });
  }).fail(function(){
    $( "#headline").text("Oops! Could not load the menu!");
  });
});
