/* Welcome.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Welcome : Page {
        private Gtk.Label status_label;
        private Gtk.Label sandbox_label;

        public Welcome (Xdp.Portal portal_) {
            Object (
                portal: portal_,
                title: "Welcome"
            );
        }

        construct {
            title = "Welcome";
            build_ui ();

            var status = child as Adw.StatusPage;

            if (Xdp.Portal.running_under_sandbox ()) {
                status.icon_name = "security-high-symbolic";
                status_label.label = "Confined";
                status_label.add_css_class ("success");
            }
            else {
                status.icon_name = "security-high-symbolic";
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

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Welcome.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                status_label = builder.get_object ("status_label") as Gtk.Label;
                sandbox_label = builder.get_object ("sandbox_label") as Gtk.Label;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
        }
    }
}
