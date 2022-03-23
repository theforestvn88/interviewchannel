import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "back", "searchInput", "searchForm", "displayHeader", "displaySelector", "openSearch" ]

  connect() {}

  changeDate(event) {
    event.target.closest("form").requestSubmit();
  }

  showDisplayHeader() {
    this.displayHeaderTarget.classList.remove("invisible", "w-1");
    this.displayHeaderTarget.classList.add("visible");
    this.displaySelectorTarget.classList.remove("invisible", "w-1");
    this.displaySelectorTarget.classList.add("visible");
    this.openSearchTarget.classList.remove("invisible");
    this.openSearchTarget.classList.add("visible");
  }

  hideDisplayHeader() {
    this.displayHeaderTarget.classList.remove("visible");
    this.displayHeaderTarget.classList.add("invisible", "w-1");
    this.displaySelectorTarget.classList.remove("visible");
    this.displaySelectorTarget.classList.add("invisible", "w-1");
    this.openSearchTarget.classList.remove("visible");
    this.openSearchTarget.classList.add("invisible");
  }

  openSearch() {
    this.hideDisplayHeader();
    this.searchFormTarget.classList.remove("invisible");
    this.searchFormTarget.classList.add("visible");
    this.backTarget.classList.remove("invisible");
    this.backTarget.classList.add("visible");
    this.focusSearch();
  }

  closeSearch() {
    this.searchFormTarget.classList.remove("visible");
    this.searchFormTarget.classList.add("invisible");
    this.backTarget.classList.remove("visible");
    this.backTarget.classList.add("invisible");
    this.showDisplayHeader();
  }

  focusSearch() {
    this.searchInputTarget.focus();
  }

  search(event) {
    if (event.key == "Enter" || event.type == "click") {
      console.log(`search ${this.searchTarget.value}`);
    }
  }
} 
