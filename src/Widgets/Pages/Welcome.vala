/* Welcome.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Welcome.ui")]
    public class Pages.Welcome : Page {
        [GtkChild]
        private unowned Gtk.Label status_label;
        [GtkChild]
        private unowned Gtk.Label sandbox_label;

        public Welcome (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        construct {
            if (Xdp.Portal.running_under_sandbox ()) {
                icon_name = "security-high-symbolic";
                status_label.label = "Confined";
                status_label.add_css_class ("success");
            }
            else {
                icon_name = "security-high-symbolic";
                status_label.label = "Unconfined";
                status_label.add_css_class ("warning");

                sandbox_label.label = "None";
                return;
            }

            if (Xdp.Portal.running_under_flatpak ()) {
                sandbox_label.label = "Flatpak";
                return;
            }

            try {
                if (Xdp.Portal.running_under_snap ()) {
                    sandbox_label.label = "Snap";
                }
            }
            catch (Error e) {
                warning (e.message);
                sandbox_label.label = "Unknown";
            }
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
        }
    }
}
