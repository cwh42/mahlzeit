const enableServiceWorker = false;

if (enableServiceWorker && "serviceWorker" in navigator) {
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

var now = new XDate();
var today = XDate.today();
if (now.getHours() >= 13) { today.addDays(1) };

$(document).ready(function() {
  var template = $("#mzCarousel .carousel-item.active").detach().removeClass("active");

  $.getJSON( "./mahlzeit_v2.json", function( data ) {
    $.each( data, function( i, day ) {
      ci = renderDay(day, template.clone());
      ci.appendTo("#mzCarousel .carousel-inner");
    });
  }).fail(function(){
    template.addClass("active");
    template.find(".mz-day").text("Oops! Could not load the menu!");
    template.appendTo("#mzCarousel .carousel-inner");
  });

  // add the crying smiley if there is no active item after rendering the whole JSON
  if (!$("#mzCarousel .carousel-item").hasClass("active")) {
    template.clone().addClass("active").appendTo("#mzCarousel .carousel-inner").find(".mz-day").text("Sorry, no data.");
  }
});

function tagPrice(elem) {
  const regex = /\b([0-9,]+&nbsp;€)/u;
  return elem.html(elem.html().replace(regex, "<span class='price'>$&</span>"));
}

function renderDay(day, template) {
  var date = day['date'];
  var menu = day['menu'];

  if ( typeof date === 'undefined' ) { return template; }

  date = new XDate(date);
  var weekday = dayNames[date.getDay()];

  template.find(".mz-day").text(weekday);
  template.find(".mz-date").text(date.toLocaleDateString());

  if ( !($("#mzCarousel .carousel-item").hasClass("active")) && date >= today ) {
    template.addClass("active");
  }

  if ( typeof menu === 'undefined' ) { return template; }

  var p = template.find( ".mz-menu .mz-dish" ).clone();
  template.find(".mz-menu").empty();

  $.each( menu, function( i, dish ) {
    item = tagPrice(p.clone().text(dish));
    item.appendTo(template.find(".mz-menu"));
  });

  return template;
}
