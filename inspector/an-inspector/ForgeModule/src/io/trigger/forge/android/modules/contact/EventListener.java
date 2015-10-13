package io.trigger.forge.android.modules.contact;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import io.trigger.forge.android.core.ForgeApp;
import io.trigger.forge.android.core.ForgeEventListener;

public class EventListener extends ForgeEventListener {

	static final int PERMISSIONS_REQUEST = 1;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		if (ContextCompat.checkSelfPermission(ForgeApp.getActivity(), Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED || 
			ContextCompat.checkSelfPermission(ForgeApp.getActivity(), Manifest.permission.WRITE_CONTACTS) != PackageManager.PERMISSION_GRANTED) {
			ActivityCompat.requestPermissions(ForgeApp.getActivity(), new String[] {  
				Manifest.permission.READ_CONTACTS,
				Manifest.permission.WRITE_CONTACTS
			}, PERMISSIONS_REQUEST);
		}
	}
}
