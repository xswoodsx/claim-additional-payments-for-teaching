"use strict";

document.addEventListener("DOMContentLoaded", function() {
  var form = document.querySelector("form.edit_tslr_claim");

  if (!form) {
    return;
  }

  var searchInputContainer = form.querySelector("#school-search-container");

  if (!searchInputContainer) {
    return;
  }

  var schoolSearchUrl = form.attributes["data-school-search-url"].nodeValue;
  var schoolIdParam = form.attributes["data-school-id-param"].nodeValue;

  var schoolIdInput = form.querySelector("#tslr_claim_" + schoolIdParam);

  if (!schoolIdInput) {
    return;
  }

  var methodInput = form.querySelector('input[name="_method"]');
  var formSubmit = form.querySelector('input[type="submit"]');

  var defaultSchoolIdInputValue = schoolIdInput.value || "";
  var defaultFormMethod = form.method || "";
  var defaultMethodInputValue = methodInput.method || "";
  var defaultFormSubmitValue = formSubmit.value || "";

  function resetForm() {
    schoolIdInput.value = defaultSchoolIdInputValue;
    form.method = defaultFormMethod;
    methodInput.value = defaultMethodInputValue;
    formSubmit.value = defaultFormSubmitValue;
  }

  var schools = [];

  function findSchool(name) {
    for (var i = 0; i < schools.length; i++) {
      var school = schools[i];

      if (school.name === name) {
        return school;
      }
    }
  }

  accessibleAutocomplete({
    element: searchInputContainer,
    id: "tslr_claim_school_search",
    name: "school_search",
    source: function(query, populateResults) {
      Rails.ajax({
        type: "get",
        url: schoolSearchUrl + "?school_search=" + query,
        success: function(response) {
          schools = response.data;

          populateResults(
            schools.map(function(school) {
              return school.name;
            })
          );
        }
      });
    },
    minLength: 4,
    showNoOptionsFound: false,
    confirmOnBlur: false,
    templates: {
      suggestion: function(name) {
        var school = findSchool(name);

        return (
          '<label class="govuk-label govuk-label--s">' +
          school.name +
          "</label>" +
          '<span class="govuk-hint">' +
          school.address +
          "</span>"
        );
      }
    },
    onConfirm: function(name) {
      var school = findSchool(name);

      if (!school) {
        resetForm();
        return;
      }

      schoolIdInput.value = school.id;
      form.method = "post";
      methodInput.value = "patch";
      formSubmit.value = "Continue";
    }
  });

  var oldSearchInput = form.querySelector('input[name="school_search"]');
  var searchValue = oldSearchInput.value;

  oldSearchInput.parentNode.removeChild(oldSearchInput);

  var newSearchInput = form.querySelector('input[name="school_search"]');

  newSearchInput.value = searchValue;
  newSearchInput.addEventListener("input", function() {
    resetForm();
  });

  resetForm();
});
