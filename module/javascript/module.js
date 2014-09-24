forge['contact'] = {
	'select': function (success, error) {
		forge.internal.call("contact.select", {}, success, error);
	},
	'selectById': function (id, success, error) {
		forge.internal.call("contact.selectById", {id: id}, success, error);
	},
	'selectAll': function (fields, success, error) {
		if (typeof fields === "function") {
			error = success;
			success = fields;
			fields = [];
		}
		forge.internal.call("contact.selectAll", {fields: fields}, success, error);
	},
	'add': function (contact, success, error) {
		if (typeof contact === "function") {
			error = success;
			success = contact;
			contact = {};
		}
		forge.internal.call("contact.add", {contact: contact}, success, error);
	},

	'insert': function (contact, success, error) {
	    forge.internal.call("contact.insert", {contact: contact}, 
				success, error);
	}
};
