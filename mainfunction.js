class LayoutLoader {

  static async load(elementId, file) {
    const response = await fetch(file);
    const data = await response.text();
    document.getElementById(elementId).innerHTML = data;
  }

  static getActiveNav() {

    let file = window.location.pathname.split("/").pop();

    if (!file || file === "" || file.startsWith("index")) {
      return null;
    }

    file = file.toLowerCase();

    if (!file.startsWith("hauptreiter_")) {
      return null;
    }

    const part = file.replace("hauptreiter_", "");
    return part.split("_")[0];

  }

  static async loadHeader() {

    await this.load("header-placeholder", "kopfzeile.html");

    const activeNav = this.getActiveNav();

    if (!activeNav) return;

    const links = document.querySelectorAll(".main-nav a");

    links.forEach(link => {

      const navName = link.dataset.nav.toLowerCase();

      if (navName === activeNav) {
        link.classList.add("active");
      } else {
        link.classList.remove("active");
      }

    });

  }
static async loadBreadcrumb() {
  const file = window.location.pathname.split("/").pop().toLowerCase();
  const container = document.getElementById("breadcrumb-placeholder");
  if (!container) return;

  // Startseite
  let html = `<nav class="breadcrumb"><a href="index.html">Startseite</a>`;

  if (!file || file.startsWith("index") || !file.startsWith("hauptreiter_")) {
    container.innerHTML = html + "</nav>";
    return;
  }

  // Alles nach hauptreiter_
  const namePart = file.replace("hauptreiter_", "").replace(".html","");
  // Split nach doppelt Unterstrich = neue Breadcrumb-Ebenen
  const parts = namePart.split("__");

  let path = "hauptreiter_" + parts[0];

  // Erste Ebene = Hauptreiter
  let text = LayoutLoader.convertUmlauts(parts[0]);
  text = text.charAt(0).toUpperCase() + text.slice(1);
  html += ` &rsaquo; <a href="${path}.html">${text}</a>`;

  // Restliche Ebenen
  for (let i = 1; i < parts.length; i++) {
    path += `__${parts[i]}`;
    let subText = LayoutLoader.convertUmlauts(parts[i]).replace(/_/g, " ");
    subText = subText.charAt(0).toUpperCase() + subText.slice(1);
    html += ` &rsaquo; <a href="${path}.html">${subText}</a>`;
  }

  html += "</nav>";
  container.innerHTML = html;
}
  static async loadFooter() {
    await this.load("footer-placeholder", "fusszeile.html");
  }
static convertUmlauts(str) {
  return str
    .replace(/ae/g, "ä")
    .replace(/oe/g, "ö")
    .replace(/ue/g, "ü")
    .replace(/ss/g, "ß")
    .replace(/_/g, " "); // Unterstriche ? Leerzeichen
}
  static init() {
    this.loadHeader();
    this.loadFooter();
	 this.loadBreadcrumb();
  }

}
const TooltipData = {
  "Automatismen": "Handlungsautomatismus: wir handeln bevor wir entscheiden \n Adaptionsautomatismus: das System lernt ohne unser Zutun"
};
document.addEventListener("DOMContentLoaded", () => {
  function formatKeyTitle(key) {
  return key
    .replace(/_/g, ' ')   // Unterstriche zu Leerzeichen
    .replace(/ae/g, 'ä')
    .replace(/oe/g, 'ö')
    .replace(/ue/g, 'ü')
    .replace(/ss/g, 'ß')
    .replace(/\b\w/g, c => c.toUpperCase()); // erstes Zeichen jedes Wortes groß
}
  document.querySelectorAll('.tooltip').forEach(el => {
    let tooltipBox;

    el.addEventListener('mouseenter', () => {
      const key = el.getAttribute('data-key');
      const content = TooltipData[key];
      if(!content) return;

      // Tooltip-Box erzeugen
      tooltipBox = document.createElement('div');
      tooltipBox.className = 'tooltip-box';

      // Key als Titel oben
      const title = document.createElement('div');
      title.className = 'tooltip-title';
      title.innerText = formatKeyTitle(key);

      // Inhalt darunter
      const body = document.createElement('div');
      body.className = 'tooltip-body';
      body.innerHTML = content; // HTML erlaubt <br>, Links, Bilder

      tooltipBox.appendChild(title);
      tooltipBox.appendChild(body);

      // Vorübergehend versteckt anhängen, um Höhe zu messen
      tooltipBox.style.position = 'absolute';
      tooltipBox.style.visibility = 'hidden';
      document.body.appendChild(tooltipBox);

      const rect = el.getBoundingClientRect();
      tooltipBox.style.left = rect.left + window.scrollX + 'px';
      tooltipBox.style.top = rect.top + window.scrollY - tooltipBox.offsetHeight - 5 + 'px';
      tooltipBox.style.visibility = 'visible';
    });

    el.addEventListener('mouseleave', () => {
      if(tooltipBox) {
        tooltipBox.remove();
        tooltipBox = null;
      }
    });
  });
  
});


