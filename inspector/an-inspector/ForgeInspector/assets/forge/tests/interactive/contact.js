module("forge.contact");

if (forge.is.mobile()) {
	asyncTest("Select all", 1, function() {
		forge.contact.selectAll(['name'], function (data) {
			askQuestion("We found "+data.length+" contacts - sound right?", {
				Yes: function () {
					var question = "Recognise these? <pre>";
					for (var idx=0; idx<Math.min(3, data.length); idx++) {
						question += JSON.stringify(data[Math.floor(Math.random() * data.length)]);
						question += "\n";
					}
					question += "</pre>";
					askQuestion(question, {
						Yes: function () {
							ok(true, "User claims success");
							start();
						}, 
						No: function () {
							ok(false, "User claims failure");
							start();
						}
					});
				}, 
				No: function () {
					ok(false, "User claims failure");
					start();
				}
			});
		}, function (e) {
			ok(false, "Error callback fired: "+e.message);
			start();
		});
	});

	asyncTest("Select by ID", 1, function() {
		forge.contact.selectAll(function (data) {
			forge.contact.selectById(data[Math.floor(Math.random() * data.length)].id, function (contact) {
				delete contact.photos;
				askQuestion("Recognise this person? <pre>"+JSON.stringify(contact)+"</pre>", {
					Yes: function () {
						ok(true, "User claims success");
						start();
					}, 
					No: function () {
						ok(false, "User claims failure");
						start();
					}
				});
			}, function () {
				ok(false, "Error callback fired: "+e.message);
				start();
			});
		}, function (e) {
			ok(false, "selectAll error callback fired: "+e.message);
			start();
		});
	});

	asyncTest("Select", 1, function() {
		var runTest = function () {
			forge.contact.select(function (data) {
				// allow for there being no photo
				var photoValue;
				if (data.photos) {
					photoValue = data.photos[0].value;
					delete data.photos;
				} else {
					photoValue = null;
				}
				askQuestion("Is this your contact: "+JSON.stringify(data), {
					Yes: function () {
						askQuestion("If your contact had an image is it shown:<br><img src='"+photoValue+"' style='max-width: 100px; max-height: 100px'>", {
							Yes: function () {
								ok(true, "User claims success");
								start();
							}, 
							No: function () {
								ok(false, "User claims failure");
								start();
							}
						});
					}, 
					No: function () {
						ok(false, "User claims failure");
						start();
					}
				});				
			}, function (e) {
				ok(false, "Error callback fired: "+e.message);
				start();
			});
		};
		askQuestion("When prompted select a contact from the list given, if possible choose a contact with a picture which hasn't been imported from Facebook", { Yes: runTest, No: runTest });
	});

	asyncTest("Select (cancel)", 1, function() {
		var runTest = function () {
			forge.contact.select(function () {
				ok(false, "Success callback fired");
				start();
			}, function (e) {
				ok(true, "Error callback fired: "+e.message);
				start();
			});
		};
		askQuestion("When prompted cancel selecting a contact	", { Yes: runTest, No: runTest });
	});
}
