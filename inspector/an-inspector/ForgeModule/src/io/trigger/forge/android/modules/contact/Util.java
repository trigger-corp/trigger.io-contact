package io.trigger.forge.android.modules.contact;

import io.trigger.forge.android.core.ForgeApp;

import java.util.Hashtable;
import java.util.Map;
import java.util.Vector;

import android.database.Cursor;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.BaseTypes;
import android.util.Base64;

import com.google.common.base.Joiner;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonNull;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

class Util {
	public static JsonArray allFields = new JsonArray();
	static {
		allFields.add(new JsonPrimitive("nickname"));
		allFields.add(new JsonPrimitive("note"));
		allFields.add(new JsonPrimitive("birthday"));
		allFields.add(new JsonPrimitive("name"));
		allFields.add(new JsonPrimitive("emails"));
		allFields.add(new JsonPrimitive("phoneNumbers"));
		allFields.add(new JsonPrimitive("addresses"));
		allFields.add(new JsonPrimitive("ims"));
		allFields.add(new JsonPrimitive("urls"));
		allFields.add(new JsonPrimitive("organizations"));
		allFields.add(new JsonPrimitive("photos"));
	}
	
	/**
	* Returns an array of Strings which can be used to limit the columns returned by the data provider.
	* 
	* @param fields the high-level field names we need data for: possible values are in the allFields array.
	*/
	private static String[] getProjection(final JsonArray fields) {
		Vector<String> projection = new Vector<String>();
		
		// Columns which must be included for internal uses
		projection.add(ContactsContract.Contacts._ID);
		projection.add(ContactsContract.Data.CONTACT_ID);
		projection.add(ContactsContract.Data.LOOKUP_KEY);
		projection.add(ContactsContract.Data.DISPLAY_NAME);
		projection.add(ContactsContract.Data.MIMETYPE);

		for (JsonElement jsonField : fields) {
			String field = jsonField.getAsString();
			if (field.equals("name")) {
				projection.add(ContactsContract.CommonDataKinds.StructuredName.FAMILY_NAME);
				projection.add(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME);
				projection.add(ContactsContract.CommonDataKinds.StructuredName.GIVEN_NAME);
				projection.add(ContactsContract.CommonDataKinds.StructuredName.PREFIX);
				projection.add(ContactsContract.CommonDataKinds.StructuredName.SUFFIX);
				projection.add(ContactsContract.CommonDataKinds.StructuredName.MIDDLE_NAME);
			} else if (field.equals("nickname")) {
				projection.add(ContactsContract.CommonDataKinds.Nickname.NAME);
			} else if (field.equals("phoneNumbers")) {
				projection.add(ContactsContract.CommonDataKinds.Phone.NUMBER);
				projection.add(ContactsContract.CommonDataKinds.Phone.TYPE);
				projection.add(ContactsContract.CommonDataKinds.Phone.LABEL);
			} else if (field.equals("emails")) {
				projection.add(ContactsContract.CommonDataKinds.Email.DATA);
				projection.add(ContactsContract.CommonDataKinds.Email.TYPE);
				projection.add(ContactsContract.CommonDataKinds.Email.LABEL);
			} else if (field.equals("addresses")) {
				projection.add(ContactsContract.CommonDataKinds.StructuredPostal.FORMATTED_ADDRESS);
				projection.add(ContactsContract.CommonDataKinds.StructuredPostal.TYPE);
				projection.add(ContactsContract.CommonDataKinds.StructuredPostal.LABEL);
				projection.add(ContactsContract.CommonDataKinds.StructuredPostal.STREET);
				projection.add(ContactsContract.CommonDataKinds.StructuredPostal.CITY);
				projection.add(ContactsContract.CommonDataKinds.StructuredPostal.REGION);
				projection.add(ContactsContract.CommonDataKinds.StructuredPostal.POSTCODE);
				projection.add(ContactsContract.CommonDataKinds.StructuredPostal.COUNTRY);
			} else if (field.equals("ims")) {
				projection.add(ContactsContract.CommonDataKinds.Im.DATA);
				projection.add(ContactsContract.CommonDataKinds.Im.PROTOCOL);
				projection.add(ContactsContract.CommonDataKinds.Im.CUSTOM_PROTOCOL);
			} else if (field.equals("organizations")) {
				projection.add(ContactsContract.CommonDataKinds.Organization.COMPANY);
				projection.add(ContactsContract.CommonDataKinds.Organization.TYPE);
				projection.add(ContactsContract.CommonDataKinds.Organization.LABEL);
				projection.add(ContactsContract.CommonDataKinds.Organization.DEPARTMENT);
				projection.add(ContactsContract.CommonDataKinds.Organization.TITLE);
			} else if (field.equals("birthday")) {
				projection.add(ContactsContract.CommonDataKinds.Event.START_DATE);
				projection.add(ContactsContract.CommonDataKinds.Event.TYPE);
			} else if (field.equals("note")) {
				projection.add(ContactsContract.CommonDataKinds.Note.NOTE);
			} else if (field.equals("photos")) {
				projection.add(ContactsContract.CommonDataKinds.Photo.PHOTO);
			} else if (field.equals("urls")) {
				projection.add(ContactsContract.CommonDataKinds.Website.URL);
				projection.add(ContactsContract.CommonDataKinds.Website.TYPE);
				projection.add(ContactsContract.CommonDataKinds.Website.LABEL);
			}
		}
		
		return projection.toArray(new String[projection.size()]);
	}
	
