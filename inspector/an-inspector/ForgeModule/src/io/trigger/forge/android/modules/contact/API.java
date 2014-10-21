package io.trigger.forge.android.modules.contact;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;
import io.trigger.forge.android.core.ForgeApp;
import io.trigger.forge.android.core.ForgeIntentResultHandler;
import io.trigger.forge.android.core.ForgeLog;
import io.trigger.forge.android.core.ForgeParam;
import io.trigger.forge.android.core.ForgeTask;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Map;

import android.accounts.AccountManager;
import android.annotation.SuppressLint;
import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.ContactsContract;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

@SuppressLint("NewApi")
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
			ArrayList<ContentProviderOperation> person = Util.contactFromJSON(null, null, contact);
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

    /**
     * Add a contact, given an account type and account name.  Here's
     * where the real magic happens.
     *
     * @param task         Active Forge task
     * @param contact      W3C contact object to add
     * @param accountName  Account name to add contact under
     * @param accountType  Account type to add contact under
     * @returns Nothing, but calls task.error() or task.success() as
     * appropriate.
     */

    private static void 
    addContactWithAccount(final ForgeTask task, final JsonObject contact, 
                          String accountName, String accountType) {
        // OK, if here, we have an accountName and accountType, and 
        // we can set up a list of ContentProviderOperations for 
        // adding our contact.  We'll let Util.opsFromJSONObject() do
        // the heavy lifting here.
		
        ArrayList<ContentProviderOperation> person =
            Util.contactFromJSON(accountType, accountName, contact);

        ContentResolver resolver = 
            ForgeApp.getActivity().getContentResolver();
        ContentProviderResult[] results = null;

        try {
            results = resolver.applyBatch(ContactsContract.AUTHORITY, person);
        }
        catch (Exception e) {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            PrintStream ps = new PrintStream(baos);
            e.printStackTrace(ps);
            String content = baos.toString();
            ForgeLog.e("Oh no! " + content);
            task.error("couldn't add contact: " + e,
                       "UNEXPECTED_FAILURE", null);
            return;
        }

        int i = 0;
        for (ContentProviderResult result : results) {
            ForgeLog.i("- result " + i + ": " + result);
            i++;
        }

        Uri contactURI = results[0].uri;
        int id = (int)ContentUris.parseId(contactURI);
        task.success(new JsonPrimitive(String.valueOf(id)));
    }

    /**
     * Add a single contact to the device.
     *
     * @param task     ForgeTask to work within
     * @param contact  W3C Contact object representing contact to add
     */

    @SuppressLint("NewApi")
    public static void insert(final ForgeTask task, 
                           	  @ForgeParam("contact") final JsonObject contact) {
        // We need an account under which to add this silly contact.  Sadly, 
        // the Right Way to do changed in Android 4 (Ice Cream Sandwich).
        //
        // So.  What up with our rev of Android?

        int currentAPIVersion = android.os.Build.VERSION.SDK_INT;
        int ICSAPIVersion = android.os.Build.VERSION_CODES.ICE_CREAM_SANDWICH;

        if (currentAPIVersion < ICSAPIVersion) {
            // Prior to Ice Cream Sandwich, we can just pass null for the
            // account name and account type.  addContactWithAccount will
            // take care of the heavy lifting here, so off we go.

            addContactWithAccount(task, contact, null, null);
        }
        else {
            // On Ice Cream Sandwich and higher, it appears that the Right
            // Way is to use the AccountPicker.  If the user has only one
            // account, we get it back; otherwise they get to pick the one
            // they want to use.
            // 
            // The AccountPicker uses an Intent, hence we need a 
            // ForgeIntentResultHandler to do the heavy lifting.

            ForgeIntentResultHandler handler = new ForgeIntentResultHandler() {
                @Override
                public void result(int requestCode, int resultCode, 
                                   Intent data) {
                    String accountName = null;
                    String accountType = null;

                    if (resultCode == RESULT_OK) {
                        // All good.

                        String acctNameKey = AccountManager.KEY_ACCOUNT_NAME;
                        String acctTypeKey = AccountManager.KEY_ACCOUNT_TYPE;

                        accountName = data.getStringExtra(acctNameKey);
                        accountType = data.getStringExtra(acctTypeKey);
                    
                        ForgeLog.i("name: " + accountName);
                        ForgeLog.i("type: " + accountType);
                    }
                    else if (resultCode == RESULT_CANCELED) {
                        task.error("User cancelled account selection",
                                   "EXPECTED_FAILURE", null);
                        return;
                    }
                    else {    
                        task.error("Unknown error selecting account",  
                                   "UNEXPECTED_FAILURE", null);
                        return;
                    }

                    // OK, if here, we have an accountName and
                    // accountType, and we can use addContactWithAccount
                    // for the heavy lifting.

                    addContactWithAccount(task, contact,
                                          accountName, accountType);
                }
            };
            
            // OK.  Fire up the AccountPicker using our handler.

            Intent intent = 
                AccountManager.newChooseAccountIntent(
                    null, null,
//                    new String[] { GoogleAuthUtil.GOOGLE_ACCOUNT_TYPE },
                    null,
                    false, null, null, null, null);

            ForgeApp.intentWithHandler(intent, handler);
        }
    }

}
