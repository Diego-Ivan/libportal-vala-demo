/* Spawn.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Spawn.ui")]
    public class Pages.Spawn : Page {
        public Spawn (Xdp.Portal portal_) {
            Object (portal: portal_);
        }

        static construct {
            typeof (DoubleEntryList).ensure ();
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
        }
    }
}
