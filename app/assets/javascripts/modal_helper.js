window.toggleModalElement = function(element, show, ...classesToToggle) {
  if (!element) return;

  if (show) {
    element.classList.remove('hidden');
    classesToToggle.forEach(cls => element.classList.add(cls));
  } else {
    element.classList.add('hidden');
    classesToToggle.forEach(cls => element.classList.remove(cls));
  }
};

window.setModalFooterLayout = function(footer, hasDelete) {
  if (!footer) return;

  footer.classList.toggle('justify-between', hasDelete);
  footer.classList.toggle('justify-end', !hasDelete);
};

window.setFormField = function(fieldId, value) {
  const field = document.getElementById(fieldId);
  if (field) {
    field.value = value || '';
  }
};

window.setFormFields = function(fields) {
  Object.entries(fields).forEach(([fieldId, value]) => {
    window.setFormField(fieldId, value);
  });
};

window.setModalTitle = function(modalId, title) {
  const modal = document.getElementById(modalId);
  if (!modal) return;

  const titleElement = modal.querySelector('h3, h2');
  if (titleElement) {
    titleElement.textContent = title;
  }
};
