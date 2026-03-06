class LayoutLoader {

  static async load(elementId, file) {
    const response = await fetch(file);
    const data = await response.text();
    document.getElementById(elementId).innerHTML = data;
  }

  static getActiveNav() {

    const file = window.location.pathname.split("/").pop();

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

      if (link.dataset.nav === activeNav) {
        link.classList.add("active");
      }

    });
  }

  static async loadFooter() {
    await this.load("footer-placeholder", "fusszeile.html");
  }

  static init() {
    this.loadHeader();
    this.loadFooter();
  }

}