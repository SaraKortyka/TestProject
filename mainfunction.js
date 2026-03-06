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
  const breadcrumbContainer = document.getElementById("breadcrumb-placeholder");
  if (!breadcrumbContainer) return;

  // Startseite
  let html = `<nav class="breadcrumb"><a href="index.html">Startseite</a>`;

  if (!file || file === "" || file.startsWith("index")) {
    breadcrumbContainer.innerHTML = html + "</nav>";
    return;
  }

  if (!file.startsWith("hauptreiter_")) {
    breadcrumbContainer.innerHTML = html + "</nav>";
    return;
  }

  // Alle Ebenen extrahieren
  const parts = file.replace("hauptreiter_", "").replace(".html", "").split("_");

  let path = "hauptreiter_" + parts[0];

  // Erstes Segment = Hauptreiter
  let text = LayoutLoader.convertUmlauts(parts[0]);
  text = text.charAt(0).toUpperCase() + text.slice(1);
  html += ` &rsaquo; <a href="${path}.html">${text}</a>`;

  // Unterseiten iterativ
  for (let i = 1; i < parts.length; i++) {
    path += `_${parts[i]}`;
    text = LayoutLoader.convertUmlauts(parts[i]);
    text = text.charAt(0).toUpperCase() + text.slice(1);
    html += ` &rsaquo; <a href="${path}.html">${text}</a>`;
  }

  html += `</nav>`;
  breadcrumbContainer.innerHTML = html;
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