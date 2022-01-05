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
		public Window (Gtk.Application app) {
			Object (application: app);
		}

		construct {
		    var portal = new Xdp.Portal ();
		    add_page (new Pages.Account (portal, this));
		    add_page (new Pages.Background (portal, this));
		}

		private void add_page (Page page) {
		    message (page.title.to_string ());
		    main_stack.add_titled (
		        page,
		        page.title,
		        page.title
		    );
		}
	}
}
