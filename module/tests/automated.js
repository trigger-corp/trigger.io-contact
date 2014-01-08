module("forge.contact");

asyncTest("Select all by ID", 1, function () {
	forge.contact.selectAll(['id'], function(contacts) {
		contacts.forEach(function(ref) {
			forge.contact.selectById(ref.id, function (contact) {
				try {
					JSON.stringify(contact);
				} catch (e) {
					ok(false, "Error invalid contact: " + JSON.stringify(e));
				}
			});
		});
		ok(true, "Success");
		start();
	}, function (e) {
		ok(false, "Error callback fired: " + e.message);
		start();
	});
});
