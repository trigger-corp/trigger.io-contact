``contact``: Accessing contacts
===============================

The ``forge.contact`` namespace allows access to the native contact
address book on the device the app is running on.

Contacts are represented by a simple JavaScript object which follows the [W3C Contacts API](http://www.w3.org/TR/contacts-api/#contact-interface>) as much as possible.

##API

!method: forge.contact.select(success, error)
!param: success `function(contact)` callback to be invoked when no errors occur
!description: Prompts the user to select a contact and returns a contact object.
!platforms: iOS, Android
!param: error `function(content)` called with details of any error which may occur

!method: forge.contact.selectAll([fields, ]success, error)
!param: fields `[string]` array of additional fields to include with each contact id and name.
!param: success `function(contactList)` callback to be invoked when no errors occur
!description: Returns a list of all the available contact IDs and contact names.
!platforms: iOS, Android
!param: error `function(content)` called with details of any error which may occur

> ::Note:: Due to performance limitations on Android devices, ``selectAll`` is unable to return the full list of fully populated contact names; our recommended pattern is to use this method to get the list of all available contact IDs, then lazily load the more detailed full contact information with the ``selectById`` method.

!method: forge.contact.selectById(id, success, error)
!param: id `string` contact ID to be queried
!param: success `function(contact)` callback to be invoked when no errors occur
!description: Returns more detailed information about a contact whose contact ID we already know.
!platforms: iOS, Android
!param: error `function(content)` called with details of any error which may occur

##Contact object 

When using ``selectAll``, the returned contacts list would look
something like:

    [
        {
            "id": "14894",
            "displayName": "Mr Joe Bloggs"
        },
        {
            "id": "481516",
            "displayName": "Mr John Locke"
        },
        ...
    ]

Below is an example of a contact object returned from ``select`` or
``selectById``, with details for some field types.

	{
	  "id": "14894",
	  "displayName": "Mr Joe Bloggs",
	  "name": {
	    "formatted": "Mr Joe Bloggs",
	    "familyName": "Bloggs",
	    "givenName": "Joe",
	    "middleName": null,
	    "honorificPrefix": "Mr",
	    "honorificSuffic": null
	  },
	  "nickname": "Joe",
	  "phoneNumbers": [
	    {
	      "value": "+447554639203",
	      "type": "work",
	      "pref": false
	    }
	  ],
	  "emails": [
	    {
	      "value": "joe-bloggs@trigger.io",
	      "type": "work",
	      "pref": false
	    }
	  ],
	  "addresses": [
	    {
	      "country": "United Kingdom",
	      "formatted": "1-11 Baches Street\nLondon\nLondon\N1 6DL\nUnited Kingdom",
	      "locality": "London",
	      "postalCode": "N1 6DL",
	      "pref": false,
	      "region": "London",
	      "streetAddress": "1-11 Baches Street",
	      "type": "work"
	    }
	  ],
	  "ims": [
	    {
	      "value": "joe-bloggs@trigger.io",
	      "type": "gtalk",
	      "pref": false
	    }
	  ],
	  "organizations": [
	    {
	      "department": "Product development",
	      "name": "Forger",
	      "pref": false,
	      "title": "Software engineer",
	      "type": null
	    }
	  ],
	  "birthday": "1983-11-23",
	  "note": "Any text can go here",
	  "photos": [
	    {
	      "value": "data:image/jpg;base64,ABCDEF1234",
	      "type": null,
	      "pref": false
	    }
	  ],
	  "categories": null,
	  "urls": [
	    {
	      "value": "http://trigger.io",
	      "type": "homepage",
	      "pref": false
	    }
	  ],
	}

###Fields

This section includes more detailed information on the contents of
fields with non-obvious content.

####id

This is a unique identifier for the contact, and is guaranteed to be the
same if the user selects the same contact again.

####displayName

This is a formatted version of the contact's name which can be used for
display. On iOS this is generated from the various parts of the name, on
Android this is stored as a separate value.

####name

This is an object containing the various parts of the contact's name,
including a formatted version which is used as the previous displayName
value.

####nickname

A string value containing a nickname for the contact

####phoneNumbers

An array of objects containing details of a contact's phone numbers. Each
number has a ``value``, a ``type`` (such as ``home`` or ``work``) and
also a ``pref`` property, which is unsupport on Android and iOS so is
always false.

####emails

Similarly this property is an array of objects describing a contact's
emails, with ``value``, ``type`` and ``pref`` (which is also always
false).

####addresses

An array of objects describing a contact's addresses, ``formatted``
contains a string generated from the other properties which can be used
to display the address. Each object also contains a ``pref`` property
which is always false.

####ims

Contains an array of Instant Messaging details for a contact, formatted
similarly to phoneNumbers and emails.

####organizations

Contains an array of objects describing organizations the contact is
part of.

Can only contain one organization on iOS.

####birthday

Contains a string with the date of birth of the contact.

####note

A string which can contain arbitrary information about the contact.

####photos

Contains an array of thumbnail photos associated with the contact, each
photo has a value which contains a ``data:`` uri of the image. The
``type`` and ``pref`` properties are not used.

Contains at most 1 photo on iOS.

####categories

Not available on iOS or Android.

####urls

Contains an array of URLs related to the contact, formatted similarly to
phoneNumbers and emails.

###Permissions

On Android this module will add the ``READ_CONTACTS`` permission to your
app, users will be prompted to accept this when they install your app.
