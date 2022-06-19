/* Window.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
	[GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/window.ui")]
	public class Window : Adw.ApplicationWindow {
	    [GtkChild] unowned Gtk.Stack main_stack;
	    [GtkChild] unowned Adw.Leaflet leaflet;
	    private Xdp.Portal portal;
	    private Page[] pages;

		public Window (Gtk.Application app) {
			Object (application: app);
		}

		construct {
		    portal = new Xdp.Portal ();

		    pages = {
		        new Pages.Welcome (portal),
		        new Pages.Account (portal),
		        new Pages.Background (portal),
		        new Pages.Camera (portal),
		        new Pages.ColorPicker (portal),
		        new Pages.Email (portal),
		        new Pages.FileChooser (portal),
		        new Pages.Location (portal),
		        new Pages.Notification (portal),
		        new Pages.OpenURI (portal),
		    //     new Pages.Screencast (portal),
		    //     new Pages.Screenshot (portal),
		    //     new Pages.Session (portal),
		    //     new Pages.TrashFile (portal),
		    //     new Pages.Wallpaper (portal),
		    };

		    foreach (var page in pages) {
		        main_stack.add_titled (
		            page,
		            page.short_title,
		            page.short_title
		        );
		    }
		}

		[GtkCallback]
		private void stack_notify_visible_child_cb () {
		    leaflet.navigate (FORWARD);
		}

		[GtkCallback]
		private void on_go_back_button_clicked_cb () {
		    leaflet.navigate (BACK);
		}
	}
}
