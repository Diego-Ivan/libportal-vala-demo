/* Page.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public abstract class Page : Adw.Bin {
        public string title { get; set; }
        public Xdp.Portal portal { get; construct set; }
        public Gtk.Window parent_window { get; construct set; }

        construct {
            vexpand = true;
        }

        public abstract void build_ui ();
        public abstract void callback (GLib.Object? obj, AsyncResult res);
    }
}
