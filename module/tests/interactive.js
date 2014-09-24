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

	asyncTest("Add contact", 1, function() {
		var runTest = function () {
			var contact = {
				"name": {
					"familyName": "Bloggs",
					"givenName": "Joe",
					// "middleName": null,
					"honorificPrefix": "Mr",
					"honorificSuffix": null
				},
				"nickname": "Joe",
				"phoneNumbers": [ {
					"value": "+447554639203",
					"type": "work"
				}, {
					"value": null,
					"type": "home"
				}, {
					"type": "work"
				}, {
					"value": "+27824485158"
				}, {
					"value": "+27824485158",
					"type": null
				} ],
				"emails": [ {
					"value": "joe-bloggs@trigger.io",
					"type": "work"
				}, {
					"value": null,
					"type": "work"
				}, {
					"type": "work"
				}, {
					"value": "joe-bloggs@trigger.io",
				}, {
					"value": "joe-bloggs@trigger.io",
					"type": null
				} ],
				"addresses": [ {
					"country": "United Kingdom",
					"locality": "London",
					"postalCode": null,
					//"region": "London",
					"streetAddress": "1-11 Baches Street",
					"type": "work"
				} ],
				"birthday": "1983-11-23",
				"note": "Any text can go here"
			};
			forge.contact.add(contact, function (data) {
				askQuestion("Contact added: " + JSON.stringify(data) + " - sound right?", {
					Yes: function () {
						ok(true, "User claims success");
						start();
					},
					No: function () {
						ok(false, "User claims failure");
						start();
					}
				});
			}, function (e) {
				ok(false, "Error callback fired: " + e.message);
				start();
			});
		};
		askQuestion("When prompted add a contact", { Yes: runTest, No: runTest });
	});
	
	if (forge.is.ios()) {
		asyncTest("Add contact (cancel)", 1, function() {
			var runTest = function () {
				forge.contact.add({}, function () {
					ok(false, "Success callback fired");
					start();
				}, function (e) {
					ok(true, "Error callback fired: "+e.message);
					start();
				});
			};
			askQuestion("When prompted cancel adding a contact", { Yes: runTest, No: runTest });
		});

		asyncTest("Insert contact", 1, function() {
			var runTest = function () {
				var contact = {
					"name": {
						"familyName": "Cald",
						"givenName": "Jane",
						// "middleName": null,
						"honorificPrefix": "Ms",
						"honorificSuffix": null
					},
					"nickname": "Janie",
					"phoneNumbers": [ {
						"value": "+18005885263",
						"type": "work"
					} ],
					"emails": [ {
						"value": "jane@cald.com",
						"type": "work"
					} ],
					"addresses": [ {
						"country": "United Kingdom",
						"locality": "London",
						"postalCode": null,
						//"region": "London",
						"streetAddress": "1-11 Baches Street",
						"type": "work"
					} ],
					"birthday": "1983-11-23",
					"note": "Girl can sing!"
				};

				forge.contact.insert(contact,
					function (contactID) {
						forge.contact.selectById(contactID, 
							function (readBack) {
								delete readBack.photos;

								askQuestion("Is this Jane? <pre>"+JSON.stringify(readBack)+"</pre>", {
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
							function (e) {
								ok(false, "Error callback on readBack: "+e.message);
								start();
							}
						);

						// askQuestion("Did Jane get added?  (ID " + contactID + ")", {
						// 	Yes: function () {
						// 		ok(true, "User claims success");
						// 		start();
						// 	}, 
						// 	No: function () {
						// 		ok(false, "User claims failure");
						// 		start();
						// 	}
						// });
					},
					function (e) {
						ok(false, "Error callback on insert: "+e.message);
						start();
					}
				);
			};				

			askQuestion("When prompted let me insert Jane", { Yes: runTest, No: runTest });
		});
	}
}
