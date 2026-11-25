#import "@local/bgslides:1.0.0": *

#show: bgslides.with(
  title: [Deklarative Systeme mit NixOS],
  subtitle: [Ein Rechner, eine Datei, kein Rätselraten],
  short-title: [NixOS],
  author: "Frederik Beimgraben",
  email: "mail@example.org",
  date: datetime(year: 2026, month: 11, day: 25),
  event: "Linux-Stammtisch",
  // theme: "blue" | "bordeaux" | "violet"
  theme: "blue",
  // appearance: "dark" | "light"
  appearance: "dark",
)

#outline-slide()

= Ausgangslage

== Warum überhaupt?

- Server wachsen über Jahre und niemand weiß mehr, *warum* etwas so ist.
- Anleitungen veralten, sobald man sie abschickt.
  - Shell-Historie als Dokumentation
  - Snapshots als Backup-Strategie
- Ein `apt upgrade` zur falschen Zeit kostet einen Abend.

#info-box[
  Ziel: Der Zustand eines Systems steht vollständig in einer Datei unter
  Versionskontrolle.
]

#slide(title: [Schritt für Schritt], steps: 3)[
  + Konfiguration schreiben
  #uncover("2-")[+ `nixos-rebuild switch` ausführen]
  #uncover("3-")[+ Fehler? Mit dem vorigen Stand neu starten.]

  #only(3)[
    #success-box[Jede Generation bleibt im Bootmenü erhalten.]
  ]
]

= Umsetzung

== Eine Konfiguration

#cols(widths: (1.5fr, 1fr))[
  ```nix
  { pkgs, ... }: {
    networking.hostName = "graben";

    services.nginx = {
      enable = true;
      virtualHosts."beimgraben.net".root = ./site;
    };

    # Pakete für alle Benutzer
    environment.systemPackages = with pkgs; [ git helix ];
  }
  ```
][
  / Deklarativ: Der Soll-Zustand, nicht der Weg dorthin.
  / Reproduzierbar: Gleiche Eingabe, gleiches System.
  / Atomar: Ein Wechsel gelingt ganz oder gar nicht.
]

== Vergleich

#table(
  columns: (1fr, auto, auto),
  align: (left, center, center),
  table.header[Eigenschaft][Klassisch][NixOS],
  [Rollback], [Snapshot], [Generation],
  [Dokumentation], [Wiki], [Konfiguration],
  [Drift zwischen Hosts], [häufig], [keine],
)

Inline-Code wie `nix flake update` steht auf einer Fläche, Links wie
#link("https://beimgraben.net")[beimgraben.net] sind unterstrichen.

== Kästen

#cols[
  #info-box[Ein Hinweis zum Kontext.]
  #warning-box[`/etc` von Hand ändern hält nur bis zum nächsten Rebuild.]
][
  #important-box[Secrets gehören nicht in den Nix-Store.]
  #custom-box(title: [Eigene Farbe], color: brand.cyan)[Jede Farbe geht.]
]

== Im Terminal

#shell[`sudo nixos-rebuild switch --flake .#graben`]

#shell[`nix run github:frederikbeimgraben/typst-beamer-template#build`]

#v(1em)

#quote(block: true, attribution: [beimgraben.net])[
  Hier landen Dinge, zu denen ich beim Suchen selbst nichts gefunden habe.
]

#focus-slide[Fragen?]
