// Open all details elements to show the anchor
function dd_open_details(event) {
    var url = new URL(window.location);
    var anchor_element = document.querySelector(url.hash);
    if (anchor_element) {
        var element = anchor_element;
        while (element.parentNode) {
            element = element.parentNode;
            if (element.tagName == "DETAILS") {
                element.open = true;
            }
        }
        anchor_element.scrollIntoView();
    }
}
// Open details elements when we click a link on the same page, or when the page loads
window.addEventListener("hashchange", dd_open_details);
window.addEventListener("load", dd_open_details);
