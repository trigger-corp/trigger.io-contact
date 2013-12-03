package io.trigger.forge.android.modules.contact;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;
import io.trigger.forge.android.core.ForgeApp;
import io.trigger.forge.android.core.ForgeIntentResultHandler;
import io.trigger.forge.android.core.ForgeParam;
import io.trigger.forge.android.core.ForgeTask;

import java.util.Hashtable;
import java.util.Map;

import android.content.Intent;
import android.database.Cursor;
import android.provider.ContactsContract;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

public class API {
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
	
	public static void selectById(final ForgeTask task, @ForgeParam("id") final String contactId) {
		JsonObject contact = Util.contactIdToJsonObject(contactId, null);
		if (contact != null) {
			task.success(contact);
		} else {
			task.error("No contact with id '"+contactId+"' found", "EXPECTED_FAILURE", null);
		}
	}
	
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
				Util.populateContacts(contacts, null);
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
}
