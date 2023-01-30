# Mahlzeit!
FrankenCampus Canteen Menu PDF Parser

[SUSE HackWeek 22 Project](https://hackweek.opensuse.org/22/projects/frankencampus-canteen-menu-pdf-parser)

Make a PDF parser command line tool that brings the Nuremberg Canteen's Menu to a usable format (Plain text, JSON) that can be used in WebApps, Smart Displays or a Slack/IRC Bots.

## Usage:

`> ./mahlzeit.rb 30_01_2023_bis_12_02_2023_1.pdf`

## Output:

```
{
  "2023W05": {
    "Montag": {
      "Suppe": "Kichererbsensuppe 0,90 €",
      "Eat fit": "Haselnussspätzle Hartkäse I Röstzwiebel Gehobelter Blumenkohl 3,90 €",
      "National": "Hausgemachter Hackbraten mit Beilage und Bratensoße 4,40 €",
      "Dessert": "Waldfruchtjoghurt 0,90 €"
    },
    "Dienstag": {
      "Suppe": "Radieschensuppe mit Brunnenkresse 0,90 €",
      "Pasta": "Geschwenkte Pasta in Paprika Pesto mit Cashew und Hähnchenbruststreifen 4,10 €",
      "Eat fit": "Broccoli-Kartoffelauflauf 3,90 €",
      "National": "Cevapcici mit Ajvar, Zwiebelringe und Tomatenreis 4,10 €",
      "Dessert": "Sauerkirschgrütze mit Vanillesahne 0,90 €"
    },
    "Mittwoch": {
      "Suppe": "Erbsensuppe 0,90 €",
      "Pasta": "Pasta mit Pesto, Oliven, getrockneten Tomaten und Rucola 3,90 €",
      "Eat fit": "Wokgemüse mit Soja-Honig- Sauce, Hähnchenbruststreifen und Duftreis 4,10 €",
      "National": "Rinderleber nach \"Berliner Art\" mit Apfelwürfel, Zwiebeln und Röstkartoffel 4,10 €",
      "Dessert": "Mango Panna cotta 0,90 €"
    },
    "Donnerstag": {
      "Suppe": "Rote Beete Suppe mit Meerrettich verfeinert 0,90 €",
      "Eat fit": "Frikadelle | Soja | Kartoffelsalat 3,90 €",
      "National": "Gulasch vom Jungschwein mit Pfirsichwürfeln Cashewnüssen und Korianderreis 4,10 €",
      "Dessert": "Kaiserschmarrn mit Apfelmus 1,10 €"
    }
  },
  "2023W06": {
    "Montag": {
      "Suppe": "Gemüsecremesuppe 0,90 €",
      "Eat fit": "Gebratene Zucchini \"Tygros\" l Zuckererbsenschoten l Paprikasauce l Rosmarinkartoffeln 4,10 €",
      "National": "Paniertes Seelachsfilet mit Kartoffelsalat und Zitronenecke 4,40 €",
      "Dessert": "Grießpudding 0,90 €"
    },
    "Dienstag": {
      "Suppe": "Kürbissuppe mit Kokosmilch & Bambussprossen 0,90 €",
      "Pasta": "Spaghetti Aglio e Olio mit Rucola und Grana Padano 3,90 €",
      "Eat fit": "Hähnchenbrustfilet mit leichter Basilikumsauce und Dampfkartoffel 4,10 €",
      "National": "Gebratene Currywurrst mit einer Jalapeñosoße oder klasischen Currysoße dazu Pommes Frites 4,40 €",
      "Dessert": "Schokoladenmousse 0,90 €"
    },
    "Mittwoch": {
      "Suppe": "Tomatensuppe 0,90 €",
      "Pasta": "Pasta Bolognese mit Rinderhackfleisch und Gemüsewürfeln dazu geriebenen Grana Padano 4,40 €",
      "Eat fit": "Schupfnudeln I Bergkernsalz Spitzkohl I Lauch- Petersiliencreme 4,40 €",
      "National": "Schweinekammsteak mit Kartoffeltwister und Sour Creme 4,10 €",
      "Dessert": "Mangojoghurt mit Kokosmilch verfeinert 0,90 €"
    },
    "Donnerstag": {
      "Suppe": "Kartoffelsuppe mit Wiener 0,90 €",
      "Eat fit": "Gebratener Reis mit frischem Gemüse und Sweet Chili Sauce 4,10 €",
      "National": "Geschnetzelten vom Schwein \"Züricher Art\" mit Butterspätzle 4,40 €",
      "Dessert": "Orangen-Weincreme mit Minze 0,90 €"
    }
  }
}
```
