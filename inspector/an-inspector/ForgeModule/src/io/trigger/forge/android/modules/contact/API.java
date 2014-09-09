package io.trigger.forge.android.modules.contact;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;
import io.trigger.forge.android.core.ForgeApp;
import io.trigger.forge.android.core.ForgeIntentResultHandler;
import io.trigger.forge.android.core.ForgeLog;
import io.trigger.forge.android.core.ForgeParam;
import io.trigger.forge.android.core.ForgeTask;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Map;

import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentUris;
import android.content.Intent;
import android.database.Cursor;
import android.provider.ContactsContract;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

public class API {
	/**
	 * Allow interactive picking of a single contact
	 * @param task
	 */
	public static void select(final ForgeTask task) {
		ForgeIntentResultHandler handler = new ForgeIntentResultHandler() {
			@Override
			public void result(int requestCode, int resultCode, Intent data) {
				if (resultCode == RESULT_OK) {
					String contactId;
					JsonObject result = new JsonObject();
					Cursor cursor = null;
					cursor = ForgeApp.getActivity().getContentResolver().query(data.getData(),
							new String[] { ContactsContract.Contacts._ID },
							null, null, null);
					try {
						if (cursor.moveToFirst()) {
							contactId = cursor.getString(0);
							result = Util.contactIdToJsonObject(contactId, null);
						}
					} finally {
						cursor.close();
					}
					task.success(result);
				} else if (resultCode == RESULT_CANCELED) {
					task.error("User cancelled selecting contact", "EXPECTED_FAILURE", null);
				} else {
					task.error("Unknown error selecting contact", "UNEXPECTED_FAILURE", null);
				}
			}
		};
		ForgeApp.intentWithHandler(new Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI), handler);
	}

	/**
	 * Return everything we know about a single contact
	 * @param task
	 * @param contactId
	 */
	public static void selectById(final ForgeTask task, @ForgeParam("id") final String contactId) {
		JsonObject contact = Util.contactIdToJsonObject(contactId, null);
		if (contact != null) {
			task.success(contact);
		} else {
			task.error("No contact with id '"+contactId+"' found", "EXPECTED_FAILURE", null);
		}
	}

	/**
	 * Return data about every contact.
	 *
	 * If fields is null, return everything for every contact; otherwise, limit the columns
	 * we inspect to the high-level fields specified therein.
	 *
	 * @param task
	 * @param fields
	 */
	public static void selectAll(final ForgeTask task, @ForgeParam("fields") final JsonArray fields) {
		Map<String, JsonObject> contacts = new Hashtable<String, JsonObject>();
		Cursor cursor = ForgeApp.getActivity().getContentResolver().query(
				ContactsContract.Contacts.CONTENT_URI,
				new String[] {
						ContactsContract.Contacts._ID,
						ContactsContract.Contacts.DISPLAY_NAME
				},
				null, null, null);
		try {
			if (cursor.moveToFirst()) {
				do {
					String contactId = cursor.getString(0);
					JsonObject contact;
					if (contacts.containsKey(contactId)) {
						contact = contacts.get(contactId);
					} else {
						contact = new JsonObject();
						contact.addProperty("id", contactId);
						contact.addProperty("displayName", cursor.getString(1));
					}
					contacts.put(contactId, contact);
				} while (cursor.moveToNext());
			}
			if (fields.size() != 0) {
				Util.populateContacts(contacts, fields);
			}

			JsonArray results = new JsonArray();
			for (JsonObject value: contacts.values()) {
				results.add(value);
			}
			task.success(results);
		} finally {
			cursor.close();
		}
	}

	/**
	 * Add a new contact
	 *
	 * @param task
	 * @param contact
	 */
	public static void add(final ForgeTask task, @ForgeParam("contact") final JsonObject contact) {
		try {
			ArrayList<ContentProviderOperation> person = Util.contactFromJSON(contact);
			if (person == null) {
				task.error("Not a valid contact");
				return;
			}
			ContentProviderResult [] result = ForgeApp.getActivity().getContentResolver().applyBatch(ContactsContract.AUTHORITY, person);
			if (result.length != person.size()) {
				ForgeLog.w("Not all contact fields could be added");
			}
			if (result.length > 0) {
				long rawContactID = ContentUris.parseId(result[0].uri);
				contact.addProperty("id", String.valueOf(rawContactID));
				task.success(contact);
			} else {
				task.error("Unknown error adding contact", "UNEXPECTED_FAILURE", null);
			}
		} catch (Exception e) {
			e.printStackTrace();
			task.error("Failed to add contact: " + e.getLocalizedMessage(), "UNEXPECTED_FAILURE", null);
		}
	}
}
