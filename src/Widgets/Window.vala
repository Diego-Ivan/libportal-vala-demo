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
	    private Xdp.Portal portal;
	    private Page[] pages;

		public Window (Gtk.Application app) {
			Object (application: app);
		}

		construct {
		    portal = new Xdp.Portal ();

		    pages = {
		        new Pages.Welcome (portal, this),
		        new Pages.Account (portal, this),
		        new Pages.Background (portal, this),
		        new Pages.ColorPicker (portal, this),
		        new Pages.Email (portal, this),
		        new Pages.FileChooser (portal, this),
		        new Pages.OpenURI (portal, this),
		        new Pages.Notification (portal, this),
		        new Pages.Screenshot (portal, this),
		        new Pages.TrashFile (portal, this),
		        new Pages.Wallpaper (portal, this),
		    };

		    foreach (var page in pages) {
		        main_stack.add_titled (
		            page,
		            page.title,
		            page.title
		        );
		    }
		}
	}
}