	/**
	* Return the mime-types which correspond to the fields passed in as an argument.
	* 
	* @param fields the high-level field names to return mime-types for; valid values are in allFields.
	*/
	private static String[] getMimeTypes(final JsonArray fields) {
		Vector<String> mimeTypes = new Vector<String>();
		
		for (JsonElement jsonField : fields) {
			String field = jsonField.getAsString();
			if (field.equals("name")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE);
			} else if (field.equals("nickname")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Nickname.CONTENT_ITEM_TYPE);
			} else if (field.equals("phoneNumbers")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE);
			} else if (field.equals("emails")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE);
			} else if (field.equals("addresses")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE);
			} else if (field.equals("ims")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Im.CONTENT_ITEM_TYPE);
			} else if (field.equals("organizations")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE);
			} else if (field.equals("birthday")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Event.CONTENT_ITEM_TYPE);
			} else if (field.equals("note")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE);
			} else if (field.equals("photos")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Photo.CONTENT_ITEM_TYPE);
			} else if (field.equals("urls")) {
				mimeTypes.add(ContactsContract.CommonDataKinds.Website.CONTENT_ITEM_TYPE);
			}
		}
		
		return mimeTypes.toArray(new String[mimeTypes.size()]);
	}

	/**
	 * Return the column index, given its name
	 * 
	 * @param name column name
	 * @param columnMemo mapping of name to index
	 * @return integer column index
	 */
	private static int getColumnIndex(String name, Map<String, Integer> columnMemo) {
		return columnMemo.get(name); 
	}
	
	/**
	 * Return the value of the named column, at the current row
	 * @param cursor database cursor into provider results
	 * @param name
	 * @param columnMemo
	 * @return specified value, or an empty string if not found 
	 */
	private static String getValue(Cursor cursor, String name, Map<String, Integer> columnMemo) {
		try {
			return cursor.getString(getColumnIndex(name, columnMemo));
		} catch (Exception e) {
			return "";
		}
	}
	
	private static int getValueOrMinusOne(Cursor cursor, String name, Map<String, Integer> columnMemo) {
		String value = getValue(cursor, name, columnMemo);
		if ("" == value) {
			return -1;
		} else {
			return Integer.parseInt(value); 
		}
	}
	
	/**
	 * For a mapping of contactId to Json contact objects, fill out each contact with the projection of fields
	 * (or all fields, if fields is null)
	 * @param contacts mapping of contactId to JsonObject contact
	 * @param fields array of high-level fields, or null for everything
	 * 
	 * NB contacts is changed in-place
	 */
	public static void populateContacts(final Map<String, JsonObject> contacts, JsonArray fields) {
		if (fields == null) {
			fields = allFields;
		}
		final String[] projection = getProjection(fields);
		
		Joiner joiner = Joiner.on("','").skipNulls();
		String contactIds = "'"+joiner.join(contacts.keySet())+"'";
		
		final String[] mimeTypes = getMimeTypes(fields);
		
		StringBuilder selection = new StringBuilder();
		
		selection.append(ContactsContract.Data.CONTACT_ID + " in ("+contactIds+")");
		if (mimeTypes.length > 0) {
			selection.append(" AND (");
			for (int i = 0; i < mimeTypes.length - 1; i++) {
				selection.append(ContactsContract.Data.MIMETYPE + " = ? OR ");
			}
			selection.append(ContactsContract.Data.MIMETYPE + " = ?)");
		}
		
		Cursor cursor = ForgeApp.getActivity().getContentResolver().query(
				ContactsContract.Data.CONTENT_URI,
				projection,
				selection.toString(),
				mimeTypes, null);
		
		try {
			if (!cursor.moveToFirst()) {
				return;
			}
			do {
				JsonObject contact = contacts.get(cursor.getString(1));
				if (contact != null) {
					contactToJSON(cursor, contact, projection);
				}
			} while (cursor.moveToNext());
		} finally {
			cursor.close();
		}
	}
	
	/**
	 * Fill out a single contact with data from the columns specified by the fields projection
	 *  
	 * @param contactId
	 * @param fields high-level field names to limit the columns inspected, or null for everything
	 * @return the contact object changed in-place
	 */
	public static JsonObject contactIdToJsonObject(final String contactId, JsonArray fields) {
		if (fields == null) {
			fields = allFields;
		}
		final String[] projection = getProjection(fields);
		final String[] mimeTypes = getMimeTypes(fields);
		
		StringBuilder selection = new StringBuilder();
		
		selection.append(ContactsContract.Data.CONTACT_ID + " = '"+contactId+"'");
		if (mimeTypes.length > 0) {
			selection.append(" AND (");
			for (int i = 0; i < mimeTypes.length - 1; i++) {
				selection.append(ContactsContract.Data.MIMETYPE + " = ? OR ");
			}
			selection.append(ContactsContract.Data.MIMETYPE + " = ?)");
		}
		
		Cursor cursor = ForgeApp.getActivity().getContentResolver().query(
				ContactsContract.Data.CONTENT_URI,
				projection,
				selection.toString(),
				mimeTypes, null);
		
		try {
			JsonObject contact = new JsonObject();
			if (!cursor.moveToFirst()) {
				return null;
			}
			do {
				contact = contactToJSON(cursor, contact, projection);
			} while (cursor.moveToNext());
			return contact;
		} finally {
			cursor.close();
		}
	}
	
	// See contactIdToJsonObject
	public static JsonObject contactToJSON(Cursor cursor, JsonObject contact, String[] projection) {
		Map<String, Integer> columnMemo = new Hashtable<String, Integer>();
		for (int idx=0; idx<projection.length; idx++) {
			columnMemo.put(projection[idx], idx);
		}
		
		contact.addProperty("displayName", Util.getValue(cursor, ContactsContract.Data.DISPLAY_NAME, columnMemo));
		contact.addProperty("id", Util.getValue(cursor, ContactsContract.Contacts._ID, columnMemo));
		
		String mimeType = getValue(cursor, ContactsContract.Data.MIMETYPE, columnMemo);
		
		if (mimeType.equals(ContactsContract.CommonDataKinds.Nickname.CONTENT_ITEM_TYPE)) {
			contact.addProperty("nickname", getValue(cursor, ContactsContract.CommonDataKinds.Nickname.NAME, columnMemo));
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE)) {
			contact.addProperty("note", getValue(cursor, ContactsContract.CommonDataKinds.Note.NOTE, columnMemo));
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.Event.CONTENT_ITEM_TYPE)) {
			if (getValue(cursor, ContactsContract.CommonDataKinds.Event.TYPE, columnMemo).equals(ContactsContract.CommonDataKinds.Event.TYPE_BIRTHDAY)) {
				contact.addProperty("birthday", getValue(cursor, ContactsContract.CommonDataKinds.Event.START_DATE, columnMemo));
			}
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)) {
			JsonObject name = new JsonObject();
			name.addProperty("familyName", getValue(cursor, ContactsContract.CommonDataKinds.StructuredName.FAMILY_NAME, columnMemo));
			name.addProperty("formatted", getValue(cursor, ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, columnMemo));
			name.addProperty("givenName", getValue(cursor, ContactsContract.CommonDataKinds.StructuredName.GIVEN_NAME, columnMemo));
			name.addProperty("honorificPrefix", getValue(cursor, ContactsContract.CommonDataKinds.StructuredName.PREFIX, columnMemo));
			name.addProperty("honorificSuffix", getValue(cursor, ContactsContract.CommonDataKinds.StructuredName.SUFFIX, columnMemo));
			name.addProperty("middleName", getValue(cursor, ContactsContract.CommonDataKinds.StructuredName.MIDDLE_NAME, columnMemo));
			contact.add("name", name);
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE)) {
			JsonObject email = new JsonObject();
			JsonArray emails;
			email.addProperty("value", getValue(cursor, ContactsContract.CommonDataKinds.Email.DATA1, columnMemo));
			email.addProperty("pref", false);
			switch (getValueOrMinusOne(cursor, ContactsContract.CommonDataKinds.Email.TYPE, columnMemo)) {
			case ContactsContract.CommonDataKinds.Email.TYPE_HOME:
				email.addProperty("type", "home");
				break;
			case ContactsContract.CommonDataKinds.Email.TYPE_WORK:
				email.addProperty("type", "work");
				break;
			case ContactsContract.CommonDataKinds.Email.TYPE_OTHER:
				email.addProperty("type", "other");
				break;
			case ContactsContract.CommonDataKinds.Email.TYPE_MOBILE:
				email.addProperty("type", "mobile");
				break;
			case BaseTypes.TYPE_CUSTOM:
				email.addProperty("type", getValue(cursor, ContactsContract.CommonDataKinds.Email.LABEL, columnMemo));
				break;
			default:
				email.add("type", JsonNull.INSTANCE);
				break;
			}
			if (contact.has("emails")) {
				emails = contact.getAsJsonArray("emails");
			} else {
				emails = new JsonArray();
			}
			emails.add(email);
			contact.add("emails", emails);
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)) {
			JsonObject phone = new JsonObject();
			JsonArray phones;
			phone.addProperty("value", getValue(cursor, ContactsContract.CommonDataKinds.Phone.NUMBER, columnMemo));
			phone.addProperty("pref", false);
			switch (getValueOrMinusOne(cursor, ContactsContract.CommonDataKinds.Phone.TYPE, columnMemo)) {
			case ContactsContract.CommonDataKinds.Phone.TYPE_HOME:
				phone.addProperty("type", "home");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE:
				phone.addProperty("type", "mobile");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_WORK:
				phone.addProperty("type", "work");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_FAX_WORK:
				phone.addProperty("type", "fax_work");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_FAX_HOME:
				phone.addProperty("type", "fax_home");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_PAGER:
				phone.addProperty("type", "pager");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_OTHER:
				phone.addProperty("type", "other");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_CALLBACK:
				phone.addProperty("type", "callback");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_CAR:
				phone.addProperty("type", "car");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_COMPANY_MAIN:
				phone.addProperty("type", "company_main");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_ISDN:
				phone.addProperty("type", "isdn");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_MAIN:
				phone.addProperty("type", "main");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_OTHER_FAX:
				phone.addProperty("type", "other_fax");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_RADIO:
				phone.addProperty("type", "radio");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_TELEX:
				phone.addProperty("type", "telex");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_TTY_TDD:
				phone.addProperty("type", "tty_tdd");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_WORK_MOBILE:
				phone.addProperty("type", "work_mobile");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_WORK_PAGER:
				phone.addProperty("type", "work_pager");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_ASSISTANT:
				phone.addProperty("type", "assistant");
				break;
			case ContactsContract.CommonDataKinds.Phone.TYPE_MMS:
				phone.addProperty("type", "mms");
				break;
			case BaseTypes.TYPE_CUSTOM:
				phone.addProperty("type", getValue(cursor, ContactsContract.CommonDataKinds.Phone.LABEL, columnMemo));
				break;
			default:
				phone.add("type", JsonNull.INSTANCE);
				break;
			}
			if (contact.has("phoneNumbers")) {
				phones = contact.getAsJsonArray("phoneNumbers");
			} else {
				phones = new JsonArray();
			}
			phones.add(phone);
			contact.add("phoneNumbers", phones);
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE)) {
			JsonObject address = new JsonObject();
			JsonArray addresses;
			address.addProperty("formatted", getValue(cursor, ContactsContract.CommonDataKinds.StructuredPostal.FORMATTED_ADDRESS, columnMemo));
			address.addProperty("pref", false);
			
			switch (getValueOrMinusOne(cursor, ContactsContract.CommonDataKinds.StructuredPostal.TYPE, columnMemo)) {
			case ContactsContract.CommonDataKinds.StructuredPostal.TYPE_HOME:
				address.addProperty("type", "home");
				break;
			case ContactsContract.CommonDataKinds.StructuredPostal.TYPE_WORK:
				address.addProperty("type", "work");
				break;
			case ContactsContract.CommonDataKinds.StructuredPostal.TYPE_OTHER:
				address.addProperty("type", "other");
				break;
			case BaseTypes.TYPE_CUSTOM:
				address.addProperty("type", getValue(cursor, ContactsContract.CommonDataKinds.StructuredPostal.LABEL, columnMemo));
				break;
			default:
				address.add("type", JsonNull.INSTANCE);
				break;
			}
			
			address.addProperty("country", getValue(cursor, ContactsContract.CommonDataKinds.StructuredPostal.COUNTRY, columnMemo));
			address.addProperty("locality", getValue(cursor, ContactsContract.CommonDataKinds.StructuredPostal.CITY, columnMemo));
			address.addProperty("postalCode", getValue(cursor, ContactsContract.CommonDataKinds.StructuredPostal.POSTCODE, columnMemo));
			address.addProperty("region", getValue(cursor, ContactsContract.CommonDataKinds.StructuredPostal.REGION, columnMemo));
			address.addProperty("streetAddress", getValue(cursor, ContactsContract.CommonDataKinds.StructuredPostal.STREET, columnMemo));
			
			if (contact.has("addresses")) {
				addresses = contact.getAsJsonArray("addresses");
			} else {
				addresses = new JsonArray();
			}
			addresses.add(address);
			contact.add("addresses", addresses);
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.Im.CONTENT_ITEM_TYPE)) {
			JsonObject im = new JsonObject();
			JsonArray ims;
			im.addProperty("value", getValue(cursor, ContactsContract.CommonDataKinds.Im.DATA, columnMemo));
			im.addProperty("pref", false);
			
			switch (getValueOrMinusOne(cursor, ContactsContract.CommonDataKinds.Im.PROTOCOL, columnMemo)) {
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_AIM:
				im.addProperty("type", "aim");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_MSN:
				im.addProperty("type", "msn");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_YAHOO:
				im.addProperty("type", "yahoo");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_SKYPE:
				im.addProperty("type", "skype");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_QQ:
				im.addProperty("type", "qq");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_GOOGLE_TALK:
				im.addProperty("type", "google_talk");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_ICQ:
				im.addProperty("type", "icq");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_JABBER:
				im.addProperty("type", "jabber");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_NETMEETING:
				im.addProperty("type", "netmeeting");
				break;
			case ContactsContract.CommonDataKinds.Im.PROTOCOL_CUSTOM:
				im.addProperty("type", getValue(cursor, ContactsContract.CommonDataKinds.Im.CUSTOM_PROTOCOL, columnMemo));
				break;
			default:
				im.add("type", JsonNull.INSTANCE);
				break;
			}
			
			if (contact.has("ims")) {
				ims = contact.getAsJsonArray("ims");
			} else {
				ims = new JsonArray();
			}
			ims.add(im);
			contact.add("ims", ims);
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.Website.CONTENT_ITEM_TYPE)) {
			JsonObject url = new JsonObject();
			JsonArray urls;
			url.addProperty("value", getValue(cursor, ContactsContract.CommonDataKinds.Website.URL, columnMemo));
			url.addProperty("pref", false);
			switch (getValueOrMinusOne(cursor, ContactsContract.CommonDataKinds.Website.TYPE, columnMemo)) {
			case ContactsContract.CommonDataKinds.Website.TYPE_HOME:
				url.addProperty("type", "home");
				break;
			case ContactsContract.CommonDataKinds.Website.TYPE_HOMEPAGE:
				url.addProperty("type", "homepage");
				break;
			case ContactsContract.CommonDataKinds.Website.TYPE_BLOG:
				url.addProperty("type", "blog");
				break;
			case ContactsContract.CommonDataKinds.Website.TYPE_PROFILE:
				url.addProperty("type", "profile");
				break;
			case ContactsContract.CommonDataKinds.Website.TYPE_WORK:
				url.addProperty("type", "work");
				break;
			case ContactsContract.CommonDataKinds.Website.TYPE_FTP:
				url.addProperty("type", "ftp");
				break;
			case ContactsContract.CommonDataKinds.Website.TYPE_OTHER:
				url.addProperty("type", "other");
				break;
			case BaseTypes.TYPE_CUSTOM:
				url.addProperty("type", getValue(cursor, ContactsContract.CommonDataKinds.Website.TYPE, columnMemo));
				break;
			default:
				url.add("type", JsonNull.INSTANCE);
				break;
			}
			
			if (contact.has("urls")) {
				urls = contact.getAsJsonArray("urls");
			} else {
				urls = new JsonArray();
			}
			urls.add(url);
			contact.add("urls", urls);
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE)) {
			JsonObject organization = new JsonObject();
			JsonArray organizations;
			organization.addProperty("name", getValue(cursor, ContactsContract.CommonDataKinds.Organization.COMPANY, columnMemo));
			organization.addProperty("department", getValue(cursor, ContactsContract.CommonDataKinds.Organization.DEPARTMENT, columnMemo));
			organization.addProperty("title", getValue(cursor, ContactsContract.CommonDataKinds.Organization.TITLE, columnMemo));
			organization.addProperty("pref", false);
			
			switch (getValueOrMinusOne(cursor, ContactsContract.CommonDataKinds.Organization.TYPE, columnMemo)) {
			case ContactsContract.CommonDataKinds.Organization.TYPE_WORK:
				organization.addProperty("type", "work");
				break;
			case ContactsContract.CommonDataKinds.Organization.TYPE_OTHER:
				organization.addProperty("type", "other");
				break;
			case BaseTypes.TYPE_CUSTOM:
				organization.addProperty("type", getValue(cursor, ContactsContract.CommonDataKinds.Organization.LABEL, columnMemo));
				break;
			default:
				organization.add("type", JsonNull.INSTANCE);
				break;
			}
			
			if (contact.has("organizations")) {
				organizations = contact.getAsJsonArray("organizations");
			} else {
				organizations = new JsonArray();
			}
			organizations.add(organization);
			contact.add("organizations", organizations);
		} else if (mimeType.equals(ContactsContract.CommonDataKinds.Photo.CONTENT_ITEM_TYPE)) {
			JsonArray photos;
			if (contact.has("photos")) {
				photos = contact.getAsJsonArray("photos");
			} else {
				photos = new JsonArray();
			}
			try {
				JsonObject photo = new JsonObject();
				byte[] photoData = cursor.getBlob(cursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Photo.PHOTO));
				if (photoData != null) {
					photo.addProperty("value", "data:image/jpg;base64," + Base64.encodeToString(photoData, Base64.NO_WRAP));
					photo.addProperty("pref", false);
				}
				photos.add(photo);
			} catch (Exception e) {
			}
			contact.add("photos", photos);
		}
		return contact;
	}
}
