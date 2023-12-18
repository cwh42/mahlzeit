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

const mzCarouselElement = document.querySelector('#mzCarousel')
const carousel = new bootstrap.Carousel(mzCarouselElement, {
  touch: true
});

const dayNames = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];
var today = new XDate();
if (today.getHours() >= 13) { today.addDays(1) };

$(document).ready(function() {
  if (today.getDay() == 0 || today.getDay() == 6) { today.setWeek(today.getWeek() + 1) };
  var template = $("#mzCarousel .carousel-item.active").detach();

  var ci = renderDay(today, template.clone());
  ci.appendTo("#mzCarousel .carousel-inner");

  while (today.getDay() < 5) {
    ci = renderDay(today.addDays(1), template.clone()).removeClass("active");
    ci.appendTo("#mzCarousel .carousel-inner");
  }
});

function tagPrice(elem) {
  const regex = /\b([0-9,]+&nbsp;€)/u;
  return elem.html(elem.html().replace(regex, "<span class='price'>$&</span>"));
}

function renderDay(date, template) {
  var weekday = dayNames[date.getDay()];
  var weekString = date.toString("yyyy'W'ww");

  template.find(".mz-day").text(weekday);
  template.find(".mz-date").text(date.toLocaleDateString());
  $.getJSON( "mahlzeit.json", function( data ) {
    var p = template.find( ".mz-menu .mz-dish" ).clone();

    if ( typeof data[weekString] === 'undefined' || typeof data[weekString][weekday] === 'undefined' ) { return template; }

    template.find(".mz-menu").empty();

    $.each( data[weekString][weekday], function( key, val ) {
      item = tagPrice(p.clone().text(val))
      item.appendTo(template.find(".mz-menu"));
    });
  }).fail(function(){
    template.find(".mz-day").text("Oops! Could not load the menu!");
  });

  return template;
}
