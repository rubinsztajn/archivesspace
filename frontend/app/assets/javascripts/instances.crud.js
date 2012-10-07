$(function() {

  var renderContainer = function() {
    if ($(".container-form-fields", this).length) {
      // container already rendered
      return;
    }

    var index_data = {};
    index_data.index = $(".instance-container-or-digital-object", $(this).parents("form")).index($(".instance-container-or-digital-object", this));

    $(".instance-container-or-digital-object", this).html(AS.renderTemplate("container_form_template", index_data));
  };

  var renderDigitalObject = function() {
    $(".instance-container-or-digital-object", this).html("<div class='alert alert-info'>TODO</div>");
  };

  var renderDigitalObjectLink = function() {
    $(".instance-container-or-digital-object", this).html("<div class='alert alert-info'>TODO</div>");
  };

  var renderNilValue =function() {
    $(".instance-container-or-digital-object", this).html(AS.renderTemplate("empty_instance_type_tempalte"));
  }

  $(document).bind("subrecord.new", function(event, object_name, subform) {
    if (object_name === "instance") {
      $("[name^='resource[instances]['][name$='][instance_type]']", subform).change(function(event) {
        if ($(this).val() === "digital_object") {
          $.proxy(renderDigitalObject, subform)();
        } else if ($(this).val() === "digital_object_link") {
          $.proxy(renderDigitalObjectLink, subform)();
        } else if ($(this).val() === "") {
          $.proxy(renderNilValue, subform)();
        } else {
          $.proxy(renderContainer, subform)();
        }
      });
    }
  });

});
