const enableServiceWorker = true;

if (enableServiceWorker && "serviceWorker" in navigator) {
  let refreshing = false;

  navigator.serviceWorker.addEventListener("controllerchange", () => {
    if (refreshing) return;
    refreshing = true;
    window.location.reload();
  });

  window.addEventListener("load", async () => {
    try {
      const registration = await navigator.serviceWorker.register("service-worker.js", {
        updateViaCache: "none"
      });
      console.log("Service worker registered");

      if (registration.installing) {
        console.log("Service worker installing");
      } else if (registration.waiting) {
        console.log("Service worker waiting");
      } else if (registration.active) {
        console.log("Service worker active");
      }

      registration.addEventListener("updatefound", () => {
        console.log("Service worker update found");
      });

      // Check for updated worker on each page load.
      await registration.update();
    } catch (error) {
      console.error("Service worker registration failed", error);
    }
  });
}

const mzCarouselElement = document.querySelector('#mzCarousel')
const carousel = new bootstrap.Carousel(mzCarouselElement, {
  touch: true
});

const dayNames = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];
const isoWeekdayByName = {
  Montag: 1,
  Dienstag: 2,
  Mittwoch: 3,
  Donnerstag: 4,
  Freitag: 5,
  Samstag: 6,
  Sonntag: 7
};

var now = new XDate();
var today = XDate.today();
if (now.getHours() >= 13) { today.addDays(1) };

$(document).ready(function() {
  var template = $("#mzCarousel .carousel-item.active").detach().removeClass("active");
  var menuUrl = `./mahlzeit_v2.json?t=${Date.now()}`;

  fetch(menuUrl, {
    cache: "no-store",
    headers: { "Cache-Control": "no-cache" }
  })
  .then(function(response) {
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return response.json();
  })
  .then(function( data ) {
    data = normalizeMenuData(data);

    $.each( data, function( i, day ) {
      ci = renderDay(day, template.clone());
      ci.appendTo("#mzCarousel .carousel-inner");
    });

    // add the crying smiley if there is no active item after rendering the whole JSON
    if (!$("#mzCarousel .carousel-item").hasClass("active")) {
      template.clone().addClass("active").appendTo("#mzCarousel .carousel-inner").find(".mz-day").text("Sorry, no data.");
    }
  }).catch(function(error){
    console.error("Could not load menu JSON", error);
    template.addClass("active");
    template.find(".mz-day").text("Oops! Could not load the menu!");
    template.appendTo("#mzCarousel .carousel-inner");
  });
});

function normalizeMenuData(data) {
  if (Array.isArray(data)) {
    return data;
  }

  if (data && typeof data === "object") {
    const normalized = [];

    $.each(data, function(weekKey, daysByName) {
      const match = /^(\d{4})W(\d{2})$/.exec(weekKey);
      if (!match || !daysByName || typeof daysByName !== "object") {
        return;
      }

      const year = Number(match[1]);
      const week = Number(match[2]);

      $.each(daysByName, function(dayName, dishesByCategory) {
        const isoWeekday = isoWeekdayByName[dayName];
        if (!isoWeekday || !dishesByCategory || typeof dishesByCategory !== "object") {
          return;
        }

        normalized.push({
          date: isoWeekDateToIsoString(year, week, isoWeekday),
          menu: Object.values(dishesByCategory)
        });
      });
    });

    normalized.sort(function(a, b) {
      return a.date.localeCompare(b.date);
    });

    return normalized;
  }

  return [];
}

function isoWeekDateToIsoString(year, week, isoWeekday) {
  // ISO week 1 is the week containing Jan 4; Monday is day 1.
  const jan4 = new Date(Date.UTC(year, 0, 4));
  const jan4Weekday = jan4.getUTCDay() || 7;
  const mondayOfWeek1 = new Date(jan4);
  mondayOfWeek1.setUTCDate(jan4.getUTCDate() - jan4Weekday + 1);

  const target = new Date(mondayOfWeek1);
  target.setUTCDate(mondayOfWeek1.getUTCDate() + (week - 1) * 7 + (isoWeekday - 1));

  return target.toISOString().slice(0, 10);
}

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
