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
    this.openSearchTarget.classList.remove("invisible");
    this.openSearchTarget.classList.add("visible");
  }

  hideDisplayHeader() {
    this.displayHeaderTarget.classList.remove("visible");
    this.displayHeaderTarget.classList.add("invisible", "w-1");
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

  // drag and drop
  
  dragStart(event) {
    event.dataTransfer.setData("data-id", event.target.getAttribute("data-id"))
    event.dataTransfer.effectAllowed = "move"
  }

  dragOver(event) {
    event.preventDefault()
    return true
  }

  dragEnter(event) {
    event.preventDefault()
  }

  drop(event) {
    let dropTarget = event.target
    let droppable = dropTarget.getAttribute("droppable") 
    if (!droppable || droppable == "false") {
      dropTarget = dropTarget.closest(`[droppable='true']`)
      droppable = dropTarget.getAttribute("droppable")
    }

    if (droppable == "true") {
      const id = event.dataTransfer.getData("data-id")
      const timespanHour = dropTarget.getAttribute("data-timespan-hour") || ""
      const timespanMDay = dropTarget.getAttribute("data-timespan-mday") || ""

      fetch(`/interviews/${id}/confirm?hour=${timespanHour}&mday=${timespanMDay}`)
        .then(r => r.text())
        .then(html => {
          const fragment = document.createRange().createContextualFragment(html)
          document.getElementById("modal").replaceWith(fragment)
        })
    }
    event.preventDefault()
  }

  dragEnd(event) {}
}
